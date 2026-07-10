/* play-lua-worker.js — runs the real, unmodified gray.lua in the browser.
 *
 * Wasmoon (Lua 5.4 on WebAssembly) executes the course inside this Web
 * Worker. A small Lua prelude re-points print / io.read / io.write /
 * io.open at JavaScript bridges: output streams to the page, input parks
 * on Atomics.wait until the page writes the student's line into a
 * SharedArrayBuffer, and "files" (progress, my_first_program.lua) live in
 * a Lua table that the page persists to localStorage.
 */

import { LuaFactory } from "https://cdn.jsdelivr.net/npm/wasmoon@1.16.0/+esm";

const GLUE_WASM = "https://cdn.jsdelivr.net/npm/wasmoon@1.16.0/dist/glue.wasm";
const PROGRESS_FILE = ".gray-progress-lua.txt";
const PROGRAM_FILE = "my_first_program.lua";

let ctrl = null;      // Int32Array view: [0] = signal, [1] = byte length
let dataBuf = null;   // Uint8Array view holding the typed line (UTF-8)
const files = {};     // mirror of the Lua-side file table, for persistence

const post = (type, extra) => self.postMessage(Object.assign({ type }, extra));
const decoder = new TextDecoder();

// Coalesce output bursts so a print-happy loop sends a few messages
// instead of thousands (which would wedge the page). Prompts still show
// up right away: the first emit after a pause flushes immediately, and
// readLine always flushes before parking.
let pendingOut = "";
let lastFlush = 0;

function emit(text) {
  pendingOut += text;
  const now = Date.now();
  if (pendingOut.length >= 4096 || now - lastFlush > 16) flushOut();
}

function flushOut() {
  if (pendingOut) {
    post("out", { text: pendingOut });
    pendingOut = "";
  }
  lastFlush = Date.now();
}

function readLine() {
  flushOut();
  Atomics.store(ctrl, 0, 0);
  post("stdin", { files: snapshot() });
  Atomics.wait(ctrl, 0, 0);
  const length = Atomics.load(ctrl, 1);
  return decoder.decode(dataBuf.slice(0, length));
}

function snapshot() {
  return {
    progress: files[PROGRESS_FILE] != null ? files[PROGRESS_FILE] : null,
    program: files[PROGRAM_FILE] != null ? files[PROGRAM_FILE] : null,
  };
}

// The prelude runs before gray.lua and swaps the pieces that expect a
// real computer for browser-friendly stand-ins. gray.lua itself is
// untouched.
const PRELUDE = `
arg = { [0] = "gray.lua" }

local function join(sep, ...)
  local parts = {}
  for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
  return table.concat(parts, sep)
end

-- A loop that prints forever would flood the page long before the
-- instruction watchdog fires, so cap the output per prompt: the counter
-- resets every time the student gets to type again.
local out_since_read = 0
local function guarded_write(text)
  out_since_read = out_since_read + 1
  if out_since_read > 2000 then
    out_since_read = 0
    error("Whoa, that was a LOT of printing — Gray stopped it. Try again!", 0)
  end
  __js_write(text)
end

print = function(...) guarded_write(join("\\t", ...) .. "\\n") end
io.write = function(...) guarded_write(join("", ...)) end
io.read = function(...) out_since_read = 0; return __js_read_line() end
io.popen = function() return nil, "no other programs inside the browser" end

local real_getenv = os.getenv
os.getenv = function(name)
  if name == "GRAY_NO_UPDATE" then return "1" end -- the browser copy is always current
  local ok, value = pcall(real_getenv, name)
  if ok then return value end
  return nil
end
os.exit = function()
  error("If you want to leave, just type  quit  — Gray will save your spot!", 0)
end
os.remove = function(name) __gray_files[name] = nil; return true end
os.rename = function(from, to)
  __gray_files[to] = __gray_files[from]
  __gray_files[from] = nil
  return true
end

if type(debug) ~= "table" or type(debug.sethook) ~= "function" then
  debug = { sethook = function() end }
end

__gray_files = {}
if __seed_progress then __gray_files["${PROGRESS_FILE}"] = __seed_progress end
if __seed_program then __gray_files["${PROGRAM_FILE}"] = __seed_program end

io.open = function(name, mode)
  mode = mode or "r"
  if mode:find("r", 1, true) then
    local content = __gray_files[name]
    if content == nil then return nil, name .. ": no such file" end
    local pos = 1
    local handle = {}
    function handle:read(...)
      local formats = { ... }
      if #formats == 0 then formats = { "l" } end
      local results, n = {}, 0
      for _, fmt in ipairs(formats) do
        n = n + 1
        fmt = tostring(fmt):gsub("^%*", "")
        if fmt == "a" then
          results[n] = content:sub(pos)
          pos = #content + 1
        elseif fmt == "n" then
          local s, e = content:find("^%s*%-?%d+%.?%d*", pos)
          if s then
            results[n] = tonumber(content:sub(s, e))
            pos = e + 1
          end
        else -- "l": one line, without the newline
          if pos <= #content then
            local nl = content:find("\\n", pos, true)
            if nl then
              results[n] = content:sub(pos, nl - 1)
              pos = nl + 1
            else
              results[n] = content:sub(pos)
              pos = #content + 1
            end
          end
        end
      end
      return table.unpack(results, 1, n)
    end
    function handle:lines()
      return function() return self:read("l") end
    end
    function handle:close() return true end
    return handle
  end

  local buffer = ""
  if mode:find("a", 1, true) then buffer = __gray_files[name] or "" end
  local handle = {}
  function handle:write(...)
    buffer = buffer .. join("", ...)
    return self
  end
  function handle:close()
    __gray_files[name] = buffer
    __js_file_saved(name, buffer)
    return true
  end
  return handle
end
`;

self.onmessage = async (event) => {
  const msg = event.data;
  if (msg.type !== "boot") return;

  ctrl = new Int32Array(msg.stdinSab, 0, 2);
  dataBuf = new Uint8Array(msg.stdinSab, 8);

  post("status", { text: "Fetching Lua… (it's tiny, one moment)" });
  let lua;
  try {
    const factory = new LuaFactory(GLUE_WASM);
    lua = await factory.createEngine();
  } catch (err) {
    post("fatal", { text: "Lua could not load: " + (err && err.message ? err.message : err) });
    return;
  }

  const saved = msg.files || {};
  if (saved.progress) files[PROGRESS_FILE] = saved.progress;
  if (saved.program) files[PROGRAM_FILE] = saved.program;

  lua.global.set("__js_write", (text) => emit(text));
  lua.global.set("__js_read_line", () => readLine());
  lua.global.set("__js_file_saved", (name, content) => {
    files[name] = content;
    post("files", { files: snapshot() });
  });
  lua.global.set("__seed_progress", saved.progress || undefined);
  lua.global.set("__seed_program", saved.program || undefined);

  post("status", { text: "Here we go!" });
  post("started", {});
  try {
    // doStringSync: fully synchronous, no promise-resume loop (whose
    // setImmediate does not exist in browsers) — our bridges block anyway
    lua.doStringSync(PRELUDE);
    // the lua CLI skips a leading #! line, but load() does not — swap it
    // for a comment so line numbers stay the same
    lua.doStringSync(msg.source.replace(/^#![^\n]*/, "--"));
  } catch (err) {
    flushOut();
    const text = String((err && err.message) || err);
    post("out", { text: "\n  🙈 Something unexpected happened:\n" + text + "\n" });
  }
  flushOut();
  post("files", { files: snapshot() });
  post("exited", {});
};

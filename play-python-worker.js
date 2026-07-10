/* play-python-worker.js — runs the real, unmodified gray.py in the browser.
 *
 * Pyodide (CPython on WebAssembly) executes the course inside this Web
 * Worker. The page and the worker share a SharedArrayBuffer: when the
 * course calls input(), the worker parks on Atomics.wait until the page
 * writes the student's line into the buffer. That gives gray.py the
 * blocking stdin it expects, without changing a single line of it.
 */

import { loadPyodide } from "https://cdn.jsdelivr.net/pyodide/v0.29.4/full/pyodide.mjs";

const PYODIDE_INDEX = "https://cdn.jsdelivr.net/pyodide/v0.29.4/full/";
const HOME = "/home/pyodide/";
const PROGRESS_FILE = ".gray-progress-python.json";
const PROGRAM_FILE = "my_first_program.py";

const BOOTSTRAP = `
import os, sys
os.environ["GRAY_NO_UPDATE"] = "1"  # the browser copy is always current
os.environ["GRAY_BROWSER"] = "1"    # lessons explain browser buttons
_path = "${HOME}gray.py"
_src = open(_path, encoding="utf-8").read()
_globals = {"__name__": "__main__", "__file__": _path}
exec(compile(_src, "gray.py", "exec"), _globals)
`;

let pyodide = null;
let ctrl = null;      // Int32Array view: [0] = signal, [1] = byte length
let dataBuf = null;   // Uint8Array view holding the typed line (UTF-8)

const post = (type, extra) => self.postMessage(Object.assign({ type }, extra));

// ---------------------------------------------------------------------------
// stdout/stderr — stream every write straight to the page, so prompts
// written without a newline (input("Password? ")) appear immediately.
// ---------------------------------------------------------------------------

const outDecoder = new TextDecoder();
let rawPending = [];
let pendingOut = "";
let lastFlush = 0;

// Coalesce bursts so a print-happy loop sends a few messages instead of
// thousands (which would wedge the page). Prompts still appear at once:
// the first emit after a pause flushes immediately, and readLine always
// flushes before parking.
function emit(text) {
  if (!text) return;
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

function flushRaw() {
  if (rawPending.length) {
    const bytes = new Uint8Array(rawPending);
    rawPending = [];
    emit(outDecoder.decode(bytes, { stream: true }));
  }
}

function onRawByte(byte) {
  rawPending.push(byte);
  if (byte === 10 || rawPending.length >= 512) flushRaw();
}

function wireStdio() {
  const writeHandler = (buffer) => {
    flushRaw();
    emit(outDecoder.decode(buffer, { stream: true }));
    return buffer.length;
  };
  try {
    pyodide.setStdout({ write: writeHandler, isatty: true });
    pyodide.setStderr({ write: writeHandler, isatty: true });
  } catch (err) {
    pyodide.setStdout({ raw: onRawByte, isatty: true });
    pyodide.setStderr({ raw: onRawByte, isatty: true });
  }
}

// ---------------------------------------------------------------------------
// stdin — block on the SharedArrayBuffer until the page sends a line
// ---------------------------------------------------------------------------

const inDecoder = new TextDecoder();

function readLine() {
  flushRaw();
  flushOut();
  Atomics.store(ctrl, 0, 0);
  post("stdin", { files: snapshot() });
  // wake up periodically to honor the Rescue button even while waiting
  // for input — checkInterrupt() raises KeyboardInterrupt into gray.py,
  // which treats it like Ctrl+C at a prompt (quit, progress saved)
  while (Atomics.wait(ctrl, 0, 0, 150) === "timed-out") {
    if (pyodide) pyodide.checkInterrupt();
  }
  const length = Atomics.load(ctrl, 1);
  const line = inDecoder.decode(dataBuf.slice(0, length));
  return line + "\n";
}

// ---------------------------------------------------------------------------
// virtual files — progress + the graduation program, persisted by the page
// ---------------------------------------------------------------------------

function fsRead(name) {
  try {
    return pyodide.FS.readFile(HOME + name, { encoding: "utf8" });
  } catch (err) {
    return null;
  }
}

function snapshot() {
  return { progress: fsRead(PROGRESS_FILE), program: fsRead(PROGRAM_FILE) };
}

// ---------------------------------------------------------------------------
// boot
// ---------------------------------------------------------------------------

self.onmessage = async (event) => {
  const msg = event.data;
  if (msg.type !== "boot") return;

  ctrl = new Int32Array(msg.stdinSab, 0, 2);
  dataBuf = new Uint8Array(msg.stdinSab, 8);

  post("status", { text: "Fetching Python… (the first visit downloads it, ~15 MB)" });
  try {
    pyodide = await loadPyodide({ indexURL: PYODIDE_INDEX });
  } catch (err) {
    post("fatal", { text: "Python could not load: " + (err && err.message ? err.message : err) });
    return;
  }

  if (msg.interruptSab) {
    try {
      pyodide.setInterruptBuffer(new Int32Array(msg.interruptSab));
    } catch (err) { /* rescue button just won't work */ }
  }

  wireStdio();
  pyodide.setStdin({ stdin: readLine, isatty: true });

  const saved = msg.files || {};
  if (saved.progress) pyodide.FS.writeFile(HOME + PROGRESS_FILE, saved.progress);
  if (saved.program) pyodide.FS.writeFile(HOME + PROGRAM_FILE, saved.program);
  pyodide.FS.writeFile(HOME + "gray.py", msg.source);

  post("status", { text: "Here we go!" });
  post("started", {});
  try {
    pyodide.runPython(BOOTSTRAP);
  } catch (err) {
    flushRaw();
    const text = String((err && err.message) || err);
    // KeyboardInterrupt = the Rescue button; SystemExit = a kid typed
    // exit() or quit() — both are fine ways to leave, not crashes
    if (!text.includes("KeyboardInterrupt") && !text.includes("SystemExit")) {
      emit("\n  🙈 Something unexpected happened:\n" + text + "\n");
    }
  }
  flushRaw();
  flushOut();
  post("files", { files: snapshot() });
  post("exited", {});
};

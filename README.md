# Gray 🐘

A guided programming course for kids, in Python and Lua.

Website: [gray.academy](https://gray.academy) — course overview,
install instructions per OS, and downloads. The site is
[index.html](index.html), served from the repo root by GitHub Pages
(`CNAME` holds the custom domain, `.nojekyll` disables Jekyll).

## Run it

```sh
python3 gray.py    # the Python course
lua gray.lua       # the Lua course
```

No dependencies — each course is a single file.

Or play without installing anything at
[gray.academy/play.html](https://gray.academy/play.html): the same
`gray.py` / `gray.lua` run unmodified in the browser (Pyodide for
Python, Wasmoon for Lua) inside a Web Worker, wired to an xterm.js
terminal. Blocking `input()` / `io.read()` works via SharedArrayBuffer +
Atomics — [coi-serviceworker.js](coi-serviceworker.js) adds the
cross-origin-isolation headers GitHub Pages can't send. (Heads-up: once
a visitor has opened the play page, that service worker applies COOP/COEP
to *every* gray.academy page — so any future cross-origin embeds on the
site must send CORP headers or be `crossorigin`-tagged.) Progress and the
graduation program are saved to the browser's localStorage. The
graduation program is a first-class citizen: a "Run my program" button
executes `my_first_program` standalone in the same terminal (inputs and
all), and a download chip lets kids take the file home. See
[play.html](play.html), [play-python-worker.js](play-python-worker.js),
[play-lua-worker.js](play-lua-worker.js).

## How it works

Gray explains a concept, then the student types **real code** at the
`you>` prompt. Gray runs it, shows the result like a real REPL, and
checks it: right answers get a cheer, wrong ones get a gentle nudge to
try again. At any prompt the student can type:

- `hint` — get a hint for the current challenge
- `skip` — skip a challenge
- `menu` — jump back to the section menu
- `quit` — stop; progress is saved (`.gray-progress-*` files next to
  the script), so the course resumes where they left off

## Paid learning paths

Beyond the free Foundations course, paid paths (like **The Game Maker**)
build on the same engine and run **browser-only**. Their content never
lives in this public repository: sources sit in the gitignored `paid/`
directory, and `python3 paid/build.py` splices each path's sections into
copies of the public engines, then bundles everything into
`paid/dist/paths-worker.js` — a Cloudflare Worker that validates
subscription keys against Lemon Squeezy's license API (with a `DEV_KEYS`
variable for testing and an optional `LS_STORE_ID` pin) and serves
course content only on a valid key. The play page asks for the key once
(`gray-license-key` in localStorage), sends it as `X-Gray-Key`, and
keeps per-path progress under separate storage keys. One subscription
unlocks every path. For local development, `python3 paid/dev-server.py`
mimics the worker on `localhost:8766` with the key `GRAY-DEV-1234`.

**Important:** `paid/` is gitignored — keep those sources backed up
somewhere private (e.g. a private repo).

## The journey counter

The homepage counter reads GoatCounter's public endpoint
(`…/counter/TOTAL.json`), which GoatCounter serves through a cache that
refreshes only every few hours — so the number lags the (live)
dashboard. For a counter that's at most a minute behind, deploy
[goatcounter-worker.js](goatcounter-worker.js) as a Cloudflare Worker
(instructions in the file header) and point `COUNTER_URL` in
[index.html](index.html) at it. The page parses `count` = **total
pageviews** and never lets the number move backwards across cache
snapshots.

## Auto-update

On startup Gray checks `https://gray.academy/gray.py` (or `.lua`) for a
newer release, compares the `GRAY_VERSION` constant, and if the remote
is newer swaps its own file in place and relaunches — seamless for the
student, before any lesson state exists. Offline? It says so nicely and
carries on. Set `GRAY_NO_UPDATE=1` to skip the check (useful while
developing — a locally bumped `GRAY_VERSION` also protects your copy,
since Gray never downgrades). Bump `GRAY_VERSION` in both files when
publishing a release.

## Sections

1. **Introduction** — the computer as a calculator (`+ - *`), printing
   messages, and quotes vs. no quotes.
2. **Variables — give things a name** — variables as boxes: storing
   numbers and words, using them in math, printing them, gluing words
   together (`+` / `..`), and changing them (`score = score + 10`).
3. **If this, then that** — yes/no questions (`>`, `<`, `==`, and
   `!=` / `~=`), `True`/`False`, one-line `if` statements, why a false
   `if` does nothing, and a secret-club password door.
4. **Loops — do it again!** — `for` loops: cheering five times,
   printing your name ten times, counting (and Python's
   starts-at-zero surprise), the 7 times table in one line, rolling
   dice (`random.randint` / `math.random`), and a counting machine
   that clicks +1 a hundred times.
5. **Input — the computer asks YOU** — `input()` / `io.read()`:
   programs that wait and listen, ask questions, turn answers into
   real numbers (`int(...)` / `tonumber(...)`), and a club door that
   asks for the password itself.
6. **While — the loop with a brain** — a rocket countdown that stops
   by itself, the doubling-coin riddle, and what to do about loops
   that never end (Ctrl+C in Python; in Lua, Gray's watchdog stops
   runaway loops automatically).
7. **Functions — teach it new words** — `def` / `function`: teaching
   the computer to `cheer()`, functions with an ingredient
   (`greet(name)`), `return` machines (`double(n)`), and feeding a
   machine into itself.
8. **Project: The Number Wizard** 🔮 — build a real guessing game:
   a hidden random secret, hand-played rounds with hints, then the
   full game loop (`while ... != secret`).
9. **Project: The Silly Story Machine** 📖 — a mad-libs machine that
   collects words with input, glues them into a story, and performs
   it with an encore.
10. **Project: The Club Doorkeeper** 🤖 — the capstone: a robot that
    greets visitors by name, demands the password in an unbreakable
    `while` loop, and throws a `party()` — every superpower in one
    build.
11. **Graduation — programs of your own** 🎓 — the student builds a
    real script file line by line (each line is saved into
    `my_first_program.py` / `my_first_program.lua` as they type it),
    then learns to run it themselves (`python my_first_program.py` /
    `lua my_first_program.lua`), that Gray itself is just such a file,
    and that `python` / `lua` alone opens the interactive REPL — the
    same thing the `you>` prompt has been all along.

## Adding a section

All content lives in the `SECTIONS` list/table at the top of each file.
A section is a title plus a list of lessons; a lesson is either plain
text (shown with "press Enter to continue") or a task with checks:

| field            | meaning                                               |
|------------------|-------------------------------------------------------|
| `say`            | text shown to the student                             |
| `say_browser`    | shown instead of `say` when Gray runs in the browser (`GRAY_BROWSER=1`, set by the play-page workers) — used by graduation lessons to explain the ▶ Run / ⬇ download buttons instead of terminal commands |
| `task`           | student must type code that passes the checks         |
| `hint`           | shown when the student types `hint`                   |
| `must_use`       | substrings the code must contain (e.g. `["+"]`)       |
| `expect`         | value the code must produce (e.g. `8`)                |
| `needs_print`    | code must use `print` and actually print something    |
| `output_is`      | exact text the printed output must match              |
| `needs`          | variables (name → default) seeded before the lesson if missing, so resuming mid-section works |
| `defines`        | name → `"number"`/`"string"`: a variable the code must create |
| `var_equals`     | name → value the variable must hold afterwards        |
| `expect_expr`    | expression (evaluated with the student's variables) the answer must match |
| `output_has_var` | variable whose contents must appear in the output     |
| `expect_silence` | the code must print nothing (a false `if`)            |
| `quiet_hint`     | custom message when `needs_print` finds no output     |
| `line_count`     | number of lines the code must print (loops)           |
| `needs_code`     | code (name → source) run before the lesson if the name is missing — like `needs`, but for functions |
| `call_test`      | `[expression, expected]` — the expression must give the expected value (checks the student's functions) |
| `expect_range`   | `[lo, hi]` — the answer must be a number in this range (dice rolls and other random things) |
| `hide_box`       | don't reveal the box contents on success (keeps game secrets secret) |
| `append_to_file` | on success, save the student's line into this file (they build their own script) |
| `start_file`     | this line starts the file fresh, with a header comment |

The student's `print` output streams live (so programs that ask
questions with `input()` / `io.read()` feel alive), and infinite loops
are survivable: Python turns Ctrl+C into a friendly "that was taking
FOREVER" message, and the Lua engine has an instruction-count watchdog
that stops runaway loops on its own.

The student's variables persist across lessons within a run, so lessons
can build on earlier ones — and a failed attempt is rolled back, so it
never corrupts the variables a later check depends on. To grow the
course, append a new section with a `lessons` list — or park an idea as
a `coming_soon: true` stub, which shows locked (🔒) in the menu.

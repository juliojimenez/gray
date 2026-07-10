#!/usr/bin/env lua
-- Gray — a programming course for kids.
--
-- Run it with:  lua gray.lua
--
-- You type real Lua code, Gray checks it and cheers you on.
-- Progress is saved in .gray-progress-lua.txt so you can stop anytime.
-- Works with Lua 5.1+ (including LuaJIT) and Lua 5.2/5.3/5.4.

local PROGRESS_FILE = (arg[0]:match("(.*[/\\])") or "") .. ".gray-progress-lua.txt"

local GRAY_VERSION = 2 -- bumped on every release; the update check compares this
local UPDATE_URL = "https://gray.academy/gray.lua"

---------------------------------------------------------------------------
-- Pretty terminal output
---------------------------------------------------------------------------

local USE_COLOR = not os.getenv("NO_COLOR")

local function paint(text, code)
  if USE_COLOR then return "\27[" .. code .. "m" .. text .. "\27[0m" end
  return text
end

local function bold(t)    return paint(t, "1")  end
local function cyan(t)    return paint(t, "96") end
local function green(t)   return paint(t, "92") end
local function yellow(t)  return paint(t, "93") end
local function magenta(t) return paint(t, "95") end
local function dim(t)     return paint(t, "2")  end

local function say(text) print(text or "") end

-- Characters on screen, not bytes: #text overshoots for multi-byte
-- characters like the em dash. Count UTF-8 characters instead
-- (continuation bytes 128-191 never start a character).
local function display_len(text)
  local _, count = text:gsub("[^\128-\191]", "")
  return count
end

local function banner(text)
  local line = string.rep("─", display_len(text) + 4)
  say(cyan("╭" .. line .. "╮"))
  say(cyan("│  " .. bold(text) .. "  │"))
  say(cyan("╰" .. line .. "╯"))
end

local function cheer(text) say(green("\n  ⭐ " .. text .. "\n")) end
local function nudge(text) say(yellow("\n  🤔 " .. text .. "\n")) end

---------------------------------------------------------------------------
-- The course content
--
-- A lesson is a table:
--   say         text shown to the student (always required)
--   task        if true, the student must type code that passes the checks
--   hint        shown when the student types: hint
--   must_use    list of substrings the code must contain (e.g. {"+"})
--   expect      the value the code must produce (e.g. 8)
--   needs_print true -> code must use print and actually print something
--   output_is   exact text the printed output must match
--   needs       variables (name -> default) created before the lesson if
--               missing, so resuming mid-section always works
--   defines     name -> "number"|"string": a box the code must create
--   var_equals  name -> value the box must hold afterwards
--   expect_expr expression (using the student's boxes) the value must match
--   output_has_var  name of a box whose contents must appear in the output
--   expect_silence  true -> the code must print NOTHING (a false if!)
--   quiet_hint  custom message when needs_print finds no output
--   line_count  number of lines the code must print (loops!)
--   needs_code  code (name -> source) run before the lesson if the name
--               is missing — like needs, but for functions
--   call_test   {expression, expected}: the expression must give the
--               expected value (for checking the student's functions)
--   expect_range  {lo, hi}: the answer must be a number in this range
--               (for dice rolls and other random things)
--   hide_box    true -> don't reveal the box contents on success
--               (keeps game secrets secret!)
--   append_to_file  filename: on success, save the student's line into
--               this file (building their very own script!)
--   start_file  true -> this line starts the file fresh, with a header
---------------------------------------------------------------------------

local SECTIONS = {
  {
    title = "Introduction",
    lessons = {
      {
        say = "Hi! I'm Gray. 👋\n" ..
              "I'm going to teach you how to talk to your computer\n" ..
              "using a language called Lua.\n" ..
              "\n" ..
              "Here's how it works: I explain something, then YOU try it.\n" ..
              "You type real Lua code and press Enter.\n" ..
              "\n" ..
              "A few magic words you can always type:\n" ..
              "  hint  - if you're stuck\n" ..
              "  menu  - to see all the sections\n" ..
              "  quit  - to stop (I'll remember where you were!)",
      },
      {
        say = "First secret: your computer is a GIANT calculator.\n" ..
              "If you type some math, Lua solves it instantly.\n" ..
              "\n" ..
              "Try it! Type:  2 + 2   and press Enter.",
        task = true,
        hint = "Type exactly this and press Enter:  2 + 2",
        must_use = { "+" },
        expect = 4,
      },
      {
        say = "You just wrote your first Lua script! 🎉\n" ..
              "\n" ..
              "Now you try one on your own: make Lua add  5 + 3.",
        task = true,
        hint = "Just like before, but with different numbers:  5 + 3",
        must_use = { "+" },
        expect = 8,
      },
      {
        say = "Lua can multiply too — but there's a trick!\n" ..
              "Computers don't use the × sign. They use a star:  *\n" ..
              "\n" ..
              "So 'six times seven' is written:  6 * 7\n" ..
              "Try it!",
        task = true,
        hint = "Type:  6 * 7   (the * is usually Shift+8 on your keyboard)",
        must_use = { "*" },
        expect = 42,
      },
      {
        say = "Nice! Now let's see how FAST your computer really is.\n" ..
              "\n" ..
              "Ask it to multiply  123 * 456.\n" ..
              "(That would take a person a while. Watch the computer do it.)",
        task = true,
        hint = "Same trick as before:  123 * 456",
        must_use = { "*" },
        expect = 56088,
      },
      {
        say = "⚡ Instant! Computers never get tired of math.\n" ..
              "\n" ..
              "One more: subtracting uses the minus sign:  -\n" ..
              "A year has 365 days, and 200 have already passed.\n" ..
              "Ask Lua how many days are left.",
        task = true,
        hint = "How many days are left? That's  365 - 200",
        must_use = { "-" },
        expect = 165,
      },
      {
        say = "Math: done! ✅  But computers can also TALK.\n" ..
              "\n" ..
              "To make Lua say something, use print with quotes:\n" ..
              '    print("Hello!")\n' ..
              "\n" ..
              "The quotes tell Lua: say exactly these words.\n" ..
              "Make your computer say hello!",
        task = true,
        hint = 'Type exactly:  print("Hello!")  — don\'t forget the quotes and parentheses!',
        needs_print = true,
      },
      {
        say = "It talks! 🗣️\n" ..
              "\n" ..
              "Now make it say something about YOU.\n" ..
              "Print your own name, or anything you like!",
        task = true,
        hint = 'Like before, put your words in quotes:  print("Ada is awesome")',
        needs_print = true,
      },
      {
        say = "Last challenge! Here's a brain-twister:\n" ..
              "\n" ..
              '    print("3 + 4")   says the words:  3 + 4\n' ..
              "    print(3 + 4)     does the MATH first, then says the answer!\n" ..
              "\n" ..
              "No quotes means: solve it, don't say it.\n" ..
              "Try printing  3 + 4  WITHOUT quotes and see what happens.",
        task = true,
        hint = "Type:  print(3 + 4)   — no quotes anywhere!",
        needs_print = true,
        must_use = { "+" },
        output_is = "7",
      },
      {
        say = "🎉🎉🎉  YOU FINISHED THE INTRODUCTION!  🎉🎉🎉\n" ..
              "\n" ..
              "Look at everything you learned:\n" ..
              "  ✅ Computers are giant calculators (+ - *)\n" ..
              "  ✅ print() makes the computer talk\n" ..
              "  ✅ Quotes = say it exactly. No quotes = solve it first.\n" ..
              "\n" ..
              "You are doing awesome! Next up: variables — giving things a name. See you there!",
      },
    },
  },
  {
    title = "Variables — give things a name",
    lessons = {
      {
        say = "Ready for a new superpower? 💪\n" ..
              "\n" ..
              "Your computer can REMEMBER things. You store something\n" ..
              "and give it a name — that's called a VARIABLE.\n" ..
              "Think of it as a BOX with a name sticker on it:\n" ..
              "\n" ..
              "    age = 9\n" ..
              "\n" ..
              "This means: make a box called 'age' and put 9 inside.\n" ..
              "The = sign puts things into boxes.",
      },
      {
        say = "Your turn! Make a box called  age  with YOUR age inside.\n" ..
              "(If you are 9 years old, type:  age = 9 )",
        task = true,
        hint = "The box name, then =, then your age:  age = 9",
        must_use = { "age", "=" },
        defines = { age = "number" },
      },
      {
        say = "The computer will remember that! 🧠\n" ..
              "To peek inside a box, just type its name.\n" ..
              "\n" ..
              "Ask the computer what's inside  age.",
        task = true,
        hint = "Just type the box's name and nothing else:  age",
        must_use = { "age" },
        expect_expr = "age",
        needs = { age = 9 },
      },
      {
        say = "And here's the magic: boxes work in MATH!\n" ..
              "\n" ..
              "    age * 365\n" ..
              "\n" ..
              "tells you (about) how many DAYS old you are. Try it!",
        task = true,
        hint = "Type:  age * 365",
        must_use = { "age", "*" },
        expect_expr = "age * 365",
        needs = { age = 9 },
      },
      {
        say = "Whoa, that's a lot of days! 📅\n" ..
              "\n" ..
              "Boxes can hold WORDS too — with quotes, just like print.\n" ..
              "Make a box called  name  with your name inside:\n" ..
              "\n" ..
              '    name = "Ada"      (but use YOUR name!)',
        task = true,
        hint = 'Box name, =, then your name in quotes:  name = "Ada"',
        must_use = { "name", "=" },
        defines = { name = "string" },
      },
      {
        say = "Now the computer knows you! Let's make it say hello TO YOU.\n" ..
              "\n" ..
              "In Lua you glue words and boxes together with two dots:  ..\n" ..
              "\n" ..
              '    print("Hello " .. name)\n' ..
              "\n" ..
              "Try it!",
        task = true,
        hint = 'Type:  print("Hello " .. name)  — the box name has NO quotes!',
        must_use = { "name" },
        needs_print = true,
        output_has_var = "name",
        needs = { name = "friend" },
      },
      {
        say = "It knows your name! 🤩\n" ..
              "\n" ..
              "Those gluing dots  ..  work anywhere words meet.\n" ..
              "Try gluing a box to some words:\n" ..
              "\n" ..
              '    print(name .. " the Great")\n' ..
              "\n" ..
              "Glue yourself a royal title!",
        task = true,
        hint = 'Type:  print(name .. " the Great")   — or invent your own title!',
        must_use = { "name", ".." },
        needs_print = true,
        output_has_var = "name",
        needs = { name = "friend" },
      },
      {
        say = "Fancy! 🎩\n" ..
              "\n" ..
              "One more trick: what's inside a box can CHANGE.\n" ..
              "Let's keep score, like in a video game. 🎮\n" ..
              "\n" ..
              "Start at zero: make a box called  score  with 0 inside.",
        task = true,
        hint = "Just like the age box:  score = 0",
        must_use = { "score", "=" },
        var_equals = { score = 0 },
      },
      {
        say = "You just scored 10 points! 🏀\n" ..
              "Tell the computer: take what's in the box, add 10,\n" ..
              "and put the answer back in the box:\n" ..
              "\n" ..
              "    score = score + 10",
        task = true,
        hint = "Type:  score = score + 10",
        must_use = { "score", "+", "=" },
        var_equals = { score = 10 },
        needs = { score = 0 },
      },
      {
        say = "🎉🎉🎉  SECTION 2: DONE!  🎉🎉🎉\n" ..
              "\n" ..
              "You unlocked the memory superpower:\n" ..
              "  ✅ age = 9  puts something in a box\n" ..
              "  ✅ typing a box's name peeks inside\n" ..
              "  ✅ boxes work in math:  age * 365\n" ..
              "  ✅ boxes can change:  score = score + 10\n" ..
              "\n" ..
              "Programmers use variables ALL THE TIME.\n" ..
              "You're a real programmer now. See you in the next section!",
      },
    },
  },
  {
    title = "If this, then that",
    lessons = {
      {
        say = "Time for a BIG one. 🧠\n" ..
              "Your computer can answer QUESTIONS — yes-or-no questions.\n" ..
              "\n" ..
              "Is 5 bigger than 3? Is 10 smaller than 2?\n" ..
              "You ask with special signs:\n" ..
              "\n" ..
              "    >   means: is it BIGGER?\n" ..
              "    <   means: is it SMALLER?\n" ..
              "\n" ..
              "The computer answers  true  (yes!) or  false  (no!).",
      },
      {
        say = "Ask the computer: is 5 bigger than 3?\n" ..
              "\n" ..
              "    5 > 3\n" ..
              "\n" ..
              "Try it and see what it says!",
        task = true,
        hint = "Type:  5 > 3",
        must_use = { ">" },
        expect = true,
      },
      {
        say = "It said true — that means YES! ✅\n" ..
              "\n" ..
              "Now ask a silly one: is 10 smaller than 2?\n" ..
              "\n" ..
              "    10 < 2",
        task = true,
        hint = "Type:  10 < 2",
        must_use = { "<" },
        expect = false,
      },
      {
        say = "false — no way! The computer NEVER lies. 😄\n" ..
              "\n" ..
              "Try a harder question: is  7 * 8  bigger than 50?\n" ..
              "Don't do the math yourself — make the computer do it,\n" ..
              "all in one question!",
        task = true,
        hint = "Type:  7 * 8 > 50",
        must_use = { "*", ">" },
        expect = true,
      },
      {
        say = "Now a tricky sign. You know  =  puts things in a box.\n" ..
              "To ASK 'are these equal?', you need TWO of them:\n" ..
              "\n" ..
              "    one   =    put it in the box\n" ..
              "    two   ==   is it equal?\n" ..
              "\n" ..
              "Ask the computer: is  2 + 2  equal to 4?",
        task = true,
        hint = "Type:  2 + 2 == 4   (two equal signs, no spaces between them!)",
        must_use = { "+", "==" },
        expect = true,
      },
      {
        say = "And here's the OPPOSITE question. In Lua,  ~=  means\n" ..
              "'is it DIFFERENT?' (the squiggle makes it a no-question):\n" ..
              "\n" ..
              "    5 ~= 3\n" ..
              "\n" ..
              "Is 5 different from 3? Ask the computer!",
        task = true,
        hint = "Type:  5 ~= 3   (a squiggle ~, then an equal sign)",
        must_use = { "~=" },
        expect = true,
      },
      {
        say = "Now the REAL superpower: your computer can DECIDE. 🚦\n" ..
              "With  if,  it only does the job when the answer is yes:\n" ..
              "\n" ..
              '    if 10 > 5 then print("10 is bigger!") end\n' ..
              "\n" ..
              "Read it out loud: IF 10 is bigger than 5, THEN say '10 is bigger!'\n" ..
              "(Lua likes the word  end  to finish the sentence.)\n" ..
              "Type it and watch what happens.",
        task = true,
        hint = 'Type it exactly:  if 10 > 5 then print("10 is bigger!") end',
        must_use = { "if", ">", "then", "end" },
        needs_print = true,
      },
      {
        say = "The question was TRUE, so the computer did the job!\n" ..
              "But what if the question is FALSE?\n" ..
              "\n" ..
              "Tell it: IF 1 is bigger than 100, say IMPOSSIBLE:\n" ..
              "\n" ..
              '    if 1 > 100 then print("IMPOSSIBLE!") end\n' ..
              "\n" ..
              "Watch very carefully...",
        task = true,
        hint = 'Type:  if 1 > 100 then print("IMPOSSIBLE!") end',
        must_use = { "if", ">", "print" },
        expect_silence = true,
      },
      {
        say = "NOTHING happened! 🤫  And that's EXACTLY right.\n" ..
              "1 is NOT bigger than 100 — the answer was no,\n" ..
              "so the computer skipped the job. That's the power of  if!\n" ..
              "\n" ..
              "Let's use it to build a SECRET CLUB DOOR. 🚪\n" ..
              "First the club needs a secret word. Make this box:\n" ..
              "\n" ..
              '    password = "octopus"',
        task = true,
        hint = 'Type:  password = "octopus"',
        must_use = { "password", "=" },
        var_equals = { password = "octopus" },
      },
      {
        say = "Now build the door! IF the password is right,\n" ..
              "the computer lets you in:\n" ..
              "\n" ..
              '    if password == "octopus" then print("Welcome to the club!") end\n' ..
              "\n" ..
              "(Remember: TWO equal signs to ask a question!)",
        task = true,
        hint = 'Type:  if password == "octopus" then print("Welcome to the club!") end',
        must_use = { "if", "==", "password" },
        needs_print = true,
        needs = { password = "octopus" },
        quiet_hint = "The computer stayed quiet — the password didn't match!\n" ..
                     '  Check your spelling. The secret word is  "octopus".',
      },
      {
        say = "🎉🎉🎉  SECTION 3: DONE!  🎉🎉🎉\n" ..
              "\n" ..
              "Your computer can now make DECISIONS:\n" ..
              "  ✅ ask questions with  >  <  ==  ~=\n" ..
              "  ✅ true means yes, false means no\n" ..
              "  ✅ if  does the job only when the answer is yes\n" ..
              "  ✅ and you built a secret club door!\n" ..
              "\n" ..
              "Next adventure: LOOPS — making the computer do things\n" ..
              "again and again and again. See you there!",
      },
    },
  },
  {
    title = "Loops — do it again!",
    lessons = {
      {
        say = "Would YOU like to say 'Hip hip hooray!' a hundred times?\n" ..
              "No? Well, the computer would LOVE to.\n" ..
              "\n" ..
              "Doing something again and again is called a LOOP,\n" ..
              "and the magic word is  for.",
      },
      {
        say = "Here's a loop that cheers FIVE times:\n" ..
              "\n" ..
              '    for i = 1, 5 do print("Hip hip hooray!") end\n' ..
              "\n" ..
              "Read it out loud: FOR counting 1 to 5, DO say\n" ..
              "'Hip hip hooray!' — and END finishes the sentence.\n" ..
              "Type it and watch the computer go wild!",
        task = true,
        hint = 'Type it exactly:  for i = 1, 5 do print("Hip hip hooray!") end',
        must_use = { "for", "do", "end" },
        needs_print = true,
        line_count = 5,
      },
      {
        say = "😄 See? It NEVER gets bored.\n" ..
              "\n" ..
              "Now use your new power: print YOUR name TEN times.\n" ..
              "(Programmers love making the computer do the boring work —\n" ..
              "that's the whole point!)",
        task = true,
        hint = 'Like the cheer, but 1, 10 and your name:  for i = 1, 10 do print("Ada") end',
        must_use = { "for", "do", "end" },
        needs_print = true,
        line_count = 10,
      },
      {
        say = "Ten names with ONE line of code! 🤯\n" ..
              "\n" ..
              "That  i  is a box the loop fills with the count:\n" ..
              "first 1, then 2, then 3... Try printing the count itself:\n" ..
              "\n" ..
              "    for i = 1, 5 do print(i) end",
        task = true,
        hint = "Type exactly:  for i = 1, 5 do print(i) end   — no quotes around i!",
        must_use = { "for", "do", "end" },
        needs_print = true,
        output_is = "1\n2\n3\n4\n5",
      },
      {
        say = "1, 2, 3, 4, 5 — Lua counts just like you do! 👍\n" ..
              "\n" ..
              "The two numbers after  for i =  say where to START\n" ..
              "and where to STOP:\n" ..
              "\n" ..
              "    for i = 1, 10   counts from 1 to 10\n" ..
              "\n" ..
              "Make Lua count from 1 to 10.",
        task = true,
        hint = "Type:  for i = 1, 10 do print(i) end",
        must_use = { "for", "do", "end" },
        needs_print = true,
        output_is = "1\n2\n3\n4\n5\n6\n7\n8\n9\n10",
      },
      {
        say = "Now for some REAL magic. 🪄\n" ..
              "Do you know your times tables? The computer can write\n" ..
              "the WHOLE 7 times table in one line:\n" ..
              "\n" ..
              "    for i = 1, 10 do print(7 * i) end\n" ..
              "\n" ..
              "The box  i  changes every time — so  7 * i  does too!\n" ..
              "Try it!",
        task = true,
        hint = "Type:  for i = 1, 10 do print(7 * i) end",
        must_use = { "for", "*" },
        needs_print = true,
        output_is = "7\n14\n21\n28\n35\n42\n49\n56\n63\n70",
      },
      {
        say = "7, 14, 21... the whole table in a blink! 📚\n" ..
              "\n" ..
              "Now something the computer is SECRETLY great at:\n" ..
              "rolling dice! 🎲 Lua keeps dice in its math kit,\n" ..
              "ready to go:\n" ..
              "\n" ..
              "    math.random(1, 6)\n" ..
              "\n" ..
              "(a surprise number between 1 and 6, different every time!)",
        task = true,
        hint = "Type:  math.random(1, 6)",
        must_use = { "math.random" },
        expect_range = { 1, 6 },
      },
      {
        say = "🎲 Roll it again if you like — you never know what comes!\n" ..
              "\n" ..
              "Now roll FIVE dice at once. You know loops...\n" ..
              "\n" ..
              "    for i = 1, 5 do print(math.random(1, 6)) end",
        task = true,
        hint = "Type:  for i = 1, 5 do print(math.random(1, 6)) end",
        must_use = { "for", "math.random" },
        line_count = 5,
      },
      {
        say = "One last experiment: THE COUNTING MACHINE.\n" ..
              "First, get a counter box ready — set it to zero:\n" ..
              "\n" ..
              "    score = 0",
        task = true,
        hint = "Type:  score = 0",
        must_use = { "score", "=" },
        var_equals = { score = 0 },
      },
      {
        say = "Now tell the computer to press the +1 button\n" ..
              "ONE HUNDRED TIMES:\n" ..
              "\n" ..
              "    for i = 1, 100 do score = score + 1 end\n" ..
              "\n" ..
              "Then we'll peek inside the box together...",
        task = true,
        hint = "Type:  for i = 1, 100 do score = score + 1 end",
        must_use = { "for", "score", "+" },
        var_equals = { score = 100 },
        needs = { score = 0 },
      },
      {
        say = "It clicked the button 100 times in a BLINK! ⚡\n" ..
              "\n" ..
              "🎉🎉🎉  SECTION 4: DONE!  🎉🎉🎉\n" ..
              "\n" ..
              "  ✅ for  repeats an exact number of times\n" ..
              "  ✅ the loop box  i  counts for you\n" ..
              "  ✅ math.random rolls dice 🎲\n" ..
              "  ✅ loops + boxes = a counting machine\n" ..
              "\n" ..
              "Next up: programs that LISTEN to you. See you there!",
      },
    },
  },
  {
    title = "Input — the computer asks YOU",
    lessons = {
      {
        say = "So far, YOU type and the computer answers.\n" ..
              "Time to flip it around! 🙃\n" ..
              "\n" ..
              "Your programs can ASK QUESTIONS and wait for a reply.\n" ..
              "The magic words are  io.read()  — 'io' is short for\n" ..
              "In-and-Out, and read means LISTEN until you press Enter.",
      },
      {
        say = "Try it! Type:\n" ..
              "\n" ..
              "    answer = io.read()\n" ..
              "\n" ..
              "The screen will go quiet — that's the computer WAITING\n" ..
              "for you. Type your favorite food and press Enter!",
        task = true,
        hint = "First type  answer = io.read()  and press Enter.\n" ..
               "     Then the computer waits — type any word you like!",
        must_use = { "answer", "io.read" },
        defines = { answer = "string" },
      },
      {
        say = "The computer caught your word and put it in the box!\n" ..
              "Now make it say your word back:\n" ..
              "\n" ..
              "    print(answer)",
        task = true,
        hint = "Type:  print(answer)   — no quotes, it's a box!",
        must_use = { "answer" },
        needs_print = true,
        output_has_var = "answer",
        needs = { answer = "pizza" },
      },
      {
        say = "It listened AND remembered. 👂\n" ..
              "\n" ..
              "A polite program asks the question first.  io.write\n" ..
              "says something WITHOUT jumping to a new line — perfect\n" ..
              "for questions. Two jobs, one line:\n" ..
              "\n" ..
              '    io.write("What is your name? ") name = io.read()\n' ..
              "\n" ..
              "Try it — and tell it your real name!",
        task = true,
        hint = 'Type:  io.write("What is your name? ") name = io.read()  — then answer it!',
        must_use = { "io.write", "name", "io.read" },
        defines = { name = "string" },
      },
      {
        say = "Now greet yourself like an old friend:\n" ..
              "\n" ..
              '    print("Hello " .. name)',
        task = true,
        hint = 'Type:  print("Hello " .. name)',
        must_use = { "name" },
        needs_print = true,
        output_has_var = "name",
        needs = { name = "friend" },
      },
      {
        say = "Now, a trap every programmer falls into once. ⚠️\n" ..
              "io.read ALWAYS hands you WORDS. If you type 7,\n" ..
              "you get the WORD '7' — and words can't do math!\n" ..
              "\n" ..
              "To get a real NUMBER, wrap it in  tonumber(...):\n" ..
              "\n" ..
              "    age = tonumber(io.read())\n" ..
              "\n" ..
              "Try it — and answer with your age!",
        task = true,
        hint = "Type:  age = tonumber(io.read())\n" ..
               "     tonumber turns the words you type into a real number.",
        must_use = { "age", "tonumber", "io.read" },
        defines = { age = "number" },
      },
      {
        say = "A real NUMBER came through. Prove it — do math on it:\n" ..
              "\n" ..
              "    print(age * 365)\n" ..
              "\n" ..
              "(Your age in days — but this time the computer ASKED you!)",
        task = true,
        hint = "Type:  print(age * 365)",
        must_use = { "age", "*" },
        needs_print = true,
        needs = { age = 9 },
      },
      {
        say = "Time to upgrade the SECRET CLUB DOOR. 🚪\n" ..
              "Before, the password lived in a box. Now the door can\n" ..
              "LISTEN for it. Secret doors don't talk — it just waits:\n" ..
              "\n" ..
              '    if io.read() == "octopus" then print("Welcome inside!") end\n' ..
              "\n" ..
              "Run it — then whisper the right word...",
        task = true,
        hint = 'Type:  if io.read() == "octopus" then print("Welcome inside!") end\n' ..
               "     Then answer with:  octopus",
        must_use = { "if", "io.read", "==" },
        needs_print = true,
        quiet_hint = "The door stayed shut — the password didn't match!\n" ..
                     "  Run it again and type  octopus  exactly.",
      },
      {
        say = "🎉🎉🎉  SECTION 5: DONE!  🎉🎉🎉\n" ..
              "\n" ..
              "Your programs can LISTEN now:\n" ..
              "  ✅ answer = io.read()  waits for typing\n" ..
              '  ✅ io.write("question?")  asks without a new line\n' ..
              "  ✅ tonumber(io.read())  turns the answer into a real number\n" ..
              "  ✅ whatever you type lands in the box\n" ..
              "\n" ..
              "That's what makes programs feel ALIVE — they talk\n" ..
              "with you. Next: loops with a brain!",
      },
    },
  },
  {
    title = "While — the loop with a brain",
    lessons = {
      {
        say = "You know  for  — it repeats an EXACT number of times.\n" ..
              "But sometimes you don't know how many times you need!\n" ..
              "\n" ..
              "  while  repeats AS LONG AS something is true.\n" ..
              "Read it like: WHILE the cup is full, keep drinking.\n" ..
              "\n" ..
              "⚠️ One warning before we start: if the thing is ALWAYS\n" ..
              "true, the loop NEVER stops! Don't worry though —\n" ..
              "Gray is a lifeguard. I'll stop a runaway loop for you.",
      },
      {
        say = "Let's launch a rocket! 🚀\n" ..
              "First we need the countdown box:\n" ..
              "\n" ..
              "    count = 10",
        task = true,
        hint = "Type:  count = 10",
        must_use = { "count", "=" },
        var_equals = { count = 10 },
      },
      {
        say = "Now the countdown. The loop has TWO jobs — say the\n" ..
              "number, then make it smaller. Between  do  and  end\n" ..
              "there's room for both:\n" ..
              "\n" ..
              "    while count > 0 do print(count) count = count - 1 end\n" ..
              "\n" ..
              "Read it: WHILE count is bigger than 0 — say it, shrink it.",
        task = true,
        hint = "Type:  while count > 0 do print(count) count = count - 1 end",
        must_use = { "while", ">", "-" },
        output_is = "10\n9\n8\n7\n6\n5\n4\n3\n2\n1",
        var_equals = { count = 0 },
        needs = { count = 10 },
      },
      {
        say = "...3, 2, 1 — and the loop stopped BY ITSELF, because\n" ..
              "count reached 0 and '0 > 0' is false. Smart loop!\n" ..
              "\n" ..
              "The rocket is ready. Shout the magic words:\n" ..
              "\n" ..
              '    print("BLAST OFF! 🚀")',
        task = true,
        hint = 'Type:  print("BLAST OFF! 🚀")   (or any launch shout you like)',
        needs_print = true,
      },
      {
        say = "Here's an old riddle. Would you rather have 100 coins\n" ..
              "right now... or ONE magic coin that DOUBLES every day?\n" ..
              "\n" ..
              "Let's find out! Start with one coin:\n" ..
              "\n" ..
              "    money = 1",
        task = true,
        hint = "Type:  money = 1",
        must_use = { "money", "=" },
        var_equals = { money = 1 },
      },
      {
        say = "Now keep doubling it UNTIL it beats 100:\n" ..
              "\n" ..
              "    while money < 100 do money = money * 2 end\n" ..
              "\n" ..
              "How big will it get? Make a guess... then run it!",
        task = true,
        hint = "Type:  while money < 100 do money = money * 2 end",
        must_use = { "while", "<", "*" },
        var_equals = { money = 128 },
        needs = { money = 1 },
      },
      {
        say = "128! It blew past 100 in just 7 doublings. 🪙✨\n" ..
              "That's why grown-ups whisper: 'doubling is POWERFUL.'\n" ..
              "\n" ..
              "🎉🎉🎉  SECTION 6: DONE!  🎉🎉🎉\n" ..
              "\n" ..
              "  ✅ while repeats AS LONG AS something is true\n" ..
              "  ✅ the loop must CHANGE something, or it never ends\n" ..
              "  ✅ Gray the lifeguard stops runaway loops\n" ..
              "\n" ..
              "Next, the greatest superpower of all!",
      },
    },
  },
  {
    title = "Functions — teach it new words",
    lessons = {
      {
        say = "The next superpower: teaching the computer NEW WORDS. 🧙\n" ..
              "\n" ..
              "The computer knows  print. It knows  io.read.\n" ..
              "But it doesn't know  cheer  — until YOU teach it!\n" ..
              "\n" ..
              "A new word is called a FUNCTION, and in Lua you teach\n" ..
              "it with... the word  function:\n" ..
              "\n" ..
              '    function cheer() print("Hip hip hooray!") end',
      },
      {
        say = "Teach your computer to cheer! Type:\n" ..
              "\n" ..
              '    function cheer() print("Hip hip hooray!") end\n' ..
              "\n" ..
              "Watch closely: NOTHING will happen. That's right —\n" ..
              "you're only TEACHING the word, not saying it yet.",
        task = true,
        hint = 'Type:  function cheer() print("Hip hip hooray!") end',
        must_use = { "function", "cheer", "print" },
        defines = { cheer = "function" },
      },
      {
        say = "The computer knows a new word! Now SAY it.\n" ..
              "To use a function, say its name with parentheses:\n" ..
              "\n" ..
              "    cheer()",
        task = true,
        hint = "Type:  cheer()   — don't forget the parentheses!",
        must_use = { "cheer()" },
        line_count = 1,
        needs_code = { cheer = 'function cheer() print("Hip hip hooray!") end' },
      },
      {
        say = "One word, and it did the whole job! 🎺\n" ..
              "\n" ..
              "Now combine your superpowers. Remember loops?\n" ..
              "Make the computer cheer FIVE times... using your new word!",
        task = true,
        hint = "A loop that calls your word:  for i = 1, 5 do cheer() end",
        must_use = { "for", "cheer()" },
        line_count = 5,
        needs_code = { cheer = 'function cheer() print("Hip hip hooray!") end' },
      },
      {
        say = "Functions can take an INGREDIENT — you hand them\n" ..
              "something to work with, inside the parentheses:\n" ..
              "\n" ..
              '    function greet(name) print("Hello " .. name) end\n' ..
              "\n" ..
              "Teach your computer to greet!",
        task = true,
        hint = 'Type:  function greet(name) print("Hello " .. name) end',
        must_use = { "function", "greet", "name" },
        defines = { greet = "function" },
      },
      {
        say = "Now greet someone! Hand a name to your function:\n" ..
              "\n" ..
              '    greet("Ada")\n' ..
              "\n" ..
              "(Try your own name, or a friend's!)",
        task = true,
        hint = 'Type:  greet("Ada")  — any name you like, in quotes',
        must_use = { "greet(" },
        line_count = 1,
        needs_code = { greet = 'function greet(name) print("Hello " .. name) end' },
      },
      {
        say = "One more trick: a function can hand an answer BACK,\n" ..
              "like a little math machine. The word is  return:\n" ..
              "\n" ..
              "    function double(n) return n * 2 end\n" ..
              "\n" ..
              "Teach it!",
        task = true,
        hint = "Type:  function double(n) return n * 2 end",
        must_use = { "function", "double", "return", "*" },
        defines = { double = "function" },
        call_test = { "double(5)", 10 },
      },
      {
        say = "Your machine works — I tested it while you weren't\n" ..
              "looking: double(5) gave 10. 😉\n" ..
              "\n" ..
              "Now feed the machine into ITSELF:\n" ..
              "\n" ..
              "    double(double(5))\n" ..
              "\n" ..
              "What will THAT give? Guess first, then try it!",
        task = true,
        hint = "Type:  double(double(5))   — double of double of 5!",
        must_use = { "double" },
        expect = 20,
        needs_code = { double = "function double(n) return n * 2 end" },
      },
      {
        say = "🎉🎉🎉  SECTION 7: DONE — AND SOMETHING BIGGER!  🎉🎉🎉\n" ..
              "\n" ..
              "You've collected ALL SEVEN superpowers:\n" ..
              "  ✅ calculate  (+ - *)\n" ..
              "  ✅ talk       (print)\n" ..
              "  ✅ remember   (variables)\n" ..
              "  ✅ decide     (if)\n" ..
              "  ✅ repeat     (for and while)\n" ..
              "  ✅ listen     (io.read)\n" ..
              "  ✅ learn new words  (function)\n" ..
              "\n" ..
              "And now comes the BEST part. No more practice —\n" ..
              "it's time to BUILD. Three real projects are waiting:\n" ..
              "a game, a story machine, and a robot doorkeeper.\n" ..
              "\n" ..
              "Grab your superpowers. Let's make something! 🔨",
      },
    },
  },
  {
    title = "Project: The Number Wizard",
    lessons = {
      {
        say = "PROJECT TIME! 🔨\n" ..
              "No more practice — you're going to BUILD A REAL GAME.\n" ..
              "\n" ..
              "🔮 THE NUMBER WIZARD 🔮\n" ..
              "The wizard (your computer) thinks of a secret number\n" ..
              "from 1 to 10. You try to read its mind.\n" ..
              "\n" ..
              "Every game is built piece by piece. Let's go.",
      },
      {
        say = "First, the wizard needs a SECRET. The dice kit can\n" ..
              "pick a number nobody sees — not even you:\n" ..
              "\n" ..
              "    secret = math.random(1, 10)",
        task = true,
        hint = "Type:  secret = math.random(1, 10)",
        must_use = { "secret", "math.random" },
        defines = { secret = "number" },
        hide_box = true,
      },
      {
        say = "The wizard is hiding its number... Time to guess!\n" ..
              "Ask the player (that's you!) for a number:\n" ..
              "\n" ..
              '    io.write("Your guess, brave one? ") guess = tonumber(io.read())',
        task = true,
        hint = 'Type:  io.write("Your guess, brave one? ") guess = tonumber(io.read())  — then answer!',
        must_use = { "guess", "tonumber", "io.read" },
        defines = { guess = "number" },
        needs = { secret = 7 },
      },
      {
        say = "Now the wizard drops hints. Was the guess too small?\n" ..
              "\n" ..
              '    if guess < secret then print("Too small, mortal!") end',
        task = true,
        hint = 'Type:  if guess < secret then print("Too small, mortal!") end',
        must_use = { "if", "<", "print" },
        needs = { secret = 7, guess = 3 },
      },
      {
        say = "And the other hint — was it too big?\n" ..
              "\n" ..
              '    if guess > secret then print("Too big, mortal!") end',
        task = true,
        hint = 'Type:  if guess > secret then print("Too big, mortal!") end',
        must_use = { "if", ">", "print" },
        needs = { secret = 7, guess = 3 },
      },
      {
        say = "And the moment of glory — the winning check:\n" ..
              "\n" ..
              '    if guess == secret then print("YOU READ MY MIND!") end',
        task = true,
        hint = 'Type:  if guess == secret then print("YOU READ MY MIND!") end',
        must_use = { "if", "==", "print" },
        needs = { secret = 7, guess = 3 },
      },
      {
        say = "You just played one round BY HAND — guess, hints, check.\n" ..
              "That's exactly what a game is!\n" ..
              "\n" ..
              "But real games run by THEMSELVES. Remember  while  and\n" ..
              "~=  ? The game keeps asking UNTIL you crack it.\n" ..
              "Let's build the whole thing.",
      },
      {
        say = "Fresh game, fresh secret:\n" ..
              "\n" ..
              "    secret = math.random(1, 10)",
        task = true,
        hint = "Type:  secret = math.random(1, 10)",
        must_use = { "secret", "math.random" },
        defines = { secret = "number" },
        hide_box = true,
      },
      {
        say = "And now — THE GAME. One line. while keeps asking\n" ..
              "as long as your answer is DIFFERENT from the secret:\n" ..
              "\n" ..
              '    while tonumber(io.read()) ~= secret do print("Not it... again!") end\n' ..
              "\n" ..
              "The wizard waits in silence for each guess.\n" ..
              "Type it, then PLAY until you read the wizard's mind!",
        task = true,
        hint = 'Type:  while tonumber(io.read()) ~= secret do print("Not it... again!") end\n' ..
               "     Then keep guessing numbers from 1 to 10!",
        must_use = { "while", "tonumber", "io.read", "~=" },
        needs = { secret = 7 },
      },
      {
        say = "You escaped the loop — that means YOU GOT IT! 🧠⚡\n" ..
              "Take your victory lap:\n" ..
              "\n" ..
              '    print("I DEFEATED THE NUMBER WIZARD! 🔮")',
        task = true,
        hint = 'Type:  print("I DEFEATED THE NUMBER WIZARD! 🔮")',
        needs_print = true,
      },
      {
        say = "🎉🎉🎉  PROJECT #1 COMPLETE!  🎉🎉🎉\n" ..
              "\n" ..
              "You built a REAL game, with:\n" ..
              "  🎲 a random secret      (math.random)\n" ..
              "  👂 a listening player   (tonumber + io.read)\n" ..
              "  🚦 wizard hints         (if < > ==)\n" ..
              "  🔁 a game loop          (while ~=)\n" ..
              "\n" ..
              "Challenge a family member to play YOUR game.\n" ..
              "Next project: a machine that writes stories!",
      },
    },
  },
  {
    title = "Project: The Silly Story Machine",
    lessons = {
      {
        say = "Project #2: 📖 THE SILLY STORY MACHINE 📖\n" ..
              "\n" ..
              "This machine collects a few words from a human...\n" ..
              "then writes a story NOBODY could predict.\n" ..
              "\n" ..
              "The trick: the machine asks WITHOUT telling you\n" ..
              "what the story will be. Let's collect the parts!",
      },
      {
        say = "Part one — the machine needs an animal:\n" ..
              "\n" ..
              '    io.write("An animal, please? ") animal = io.read()',
        task = true,
        hint = 'Type:  io.write("An animal, please? ") animal = io.read()  — then answer it!',
        must_use = { "animal", "io.read" },
        defines = { animal = "string" },
      },
      {
        say = "Part two — every good story has food:\n" ..
              "\n" ..
              '    io.write("A food, please? ") food = io.read()',
        task = true,
        hint = 'Type:  io.write("A food, please? ") food = io.read()',
        must_use = { "food", "io.read" },
        defines = { food = "string" },
      },
      {
        say = "Part three — a hero:\n" ..
              "\n" ..
              '    io.write("A friend\'s name? ") friend = io.read()',
        task = true,
        hint = 'Type:  io.write("A friend\'s name? ") friend = io.read()',
        must_use = { "friend", "io.read" },
        defines = { friend = "string" },
      },
      {
        say = "All parts collected! Now GLUE them into a story\n" ..
              "with the dots  ..  — remember your royal title?\n" ..
              "\n" ..
              '    story = "The " .. animal .. " ate " .. food .. " with " .. friend\n' ..
              "\n" ..
              "(Watch the spaces inside the quotes!)",
        task = true,
        hint = 'Type:  story = "The " .. animal .. " ate " .. food .. " with " .. friend',
        must_use = { "story", "..", "animal", "food", "friend" },
        defines = { story = "string" },
        needs = { animal = "dragon", food = "pizza", friend = "Ada" },
      },
      {
        say = "The story is in the box... Read it aloud, machine!\n" ..
              "\n" ..
              "    print(story)",
        task = true,
        hint = "Type:  print(story)",
        must_use = { "story" },
        needs_print = true,
        output_has_var = "story",
        needs = { story = "The dragon ate pizza with Ada" },
      },
      {
        say = "😂 Every great story deserves an ENCORE.\n" ..
              "Tell it three times, like a proper storyteller:\n" ..
              "\n" ..
              "    for i = 1, 3 do print(story) end",
        task = true,
        hint = "Type:  for i = 1, 3 do print(story) end",
        must_use = { "for", "story" },
        line_count = 3,
        needs = { story = "The dragon ate pizza with Ada" },
      },
      {
        say = "🎉🎉🎉  PROJECT #2 COMPLETE!  🎉🎉🎉\n" ..
              "\n" ..
              "Your machine:\n" ..
              "  👂 collects words     (io.read)\n" ..
              "  🧠 remembers them     (variables)\n" ..
              "  🧵 glues a story      (..)\n" ..
              "  📣 performs it        (print + for)\n" ..
              "\n" ..
              "Run it again with sillier words — new story every time!\n" ..
              "One project left: the grand finale. 🚪",
      },
    },
  },
  {
    title = "Project: The Club Doorkeeper",
    lessons = {
      {
        say = "THE FINAL PROJECT: 🚪🤖 THE CLUB DOORKEEPER 🤖🚪\n" ..
              "\n" ..
              "The secret octopus club needs a robot to guard the door.\n" ..
              "It must: greet visitors, demand the password FOREVER\n" ..
              "until it's right, and throw a party for members.\n" ..
              "\n" ..
              "This build uses EVERY superpower you have. Ready?",
      },
      {
        say = "First, teach the robot its party trick:\n" ..
              "\n" ..
              '    function party() print("🎉 WELCOME TO THE SECRET CLUB! 🎉") end',
        task = true,
        hint = 'Type:  function party() print("🎉 WELCOME TO THE SECRET CLUB! 🎉") end',
        must_use = { "function", "party", "print" },
        defines = { party = "function" },
      },
      {
        say = "The robot knows how to party. 🤖\n" ..
              "Now it should ask who's knocking:\n" ..
              "\n" ..
              '    io.write("Who knocks at the door? ") visitor = io.read()',
        task = true,
        hint = 'Type:  io.write("Who knocks at the door? ") visitor = io.read()  — then knock!',
        must_use = { "visitor", "io.read" },
        defines = { visitor = "string" },
      },
      {
        say = "A polite robot greets by name — glue it:\n" ..
              "\n" ..
              '    print("Greetings, " .. visitor .. "!")',
        task = true,
        hint = 'Type:  print("Greetings, " .. visitor .. "!")',
        must_use = { "visitor", ".." },
        needs_print = true,
        output_has_var = "visitor",
        needs = { visitor = "Ada" },
      },
      {
        say = "Now THE UNBREAKABLE DOOR. It listens for the secret\n" ..
              "word again and again and AGAIN — until it hears it:\n" ..
              "\n" ..
              '    while io.read() ~= "octopus" do print("WRONG! The door stays shut.") end\n' ..
              "\n" ..
              "Type it — then try a few wrong words before the right one,\n" ..
              "just to feel the door's power. 😈",
        task = true,
        hint = 'Type:  while io.read() ~= "octopus" do print("WRONG! The door stays shut.") end\n' ..
               "     The secret word is  octopus  — but try wrong ones first!",
        must_use = { "while", "io.read", "~=" },
      },
      {
        say = "The door swings open... and the robot does its thing:\n" ..
              "\n" ..
              "    party()",
        task = true,
        hint = "Type:  party()",
        must_use = { "party()" },
        line_count = 1,
        needs_code = { party = 'function party() print("🎉 WELCOME TO THE SECRET CLUB! 🎉") end' },
      },
      {
        say = "But wait — a proper welcome needs MORE party:\n" ..
              "\n" ..
              "    for i = 1, 3 do party() end",
        task = true,
        hint = "Type:  for i = 1, 3 do party() end",
        must_use = { "for", "party()" },
        line_count = 3,
        needs_code = { party = 'function party() print("🎉 WELCOME TO THE SECRET CLUB! 🎉") end' },
      },
      {
        say = "🎉🎉🎉  ALL THREE PROJECTS COMPLETE!  🎉🎉🎉\n" ..
              "\n" ..
              "Look at what you BUILT:\n" ..
              "  🔮 a mind-reading game\n" ..
              "  📖 a story-writing machine\n" ..
              "  🤖 a robot doorkeeper\n" ..
              "\n" ..
              "...using calculating, talking, remembering, deciding,\n" ..
              "repeating, listening, and words YOU taught the computer.\n" ..
              "\n" ..
              "There's just one thing left to do before you go:\n" ..
              "GRADUATION. 🎓 See you in the final section!",
      },
    },
  },
  {
    title = "Graduation — programs of your own",
    lessons = {
      {
        say = "🎓 Welcome to GRADUATION. 🎓\n" ..
              "\n" ..
              "Here's the last secret Gray has been keeping:\n" ..
              "everything you typed here was REAL Lua — but real\n" ..
              "programmers don't type one line at a time forever.\n" ..
              "They save MANY lines in a FILE, and the computer runs\n" ..
              "the whole file, top to bottom, in one go.\n" ..
              "\n" ..
              "In fact... Gray itself is just a file like that! You've\n" ..
              "been running it all along:  lua gray.lua\n" ..
              "\n" ..
              "So for your final challenge, we'll build YOUR OWN file:\n" ..
              "    my_first_program.lua\n" ..
              "Every line you type now gets SAVED into it. Let's go!",
      },
      {
        say = "Every great program starts with a proud announcement:\n" ..
              "\n" ..
              '    print("This program was written by ME!")',
        task = true,
        hint = 'Type:  print("This program was written by ME!")  — or your own words!',
        needs_print = true,
        append_to_file = "my_first_program.lua",
        start_file = true,
      },
      {
        say = "Saved! ✏️  Now make your program ask who's there:\n" ..
              "\n" ..
              '    io.write("What is your name? ") name = io.read()',
        task = true,
        hint = 'Type:  io.write("What is your name? ") name = io.read()  — then answer it!',
        must_use = { "name", "io.read" },
        defines = { name = "string" },
        append_to_file = "my_first_program.lua",
      },
      {
        say = "And greet them properly, with glue:\n" ..
              "\n" ..
              '    print("Hello " .. name .. "!")',
        task = true,
        hint = 'Type:  print("Hello " .. name .. "!")',
        must_use = { "name", ".." },
        needs_print = true,
        output_has_var = "name",
        needs = { name = "friend" },
        append_to_file = "my_first_program.lua",
      },
      {
        say = "Now some celebration — a loop, of course:\n" ..
              "\n" ..
              '    for i = 1, 3 do print("Hip hip hooray!") end',
        task = true,
        hint = 'Type:  for i = 1, 3 do print("Hip hip hooray!") end',
        must_use = { "for" },
        line_count = 3,
        append_to_file = "my_first_program.lua",
      },
      {
        say = "And every story needs an ending:\n" ..
              "\n" ..
              '    print("THE END")',
        task = true,
        hint = 'Type:  print("THE END")',
        needs_print = true,
        append_to_file = "my_first_program.lua",
      },
      {
        say = "🎁 Your program is complete! It's saved in a real file\n" ..
              "called  my_first_program.lua  — sitting right next to\n" ..
              "gray.lua on your computer.\n" ..
              "\n" ..
              "HERE'S HOW TO RUN IT:\n" ..
              "  1. Type  quit  to say goodbye to Gray\n" ..
              "  2. In the same terminal window, type:\n" ..
              "\n" ..
              "         lua my_first_program.lua\n" ..
              "\n" ..
              "  3. Watch YOUR program run, top to bottom!\n" ..
              "\n" ..
              "And here's the best part: open my_first_program.lua in\n" ..
              "any text editor. Change the words. Add more lines.\n" ..
              "Run it again. THAT is programming.",
      },
      {
        say = "One more secret before you graduate. 🤫\n" ..
              "\n" ..
              "You don't even need a file — or Gray! If you type just\n" ..
              "\n" ..
              "         lua\n" ..
              "\n" ..
              "in the terminal (no file name), Lua itself answers\n" ..
              "with its own prompt:  >\n" ..
              "\n" ..
              "That's called the REPL — a place to talk to Lua\n" ..
              "directly, one line at a time. Sound familiar? It's\n" ..
              "exactly what the  you>  prompt has been all along!\n" ..
              "Try  2 + 2  in there. Old friends. 😉\n" ..
              "\n" ..
              "(To leave the REPL, type  os.exit()  and press Enter.)",
      },
      {
        say = "🎓🎓🎓  YOU FINISHED THE WHOLE COURSE!  🎓🎓🎓\n" ..
              "\n" ..
              "You can now:\n" ..
              "  ✅ write real Lua, line by line\n" ..
              "  ✅ build games, machines, and robots\n" ..
              "  ✅ save programs in files and run them:\n" ..
              "         lua my_first_program.lua\n" ..
              "  ✅ talk to Lua directly in the REPL:  lua\n" ..
              "\n" ..
              "Here's the biggest secret of all: every program ever\n" ..
              "written — games, robots, rockets — is built from\n" ..
              "exactly the pieces you now hold.\n" ..
              "\n" ..
              "Gray is SO proud of you.\n" ..
              "THE END... or really: THE BEGINNING. 🐘💙",
      },
    },
  },
}

---------------------------------------------------------------------------
-- Running the student's code
---------------------------------------------------------------------------

local NO_VALUE = {} -- unique marker for "the code produced no value"

-- Shared between lessons, so later sections can use variables.
-- The student's print shows the line right away (so programs that ask
-- questions feel alive) AND records it for the checks.
local captured_output
local STUDENT_ENV = setmetatable({
  print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do
      parts[#parts + 1] = tostring((select(i, ...)))
    end
    local text = table.concat(parts, "\t")
    captured_output[#captured_output + 1] = text
    say("  " .. bold("🖥  " .. text))
  end,
}, { __index = _G })

local function compile(source)
  if setfenv then -- Lua 5.1 / LuaJIT
    local chunk, err = loadstring(source, "lesson")
    if chunk then setfenv(chunk, STUDENT_ENV) end
    return chunk, err
  end
  return load(source, "lesson", "t", STUDENT_ENV)
end

-- Run a chunk with a watchdog: a loop that never ends gets stopped
-- (Ctrl+C would kill Lua entirely, so Gray plays lifeguard instead).
local function run_guarded(chunk)
  debug.sethook(function()
    debug.sethook()
    error("That was taking FOREVER, so I stopped it. Phew!", 0)
  end, "", 1e8)
  local ok, value = pcall(chunk)
  debug.sethook()
  return ok, value
end

-- Run one line of student code. Returns (value, printed_lines, error).
local function run_code(source)
  captured_output = {}
  local chunk = compile("return " .. source)
  if not chunk then
    local err
    chunk, err = compile(source)
    if not chunk then return NO_VALUE, captured_output, err end
  end
  local ok, value = run_guarded(chunk)
  if not ok then return NO_VALUE, captured_output, value end
  if value == nil then value = NO_VALUE end
  return value, captured_output, nil
end

---------------------------------------------------------------------------
-- Checking the student's answer
---------------------------------------------------------------------------

local function show_value(v)
  if type(v) == "string" then return '"' .. v .. '"' end
  return tostring(v)
end

local function check(lesson, source, value, output_lines, err)
  local output = table.concat(output_lines, "\n")
  if err ~= nil then
    return false, "Oops — the computer got confused:\n     " .. dim(tostring(err)) ..
                  "\n  No problem, that happens to every programmer. Try again!"
  end
  for _, needed in ipairs(lesson.must_use or {}) do
    if not source:find(needed, 1, true) then
      if needed == "+" or needed == "-" or needed == "*" or needed == "/" then
        return false, "You're allowed to know the answer — but let the COMPUTER " ..
                      "do the work!\n  Use the  " .. needed .. "  sign in your code."
      end
      return false, "Your code should use  " .. needed .. "  — check the challenge again!"
    end
  end
  if lesson.needs_print then
    if not source:find("print", 1, true) then
      return false, "Use print( ... ) to make the computer talk!"
    end
    if output:match("^%s*$") then
      return false, lesson.quiet_hint or
                    ("Hmm, the computer stayed quiet. Put the words you want\n" ..
                     '  inside the parentheses:  print("like this")')
    end
    if output:gsub("nil", ""):match("^%s*$") then
      return false, "The computer said 'nil' — that means NOTHING in Lua!\n" ..
                    '  Did you forget the quotes? Try:  print("Hello!")'
    end
  end
  if lesson.expect_silence and not output:match("^%s*$") then
    return false, "The computer spoke! But the answer to this question is NO —\n" ..
                  "  so it should do NOTHING. Check your numbers!"
  end
  if lesson.output_is and output:match("^%s*(.-)%s*$") ~= lesson.output_is then
    if lesson.output_is:find("\n", 1, true) then
      return false, "Close, but that's not quite the list I wanted!\n" ..
                    "  Look at the FIRST number and the LAST number — then try again."
    end
    return false, "The computer said '" .. output .. "', but I expected '" ..
                  lesson.output_is .. "'.\n  Check the challenge again!"
  end
  if lesson.line_count then
    local count = 0
    for _, line in ipairs(output_lines) do
      if not line:match("^%s*$") then count = count + 1 end
    end
    if count ~= lesson.line_count then
      return false, "The computer said it " .. count .. " time(s) — I wanted " ..
                    lesson.line_count .. " times!\n" ..
                    "  Check the number in your loop and try again!"
    end
  end
  if lesson.output_has_var then
    local box = lesson.output_has_var
    local inside = tostring(rawget(STUDENT_ENV, box) or "")
    if not output:find(inside, 1, true) then
      return false, "I wanted to hear what's inside the '" .. box .. "' box!\n" ..
                    "  Glue it into your message — check the example again."
    end
  end
  for box, kind in pairs(lesson.defines or {}) do
    local val = rawget(STUDENT_ENV, box)
    if val == nil then
      return false, "I don't see a box called '" .. box .. "' yet.\n" ..
                    "  Make one with the = sign, like:  " .. box .. " = ..."
    end
    if kind == "number" and type(val) ~= "number" then
      return false, "The box '" .. box .. "' needs a NUMBER inside.\n" ..
                    "  Numbers don't need quotes!"
    end
    if kind == "string" and type(val) ~= "string" then
      return false, "The box '" .. box .. "' needs WORDS inside.\n" ..
                    '  Words need quotes, like  "this"!'
    end
    if kind == "function" and type(val) ~= "function" then
      return false, "'" .. box .. "' should be a new WORD the computer learns.\n" ..
                    "  Teach it with:  function " .. box .. "() ... end"
    end
  end
  for box, want in pairs(lesson.var_equals or {}) do
    local val = rawget(STUDENT_ENV, box)
    if val == nil then
      return false, "I don't see a box called '" .. box .. "' yet.\n" ..
                    "  Make one with the = sign, like:  " .. box .. " = ..."
    end
    if val ~= want then
      return false, "I peeked inside '" .. box .. "' and found " .. show_value(val) ..
                    ",\n  but I expected " .. show_value(want) .. ". Try again!"
    end
  end
  if lesson.expect_range then
    local lo, hi = lesson.expect_range[1], lesson.expect_range[2]
    local got
    if type(value) == "number" then
      got = value
    else
      got = tonumber(output:match("^%s*(.-)%s*$"))
    end
    if not got or got < lo or got > hi then
      local shown = "nothing"
      if got then shown = tostring(got)
      elseif value ~= NO_VALUE then shown = show_value(value)
      elseif not output:match("^%s*$") then shown = output end
      return false, "I expected a number between " .. lo .. " and " .. hi ..
                    ", but I got " .. shown .. ".\n  Check the challenge and try again!"
    end
  end
  if lesson.call_test then
    local expr, want = lesson.call_test[1], lesson.call_test[2]
    local chunk = compile("return " .. expr)
    local okc, got
    if chunk then
      okc, got = run_guarded(chunk)
    else
      okc, got = false, "that's not something I can run"
    end
    if not okc then
      return false, "I tried  " .. expr .. "  but it broke:\n     " .. dim(tostring(got)) ..
                    "\n  Check your function and try again!"
    end
    if got ~= want then
      local shown = (got == nil) and "nothing" or show_value(got)
      return false, "I tried  " .. expr .. "  and got " .. shown .. " — I expected " ..
                    show_value(want) .. ".\n  Check your function and try again!"
    end
  end
  if lesson.expect_expr then
    local chunk = compile("return " .. lesson.expect_expr)
    local okv, want = pcall(chunk)
    if okv then
      local trimmed = output:match("^%s*(.-)%s*$")
      if value ~= want and trimmed ~= tostring(want) then
        local shown = (value == NO_VALUE) and "nothing" or show_value(value)
        return false, "The computer answered " .. shown .. " — not what I was looking for." ..
                      "\n  Check your boxes and try again!"
      end
    end
  end
  if lesson.expect ~= nil and value ~= lesson.expect then
    local shown = (value == NO_VALUE) and "nothing" or tostring(value)
    return false, "The computer answered " .. shown .. " — not what I was looking for." ..
                  "\n  Check your numbers and try again!"
  end
  return true, ""
end

local PRAISE = { "Perfect!", "You got it!", "Exactly right!", "Amazing!", "That's it!",
                 "Wow, nice work!", "Correct!", "You're a natural!" }

-- Save the student's line into their very own script file.
local function add_to_script(lesson, source)
  local target = lesson.append_to_file
  if not target then return end
  local path = (arg[0]:match("(.*[/\\])") or "") .. target
  local fh = io.open(path, lesson.start_file and "w" or "a")
  if not fh then return end
  if lesson.start_file then
    fh:write("-- My first program — written with Gray 🐘\n")
  end
  fh:write(source, "\n")
  fh:close()
  say(dim("  📝 line saved to  " .. target))
end

---------------------------------------------------------------------------
-- Lesson loop
---------------------------------------------------------------------------

local function prompt(text)
  io.write(text)
  io.flush()
  return io.read("*l")
end

-- Let the student try until they solve it. Returns "done", "menu" or "quit".
local function do_task(lesson, praise_index)
  while true do
    local typed = prompt(magenta("  you> "))
    if typed == nil then return "quit" end
    typed = typed:match("^%s*(.-)%s*$")

    if typed ~= "" then
      local low = typed:lower()
      if low == "quit" or low == "exit" then return "quit" end
      if low == "menu" then return "menu" end
      if low == "hint" then
        say(cyan("\n  💡 " .. (lesson.hint or "No hint here — you can do it!") .. "\n"))
      elseif low == "skip" then
        say(dim("\n  Skipped! (You can come back to it from the menu.)\n"))
        return "done"
      else
        local snapshot = {} -- a failed try must not change the boxes
        for k, v in pairs(STUDENT_ENV) do snapshot[k] = v end
        local value, output_lines, err = run_code(typed)
        if value ~= NO_VALUE and err == nil then
          say("  " .. bold("= " .. tostring(value)))
        end
        local ok, feedback = check(lesson, typed, value, output_lines, err)
        if ok then
          add_to_script(lesson, typed)
          local boxes = {}
          for box in pairs(lesson.defines or {}) do boxes[#boxes + 1] = box end
          for box in pairs(lesson.var_equals or {}) do boxes[#boxes + 1] = box end
          table.sort(boxes)
          for _, box in ipairs(boxes) do
            local val = rawget(STUDENT_ENV, box)
            if type(val) == "function" then
              say(dim("  ✨ new word learned:  " .. box .. "()"))
            elseif lesson.hide_box then
              say(dim("  📦 " .. box .. " = ✨ shhh... it's a secret! ✨"))
            else
              say(dim("  📦 " .. box .. " = " .. show_value(val)))
            end
          end
          cheer(PRAISE[(praise_index % #PRAISE) + 1])
          return "done"
        end
        for k in pairs(STUDENT_ENV) do
          if snapshot[k] == nil then STUDENT_ENV[k] = nil end
        end
        for k, v in pairs(snapshot) do STUDENT_ENV[k] = v end
        nudge(feedback)
      end
    end
  end
end

local function wait_for_enter()
  local line = prompt(dim("        (press Enter to continue)"))
  if line == nil then return "quit" end
  return "done"
end

---------------------------------------------------------------------------
-- Progress
---------------------------------------------------------------------------

local function load_progress()
  local fh = io.open(PROGRESS_FILE, "r")
  if not fh then return 1, 1 end
  local section, lesson = fh:read("*n", "*n")
  fh:close()
  if type(section) ~= "number" or type(lesson) ~= "number" then return 1, 1 end
  return section, lesson
end

local function save_progress(section, lesson)
  local fh = io.open(PROGRESS_FILE, "w")
  if fh then
    fh:write(section, " ", lesson, "\n")
    fh:close()
  end
end

---------------------------------------------------------------------------
-- Updates
---------------------------------------------------------------------------

local function fetch_latest()
  -- curl ships with macOS, Linux, and Windows 10+
  local null = package.config:sub(1, 1) == "\\" and "nul" or "/dev/null"
  local fh = io.popen('curl -fsS -m 3 "' .. UPDATE_URL .. '" 2>' .. null)
  if not fh then return nil end
  local body = fh:read("*a")
  local ok = fh:close()
  if not ok or not body or body == "" then return nil end
  return body
end

-- Swap in the newest Gray from gray.academy, in place.
-- This runs at startup, before any lesson state exists, so on update we
-- can simply run the new file — the student never has to do a thing.
-- Set GRAY_NO_UPDATE=1 to skip the check entirely.
local function check_for_updates()
  if GRAY_UPDATED or os.getenv("GRAY_NO_UPDATE") then return end
  say(dim("  📡 Checking gray.academy for new adventures..."))
  local fresh = fetch_latest()
  if not fresh then
    say(dim("  🌥  No internet right now — that's totally fine!\n" ..
            "      Gray works great offline. On with the adventure!"))
    return
  end
  local remote_version = tonumber(fresh:match("GRAY_VERSION%s*=%s*(%d+)"))
  if not remote_version or remote_version <= GRAY_VERSION
      or fresh:sub(1, 18) ~= "#!/usr/bin/env lua" then
    say(dim("  ✅ Gray is up to date!"))
    return
  end
  local me, tmp_path, old_path = arg[0], arg[0] .. ".new", arg[0] .. ".old"
  local out = io.open(tmp_path, "w")
  if out then
    out:write(fresh)
    out:close()
  end
  os.remove(old_path)
  local swapped = out and os.rename(me, old_path) and os.rename(tmp_path, me)
  if not swapped then
    os.rename(old_path, me) -- put things back if the swap half-happened
    os.remove(tmp_path)
    say(yellow("  ✨ A newer Gray is out at gray.academy, but I couldn't\n" ..
               "     update this copy. Re-download me when you get a chance!"))
    return
  end
  os.remove(old_path)
  say(green("  ✨ Gray just learned some new tricks — updating myself..."))
  GRAY_UPDATED = true
  local chunk = loadfile(me)
  if chunk then chunk() end
  os.exit(0)
end

---------------------------------------------------------------------------
-- Menu and main loop
---------------------------------------------------------------------------

local function show_menu(current_section)
  banner("Gray — Lua course")
  for i, section in ipairs(SECTIONS) do
    local number = i .. "."
    if section.coming_soon then
      say(dim("   🔒 " .. number .. " " .. section.title .. "  (coming soon)"))
    elseif i < current_section then
      say(green("   ✅ " .. number .. " " .. section.title))
    elseif i == current_section then
      say(bold("   👉 " .. number .. " " .. section.title))
    else
      say("      " .. number .. " " .. section.title)
    end
  end
  say()
  while true do
    local choice = prompt("  Pick a number, or press Enter to continue: ")
    if choice == nil then return "quit" end
    choice = choice:match("^%s*(.-)%s*$")
    local low = choice:lower()
    if low == "quit" or low == "exit" then return "quit" end
    local picked = tonumber(choice)
    if picked and picked >= 1 and picked <= #SECTIONS and picked == math.floor(picked) then
      if SECTIONS[picked].coming_soon then
        say(yellow("\n  That section isn't ready yet — soon! 🚧"))
      else
        return picked
      end
    else
      return current_section
    end
  end
end

-- Play one section. Returns ("finished"|"menu"|"quit"), lesson_index.
local function run_section(section_index, start_lesson)
  local section = SECTIONS[section_index]
  banner("Section " .. section_index .. ": " .. section.title)
  local praise_index = 0
  local lesson_index = start_lesson
  while lesson_index <= #section.lessons do
    local lesson = section.lessons[lesson_index]
    for box, default in pairs(lesson.needs or {}) do
      if rawget(STUDENT_ENV, box) == nil then STUDENT_ENV[box] = default end
    end
    for box, code in pairs(lesson.needs_code or {}) do
      if rawget(STUDENT_ENV, box) == nil then run_code(code) end
    end
    say()
    say(lesson.say)
    say()
    local result
    if lesson.task then
      result = do_task(lesson, praise_index)
      praise_index = praise_index + 1
    else
      result = wait_for_enter()
    end
    if result == "quit" then return "quit", lesson_index end
    if result == "menu" then return "menu", lesson_index end
    lesson_index = lesson_index + 1
    save_progress(section_index, lesson_index)
  end
  return "finished", 1
end

local function main()
  check_for_updates()
  local section, lesson = load_progress()
  if section > #SECTIONS or not SECTIONS[section] or SECTIONS[section].coming_soon then
    section, lesson = 1, 1
  end

  if section == 1 and lesson == 1 then
    say(bold("\n  Welcome to Gray! 🐘 Let's learn Lua.\n"))
  else
    say(bold("\n  Welcome back! 🐘 Let's pick up where you left off.\n"))
  end

  while true do
    local choice = show_menu(section)
    if choice == "quit" then break end
    if choice ~= section then
      section, lesson = choice, 1
    end
    local status
    status, lesson = run_section(section, lesson)
    if status == "quit" then
      save_progress(section, lesson)
      break
    end
    if status == "finished" then
      section, lesson = section + 1, 1
      while section <= #SECTIONS and SECTIONS[section].coming_soon do
        section = section + 1
      end
      if section > #SECTIONS then
        -- everything done — keep pointing at the last section visited
        section = #SECTIONS
        while section > 1 and SECTIONS[section].coming_soon do
          section = section - 1
        end
        lesson = 1
      end
      save_progress(section, lesson)
    end
  end

  say(cyan("\n  Bye! Your progress is saved — come back soon. 👋\n"))
end

main()

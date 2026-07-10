#!/usr/bin/env python3
"""Gray — a programming course for kids.

Run it with:  python gray.py

You type real Python code, Gray checks it and cheers you on.
Progress is saved in .gray-progress-python.json so you can stop anytime.
"""

import json
import os
import sys

PROGRESS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                             ".gray-progress-python.json")

# ---------------------------------------------------------------------------
# Pretty terminal output
# ---------------------------------------------------------------------------

USE_COLOR = sys.stdout.isatty() and not os.environ.get("NO_COLOR")

def paint(text, code):
    return f"\033[{code}m{text}\033[0m" if USE_COLOR else text

def bold(t):    return paint(t, "1")
def cyan(t):    return paint(t, "96")
def green(t):   return paint(t, "92")
def yellow(t):  return paint(t, "93")
def magenta(t): return paint(t, "95")
def dim(t):     return paint(t, "2")

def say(text=""):
    print(text)

def banner(text):
    line = "─" * (len(text) + 4)
    say(cyan(f"╭{line}╮"))
    say(cyan(f"│  {bold(text)}  │"))
    say(cyan(f"╰{line}╯"))

def cheer(text):
    say(green(f"\n  ⭐ {text}\n"))

def nudge(text):
    say(yellow(f"\n  🤔 {text}\n"))

# ---------------------------------------------------------------------------
# The course content
#
# A lesson is a dict:
#   say         text shown to the student (always required)
#   task        if True, the student must type code that passes the checks
#   hint        shown when the student types: hint
#   must_use    list of substrings the code must contain (e.g. ["+"])
#   expect      the value the code must produce (e.g. 8)
#   needs_print True -> code must use print and actually print something
#   output_is   exact text the printed output must match
#   needs       variables (name -> default) created before the lesson if
#               missing, so resuming mid-section always works
#   defines     name -> "number"|"string": a box the code must create
#   var_equals  name -> value the box must hold afterwards
#   expect_expr expression (using the student's boxes) the value must match
#   output_has_var  name of a box whose contents must appear in the output
#   expect_silence  True -> the code must print NOTHING (a false if!)
#   quiet_hint  custom message when needs_print finds no output
#   line_count  number of lines the code must print (loops!)
#   needs_code  code (name -> source) run before the lesson if the name
#               is missing — like needs, but for functions
#   call_test   [expression, expected]: the expression must give the
#               expected value (for checking the student's functions)
#   expect_range  [lo, hi]: the answer must be a number in this range
#               (for dice rolls and other random things)
#   hide_box    True -> don't reveal the box contents on success
#               (keeps game secrets secret!)
#   append_to_file  filename: on success, save the student's line into
#               this file (building their very own script!)
#   start_file  True -> this line starts the file fresh, with a header
# ---------------------------------------------------------------------------

SECTIONS = [
    {
        "title": "Introduction",
        "lessons": [
            {
                "say": (
                    "Hi! I'm Gray. 👋\n"
                    "I'm going to teach you how to talk to your computer\n"
                    "using a language called Python.\n"
                    "\n"
                    "Here's how it works: I explain something, then YOU try it.\n"
                    "You type real Python code and press Enter.\n"
                    "\n"
                    "A few magic words you can always type:\n"
                    "  hint  - if you're stuck\n"
                    "  menu  - to see all the sections\n"
                    "  quit  - to stop (I'll remember where you were!)"
                ),
            },
            {
                "say": (
                    "First secret: your computer is a GIANT calculator.\n"
                    "If you type some math, Python solves it instantly.\n"
                    "\n"
                    "Try it! Type:  2 + 2   and press Enter."
                ),
                "task": True,
                "hint": "Type exactly this and press Enter:  2 + 2",
                "must_use": ["+"],
                "expect": 4,
            },
            {
                "say": (
                    "You just wrote your first Python script! 🎉\n"
                    "\n"
                    "Now you try one on your own: make Python add  5 + 3."
                ),
                "task": True,
                "hint": "Just like before, but with different numbers:  5 + 3",
                "must_use": ["+"],
                "expect": 8,
            },
            {
                "say": (
                    "Python can multiply too — but there's a trick!\n"
                    "Computers don't use the × sign. They use a star:  *\n"
                    "\n"
                    "So 'six times seven' is written:  6 * 7\n"
                    "Try it!"
                ),
                "task": True,
                "hint": "Type:  6 * 7   (the * is usually Shift+8 on your keyboard)",
                "must_use": ["*"],
                "expect": 42,
            },
            {
                "say": (
                    "Nice! Now let's see how FAST your computer really is.\n"
                    "\n"
                    "Ask it to multiply  123 * 456.\n"
                    "(That would take a person a while. Watch the computer do it.)"
                ),
                "task": True,
                "hint": "Same trick as before:  123 * 456",
                "must_use": ["*"],
                "expect": 56088,
            },
            {
                "say": (
                    "⚡ Instant! Computers never get tired of math.\n"
                    "\n"
                    "One more: subtracting uses the minus sign:  -\n"
                    "A year has 365 days, and 200 have already passed.\n"
                    "Ask Python how many days are left."
                ),
                "task": True,
                "hint": "How many days are left? That's  365 - 200",
                "must_use": ["-"],
                "expect": 165,
            },
            {
                "say": (
                    "Math: done! ✅  But computers can also TALK.\n"
                    "\n"
                    "To make Python say something, use print with quotes:\n"
                    '    print("Hello!")\n'
                    "\n"
                    "The quotes tell Python: say exactly these words.\n"
                    "Make your computer say hello!"
                ),
                "task": True,
                "hint": 'Type exactly:  print("Hello!")  — don\'t forget the quotes and parentheses!',
                "needs_print": True,
            },
            {
                "say": (
                    "It talks! 🗣️\n"
                    "\n"
                    "Now make it say something about YOU.\n"
                    "Print your own name, or anything you like!"
                ),
                "task": True,
                "hint": 'Like before, put your words in quotes:  print("Ada is awesome")',
                "needs_print": True,
            },
            {
                "say": (
                    "Last challenge! Here's a brain-twister:\n"
                    "\n"
                    '    print("3 + 4")   says the words:  3 + 4\n'
                    "    print(3 + 4)     does the MATH first, then says the answer!\n"
                    "\n"
                    "No quotes means: solve it, don't say it.\n"
                    "Try printing  3 + 4  WITHOUT quotes and see what happens."
                ),
                "task": True,
                "hint": "Type:  print(3 + 4)   — no quotes anywhere!",
                "needs_print": True,
                "must_use": ["+"],
                "output_is": "7",
            },
            {
                "say": (
                    "🎉🎉🎉  YOU FINISHED THE INTRODUCTION!  🎉🎉🎉\n"
                    "\n"
                    "Look at everything you learned:\n"
                    "  ✅ Computers are giant calculators (+ - *)\n"
                    "  ✅ print() makes the computer talk\n"
                    "  ✅ Quotes = say it exactly. No quotes = solve it first.\n"
                    "\n"
                    "You are doing awesome! Next up: variables — giving things a name. See you there!"
                ),
            },
        ],
    },
    {
        "title": "Variables — give things a name",
        "lessons": [
            {
                "say": (
                    "Ready for a new superpower? 💪\n"
                    "\n"
                    "Your computer can REMEMBER things. You store something\n"
                    "and give it a name — that's called a VARIABLE.\n"
                    "Think of it as a BOX with a name sticker on it:\n"
                    "\n"
                    "    age = 9\n"
                    "\n"
                    "This means: make a box called 'age' and put 9 inside.\n"
                    "The = sign puts things into boxes."
                ),
            },
            {
                "say": (
                    "Your turn! Make a box called  age  with YOUR age inside.\n"
                    "(If you are 9 years old, type:  age = 9 )"
                ),
                "task": True,
                "hint": "The box name, then =, then your age:  age = 9",
                "must_use": ["age", "="],
                "defines": {"age": "number"},
            },
            {
                "say": (
                    "The computer will remember that! 🧠\n"
                    "To peek inside a box, just type its name.\n"
                    "\n"
                    "Ask the computer what's inside  age."
                ),
                "task": True,
                "hint": "Just type the box's name and nothing else:  age",
                "must_use": ["age"],
                "expect_expr": "age",
                "needs": {"age": 9},
            },
            {
                "say": (
                    "And here's the magic: boxes work in MATH!\n"
                    "\n"
                    "    age * 365\n"
                    "\n"
                    "tells you (about) how many DAYS old you are. Try it!"
                ),
                "task": True,
                "hint": "Type:  age * 365",
                "must_use": ["age", "*"],
                "expect_expr": "age * 365",
                "needs": {"age": 9},
            },
            {
                "say": (
                    "Whoa, that's a lot of days! 📅\n"
                    "\n"
                    "Boxes can hold WORDS too — with quotes, just like print.\n"
                    "Make a box called  name  with your name inside:\n"
                    "\n"
                    '    name = "Ada"      (but use YOUR name!)'
                ),
                "task": True,
                "hint": 'Box name, =, then your name in quotes:  name = "Ada"',
                "must_use": ["name", "="],
                "defines": {"name": "string"},
            },
            {
                "say": (
                    "Now the computer knows you! Let's make it say hello TO YOU.\n"
                    "\n"
                    "print can say several things — separate them with a comma:\n"
                    "\n"
                    '    print("Hello", name)\n'
                    "\n"
                    "Try it!"
                ),
                "task": True,
                "hint": 'Type:  print("Hello", name)  — the box name has NO quotes!',
                "must_use": ["name"],
                "needs_print": True,
                "output_has_var": "name",
                "needs": {"name": "friend"},
            },
            {
                "say": (
                    "It knows your name! 🤩\n"
                    "\n"
                    "Words can also be GLUED together — with  + ,\n"
                    "the same sign you use for adding numbers:\n"
                    "\n"
                    '    print(name + " the Great")\n'
                    "\n"
                    "Glue yourself a royal title!"
                ),
                "task": True,
                "hint": 'Type:  print(name + " the Great")   — or invent your own title!',
                "must_use": ["name", "+"],
                "needs_print": True,
                "output_has_var": "name",
                "needs": {"name": "friend"},
            },
            {
                "say": (
                    "Fancy! 🎩\n"
                    "\n"
                    "One more trick: what's inside a box can CHANGE.\n"
                    "Let's keep score, like in a video game. 🎮\n"
                    "\n"
                    "Start at zero: make a box called  score  with 0 inside."
                ),
                "task": True,
                "hint": "Just like the age box:  score = 0",
                "must_use": ["score", "="],
                "var_equals": {"score": 0},
            },
            {
                "say": (
                    "You just scored 10 points! 🏀\n"
                    "Tell the computer: take what's in the box, add 10,\n"
                    "and put the answer back in the box:\n"
                    "\n"
                    "    score = score + 10"
                ),
                "task": True,
                "hint": "Type:  score = score + 10",
                "must_use": ["score", "+", "="],
                "var_equals": {"score": 10},
                "needs": {"score": 0},
            },
            {
                "say": (
                    "🎉🎉🎉  SECTION 2: DONE!  🎉🎉🎉\n"
                    "\n"
                    "You unlocked the memory superpower:\n"
                    "  ✅ age = 9  puts something in a box\n"
                    "  ✅ typing a box's name peeks inside\n"
                    "  ✅ boxes work in math:  age * 365\n"
                    "  ✅ boxes can change:  score = score + 10\n"
                    "\n"
                    "Programmers use variables ALL THE TIME.\n"
                    "You're a real programmer now. See you in the next section!"
                ),
            },
        ],
    },
    {
        "title": "If this, then that",
        "lessons": [
            {
                "say": (
                    "Time for a BIG one. 🧠\n"
                    "Your computer can answer QUESTIONS — yes-or-no questions.\n"
                    "\n"
                    "Is 5 bigger than 3? Is 10 smaller than 2?\n"
                    "You ask with special signs:\n"
                    "\n"
                    "    >   means: is it BIGGER?\n"
                    "    <   means: is it SMALLER?\n"
                    "\n"
                    "The computer answers  True  (yes!) or  False  (no!)."
                ),
            },
            {
                "say": (
                    "Ask the computer: is 5 bigger than 3?\n"
                    "\n"
                    "    5 > 3\n"
                    "\n"
                    "Try it and see what it says!"
                ),
                "task": True,
                "hint": "Type:  5 > 3",
                "must_use": [">"],
                "expect": True,
            },
            {
                "say": (
                    "It said True — that means YES! ✅\n"
                    "\n"
                    "Now ask a silly one: is 10 smaller than 2?\n"
                    "\n"
                    "    10 < 2"
                ),
                "task": True,
                "hint": "Type:  10 < 2",
                "must_use": ["<"],
                "expect": False,
            },
            {
                "say": (
                    "False — no way! The computer NEVER lies. 😄\n"
                    "\n"
                    "Try a harder question: is  7 * 8  bigger than 50?\n"
                    "Don't do the math yourself — make the computer do it,\n"
                    "all in one question!"
                ),
                "task": True,
                "hint": "Type:  7 * 8 > 50",
                "must_use": ["*", ">"],
                "expect": True,
            },
            {
                "say": (
                    "Now a tricky sign. You know  =  puts things in a box.\n"
                    "To ASK 'are these equal?', you need TWO of them:\n"
                    "\n"
                    "    one   =    put it in the box\n"
                    "    two   ==   is it equal?\n"
                    "\n"
                    "Ask the computer: is  2 + 2  equal to 4?"
                ),
                "task": True,
                "hint": "Type:  2 + 2 == 4   (two equal signs, no spaces between them!)",
                "must_use": ["+", "=="],
                "expect": True,
            },
            {
                "say": (
                    "And here's the OPPOSITE question:  !=  means\n"
                    "'is it DIFFERENT?' (the ! makes it a no-question):\n"
                    "\n"
                    "    5 != 3\n"
                    "\n"
                    "Is 5 different from 3? Ask the computer!"
                ),
                "task": True,
                "hint": "Type:  5 != 3   (an exclamation mark, then an equal sign)",
                "must_use": ["!="],
                "expect": True,
            },
            {
                "say": (
                    "Now the REAL superpower: your computer can DECIDE. 🚦\n"
                    "With  if,  it only does the job when the answer is yes:\n"
                    "\n"
                    '    if 10 > 5: print("10 is bigger!")\n'
                    "\n"
                    "Read it out loud: IF 10 is bigger than 5, say '10 is bigger!'\n"
                    "(Careful: there's a  :  after the question.)\n"
                    "Type it and watch what happens."
                ),
                "task": True,
                "hint": 'Type it exactly:  if 10 > 5: print("10 is bigger!")',
                "must_use": ["if", ">", ":"],
                "needs_print": True,
            },
            {
                "say": (
                    "The question was TRUE, so the computer did the job!\n"
                    "But what if the question is FALSE?\n"
                    "\n"
                    "Tell it: IF 1 is bigger than 100, say IMPOSSIBLE:\n"
                    "\n"
                    '    if 1 > 100: print("IMPOSSIBLE!")\n'
                    "\n"
                    "Watch very carefully..."
                ),
                "task": True,
                "hint": 'Type:  if 1 > 100: print("IMPOSSIBLE!")',
                "must_use": ["if", ">", "print"],
                "expect_silence": True,
            },
            {
                "say": (
                    "NOTHING happened! 🤫  And that's EXACTLY right.\n"
                    "1 is NOT bigger than 100 — the answer was no,\n"
                    "so the computer skipped the job. That's the power of  if!\n"
                    "\n"
                    "Let's use it to build a SECRET CLUB DOOR. 🚪\n"
                    "First the club needs a secret word. Make this box:\n"
                    "\n"
                    '    password = "octopus"'
                ),
                "task": True,
                "hint": 'Type:  password = "octopus"',
                "must_use": ["password", "="],
                "var_equals": {"password": "octopus"},
            },
            {
                "say": (
                    "Now build the door! IF the password is right,\n"
                    "the computer lets you in:\n"
                    "\n"
                    '    if password == "octopus": print("Welcome to the club!")\n'
                    "\n"
                    "(Remember: TWO equal signs to ask a question!)"
                ),
                "task": True,
                "hint": 'Type:  if password == "octopus": print("Welcome to the club!")',
                "must_use": ["if", "==", "password"],
                "needs_print": True,
                "needs": {"password": "octopus"},
                "quiet_hint": ("The computer stayed quiet — the password didn't match!\n"
                               '  Check your spelling. The secret word is  "octopus".'),
            },
            {
                "say": (
                    "🎉🎉🎉  SECTION 3: DONE!  🎉🎉🎉\n"
                    "\n"
                    "Your computer can now make DECISIONS:\n"
                    "  ✅ ask questions with  >  <  ==  !=\n"
                    "  ✅ True means yes, False means no\n"
                    "  ✅ if  does the job only when the answer is yes\n"
                    "  ✅ and you built a secret club door!\n"
                    "\n"
                    "Next adventure: LOOPS — making the computer do things\n"
                    "again and again and again. See you there!"
                ),
            },
        ],
    },
    {
        "title": "Loops — do it again!",
        "lessons": [
            {
                "say": (
                    "Would YOU like to say 'Hip hip hooray!' a hundred times?\n"
                    "No? Well, the computer would LOVE to.\n"
                    "\n"
                    "Doing something again and again is called a LOOP,\n"
                    "and the magic word is  for."
                ),
            },
            {
                "say": (
                    "Here's a loop that cheers FIVE times:\n"
                    "\n"
                    '    for i in range(5): print("Hip hip hooray!")\n'
                    "\n"
                    "Read it out loud: FOR each count in a RANGE of 5,\n"
                    "say 'Hip hip hooray!'\n"
                    "Type it and watch the computer go wild!"
                ),
                "task": True,
                "hint": 'Type it exactly:  for i in range(5): print("Hip hip hooray!")',
                "must_use": ["for", "range"],
                "needs_print": True,
                "line_count": 5,
            },
            {
                "say": (
                    "😄 See? It NEVER gets bored.\n"
                    "\n"
                    "Now use your new power: print YOUR name TEN times.\n"
                    "(Programmers love making the computer do the boring work —\n"
                    "that's the whole point!)"
                ),
                "task": True,
                "hint": 'Like the cheer, but range(10) and your name:  for i in range(10): print("Ada")',
                "must_use": ["for", "range"],
                "needs_print": True,
                "line_count": 10,
            },
            {
                "say": (
                    "Ten names with ONE line of code! 🤯\n"
                    "\n"
                    "That  i  is a box the loop fills with the count.\n"
                    "Try printing the count itself — and watch CLOSELY,\n"
                    "Python has a surprise for you:\n"
                    "\n"
                    "    for i in range(5): print(i)"
                ),
                "task": True,
                "hint": "Type exactly:  for i in range(5): print(i)   — no quotes around i!",
                "must_use": ["for", "range"],
                "needs_print": True,
                "output_is": "0\n1\n2\n3\n4",
            },
            {
                "say": (
                    "Did you see that?! Python starts counting at ZERO:\n"
                    "0, 1, 2, 3, 4 — that's still five numbers, but no 5!\n"
                    "Computers are funny like that. 🤖\n"
                    "\n"
                    "You can tell range where to start and where to stop:\n"
                    "\n"
                    "    range(1, 11)   counts 1, 2, 3 ... 10\n"
                    "\n"
                    "(It stops just BEFORE 11.)\n"
                    "Make Python count from 1 to 10."
                ),
                "task": True,
                "hint": "Type:  for i in range(1, 11): print(i)",
                "must_use": ["for", "range"],
                "needs_print": True,
                "output_is": "1\n2\n3\n4\n5\n6\n7\n8\n9\n10",
            },
            {
                "say": (
                    "Now for some REAL magic. 🪄\n"
                    "Do you know your times tables? The computer can write\n"
                    "the WHOLE 7 times table in one line:\n"
                    "\n"
                    "    for i in range(1, 11): print(7 * i)\n"
                    "\n"
                    "The box  i  changes every time — so  7 * i  does too!\n"
                    "Try it!"
                ),
                "task": True,
                "hint": "Type:  for i in range(1, 11): print(7 * i)",
                "must_use": ["for", "*"],
                "needs_print": True,
                "output_is": "7\n14\n21\n28\n35\n42\n49\n56\n63\n70",
            },
            {
                "say": (
                    "7, 14, 21... the whole table in a blink! 📚\n"
                    "\n"
                    "Now something the computer is SECRETLY great at:\n"
                    "rolling dice! 🎲 The dice live in a kit called  random.\n"
                    "First, grab the kit:\n"
                    "\n"
                    "    import random"
                ),
                "task": True,
                "hint": "Type:  import random",
                "must_use": ["import", "random"],
            },
            {
                "say": (
                    "Kit ready! Now roll the dice:\n"
                    "\n"
                    "    random.randint(1, 6)\n"
                    "\n"
                    "(randint = RANDom INTeger — a surprise number\n"
                    "between 1 and 6, different every time!)"
                ),
                "task": True,
                "hint": "Type:  random.randint(1, 6)",
                "must_use": ["random"],
                "expect_range": [1, 6],
                "needs_code": {"random": "import random"},
            },
            {
                "say": (
                    "🎲 Roll it again if you like — you never know what comes!\n"
                    "\n"
                    "Now roll FIVE dice at once. You know loops...\n"
                    "\n"
                    "    for i in range(5): print(random.randint(1, 6))"
                ),
                "task": True,
                "hint": "Type:  for i in range(5): print(random.randint(1, 6))",
                "must_use": ["for", "random"],
                "line_count": 5,
                "needs_code": {"random": "import random"},
            },
            {
                "say": (
                    "One last experiment: THE COUNTING MACHINE.\n"
                    "First, get a counter box ready — set it to zero:\n"
                    "\n"
                    "    score = 0"
                ),
                "task": True,
                "hint": "Type:  score = 0",
                "must_use": ["score", "="],
                "var_equals": {"score": 0},
            },
            {
                "say": (
                    "Now tell the computer to press the +1 button\n"
                    "ONE HUNDRED TIMES:\n"
                    "\n"
                    "    for i in range(100): score = score + 1\n"
                    "\n"
                    "Then we'll peek inside the box together..."
                ),
                "task": True,
                "hint": "Type:  for i in range(100): score = score + 1",
                "must_use": ["for", "score", "+"],
                "var_equals": {"score": 100},
                "needs": {"score": 0},
            },
            {
                "say": (
                    "It clicked the button 100 times in a BLINK! ⚡\n"
                    "\n"
                    "🎉🎉🎉  SECTION 4: DONE!  🎉🎉🎉\n"
                    "\n"
                    "  ✅ for  repeats an exact number of times\n"
                    "  ✅ the loop box  i  counts for you\n"
                    "  ✅ random.randint rolls dice 🎲\n"
                    "  ✅ loops + boxes = a counting machine\n"
                    "\n"
                    "Next up: programs that LISTEN to you. See you there!"
                ),
            },
        ],
    },
    {
        "title": "Input — the computer asks YOU",
        "lessons": [
            {
                "say": (
                    "So far, YOU type and the computer answers.\n"
                    "Time to flip it around! 🙃\n"
                    "\n"
                    "Your programs can ASK QUESTIONS and wait for a reply.\n"
                    "The magic word is  input  — it makes the computer stop\n"
                    "and LISTEN until you type something and press Enter."
                ),
            },
            {
                "say": (
                    "Try it! Type:\n"
                    "\n"
                    "    answer = input()\n"
                    "\n"
                    "The screen will go quiet — that's the computer WAITING\n"
                    "for you. Type your favorite food and press Enter!"
                ),
                "task": True,
                "hint": ("First type  answer = input()  and press Enter.\n"
                         "     Then the computer waits — type any word you like!"),
                "must_use": ["answer", "input"],
                "defines": {"answer": "string"},
            },
            {
                "say": (
                    "The computer caught your word and put it in the box!\n"
                    "Now make it say your word back:\n"
                    "\n"
                    "    print(answer)"
                ),
                "task": True,
                "hint": "Type:  print(answer)   — no quotes, it's a box!",
                "must_use": ["answer"],
                "needs_print": True,
                "output_has_var": "answer",
                "needs": {"answer": "pizza"},
            },
            {
                "say": (
                    "It listened AND remembered. 👂\n"
                    "\n"
                    "input can also ASK the question for you —\n"
                    "put the question inside, in quotes:\n"
                    "\n"
                    '    name = input("What is your name? ")\n'
                    "\n"
                    "Try it — and tell it your real name!"
                ),
                "task": True,
                "hint": 'Type:  name = input("What is your name? ")  — then answer it!',
                "must_use": ["name", "input"],
                "defines": {"name": "string"},
            },
            {
                "say": (
                    "Now greet yourself like an old friend:\n"
                    "\n"
                    '    print("Hello", name)'
                ),
                "task": True,
                "hint": 'Type:  print("Hello", name)',
                "must_use": ["name"],
                "needs_print": True,
                "output_has_var": "name",
                "needs": {"name": "friend"},
            },
            {
                "say": (
                    "Now, a trap every programmer falls into once. ⚠️\n"
                    "input ALWAYS hands you WORDS. If you type 7,\n"
                    "you get the WORD '7' — and words can't do math!\n"
                    "\n"
                    "To get a real NUMBER, wrap the input in  int(...):\n"
                    "\n"
                    '    age = int(input("How old are you? "))\n'
                    "\n"
                    "Try it — and answer with your age!"
                ),
                "task": True,
                "hint": ('Type:  age = int(input("How old are you? "))\n'
                         "     int turns the words you type into a real number."),
                "must_use": ["age", "int", "input"],
                "defines": {"age": "number"},
            },
            {
                "say": (
                    "A real NUMBER came through. Prove it — do math on it:\n"
                    "\n"
                    "    print(age * 365)\n"
                    "\n"
                    "(Your age in days — but this time the computer ASKED you!)"
                ),
                "task": True,
                "hint": "Type:  print(age * 365)",
                "must_use": ["age", "*"],
                "needs_print": True,
                "needs": {"age": 9},
            },
            {
                "say": (
                    "Time to upgrade the SECRET CLUB DOOR. 🚪\n"
                    "Before, the password lived in a box.\n"
                    "Now the door can ASK for it, all by itself:\n"
                    "\n"
                    '    if input("Password? ") == "octopus": print("Welcome inside!")\n'
                    "\n"
                    "Run it — and whisper the right word..."
                ),
                "task": True,
                "hint": ('Type:  if input("Password? ") == "octopus": print("Welcome inside!")\n'
                         "     Then answer with:  octopus"),
                "must_use": ["if", "input", "=="],
                "needs_print": True,
                "quiet_hint": ("The door stayed shut — the password didn't match!\n"
                               "  Run it again and type  octopus  exactly."),
            },
            {
                "say": (
                    "🎉🎉🎉  SECTION 5: DONE!  🎉🎉🎉\n"
                    "\n"
                    "Your programs can LISTEN now:\n"
                    "  ✅ answer = input()  waits for typing\n"
                    '  ✅ input("question?")  asks first, then waits\n'
                    "  ✅ int(input())  turns the answer into a real number\n"
                    "  ✅ whatever you type lands in the box\n"
                    "\n"
                    "That's what makes programs feel ALIVE — they talk\n"
                    "with you. Next: loops with a brain!"
                ),
            },
        ],
    },
    {
        "title": "While — the loop with a brain",
        "lessons": [
            {
                "say": (
                    "You know  for  — it repeats an EXACT number of times.\n"
                    "But sometimes you don't know how many times you need!\n"
                    "\n"
                    "  while  repeats AS LONG AS something is true.\n"
                    "Read it like: WHILE the cup is full, keep drinking.\n"
                    "\n"
                    "⚠️ One warning before we start: if the thing is ALWAYS\n"
                    "true, the loop NEVER stops! If your computer ever gets\n"
                    "stuck, hold  Ctrl  and press  C  to rescue it."
                ),
            },
            {
                "say": (
                    "Let's launch a rocket! 🚀\n"
                    "First we need the countdown box:\n"
                    "\n"
                    "    count = 10"
                ),
                "task": True,
                "hint": "Type:  count = 10",
                "must_use": ["count", "="],
                "var_equals": {"count": 10},
            },
            {
                "say": (
                    "Now the countdown. The loop has TWO jobs — say the\n"
                    "number, then make it smaller. A semicolon  ;  glues\n"
                    "two jobs into one line:\n"
                    "\n"
                    "    while count > 0: print(count); count = count - 1\n"
                    "\n"
                    "Read it: WHILE count is bigger than 0 — say it, shrink it."
                ),
                "task": True,
                "hint": "Type:  while count > 0: print(count); count = count - 1",
                "must_use": ["while", ">", "-"],
                "output_is": "10\n9\n8\n7\n6\n5\n4\n3\n2\n1",
                "var_equals": {"count": 0},
                "needs": {"count": 10},
            },
            {
                "say": (
                    "...3, 2, 1 — and the loop stopped BY ITSELF, because\n"
                    "count reached 0 and '0 > 0' is false. Smart loop!\n"
                    "\n"
                    "The rocket is ready. Shout the magic words:\n"
                    "\n"
                    '    print("BLAST OFF! 🚀")'
                ),
                "task": True,
                "hint": 'Type:  print("BLAST OFF! 🚀")   (or any launch shout you like)',
                "needs_print": True,
            },
            {
                "say": (
                    "Here's an old riddle. Would you rather have 100 coins\n"
                    "right now... or ONE magic coin that DOUBLES every day?\n"
                    "\n"
                    "Let's find out! Start with one coin:\n"
                    "\n"
                    "    money = 1"
                ),
                "task": True,
                "hint": "Type:  money = 1",
                "must_use": ["money", "="],
                "var_equals": {"money": 1},
            },
            {
                "say": (
                    "Now keep doubling it UNTIL it beats 100:\n"
                    "\n"
                    "    while money < 100: money = money * 2\n"
                    "\n"
                    "How big will it get? Make a guess... then run it!"
                ),
                "task": True,
                "hint": "Type:  while money < 100: money = money * 2",
                "must_use": ["while", "<", "*"],
                "var_equals": {"money": 128},
                "needs": {"money": 1},
            },
            {
                "say": (
                    "128! It blew past 100 in just 7 doublings. 🪙✨\n"
                    "That's why grown-ups whisper: 'doubling is POWERFUL.'\n"
                    "\n"
                    "🎉🎉🎉  SECTION 6: DONE!  🎉🎉🎉\n"
                    "\n"
                    "  ✅ while repeats AS LONG AS something is true\n"
                    "  ✅ the loop must CHANGE something, or it never ends\n"
                    "  ✅ Ctrl + C rescues a stuck computer\n"
                    "\n"
                    "Next, the greatest superpower of all!"
                ),
            },
        ],
    },
    {
        "title": "Functions — teach it new words",
        "lessons": [
            {
                "say": (
                    "The next superpower: teaching the computer NEW WORDS. 🧙\n"
                    "\n"
                    "The computer knows  print. It knows  input.\n"
                    "But it doesn't know  cheer  — until YOU teach it!\n"
                    "\n"
                    "A new word is called a FUNCTION, and you teach it\n"
                    "with  def  (short for 'define'):\n"
                    "\n"
                    '    def cheer(): print("Hip hip hooray!")'
                ),
            },
            {
                "say": (
                    "Teach your computer to cheer! Type:\n"
                    "\n"
                    '    def cheer(): print("Hip hip hooray!")\n'
                    "\n"
                    "Watch closely: NOTHING will happen. That's right —\n"
                    "you're only TEACHING the word, not saying it yet."
                ),
                "task": True,
                "hint": 'Type:  def cheer(): print("Hip hip hooray!")',
                "must_use": ["def", "cheer", "print"],
                "defines": {"cheer": "function"},
            },
            {
                "say": (
                    "The computer knows a new word! Now SAY it.\n"
                    "To use a function, say its name with parentheses:\n"
                    "\n"
                    "    cheer()"
                ),
                "task": True,
                "hint": "Type:  cheer()   — don't forget the parentheses!",
                "must_use": ["cheer()"],
                "line_count": 1,
                "needs_code": {"cheer": 'def cheer(): print("Hip hip hooray!")'},
            },
            {
                "say": (
                    "One word, and it did the whole job! 🎺\n"
                    "\n"
                    "Now combine your superpowers. Remember loops?\n"
                    "Make the computer cheer FIVE times... using your new word!"
                ),
                "task": True,
                "hint": "A loop that calls your word:  for i in range(5): cheer()",
                "must_use": ["for", "cheer()"],
                "line_count": 5,
                "needs_code": {"cheer": 'def cheer(): print("Hip hip hooray!")'},
            },
            {
                "say": (
                    "Functions can take an INGREDIENT — you hand them\n"
                    "something to work with, inside the parentheses:\n"
                    "\n"
                    '    def greet(name): print("Hello", name)\n'
                    "\n"
                    "Teach your computer to greet!"
                ),
                "task": True,
                "hint": 'Type:  def greet(name): print("Hello", name)',
                "must_use": ["def", "greet", "name"],
                "defines": {"greet": "function"},
            },
            {
                "say": (
                    "Now greet someone! Hand a name to your function:\n"
                    "\n"
                    '    greet("Ada")\n'
                    "\n"
                    "(Try your own name, or a friend's!)"
                ),
                "task": True,
                "hint": 'Type:  greet("Ada")  — any name you like, in quotes',
                "must_use": ["greet("],
                "line_count": 1,
                "needs_code": {"greet": 'def greet(name): print("Hello", name)'},
            },
            {
                "say": (
                    "One more trick: a function can hand an answer BACK,\n"
                    "like a little math machine. The word is  return:\n"
                    "\n"
                    "    def double(n): return n * 2\n"
                    "\n"
                    "Teach it!"
                ),
                "task": True,
                "hint": "Type:  def double(n): return n * 2",
                "must_use": ["def", "double", "return", "*"],
                "defines": {"double": "function"},
                "call_test": ["double(5)", 10],
            },
            {
                "say": (
                    "Your machine works — I tested it while you weren't\n"
                    "looking: double(5) gave 10. 😉\n"
                    "\n"
                    "Now feed the machine into ITSELF:\n"
                    "\n"
                    "    double(double(5))\n"
                    "\n"
                    "What will THAT give? Guess first, then try it!"
                ),
                "task": True,
                "hint": "Type:  double(double(5))   — double of double of 5!",
                "must_use": ["double"],
                "expect": 20,
                "needs_code": {"double": "def double(n): return n * 2"},
            },
            {
                "say": (
                    "🎉🎉🎉  SECTION 7: DONE — AND SOMETHING BIGGER!  🎉🎉🎉\n"
                    "\n"
                    "You've collected ALL SEVEN superpowers:\n"
                    "  ✅ calculate  (+ - *)\n"
                    "  ✅ talk       (print)\n"
                    "  ✅ remember   (variables)\n"
                    "  ✅ decide     (if)\n"
                    "  ✅ repeat     (for and while)\n"
                    "  ✅ listen     (input)\n"
                    "  ✅ learn new words  (def)\n"
                    "\n"
                    "And now comes the BEST part. No more practice —\n"
                    "it's time to BUILD. Three real projects are waiting:\n"
                    "a game, a story machine, and a robot doorkeeper.\n"
                    "\n"
                    "Grab your superpowers. Let's make something! 🔨"
                ),
            },
        ],
    },
    {
        "title": "Project: The Number Wizard",
        "lessons": [
            {
                "say": (
                    "PROJECT TIME! 🔨\n"
                    "No more practice — you're going to BUILD A REAL GAME.\n"
                    "\n"
                    "🔮 THE NUMBER WIZARD 🔮\n"
                    "The wizard (your computer) thinks of a secret number\n"
                    "from 1 to 10. You try to read its mind.\n"
                    "\n"
                    "Every game is built piece by piece. Let's go."
                ),
            },
            {
                "say": (
                    "First, the wizard needs a SECRET. The dice kit can\n"
                    "pick a number nobody sees — not even you:\n"
                    "\n"
                    "    secret = random.randint(1, 10)"
                ),
                "task": True,
                "hint": "Type:  secret = random.randint(1, 10)",
                "must_use": ["secret", "random"],
                "defines": {"secret": "number"},
                "hide_box": True,
                "needs_code": {"random": "import random"},
            },
            {
                "say": (
                    "The wizard is hiding its number... Time to guess!\n"
                    "Ask the player (that's you!) for a number:\n"
                    "\n"
                    '    guess = int(input("Your guess, brave one? "))'
                ),
                "task": True,
                "hint": 'Type:  guess = int(input("Your guess, brave one? "))  — then answer!',
                "must_use": ["guess", "int", "input"],
                "defines": {"guess": "number"},
                "needs": {"secret": 7},
                "needs_code": {"random": "import random"},
            },
            {
                "say": (
                    "Now the wizard drops hints. Was the guess too small?\n"
                    "\n"
                    '    if guess < secret: print("Too small, mortal!")'
                ),
                "task": True,
                "hint": 'Type:  if guess < secret: print("Too small, mortal!")',
                "must_use": ["if", "<", "print"],
                "needs": {"secret": 7, "guess": 3},
            },
            {
                "say": (
                    "And the other hint — was it too big?\n"
                    "\n"
                    '    if guess > secret: print("Too big, mortal!")'
                ),
                "task": True,
                "hint": 'Type:  if guess > secret: print("Too big, mortal!")',
                "must_use": ["if", ">", "print"],
                "needs": {"secret": 7, "guess": 3},
            },
            {
                "say": (
                    "And the moment of glory — the winning check:\n"
                    "\n"
                    '    if guess == secret: print("YOU READ MY MIND!")'
                ),
                "task": True,
                "hint": 'Type:  if guess == secret: print("YOU READ MY MIND!")',
                "must_use": ["if", "==", "print"],
                "needs": {"secret": 7, "guess": 3},
            },
            {
                "say": (
                    "You just played one round BY HAND — guess, hints, check.\n"
                    "That's exactly what a game is!\n"
                    "\n"
                    "But real games run by THEMSELVES. Remember  while  and\n"
                    "!=  ? The game keeps asking UNTIL you crack it.\n"
                    "Let's build the whole thing."
                ),
            },
            {
                "say": (
                    "Fresh game, fresh secret:\n"
                    "\n"
                    "    secret = random.randint(1, 10)"
                ),
                "task": True,
                "hint": "Type:  secret = random.randint(1, 10)",
                "must_use": ["secret", "random"],
                "defines": {"secret": "number"},
                "hide_box": True,
                "needs_code": {"random": "import random"},
            },
            {
                "say": (
                    "And now — THE GAME. One line. while keeps asking\n"
                    "as long as your answer is DIFFERENT from the secret:\n"
                    "\n"
                    '    while int(input("Guess? ")) != secret: print("Not it... again!")\n'
                    "\n"
                    "Type it, then PLAY until you read the wizard's mind!"
                ),
                "task": True,
                "hint": ('Type:  while int(input("Guess? ")) != secret: print("Not it... again!")\n'
                         "     Then keep guessing numbers from 1 to 10!"),
                "must_use": ["while", "int", "input", "!="],
                "needs": {"secret": 7},
            },
            {
                "say": (
                    "You escaped the loop — that means YOU GOT IT! 🧠⚡\n"
                    "Take your victory lap:\n"
                    "\n"
                    '    print("I DEFEATED THE NUMBER WIZARD! 🔮")'
                ),
                "task": True,
                "hint": 'Type:  print("I DEFEATED THE NUMBER WIZARD! 🔮")',
                "needs_print": True,
            },
            {
                "say": (
                    "🎉🎉🎉  PROJECT #1 COMPLETE!  🎉🎉🎉\n"
                    "\n"
                    "You built a REAL game, with:\n"
                    "  🎲 a random secret      (random.randint)\n"
                    "  👂 a listening player   (int + input)\n"
                    "  🚦 wizard hints         (if < > ==)\n"
                    "  🔁 a game loop          (while !=)\n"
                    "\n"
                    "Challenge a family member to play YOUR game.\n"
                    "Next project: a machine that writes stories!"
                ),
            },
        ],
    },
    {
        "title": "Project: The Silly Story Machine",
        "lessons": [
            {
                "say": (
                    "Project #2: 📖 THE SILLY STORY MACHINE 📖\n"
                    "\n"
                    "This machine collects a few words from a human...\n"
                    "then writes a story NOBODY could predict.\n"
                    "\n"
                    "The trick: the machine asks WITHOUT telling you\n"
                    "what the story will be. Let's collect the parts!"
                ),
            },
            {
                "say": (
                    "Part one — the machine needs an animal:\n"
                    "\n"
                    '    animal = input("An animal, please? ")'
                ),
                "task": True,
                "hint": 'Type:  animal = input("An animal, please? ")  — then answer it!',
                "must_use": ["animal", "input"],
                "defines": {"animal": "string"},
            },
            {
                "say": (
                    "Part two — every good story has food:\n"
                    "\n"
                    '    food = input("A food, please? ")'
                ),
                "task": True,
                "hint": 'Type:  food = input("A food, please? ")',
                "must_use": ["food", "input"],
                "defines": {"food": "string"},
            },
            {
                "say": (
                    "Part three — a hero:\n"
                    "\n"
                    "    friend = input(\"A friend's name? \")"
                ),
                "task": True,
                "hint": "Type:  friend = input(\"A friend's name? \")",
                "must_use": ["friend", "input"],
                "defines": {"friend": "string"},
            },
            {
                "say": (
                    "All parts collected! Now GLUE them into a story\n"
                    "with  +  — remember your royal title?\n"
                    "\n"
                    '    story = "The " + animal + " ate " + food + " with " + friend\n'
                    "\n"
                    "(Watch the spaces inside the quotes!)"
                ),
                "task": True,
                "hint": ('Type:  story = "The " + animal + " ate " + food + " with " + friend'),
                "must_use": ["story", "+", "animal", "food", "friend"],
                "defines": {"story": "string"},
                "needs": {"animal": "dragon", "food": "pizza", "friend": "Ada"},
            },
            {
                "say": (
                    "The story is in the box... Read it aloud, machine!\n"
                    "\n"
                    "    print(story)"
                ),
                "task": True,
                "hint": "Type:  print(story)",
                "must_use": ["story"],
                "needs_print": True,
                "output_has_var": "story",
                "needs": {"story": "The dragon ate pizza with Ada"},
            },
            {
                "say": (
                    "😂 Every great story deserves an ENCORE.\n"
                    "Tell it three times, like a proper storyteller:\n"
                    "\n"
                    "    for i in range(3): print(story)"
                ),
                "task": True,
                "hint": "Type:  for i in range(3): print(story)",
                "must_use": ["for", "story"],
                "line_count": 3,
                "needs": {"story": "The dragon ate pizza with Ada"},
            },
            {
                "say": (
                    "🎉🎉🎉  PROJECT #2 COMPLETE!  🎉🎉🎉\n"
                    "\n"
                    "Your machine:\n"
                    "  👂 collects words     (input)\n"
                    "  🧠 remembers them     (variables)\n"
                    "  🧵 glues a story      (+)\n"
                    "  📣 performs it        (print + for)\n"
                    "\n"
                    "Run it again with sillier words — new story every time!\n"
                    "One project left: the grand finale. 🚪"
                ),
            },
        ],
    },
    {
        "title": "Project: The Club Doorkeeper",
        "lessons": [
            {
                "say": (
                    "THE FINAL PROJECT: 🚪🤖 THE CLUB DOORKEEPER 🤖🚪\n"
                    "\n"
                    "The secret octopus club needs a robot to guard the door.\n"
                    "It must: greet visitors, demand the password FOREVER\n"
                    "until it's right, and throw a party for members.\n"
                    "\n"
                    "This build uses EVERY superpower you have. Ready?"
                ),
            },
            {
                "say": (
                    "First, teach the robot its party trick:\n"
                    "\n"
                    '    def party(): print("🎉 WELCOME TO THE SECRET CLUB! 🎉")'
                ),
                "task": True,
                "hint": 'Type:  def party(): print("🎉 WELCOME TO THE SECRET CLUB! 🎉")',
                "must_use": ["def", "party", "print"],
                "defines": {"party": "function"},
            },
            {
                "say": (
                    "The robot knows how to party. 🤖\n"
                    "Now it should ask who's knocking:\n"
                    "\n"
                    '    visitor = input("Who knocks at the door? ")'
                ),
                "task": True,
                "hint": 'Type:  visitor = input("Who knocks at the door? ")  — then knock!',
                "must_use": ["visitor", "input"],
                "defines": {"visitor": "string"},
            },
            {
                "say": (
                    "A polite robot greets by name — glue it:\n"
                    "\n"
                    '    print("Greetings, " + visitor + "!")'
                ),
                "task": True,
                "hint": 'Type:  print("Greetings, " + visitor + "!")',
                "must_use": ["visitor", "+"],
                "needs_print": True,
                "output_has_var": "visitor",
                "needs": {"visitor": "Ada"},
            },
            {
                "say": (
                    "Now THE UNBREAKABLE DOOR. It asks for the secret word\n"
                    "again and again and AGAIN — until it hears it:\n"
                    "\n"
                    '    while input("Secret word? ") != "octopus": print("WRONG! The door stays shut.")\n'
                    "\n"
                    "Type it — then try a few wrong words before the right one,\n"
                    "just to feel the door's power. 😈"
                ),
                "task": True,
                "hint": ('Type:  while input("Secret word? ") != "octopus": print("WRONG! The door stays shut.")\n'
                         "     The secret word is  octopus  — but try wrong ones first!"),
                "must_use": ["while", "input", "!="],
            },
            {
                "say": (
                    "The door swings open... and the robot does its thing:\n"
                    "\n"
                    "    party()"
                ),
                "task": True,
                "hint": "Type:  party()",
                "must_use": ["party()"],
                "line_count": 1,
                "needs_code": {"party": 'def party(): print("🎉 WELCOME TO THE SECRET CLUB! 🎉")'},
            },
            {
                "say": (
                    "But wait — a proper welcome needs MORE party:\n"
                    "\n"
                    "    for i in range(3): party()"
                ),
                "task": True,
                "hint": "Type:  for i in range(3): party()",
                "must_use": ["for", "party()"],
                "line_count": 3,
                "needs_code": {"party": 'def party(): print("🎉 WELCOME TO THE SECRET CLUB! 🎉")'},
            },
            {
                "say": (
                    "🎉🎉🎉  ALL THREE PROJECTS COMPLETE!  🎉🎉🎉\n"
                    "\n"
                    "Look at what you BUILT:\n"
                    "  🔮 a mind-reading game\n"
                    "  📖 a story-writing machine\n"
                    "  🤖 a robot doorkeeper\n"
                    "\n"
                    "...using calculating, talking, remembering, deciding,\n"
                    "repeating, listening, and words YOU taught the computer.\n"
                    "\n"
                    "There's just one thing left to do before you go:\n"
                    "GRADUATION. 🎓 See you in the final section!"
                ),
            },
        ],
    },
    {
        "title": "Graduation — programs of your own",
        "lessons": [
            {
                "say": (
                    "🎓 Welcome to GRADUATION. 🎓\n"
                    "\n"
                    "Here's the last secret Gray has been keeping:\n"
                    "everything you typed here was REAL Python — but real\n"
                    "programmers don't type one line at a time forever.\n"
                    "They save MANY lines in a FILE, and the computer runs\n"
                    "the whole file, top to bottom, in one go.\n"
                    "\n"
                    "In fact... Gray itself is just a file like that! You've\n"
                    "been running it all along:  python gray.py\n"
                    "\n"
                    "So for your final challenge, we'll build YOUR OWN file:\n"
                    "    my_first_program.py\n"
                    "Every line you type now gets SAVED into it. Let's go!"
                ),
            },
            {
                "say": (
                    "Every great program starts with a proud announcement:\n"
                    "\n"
                    '    print("This program was written by ME!")'
                ),
                "task": True,
                "hint": 'Type:  print("This program was written by ME!")  — or your own words!',
                "needs_print": True,
                "append_to_file": "my_first_program.py",
                "start_file": True,
            },
            {
                "say": (
                    "Saved! ✏️  Now make your program ask who's there:\n"
                    "\n"
                    '    name = input("What is your name? ")'
                ),
                "task": True,
                "hint": 'Type:  name = input("What is your name? ")  — then answer it!',
                "must_use": ["name", "input"],
                "defines": {"name": "string"},
                "append_to_file": "my_first_program.py",
            },
            {
                "say": (
                    "And greet them properly, with glue:\n"
                    "\n"
                    '    print("Hello " + name + "!")'
                ),
                "task": True,
                "hint": 'Type:  print("Hello " + name + "!")',
                "must_use": ["name", "+"],
                "needs_print": True,
                "output_has_var": "name",
                "needs": {"name": "friend"},
                "append_to_file": "my_first_program.py",
            },
            {
                "say": (
                    "Now some celebration — a loop, of course:\n"
                    "\n"
                    '    for i in range(3): print("Hip hip hooray!")'
                ),
                "task": True,
                "hint": 'Type:  for i in range(3): print("Hip hip hooray!")',
                "must_use": ["for"],
                "line_count": 3,
                "append_to_file": "my_first_program.py",
            },
            {
                "say": (
                    "And every story needs an ending:\n"
                    "\n"
                    '    print("THE END")'
                ),
                "task": True,
                "hint": 'Type:  print("THE END")',
                "needs_print": True,
                "append_to_file": "my_first_program.py",
            },
            {
                "say": (
                    "🎁 Your program is complete! It's saved in a real file\n"
                    "called  my_first_program.py  — sitting right next to\n"
                    "gray.py on your computer.\n"
                    "\n"
                    "HERE'S HOW TO RUN IT:\n"
                    "  1. Type  quit  to say goodbye to Gray\n"
                    "  2. In the same terminal window, type:\n"
                    "\n"
                    "         python my_first_program.py\n"
                    "\n"
                    "  3. Watch YOUR program run, top to bottom!\n"
                    "\n"
                    "And here's the best part: open my_first_program.py in\n"
                    "any text editor. Change the words. Add more lines.\n"
                    "Run it again. THAT is programming."
                ),
            },
            {
                "say": (
                    "One more secret before you graduate. 🤫\n"
                    "\n"
                    "You don't even need a file — or Gray! If you type just\n"
                    "\n"
                    "         python\n"
                    "\n"
                    "in the terminal (no file name), Python itself answers\n"
                    "with its own prompt:  >>>\n"
                    "\n"
                    "That's called the REPL — a place to talk to Python\n"
                    "directly, one line at a time. Sound familiar? It's\n"
                    "exactly what the  you>  prompt has been all along!\n"
                    "Try  2 + 2  in there. Old friends. 😉\n"
                    "\n"
                    "(To leave the REPL, type  exit()  and press Enter.)"
                ),
            },
            {
                "say": (
                    "🎓🎓🎓  YOU FINISHED THE WHOLE COURSE!  🎓🎓🎓\n"
                    "\n"
                    "You can now:\n"
                    "  ✅ write real Python, line by line\n"
                    "  ✅ build games, machines, and robots\n"
                    "  ✅ save programs in files and run them:\n"
                    "         python my_first_program.py\n"
                    "  ✅ talk to Python directly in the REPL:  python\n"
                    "\n"
                    "Here's the biggest secret of all: every program ever\n"
                    "written — games, robots, rockets — is built from\n"
                    "exactly the pieces you now hold.\n"
                    "\n"
                    "Gray is SO proud of you.\n"
                    "THE END... or really: THE BEGINNING. 🐘💙"
                ),
            },
        ],
    },
]

# ---------------------------------------------------------------------------
# Running the student's code
# ---------------------------------------------------------------------------

NO_VALUE = object()
STUDENT_ENV = {}  # shared between lessons, so later sections can use variables


def run_code(source):
    """Run one line of student code. Returns (value, printed_output, error).

    The student gets their own print (shown live AND recorded for the
    checks) and their own input (so prompts appear before the wait).
    """
    captured = []

    def student_print(*args, sep=" ", end="\n"):
        text = sep.join(str(a) for a in args)
        captured.append(text)
        say(f"  {bold('🖥  ' + text)}")

    def student_input(prompt=""):
        try:
            return input(str(prompt))
        except EOFError:
            return ""

    STUDENT_ENV["print"] = student_print
    STUDENT_ENV["input"] = student_input

    value, error = NO_VALUE, None
    try:
        value = eval(source, STUDENT_ENV)
    except SyntaxError:
        try:
            exec(source, STUDENT_ENV)
        except KeyboardInterrupt:
            error = "That was taking FOREVER, so I stopped it. Phew!"
        except Exception as exc:
            error = exc
    except KeyboardInterrupt:
        error = "That was taking FOREVER, so I stopped it. Phew!"
    except Exception as exc:
        error = exc
    return value, "\n".join(captured), error


def show_value(v):
    return f'"{v}"' if isinstance(v, str) else repr(v)


def check(lesson, source, value, output, error):
    """Decide if the student's code solves the task. Returns (ok, feedback)."""
    if error is not None:
        return False, (f"Oops — the computer got confused:\n     {dim(str(error))}\n"
                       "  No problem, that happens to every programmer. Try again!")
    for needed in lesson.get("must_use", []):
        if needed not in source:
            if needed in ("+", "-", "*", "/"):
                return False, (f"You're allowed to know the answer — but let the COMPUTER "
                               f"do the work!\n  Use the  {needed}  sign in your code.")
            return False, f"Your code should use  {needed}  — check the challenge again!"
    if lesson.get("needs_print"):
        if "print" not in source:
            return False, "Use print( ... ) to make the computer talk!"
        if output.strip() == "":
            return False, lesson.get("quiet_hint",
                          "Hmm, the computer stayed quiet. Put the words you want\n"
                          '  inside the parentheses:  print("like this")')
    if lesson.get("expect_silence") and output.strip() != "":
        return False, ("The computer spoke! But the answer to this question is NO —\n"
                       "  so it should do NOTHING. Check your numbers!")
    if "output_is" in lesson and output.strip() != lesson["output_is"]:
        if "\n" in lesson["output_is"]:
            return False, ("Close, but that's not quite the list I wanted!\n"
                           "  Look at the FIRST number and the LAST number — then try again.")
        return False, (f"The computer said '{output.strip()}', but I expected "
                       f"'{lesson['output_is']}'.\n  Check the challenge again!")
    if "line_count" in lesson:
        count = len([l for l in output.splitlines() if l.strip()])
        if count != lesson["line_count"]:
            return False, (f"The computer said it {count} time(s) — I wanted "
                           f"{lesson['line_count']} times!\n"
                           "  Check the number in your loop and try again!")
    if "output_has_var" in lesson:
        box = lesson["output_has_var"]
        if str(STUDENT_ENV.get(box, "")) not in output:
            return False, (f"I wanted to hear what's inside the '{box}' box!\n"
                           "  Glue it into your message — check the example again.")
    for box, kind in lesson.get("defines", {}).items():
        if box not in STUDENT_ENV:
            return False, (f"I don't see a box called '{box}' yet.\n"
                           f"  Make one with the = sign, like:  {box} = ...")
        val = STUDENT_ENV[box]
        if kind == "number" and not isinstance(val, (int, float)):
            return False, (f"The box '{box}' needs a NUMBER inside.\n"
                           "  Numbers don't need quotes!")
        if kind == "string" and not isinstance(val, str):
            return False, (f"The box '{box}' needs WORDS inside.\n"
                           '  Words need quotes, like  "this"!')
        if kind == "function" and not callable(val):
            return False, (f"'{box}' should be a new WORD the computer learns.\n"
                           f"  Teach it with:  def {box}(): ...")
    for box, want in lesson.get("var_equals", {}).items():
        if box not in STUDENT_ENV:
            return False, (f"I don't see a box called '{box}' yet.\n"
                           f"  Make one with the = sign, like:  {box} = ...")
        if STUDENT_ENV[box] != want:
            return False, (f"I peeked inside '{box}' and found {show_value(STUDENT_ENV[box])},\n"
                           f"  but I expected {show_value(want)}. Try again!")
    if "expect_range" in lesson:
        lo, hi = lesson["expect_range"]
        got = None
        if isinstance(value, (int, float)) and not isinstance(value, bool):
            got = value
        elif output.strip().lstrip("-").isdigit():
            got = int(output.strip())
        if got is None or not (lo <= got <= hi):
            shown = "nothing" if value is NO_VALUE and not output.strip() else \
                (output.strip() or show_value(value))
            return False, (f"I expected a number between {lo} and {hi}, but I got "
                           f"{shown}.\n  Check the challenge and try again!")
    if "call_test" in lesson:
        expr, want = lesson["call_test"]
        try:
            got = eval(expr, STUDENT_ENV)
        except Exception as exc:
            return False, (f"I tried  {expr}  but it broke:\n     {dim(str(exc))}\n"
                           "  Check your function and try again!")
        if got != want:
            shown = "nothing" if got is None else show_value(got)
            return False, (f"I tried  {expr}  and got {shown} — I expected "
                           f"{show_value(want)}.\n  Check your function and try again!")
    if "expect_expr" in lesson:
        want = eval(lesson["expect_expr"], STUDENT_ENV)
        if value != want and output.strip() != str(want):
            shown = "nothing" if value is NO_VALUE else show_value(value)
            return False, (f"The computer answered {shown} — not what I was looking for.\n"
                           "  Check your boxes and try again!")
    if "expect" in lesson and value != lesson["expect"]:
        shown = "nothing" if value is NO_VALUE else repr(value)
        return False, (f"The computer answered {shown} — not what I was looking for.\n"
                       "  Check your numbers and try again!")
    return True, ""


PRAISE = ["Perfect!", "You got it!", "Exactly right!", "Amazing!", "That's it!",
          "Wow, nice work!", "Correct!", "You're a natural!"]


def add_to_script(lesson, source):
    """Save the student's line into their very own script file."""
    target = lesson.get("append_to_file")
    if not target:
        return
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), target)
    try:
        with open(path, "w" if lesson.get("start_file") else "a") as fh:
            if lesson.get("start_file"):
                fh.write("# My first program — written with Gray 🐘\n")
            fh.write(source + "\n")
        say(dim(f"  📝 line saved to  {target}"))
    except OSError:
        pass


def do_task(lesson, praise_index):
    """Let the student try until they solve it. Returns 'done', 'menu' or 'quit'."""
    while True:
        try:
            typed = input(magenta("  you> ")).strip()
        except (EOFError, KeyboardInterrupt):
            return "quit"

        if typed == "":
            continue
        low = typed.lower()
        if low in ("quit", "exit"):
            return "quit"
        if low == "menu":
            return "menu"
        if low == "hint":
            say(cyan(f"\n  💡 {lesson.get('hint', 'No hint here — you can do it!')}\n"))
            continue
        if low == "skip":
            say(dim("\n  Skipped! (You can come back to it from the menu.)\n"))
            return "done"

        snapshot = dict(STUDENT_ENV)  # a failed try must not change the boxes
        value, output, error = run_code(typed)
        if value is not NO_VALUE and value is not None and error is None:
            say(f"  {bold('= ' + repr(value))}")

        ok, feedback = check(lesson, typed, value, output, error)
        if ok:
            add_to_script(lesson, typed)
            for box in list(lesson.get("defines", {})) + list(lesson.get("var_equals", {})):
                if callable(STUDENT_ENV[box]):
                    say(dim(f"  ✨ new word learned:  {box}()"))
                elif lesson.get("hide_box"):
                    say(dim(f"  📦 {box} = ✨ shhh... it's a secret! ✨"))
                else:
                    say(dim(f"  📦 {box} = {show_value(STUDENT_ENV[box])}"))
            cheer(PRAISE[praise_index % len(PRAISE)])
            return "done"
        STUDENT_ENV.clear()
        STUDENT_ENV.update(snapshot)
        nudge(feedback)


def wait_for_enter():
    try:
        input(dim("        (press Enter to continue)"))
        return "done"
    except (EOFError, KeyboardInterrupt):
        return "quit"

# ---------------------------------------------------------------------------
# Progress
# ---------------------------------------------------------------------------

def load_progress():
    try:
        with open(PROGRESS_FILE) as fh:
            data = json.load(fh)
            return int(data["section"]), int(data["lesson"])
    except Exception:
        return 0, 0


def save_progress(section, lesson):
    try:
        with open(PROGRESS_FILE, "w") as fh:
            json.dump({"section": section, "lesson": lesson}, fh)
    except OSError:
        pass

# ---------------------------------------------------------------------------
# Menu and main loop
# ---------------------------------------------------------------------------

def show_menu(current_section):
    banner("Gray — Python course")
    for i, section in enumerate(SECTIONS):
        number = f"{i + 1}."
        if section.get("coming_soon"):
            say(dim(f"   🔒 {number} {section['title']}  (coming soon)"))
        elif i < current_section:
            say(green(f"   ✅ {number} {section['title']}"))
        elif i == current_section:
            say(bold(f"   👉 {number} {section['title']}"))
        else:
            say(f"      {number} {section['title']}")
    say()
    try:
        choice = input("  Pick a number, or press Enter to continue: ").strip()
    except (EOFError, KeyboardInterrupt):
        return "quit"
    if choice.lower() in ("quit", "exit"):
        return "quit"
    if choice.isdigit() and 1 <= int(choice) <= len(SECTIONS):
        picked = int(choice) - 1
        if SECTIONS[picked].get("coming_soon"):
            say(yellow("\n  That section isn't ready yet — soon! 🚧"))
            return show_menu(current_section)
        return picked
    return current_section


def run_section(section_index, start_lesson):
    """Play one section. Returns ('finished'|'menu'|'quit', lesson_index)."""
    section = SECTIONS[section_index]
    banner(f"Section {section_index + 1}: {section['title']}")
    praise_index = 0
    lesson_index = start_lesson
    while lesson_index < len(section["lessons"]):
        lesson = section["lessons"][lesson_index]
        for box, default in lesson.get("needs", {}).items():
            STUDENT_ENV.setdefault(box, default)
        for box, code in lesson.get("needs_code", {}).items():
            if box not in STUDENT_ENV:
                run_code(code)
        say()
        say(lesson["say"])
        say()
        if lesson.get("task"):
            result = do_task(lesson, praise_index)
            praise_index += 1
        else:
            result = wait_for_enter()
        if result == "quit":
            return "quit", lesson_index
        if result == "menu":
            return "menu", lesson_index
        lesson_index += 1
        save_progress(section_index, lesson_index)
    return "finished", 0


def main():
    section, lesson = load_progress()
    if section >= len(SECTIONS) or SECTIONS[section].get("coming_soon"):
        section, lesson = 0, 0

    if section == 0 and lesson == 0:
        say(bold("\n  Welcome to Gray! 🐘 Let's learn Python.\n"))
    else:
        say(bold("\n  Welcome back! 🐘 Let's pick up where you left off.\n"))

    while True:
        choice = show_menu(section)
        if choice == "quit":
            break
        if choice != section:
            section, lesson = choice, 0
        status, lesson = run_section(section, lesson)
        if status == "quit":
            save_progress(section, lesson)
            break
        if status == "finished":
            section += 1
            lesson = 0
            while section < len(SECTIONS) and SECTIONS[section].get("coming_soon"):
                section += 1
            if section >= len(SECTIONS):
                # everything done — keep pointing at the last section visited
                section = len(SECTIONS) - 1
                while section > 0 and SECTIONS[section].get("coming_soon"):
                    section -= 1
                lesson = 0
            save_progress(section, lesson)

    say(cyan("\n  Bye! Your progress is saved — come back soon. 👋\n"))


if __name__ == "__main__":
    main()

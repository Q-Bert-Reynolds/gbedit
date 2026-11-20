# GBEdit

A text editor for the Game Boy.

PS/2 keyboard input can be emulated with my forks of [Gearboy](https://github.com/Q-Bert-Reynolds/Gearboy)
and [binjgb](https://github.com/q-bert-reynolds/binjgb/). It also works with real PS/2 keyboards via Link Port.
I don't know of anyone who sells an adapter anymore, but [building one yourself](https://blog.x-e.ro/lsdj_keyboard_tutorial) is fairly straightforward. Some modern PS/2 keyboards that are really USB under the hood will not work.

This project is a fork of [Beisbol](https://bitbucket.org/q_bert_reynolds/beisbolgb/), a baseball RPG.
It has been superseded by [FatPak](https://github.com/Q-Bert-Reynolds/fatpak), an OS for Everdrive.

# Controls
| Button | Action |
| --- | --- |
| D-pad | move cursor, or the on screen keyboard selection when it's open |
| A | type the selected key |
| B | backspace |
| START | new line |
| SELECT | show/hide the on screen keyboard |

On screen keyboard bottom row: shift (one shot), symbols, space, cursor left, cursor right.

PS/2 keyboards type directly: arrows, home, end, page up/down, backspace, delete, enter.

Text is kept in SRAM, so it's still there after turning the Game Boy off.

# Building

Requires Make, RGBDS (`rgbasm`, `rgblink`, `rgbfix`), SDCC with the SM83/RGBDS
backend, and Python 3 with Pillow for image conversion.

```sh
make             # build bin/TEXT_EDITOR.gbc
make clean       # remove compiled code and ROM output
make -j4         # rebuild, including required generated files
make assets      # regenerate changed constants, font, and SGB border assets
make run         # build and launch gearboy
make run EMULATOR=/path/to/emulator
```
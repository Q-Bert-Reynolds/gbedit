Priority (v1)

- call tb_Normalize before saving/menus so the .sav reads as plain text
- emulate Everdrive X SD card in Gearboy ($BD00 data, $BD01 ctrl, $BD0A key)
- Everdrive X SD card: SPI driver (asm), FatFs (C), file browser
- open/save .txt files

Editor

- only redraw changed rows, copy during VBlank (whole screen redraw takes a few frames)
- TBMoveGap does bank math per byte (~1s+ to move the gap across 24KB on DMG), copy in chunks
- tabs are drawn as a single space
- function keys, ctrl shortcuts
- select text (shift + arrows / A + d-pad), delete, cut, copy, paste
- status line (file name, modified, free space)
- iGKB handlers don't send home/end/page/delete keys
- on screen keyboard: hold A to repeat, a way to move the cursor up/down while it's open

Later

- horizontal scrolling (no wrap) option
- multiple encodings (CP437, CP1252, UTF-8)
- variable width fonts (see untoxa/VWF)
- rich text, colors, highlights
- WorkBoy keyboard
- iGKB (also supports mouse and gamepad), needs Gearboy emulation first
- mouse on the Super Game Boy

Build and runtime

- C code is placed in ROMX with no banked calls, and _GSINIT (static initializers) never runs
- use HDMA transfers on GBC for faster redraws
- use GB Printer to print text files

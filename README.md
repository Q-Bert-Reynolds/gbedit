# TEXT EDITOR

A text editor for the Game Boy, Game Boy Color, and Super Game Boy.

Edit text with a fixed width font using the gamepad, on screen keyboard, or a
PS/2 keyboard connected through the link port (the same adapter LSDJ uses).
The editor supports insertion, deletion, word wrapping, scrolling, and a blinking
cursor. Text is kept in a 24 KB SRAM gap buffer and survives power off.

Planned: open/save .txt files on the EverdriveGB X-series SD card, more encodings,
variable width fonts, WorkBoy input, iGKB, and Super Game Boy mouse support.

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

# Source

- `src/editor/`: editor logic in C (SDCC), SRAM text buffer, rendering, and on screen keyboard
- `src/keyboard/`: PS/2 input, key events, and preliminary iGKB support
- `src/text_editor.inc`: shared assembly includes
- `src/core.asm`, `src/input.asm`, `src/interrupts.asm`: bank switching, display clearing, and input
- `src/memory1.asm`, `src/gbdk.asm`: memory and Game Boy hardware helpers
- `src/color.asm`, `src/sgb.asm`: editor palettes and Super Game Boy border initialization
- `src/sram.asm`, `src/wram.asm`: text storage and display buffers

# Font

`img/ui_font.png` is a 256-tile sheet. Tile indices match character codes:
ASCII occupies 32–126, with keyboard glyphs below 32 and some Latin-1 characters
above 159. `img2rgbds.py` converts this font without reordering its tiles.
Text uses ASCII line feed (10) for new lines.

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

`make assemble` also builds the ROM and generates any missing or outdated inputs.
The default target builds without launching an emulator. Only editor constants,
font tiles, and the Super Game Boy border have generation steps.

# Cartridge

MBC5 with 32 KB SRAM (four banks). Text occupies banks 0–2; its existing `TXT1`
signature stays at the start of bank 3 for compatibility with saved text.
RGBDS pads the ROM to the required cartridge size.

# Credits

- Code, Art - Nolan Baker
- hardware.inc - Jones, Carsten Sorenson, Jeff Frohwein, Antonio Niño Díaz
- memory1.asm - Jeff Frohwein, Carsten Sorensen
- gbdk.asm - Pascal Felber, Lars Malmborg, Michael Hope
- sgb.asm - Imanol Barriuso, Martin Ahrnbom

# Thanks

- [Jeff Frohwein](https://devrs.com/gb/)
- [John Metcalf](http://www.retroprogramming.com)
- [Z80 Heaven](https://z80-heaven.wikidot.com/)
- [GameBoy Pandocs](https://gbdev.github.io/pandocs/):
- [GameBoy CPU Manual](http://marc.rawer.de/Gameboy/Docs/GBCPUman.pdf)
- [untoxa/VWF](https://github.com/untoxa/VWF)
- [RodrigoCard/TXTReaderGB](https://github.com/RodrigoCard/TXTReaderGB)

DefaultPalettes::

PALETTE_GREY EQU 0
PaletteGrey::
  RGB 31, 31, 31
  RGB 23, 23, 23
  RGB 15, 15, 15
  RGB  0,  0,  0

PALETTE_SEPIA EQU 1
PaletteSepia::
  RGB 31, 31, 31
  RGB 24, 20, 15
  RGB 13, 10,  5
  RGB  3,  2,  0

PALETTE_INTRO EQU 2
PaletteIntro::
  RGB 31, 31, 31
  RGB 30, 22, 28
  RGB 13,  4,  9
  RGB  3,  1,  7

PALETTE_TITLE_SCREEN EQU 3
PaletteTitleScreen::
  RGB 31, 31, 31
  RGB 31, 30, 18
  RGB  5,  9, 17
  RGB  1,  3,  7

PALETTE_HOME_AWAY EQU 4
PaletteHomeAway::
IF DEF(_HOME)
  RGB 31, 31, 31
  RGB  1,  3,  7
  RGB 31, 19, 29
  RGB  5, 10, 16
ELSE;AWAY
  RGB 31, 31, 31
  RGB  1,  3,  7
  RGB 19, 29, 31
  RGB  5, 10, 16
ENDC
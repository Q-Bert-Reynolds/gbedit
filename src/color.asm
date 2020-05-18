;DMG
DMG_PAL_BDLW EQU %11100100 ;normal
DMG_PAL_BDLL EQU %11100101 ;good for testing palettes
DMG_PAL_DLWW EQU %10010000 ;dark,  light, white, white/transparent
DMG_PAL_BDWW EQU %11100000 ;black, dark,  white, white/transparent
DMG_PAL_BLWW EQU %11010000 ;black, light, white, white/transparent

;CGB/SGB
COLOR_WHITE       : MACRO RGB 31, 31, 31 ENDM
COLOR_ALMOST_WHITE: MACRO RGB 29, 29, 27 ENDM
COLOR_LIGHT_GREY  : MACRO RGB 23, 23, 23 ENDM
COLOR_DARK_GREY   : MACRO RGB 15, 15, 15 ENDM
COLOR_DARKER_GREY : MACRO RGB  8,  8,  8 ENDM
COLOR_ALMOST_BLACK: MACRO RGB  6,  6,  6 ENDM
COLOR_BLACK       : MACRO RGB  0,  0,  0 ENDM

COLOR_DEEP_PURPLE : MACRO RGB  0,  2,  5 ENDM
COLOR_PURPLE_GREY : MACRO RGB 10, 10, 12 ENDM

COLOR_TAN         : MACRO RGB 22, 18, 13 ENDM
COLOR_BROWN       : MACRO RGB 15, 12,  7 ENDM
COLOR_DARK_BROWN  : MACRO RGB  3,  2,  0 ENDM

COLOR_PINK        : MACRO RGB 30, 25, 26 ENDM
COLOR_RED         : MACRO RGB 25, 11, 15 ENDM
COLOR_SALMON      : MACRO RGB 25,  8, 10 ENDM
COLOR_DARK_RED    : MACRO RGB 13,  3,  8 ENDM

COLOR_YELLOW      : MACRO RGB 29, 27, 17 ENDM
COLOR_PEACH       : MACRO RGB 28, 24, 17 ENDM

COLOR_LIGHT_GREEN : MACRO RGB 16, 23, 13 ENDM
COLOR_OLIVE       : MACRO RGB 18, 19, 12 ENDM
COLOR_GREEN       : MACRO RGB  5, 16,  8 ENDM

COLOR_LIGHT_BLUE  : MACRO RGB 26, 27, 29 ENDM
COLOR_BLUE        : MACRO RGB 11, 15, 25 ENDM
COLOR_BLUE_GREY   : MACRO RGB 14, 16, 18 ENDM
COLOR_DARK_BLUE   : MACRO RGB  5,  8, 16 ENDM

DefaultPalettes::
PaletteGrey::
  COLOR_ALMOST_WHITE
  COLOR_LIGHT_GREY
  COLOR_DARK_GREY
  COLOR_BLACK
PALETTE_GREY EQU (PaletteGrey-DefaultPalettes)/8

PaletteSepia::
  COLOR_ALMOST_WHITE
  COLOR_TAN
  COLOR_BROWN
  COLOR_DARK_BROWN
PALETTE_SEPIA EQU (PaletteSepia-DefaultPalettes)/8

PaletteIntro::
  COLOR_ALMOST_WHITE
  RGB 30, 22, 28
  RGB 13,  4,  9
  RGB  3,  1,  7
PALETTE_INTRO EQU (PaletteIntro-DefaultPalettes)/8

PaletteTitleScreen::
  COLOR_ALMOST_WHITE
  COLOR_YELLOW    
  COLOR_BLUE      
  COLOR_DARK_BLUE 
PALETTE_TITLE_SCREEN EQU (PaletteTitleScreen-DefaultPalettes)/8

PaletteHomeAwayCalvin::
IF DEF(_HOME)
  COLOR_ALMOST_WHITE
  COLOR_RED
  COLOR_BROWN
  COLOR_DARK_RED
ELSE;AWAY
  COLOR_ALMOST_WHITE
  COLOR_BLUE
  COLOR_BROWN
  COLOR_DARK_BLUE
ENDC
PALETTE_HOME_AWAY_CALVIN EQU (PaletteHomeAwayCalvin-DefaultPalettes)/8

PaletteHomeAwayVersion::
IF DEF(_HOME)
  COLOR_ALMOST_WHITE
  COLOR_RED
  COLOR_BLUE_GREY
  COLOR_DARK_RED
ELSE;AWAY
  COLOR_ALMOST_WHITE
  COLOR_BLUE
  COLOR_BLUE_GREY
  COLOR_DARK_BLUE
ENDC
PALETTE_HOME_AWAY_VERSION EQU (PaletteHomeAwayVersion-DefaultPalettes)/8

PaletteUI::
  COLOR_ALMOST_WHITE
  COLOR_TAN    
  COLOR_RED      
  COLOR_BLACK 
PALETTE_UI EQU (PaletteUI-DefaultPalettes)/8

PaletteBubbi::
  COLOR_ALMOST_WHITE
  COLOR_LIGHT_GREEN     
  COLOR_BROWN
  COLOR_BLACK
PALETTE_BUBBI EQU (PaletteBubbi-DefaultPalettes)/8

PaletteGinger::
  COLOR_ALMOST_WHITE
  COLOR_PEACH
  COLOR_SALMON
  COLOR_BLACK 
PALETTE_GINGER EQU (PaletteGinger-DefaultPalettes)/8

PaletteSquirt::
  COLOR_ALMOST_WHITE
  COLOR_TAN
  COLOR_BLUE
  COLOR_DARK_BLUE
PALETTE_SQUIRT EQU (PaletteSquirt-DefaultPalettes)/8

PaletteBaseball::
  COLOR_ALMOST_WHITE
  COLOR_ALMOST_WHITE    
  COLOR_RED      
  COLOR_DARK_RED 
PALETTE_BASEBALL EQU (PaletteBaseball-DefaultPalettes)/8

PaletteDark::
  COLOR_ALMOST_WHITE
  COLOR_DARKER_GREY
  COLOR_ALMOST_BLACK
  COLOR_BLACK 
PALETTE_DARK EQU (PaletteDark-DefaultPalettes)/8

PaletteHomeAwayNolan::
IF DEF(_AWAY)
  COLOR_ALMOST_WHITE
  COLOR_RED
  COLOR_BROWN
  COLOR_DARK_RED
ELSE;AWAY
  COLOR_ALMOST_WHITE
  COLOR_BLUE
  COLOR_BROWN
  COLOR_DARK_BLUE
ENDC
PALETTE_HOME_AWAY_NOLAN EQU (PaletteHomeAwayNolan-DefaultPalettes)/8

PaletteStartLights::
  COLOR_ALMOST_WHITE
  COLOR_TAN
  COLOR_BROWN
  COLOR_BLACK
PALETTE_START_LIGHTS EQU (PaletteStartLights-DefaultPalettes)/8

PaletteMacobb::
  COLOR_ALMOST_WHITE
  COLOR_YELLOW
  COLOR_PURPLE_GREY
  COLOR_DEEP_PURPLE
PALETTE_MACOBB EQU (PaletteMacobb-DefaultPalettes)/8

PalettePuff::
  COLOR_ALMOST_WHITE
  COLOR_PINK
  COLOR_RED
  COLOR_BLACK
PALETTE_PUFF EQU (PalettePuff-DefaultPalettes)/8

PaletteMuchacho::
  COLOR_ALMOST_WHITE
  COLOR_PINK
  COLOR_PURPLE_GREY
  COLOR_BLACK
PALETTE_MUCHACHO EQU (PaletteMuchacho-DefaultPalettes)/8

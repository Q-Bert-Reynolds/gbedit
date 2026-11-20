;Font tiles shared by the text view and on screen keyboard.
SECTION "Font", ROMX
INCLUDE "img/ui_font.asm"

UILoadFontTiles::
  LOAD_TILES _UiFontTiles, _VRAM+$1000, 0, _UI_FONT_TILE_COUNT
  ret

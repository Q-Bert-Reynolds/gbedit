SECTION "Keyboard Demo", ROM0
INCLUDE "src/keyboard/kb_debug_ui.asm"
INCLUDE "img/sprite_font.asm"

AliceText:: INCBIN "data/Alice.txt"
AliceTextEnd:: DB, 0;string terminator

HighlightInterrupt::; only highlights whole lines, sprites cover the other 
  push af
  push bc
  ld a, [rLY]
  inc a;check next line
  srl a
  srl a
  srl a;tileY = LY/8
  ld b, a;tileY
  ld a, [selection_y1]
  cp a, b
  jr z, .firstLine;if LY == y1
  jr nc, .beforeFirstLine;if LY < y1
  ld a, [selection_y2]
  cp a, b
  jr z, .lastLine;if LY == y2
  jr c, .afterLastLine; if LY > y2

.middleLines;otherwise
  sla a
  sla a
  sla a;selection_y2*8
  dec a;y2*8-1
  ld [rLYC], a
  jr .highlighted

.beforeFirstLine
  sla a
  sla a
  sla a;selection_y1*8
  dec a;y1*8-1
  ld [rLYC], a
  jr .notHighlighted

.firstLine;a = selection_y1
  ld b, a;selection_y1
  ld a, [rLY]
  add a, 8
  ld [rLYC], a
  ld a, [selection_y2]
  cp a, b
  ld a, [selection_x1]
  jr z, .firstLineIsLastLine;if y1 == y2
  cp a, 10
  jp c, .highlighted
  jp .notHighlighted
.firstLineIsLastLine
  ld b, a;x1
  ld a, [selection_x2]
  sub a, b
  inc a
  cp a, 10
  jp nc, .highlighted
  jp .notHighlighted
  
.lastLine
  ld a, [rLY]
  add a, 8
  ld [rLYC], a
  ld a, [selection_x2]
  cp a, 10
  jp c, .notHighlighted
  jp .highlighted

.afterLastLine
  xor a
  ld [rLYC], a

.notHighlighted
  ld a, DMG_PAL_NORMAL
  jr .setPalette

.highlighted
  ld a, DMG_PAL_INVERT

.setPalette
  ld [rBGP], a
  pop bc
  pop af
  reti

KeyboardDemo::
  di
  DISPLAY_OFF
  call LoadFontTiles
  ld a, " "
  call ClearScreen

  ld hl, _SpriteFontTiles
  ld de, _VRAM8000
  ld bc, _SPRITE_FONT_TILE_COUNT*16
  call mem_CopyVRAM

  ld a, 1;cursor will be a 1 pixel vertical line
  ld hl, _VRAM8000
  ld bc, 16
  call mem_SetVRAM


  ld a, DMG_PAL_BLWW
  ld [rOBP0], a;normal
  ld a, DMG_PAL_WLBW
  ld [rOBP1], a;highlighted

  DISPLAY_ON
  ei

  ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_NO_SPACE
  ld hl, AliceText
  ld de, 0
  ld bc, -1
  call DrawText

  call SaveLine

  PLAY_SONG tessie_data, 1

.setupInterrupt
  ld a, 2
  ld [selection_x1], a
  ld a, 3
  ld [selection_y1], a
  ld a, 16
  ld [selection_x2], a
  ld a, 7
  ld [selection_y2], a
  
  ld b, IEF_LCDC
  ld a, [rIE]
  or a, b
  ld [rIE], a
  
  xor a
  ld [rLYC], a

  ld a, STATF_LYC
  ld [rSTAT], a

.setupMenu
  ld a, 7
  ld [rWX], a
  ld a, 144
  ld [rWY], a
  SHOW_WIN
  
  xor a
  ld [_x], a
  ld [_y], a
  ld [_i], a
  ld [kb_scan_code], a
  ld [rSB], a
  
  call DetectKeyboard
  ld a, [kb_mode]
  cp a, KB_MODE_PS2
  jr nz, .loop
.usePS2Clock
  ld a, SCF_TRANSFER_START | SCF_CLOCK_EXTERNAL
  ld [rSC], a;ask for bits using keyboard clock 
.loop
    call DrawCursor
    call DrawHighlight
    call gbdk_WaitVBL
    call ProcessKeyCodes
    call DrawKeyboardDebugData
    call UpdateInput
  .testAButton
    ld a, [button_state]
    and a, PADF_A
    jr z, .testBButton
    ld a, [last_button_state]
    and a, PADF_A
    jr nz, .testBButton
  .pressedAButton
    ld a, [_i]
    xor a, 1
    ld [_i], a
    jr nz, .hideDebug
  .showDebug
    ld a, 104
    ld [rWY], a
    jp .testBButton
  .hideDebug
    ld a, 144
    ld [rWY], a

  .testBButton
    ld a, [button_state]
    and a, PADF_B
    jp z, .loop
    ld a, [last_button_state]
    and a, PADF_B
    jp nz, .loop
  .pressedBButton
    call ToggleKBMode
    jp .loop
  ret


DrawCharacter::;a = ASCII value
  ld [tile_buffer], a

  ld a, [_y]
  ld e, a
  ld a, [_x]
  ld d, a;de = xy
.testXWrap
  inc a
  ld [_x], a
  cp a, 20
  jr c, .setTiles
  xor a
  ld [_x], a
.testYWrap
  ld a, [_y]
  inc a
  ld [_y], a
  cp a, 18
  jr c, .setTiles
  xor a
  ld [_y], a
.setTiles
  ld hl, $0101
  ld bc, tile_buffer
  call gbdk_SetBkgTiles
  ret

;TODO: handle backspace and delete differently
RemoveCharacter::
  ld a, [_x]
  dec a
  jr nc, .setX
.wrapX
  ld a, 19
  push af
  ld a, [_y]
  dec a
  jr nc, .setY
  ld a, 17
.setY
  ld [_y], a
  pop af
.setX
  ld [_x], a
  cp a, %00000111
  ld a, " "
  ld [tile_buffer], a
  ld a, [_y]
  ld e, a
  ld a, [_x]
  ld d, a;de = xy
  ld hl, $0101
  ld bc, tile_buffer
  call gbdk_SetBkgTiles  
  ret 

ToggleKBMode::
  xor a
  ld [rSC], a;stop transfer
  ld a, [kb_mode]
  and a, %0000001
  inc a
  ld [kb_mode], a
.checkPS2
  cp a, KB_MODE_PS2
  ret nz
  ld a, SCF_TRANSFER_START | SCF_CLOCK_EXTERNAL
  ld [rSC], a ;ask for more bits using keyboard clock   
  ret

DrawCursor::
  ld hl, oam_buffer
  ld a, [vbl_timer]
  cp a, 30
  jr c, .hide
.show
  ld a, [_y]
  add a, 16
  ld [hli], a
  ld a, [_x]
  add a, 8
  ld [hli], a
  xor a
  ld [hli], a
  ld a, OAMF_PAL1
  ld [hli], a
  ret
.hide
  xor a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ret

DrawHighlight::;DMG and SGB use sprites to highlight the first and last row
  ld a, 1
  ld [sprite_first_tile], a
  ld a, [selection_y1]
  ld e, a
  ld a, [selection_y2]
  cp a, e
  jr nz, .differentRows
  
.sameRow
  ld a, [selection_x1]
  ld d, a
  ld a, [selection_x2]
  sub a, d;x2-x1
  inc a
  cp a, 10
  jr nc, .sameRowNoHighlight
.sameRowHighlight
  ld h, a;width
  ld a, OAMF_PAL1;highlight
  ld [sprite_props], a
  jp HighlightTiles

.sameRowUnHighlight
  ld a, [selection_x2]
  ld d, a;x
  ld a, 20
  sub a, d;width
  ld h, a;width
  ld a, OAMF_PAL0;normal
  ld [sprite_props], a
  call HighlightTiles

  ld d, 0
  ld a, [selection_y1]
  ld h, a;width
  ld a, OAMF_PAL0;normal
  ld [sprite_props], a
  jp HighlightTiles

.differentRows;e = y1
  ld a, [selection_x1]
  ld d, a;d = x1
  ld a, 20
  sub a, d;20-x1
  ld h, a;width
  push af
  call HighlightTiles

  pop af
  ld [sprite_first_tile], a
  ld d, 0
  ld a, [selection_y2]
  ld e, a
  ld a, [selection_x2]
  inc a
  ld h, a
  ;fall through to hightlight
HighlightTiles:;de = xy, h = width
  ld l, 1
  push de;xy
  push hl;wh
  ld bc, str_buffer
  call gbdk_GetBkgTiles

  pop hl;wh
  pop bc;xy
  inc b
  sla b
  sla b
  sla b
  inc c
  inc c
  sla c
  sla c
  sla c

  xor a
  ld [sprite_flags], a
  ld de, str_buffer
  call SetSpriteTilesXY

  ret
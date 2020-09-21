INCLUDE "src/beisbol.inc"

SECTION "UI Bank 0", ROM0

; LoadFontTiles
; RevealTextAndWait   hl = text
; RevealText          a = draw flags, de = xy hl = text
; FlashNextArrow      a = draw flags, de = xy
; DrawUIBox           a=draw flags, bc = xy, de = wh
; DrawText            a = draw flags, hl = text, de = xy, bc = max lines
; DisplayText         a = draw flags, hl = text
; DrawListMenuArrow   a = draw flags, de = xy, _j = current index, _c = count
; MoveListMenuArrow   a = draw flags, de = xy, _j = current index, _c = count, must call UpdateInput first, returns direction in a
; ShowListMenu        a = draw flags, bc = xy, de = wh, [list_selection] = initial selection, [str_buffer] = text, [name_buffer] = title, returns choice in a (0 = cancel)
; AskYesNo            a = draw flags, bc = xy, returns choice in a (0 = cancel, 1 = yes, 2 = no)
; ShowTextEntry       bc = title, de = str, l = max_len -> puts text in name_buffer
; ShowOptions
; ShowNumberPicker    a = draw flags, bc = xy, de = wh, h = max number, returns number in a (0 = cancel)

LoadFontTiles::
  ld a, [loaded_bank]
  push af;bank
  ld a, UI_BANK
  call SetBank

  call UILoadFontTiles

  pop af;bank
  call SetBank
  ret

RevealTextAndWait:: ;hl = text
  ld de, str_buffer
  call str_Copy

  ld a, [loaded_bank]
  push af;bank
  ld a, UI_BANK
  call SetBank

  ld hl, str_buffer
  ld a, DRAW_FLAGS_PAD_TOP
  call UIRevealTextAndWait

  pop af;bank
  call SetBank
  ret

RevealText:: ;a = draw flags, de = xy, hl = text
  ld b, a;draw flags
  ld a, [loaded_bank]
  push af;bank
  push bc;draw flags
  push de;xy
  ld de, str_buffer
  call str_Copy

  ld a, UI_BANK
  call SetBank

  pop de;xy
  pop af;draw flags
  ld hl, str_buffer
  call UIRevealText

  pop af;bank
  call SetBank
  ret

FlashNextArrow:: ;a = draw flags, de = xy
  push de;xy
  push af;draw flags
  ld bc, tile_buffer
  ld a, ARROW_DOWN
  ld [bc], a ;tile_buffer[0] = ARROW_DOWN;
  ld hl, $0101
  pop af;draw flags
  push af
  call SetTiles

  WAITPAD_UP
  ld l, 20
.loop1 ;for (a = 20; a > 0; --a) {
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exitFlashNextArrow, (PADF_A | PADF_B)
    ld de, 10
    call gbdk_Delay
    dec l
    jp nz, .loop1

  ld bc, tile_buffer
  xor a
  ld [bc], a
  ld hl, $0101
  pop af;draw flags
  pop de ;xy
  push de ;xy
  push af
  call SetTiles

  ld l, 20
.loop2
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exitFlashNextArrow, (PADF_A | PADF_B)
    ld de, 10
    call gbdk_Delay
    dec l
    jp nz, .loop2

  pop af;draw flags
  pop de ;xy
  jp FlashNextArrow
.exitFlashNextArrow
  PLAY_SFX SelectSound
  pop af;draw flags
  pop de ;xy
  ret

GetUIBoxTiles: ;Entry: de = wh, Affects: hl
  PUSH_VAR _i
  PUSH_VAR _j

  ld hl, tile_buffer
  xor a
  ld [_j], a
.rowLoop ;for (j = 0; j < h; ++j) {
    xor a
    ld [_i], a
  .columnLoop ;for (i = 0; i < w; ++i) {
    .testTop ;if (j == 0) {
      ld a, [_j] 
      and a
      jr nz, .testBottom
    .testUpperLeft ;if (i == 0) k = BOX_UPPER_LEFT;
      ld a, [_i]
      and a
      jr nz, .testUpperRight
      ld a, BOX_UPPER_LEFT
      jp .setTile
    .testUpperRight ;else if (i == w-1) k = BOX_UPPER_RIGHT;
      ld a, [_i]
      sub a, d
      inc a
      jr nz, .setHorizontal
      ld a, BOX_UPPER_RIGHT
      jp .setTile
    .testBottom ;else if (j == h-1) {
      ld a, [_j] 
      sub a, e
      inc a
      jr nz, .testSides
    .testLowerLeft ;if (i == 0) k = BOX_LOWER_LEFT;
      ld a, [_i]
      and a
      jr nz, .testLowerRight
      ld a, BOX_LOWER_LEFT
      jp .setTile
    .testLowerRight ;else if (i == w-1) k = BOX_LOWER_RIGHT;
      ld a, [_i]
      sub a, d
      inc a
      jr nz, .setHorizontal
      ld a, BOX_LOWER_RIGHT
      jp .setTile
    .testSides ;else if (i == 0 || i == w-1) k = BOX_VERTICAL;
      ld a, [_i]
      and a
      jr z, .setVertical
      sub d
      inc a
      jr z, .setVertical
    .setNone
      xor a
      jr .setTile
    .setVertical
      ld a, BOX_VERTICAL
      jr .setTile
    .setHorizontal
      ld a, BOX_HORIZONTAL
    .setTile
      ld [hli], a ;tiles[j*w+i] = k;

      ld a, [_i]
      inc a
      ld [_i], a
      sub a, d
      jr nz, .columnLoop

    ld a, [_j]
    inc a
    ld [_j], a
    sub a, e
    jr nz, .rowLoop

  POP_VAR _j
  POP_VAR _i
  ret

DrawUIBox::;a=draw flags, bc = xy, de = wh
  push af ;draw flags
  push bc ;xy
  push de ;wh
  call GetUIBoxTiles
  pop hl ;wh
  pop de ;xy
  pop af;draw flags
  ld bc, tile_buffer
  call SetTiles
  ret

DrawText:: ;a = draw flags, hl = text, de = xy, bc = max lines
    push bc;max lines
    push af;draw flags
    push de;xy
    ld de, tile_buffer
    call str_CopyLine
    pop de;xy
    pop af;draw flags
    push af;draw flags
    push de;xy
    push hl;next line
    ld h, c;width
    ld l, 1;height
    ld bc, tile_buffer
    call SetTiles
    pop hl;line
    dec hl
    ld a, [hli]
    and a
    jr z, .exit
    pop de;xy
    inc e
    inc e;y+=2
    pop af;draw flags
    pop bc;max lines
    dec c
    ret z
    jr DrawText
.exit
  pop de;xy
  pop af;draw flags
  pop bc;max lines
  ret

DisplayTextAtPos:: ;a = draw flags, hl = text, bc = xy
  push hl;text
  push af;draw flags

  ld d, 20
  ld e, 6
  pop af;draw flags
  push af;draw flags
  push bc;xy
  call DrawUIBox
  pop de;xy
  inc d
  inc e
  pop af;draw flags
  push af;draw flags
  and a, DRAW_FLAGS_PAD_TOP
  jr z, .skipPad
  inc e
.skipPad
  pop af;draw flags
  pop hl;text
  push af;draw flags
  ld bc, 2;max lines
  call DrawText ;a = draw flags, hl = text, de = xy, bc = max lines
  pop af;draw flags
  ret

DisplayText:: ;a = draw flags, hl = text
  ld bc, 0
  call DisplayTextAtPos
.show
  and a, DRAW_FLAGS_WIN
  ret z;no reason to show win if not drawing on win
  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a
  SHOW_WIN
  ret

DrawListMenuArrow:: ;a = draw flags, de = xy, _j = current index, _c = count
  push af;draw flags
  and a, DRAW_FLAGS_NO_SPACE
  ld a, [_c]
  jr nz, .skip
  add a, a
.skip
  inc a
  ld b, 0
  ld c, a
  ld hl, tile_buffer
  xor a
  call mem_Set

  pop af;draw flags
  push af;draw flags
  and a, DRAW_FLAGS_NO_SPACE
  ld a, [_j]
  jr nz, .skip2
  add a, a
.skip2
  inc a
  ld b, 0
  ld c, a
  ld hl, tile_buffer
  add hl, bc
  ld a, ARROW_RIGHT
  ld [hl], a

  ld a, 1
  ld h, a ;w=1
  pop af;draw flags
  push af;draw flags
  and a, DRAW_FLAGS_NO_SPACE
  ld a, [_c]
  jr nz, .skip3
  add a, a
  jr .skip4
.skip3
  inc a
.skip4
  ld l, a ;h=_c*2
  
  pop af;draw flags
  push af
  ld bc, tile_buffer
  and a, DRAW_FLAGS_PAD_TOP
  jr nz, .setTiles
  inc bc
  dec l
.setTiles
  pop af;draw flags
  call SetTiles
  ret

MoveListMenuArrow:: ;a = draw flags, de = xy, _j = current index, _c = count, must call UpdateInput first, returns direction in a
  push af;draw flags
.checkMoveArrowUp ;if (button_state & PADF_UP && j > 0) {
  ld a, [button_state]
  and a, PADF_UP
  jp z, .checkMoveArrowDown
  ld a, [_j]
  or a
  jp z, .failMoveUp
  call gbdk_WaitVBL
  ld a, [_j]
  dec a
  ld [list_selection], a
  ld [_j], a ;--j
  pop af;draw flags
  push af
  call DrawListMenuArrow;move_menu_arrow(--j);
.failMoveUp
  pop af;draw flags
  WAITPAD_UP_OR_FRAMES 20
  ld a, -1
  ret
.checkMoveArrowDown ;else if (button_state & PADF_DOWN && _j < _c-1) {
  ld a, [button_state]
  and a, PADF_DOWN
  jr z, .noMove
  ld a, [_c]
  dec a
  ld b, a
  ld a, [_j]
  cp b
  jr nc, .failMoveDown
  call gbdk_WaitVBL
  ld a, [_j]
  inc a
  ld [list_selection], a
  ld [_j], a ;++j
  pop af;draw flags
  push af
  call DrawListMenuArrow;move_menu_arrow(++j);
.failMoveDown
  pop af;draw flags
  WAITPAD_UP_OR_FRAMES 20
  ld a, 1
  ret
.noMove
  pop af
  xor a;0
  ret

ShowListMenu:: ;a = draw flags, bc = xy, de = wh, [list_selection] = initial selection, [str_buffer] = text, [name_buffer] = title, returns choice in a (0 = cancel)
  ld h, a;draw flags
  ld a, [loaded_bank]
  push af;bank
  push hl;draw flags
  ld a, UI_BANK
  call SetBank
  
  pop af;draw flags
  call UIShowListMenu
  ld b, a;choice

  pop af;bank
  call SetBank

  ld a, b;choice
  ret; return a=choice;

AskYesNo::;a = draw flags, bc = xy, returns choice in a (0 = cancel, 1 = yes, 2 = no)
  push af;draw flags
  push bc;xy
  ld hl, YesNoText
  ld de, str_buffer
  call str_Copy
  xor a
  ld [name_buffer], a
  ld [list_selection], a
  pop bc;xy
  ld d, 6
  ld e, 5
  pop af;draw flags
  call ShowListMenu
  ret

ShowTextEntry:: ;bc = title, de = str, l = max_len -> puts text in name_buffer
  ld a, [loaded_bank]
  push af ;bank
  push hl ;max_len
  push de ;str
  ld h, b
  ld l, c
  ld de, str_buffer
  call str_Copy

  pop hl ;str
  ld de, name_buffer
  call str_Copy

  ld a, UI_BANK
  call SetBank
  
  ld de, str_buffer
  ld hl, name_buffer
  pop bc ;max_len
  call UIShowTextEntry

  pop af;bank
  call SetBank
  ret

ShowOptions::
  ld a, [loaded_bank]
  push af;bank
  ld a, UI_BANK
  call SetBank

  call UIShowOptions

  pop af;bank
  call SetBank
  ret

ShowNumberPicker::; a = draw flags, bc = xy, de = wh, h = max number, returns number in a (0 = cancel)
  ld l, a;draw flags
  ld a, [loaded_bank]
  push af;bank
  ld a, UI_BANK
  call SetBank
  
  ld a, l;draw flags
  call UIShowNumberPicker
  ld b, a;number

  pop af;bank
  call SetBank

  ld a, b;number
  ret


SECTION "UI", ROMX, BANK[UI_BANK]

INCLUDE "img/ui_font.asm"
INCLUDE "img/town_map.asm"

;UILoadFontTiles
;UIDrawStateMap
;UIRevealText - a = draw flags, hl = text, de = xy
;UIRevealTextAndWait - a = draw flags, hl = text
;UIShowOptions
;UIShowTextEntry - a = draw flags, de = title, hl = str, c = max_len
;UIShowListMenu - a = draw flags, bc = xy, de = wh, text = [str_buffer], title = [name_buff], returns choice in a
;UIShowNumberPicker - a = draw flags, bc = xy, de = wh, h = max number, returns number in a (0 = cancel)
;UIDrawSaveStats - a = draw flags, de = xy

; User Stats
CoachStatText:         DB "COACH"
PennantsStatText:      DB "PENNANTS"
RoledexStatText:       DB "ROLéDEX"
TimeStatText:          DB "TIME"

; Options
TextSpeedOptionString: DB "TEXT SPEED        "
                       DB "                  "
                       DB " FAST  MEDIUM SLOW"

AnimationOptionString: DB "AT-BAT ANIMATIONS "
                       DB "                  "
                       DB " ON       OFF     "

CoachingOptionString:  DB "COACHING STYLE    "
                       DB "                  "
                       DB " SHIFT    SET     "

; Text Entry
LowerCase:             DB "abcdefghijklmnopqrstuvwxyz *():;[]#%-?!*+/.,↵", 0
LowerCaseTitle:        DB "lower case", 0
UpperCase:             DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ *():;[]#%-?!*+/.,↵", 0
UpperCaseTitle:        DB "UPPER CASE", 0

UILoadFontTiles::
  ld hl, _UiFontTiles
  ld de, _VRAM+$1000
  ld bc, _UI_FONT_TILE_COUNT*16
  call mem_CopyVRAM ;doesn't loop so mem_CopyToTileData is unnecessary
  ret

; State Map SGB Palettes
SGBTownMapPalSet: PAL_SET PALETTE_UI, PALETTE_TOWN_MAP, PALETTE_TOWN_MAP_LOCATION, PALETTE_GREY
SGBTownMapAttrBlk:
  ATTR_BLK 7
  ATTR_BLK_PACKET %001, 0,0,0,  0,0, 20,1  ;title
  ATTR_BLK_PACKET %001, 1,1,1,  0,1, 20,17 ;map
  ATTR_BLK_PACKET %001, 2,2,2,  1,2,  7,1  ;locations
  ATTR_BLK_PACKET %001, 2,2,2,  3,6,  6,7
  ATTR_BLK_PACKET %001, 2,2,2, 12,11, 1,1
  ATTR_BLK_PACKET %001, 2,2,2, 16,14, 1,1
  ATTR_BLK_PACKET %001, 2,2,2, 17,12, 1,1

UIDrawStateMap::
  DISPLAY_OFF
  ld hl, _TownMapTiles
  ld de, $8800
  ld bc, _TOWN_MAP_TILE_COUNT*16
  call mem_CopyVRAM

  ld de, 0
  ld h, _TOWN_MAP_COLUMNS
  ld l, _TOWN_MAP_ROWS
  ld bc, _TownMapTileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBkgTilesWithOffset

  ld hl, SGBTownMapPalSet               
  call SetPalettesIndirect
  ld hl, SGBTownMapAttrBlk
  ld b, DRAW_FLAGS_BKG
  call SetColorBlocks

  DISPLAY_ON
  ret

UIRevealText:: ;a = draw flags, hl = text, de = xy
  ld b, a;draw flags
  PUSH_VAR _i
  PUSH_VAR _j
  PUSH_VAR _l
  PUSH_VAR _w
  PUSH_VAR _x
  PUSH_VAR _y
  ld a, b;draw flags
  push af;draw flags
  push hl;text
  push de;xy

  ld b, d
  ld c, e
  ld d, 20
  ld e, 6
  call DrawUIBox
  
  pop de;xy
  pop hl;text
  pop af;draw flags
  push af;draw flags
  push hl;text
  push de;xy

  and a, DRAW_FLAGS_WIN
  jr z, .skipWin
  SHOW_WIN
.skipWin

  xor a
  ld [_i], a
  ld [_x], a
  ld [_y], a
  ld [_w], a
  pop de;xy
  pop hl;text
  push hl;text
  push de;xy
  call str_Length ;de = length
  ld a, e ;assumes length < 256
  ld [_l], a; l = strlen(text);
.revealTextLoop; for (i = 0; i < l; ++i) {
    pop de;xy
    pop hl;text
    push hl;text
    push de;xy
  .testNewLine;   if (text[i] == '\n') {
    xor a
    ld b, a
    ld a, [_i]
    ld c, a
    add hl, bc;text[i]
    ld a, [hl]
    cp "\n"
    jp nz, .drawCharacter

    ld a, [_y]
    inc a
    ld [_y], a
    sub a, 2
    jp nz, .skipFlash ;if (y == 2) {
    pop de;xy
    pop hl;text
    pop af;draw flags
    push af;draw flags
    push hl;text
    push de;xy
    push af;draw flags
    ld a, d
    add a, 18
    ld d, a
    ld a, e
    add a, 4
    ld e, a
    pop af;draw flags
    call FlashNextArrow ;flash_next_arrow(18,4);

    ld a, 1
    ld [_y], a

    pop de;xy
    pop hl;text
    push hl;text
    push de;xy
    xor a
    ld b, a
    ld a, [_w]
    ld c, a
    add hl, bc;text+w
    ld de, str_buffer
    ld a, [_i]
    sub a, c
    ld c, a;i-w
    call mem_Copy ;memcpy(str_buff,text+w,i-w);

    ld a, [_x]
    and a
    jr z, .skipWhiteSpace
    ld bc, 17
    ld hl, str_buffer
  .whiteSpaceLoop
      dec bc
      inc hl
      dec a
      jr nz, .whiteSpaceLoop
    ld a, " "
    call mem_Set
  .skipWhiteSpace
    pop de;xy
    pop hl;text
    pop af;draw flags
    push af;draw flags
    push hl;text
    push de;xy
    push af;draw flags
    and a, DRAW_FLAGS_PAD_TOP
    rr a
    add a, e
    add a, 1
    ld e, a;y
    ld a, d
    add a, 1
    ld d, a;x
    ld h, 17 ;w
    ld l, 1 ;h
    ld bc, str_buffer
    pop af
    call SetTiles

    ld bc, 17
    ld hl, str_buffer
    ld a, " "
    call mem_Set
    pop de;xy
    pop hl;text
    pop af;draw flags
    push af;draw flags
    push hl;text
    push de;xy
    push af;draw flags
    and a, DRAW_FLAGS_PAD_TOP
    rr a
    add a, e
    add a, 3
    ld e, a;y
    ld a, d
    add a, 1
    ld d, a;x
    ld h, 17 ;w
    ld l, 1 ;h
    ld bc, str_buffer
    pop af
    call SetTiles

  .skipFlash
    xor a
    ld [_x], a
    ld a, [_i]
    inc a
    ld [_w], a
    jr .getTextSpeed
  .drawCharacter ;else {
    pop de;xy
    pop hl;text
    pop af;draw flags
    push af;draw flags
    push hl;text
    push de;xy
    push af;draw flags
    xor a
    ld b, a
    ld a, [_i]
    ld c, a
    add hl, bc
    ld b, h
    ld c, l;bc = text+i
    ld a, [_x]
    inc a
    ld [_x], a
    ld d, a ;_x+1
    ld a, [_y]
    add a, a;_y*2
    add a, 1;_y*2+1
    ld e, a ;y=_y*2+1
    pop af;draw flags
    push af;draw flags
    and a, DRAW_FLAGS_PAD_TOP
    rr a
    add a, e
    ld e, a;if pad top, y=_y*2+2
    pop af;draw flags
    pop hl;xy
    push hl;xy
    push af;draw flags
    ld a, d
    add a, h
    ld d, a
    ld a, e
    add a, l
    ld e, a
    ld h, 1 ;w
    ld l, 1 ;h
    pop af;draw flags
    call SetTiles

  .getTextSpeed
    ld a, [text_speed]
    cp a, 2
    ld de, 100
    jr z, .delay
    cp a, 1
    ld de, 50
    jr z, .delay
    ld de, 10
  .delay
    call gbdk_Delay

    ld a, [_i]
    inc a
    ld [_i], a
    ld b, a
    ld a, [_l]
    sub b
    jp nz, .revealTextLoop

  pop de;xy
  pop hl;text
  pop af;draw flags
  POP_VAR _y
  POP_VAR _x
  POP_VAR _w
  POP_VAR _l
  POP_VAR _j
  POP_VAR _i
  ret

UIRevealTextAndWait::
  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a; move_win(7,96);
  
  ld de, 0
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call UIRevealText

  ld d, 18
  ld e, 4
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call FlashNextArrow ;flash_next_arrow(18,4);
  ret

SET_MOVE_OPTIONS_ARROW_TILE: MACRO ;var, row, column
  xor a
  ld bc, tile_buffer
  ld [bc], a
  ld a, [\1]
  cp \3
  jr nz, .setTile\@
  ld a, ARROW_RIGHT_BLANK
  ld bc, tile_buffer
  ld [bc], a
.subY\@
  ld a, [_y]
  cp \2
  jr nz, .setTile\@
  ld a, ARROW_RIGHT
  ld bc, tile_buffer
  ld [bc], a
.setTile\@
ENDM

MoveOptionsArrow:
  ld d, 1 ;x
  ld e, 3 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE text_speed, 0, 0
  call gbdk_SetBkgTiles; set_bkg_tiles(1,3,1,1,tile_buffer + (a==0 ? 2 : 0) - (y==0 ? 1 : 0));
  
  ld d, 7 ;x
  ld e, 3 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE text_speed, 0, 1
  call gbdk_SetBkgTiles; set_bkg_tiles(7,3,1,1,tile_buffer + (a==1 ? 2 : 0) - (y==0 ? 1 : 0));
  
  ld d, 14 ;x
  ld e, 3 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE text_speed, 0, 2
  call gbdk_SetBkgTiles; set_bkg_tiles(14,3,1,1,tile_buffer + (a==2 ? 2 : 0) - (y==0 ? 1 : 0));
  
  ld d, 1 ;x
  ld e, 8 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE animation_style, 1, 0
  call gbdk_SetBkgTiles; set_bkg_tiles(1,8,1,1,tile_buffer + (b==0 ? 2 : 0) - (y==1 ? 1 : 0));
  
  ld d, 10 ;x
  ld e, 8 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE animation_style, 1, 1
  call gbdk_SetBkgTiles; set_bkg_tiles(10,8,1,1,tile_buffer + (b==1 ? 2 : 0) - (y==1 ? 1 : 0));

  ld d, 1 ;x
  ld e, 13 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE coaching_style, 2, 0
  call gbdk_SetBkgTiles; set_bkg_tiles(1,13,1,1,tile_buffer + (c==0 ? 2 : 0) - (y==2 ? 1 : 0));
  
  ld d, 10 ;x
  ld e, 13 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE coaching_style, 2, 1
  call gbdk_SetBkgTiles; set_bkg_tiles(10,13,1,1,tile_buffer + (c==1 ? 2 : 0) - (y==2 ? 1 : 0));

  ld a, ARROW_RIGHT
  ld bc, tile_buffer
  ld [bc], a
  ld d, 1 ;x
  ld e, 16 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  ld a, [_y]
  cp 3
  jr z, .setCancelTile
  ld a, ARROW_RIGHT_BLANK
  ld [bc], a
.setCancelTile
  call gbdk_SetBkgTiles; set_bkg_tiles(1,16,1,1,tile_buffer + (y==3 ? 1 : 2));
  ret

UIShowOptions::
  PUSH_VAR _y
  DISPLAY_OFF
  CLEAR_BKG_AREA 0,0,20,18," "

  call LoadOptions

.testTextSpeed; if (a > 2) a = 0;
  ld a, [text_speed]
  cp 3
  jr c, .testAnimationStyle 
  xor a
  ld [text_speed], a
.testAnimationStyle; if (b > 1) b = 0;
  ld a, [animation_style]
  cp 2
  jr c, .testCoachingStyle
  xor a
  ld [animation_style], a
.testCoachingStyle; if (c > 1) c = 0;
  ld a, [coaching_style]
  cp 2
  jr c, .doneTestingStoreOptions
  xor a
  ld [coaching_style], a
.doneTestingStoreOptions

  xor a
  ld b, a
  ld c, a
  ld a, 20
  ld d, a
  ld a, 5
  ld e, a
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox
  ; set_bkg_tiles(1,1,18,3,
  ;   "TEXT SPEED        "
  ;   "                  "
  ;   " FAST  MEDIUM SLOW"
  ld d, 1
  ld e, 1
  ld h, 18
  ld l, 3
  ld bc, TextSpeedOptionString
  call gbdk_SetBkgTiles

  xor a
  ld b, a
  ld a, 5
  ld c, a
  ld e, a
  ld a, 20
  ld d, a
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox
  ; set_bkg_tiles(1,6,18,3,
  ;   "AT-BAT ANIMATIONS "
  ;   "                  "
  ;   " ON       OFF     "
  ld d, 1
  ld e, 6
  ld h, 18
  ld l, 3
  ld bc, AnimationOptionString
  call gbdk_SetBkgTiles

  xor a
  ld b, a
  ld a, 10
  ld c, a
  ld a, 20
  ld d, a
  ld a, 5
  ld e, a
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox
  ; set_bkg_tiles(1,11,18,3,
  ;   "COACHING STYLE    "
  ;   "                  "
  ;   " SHIFT    SET     "
  ld d, 1
  ld e, 11
  ld h, 18
  ld l, 3
  ld bc, CoachingOptionString
  call gbdk_SetBkgTiles

  ; set_bkg_tiles(2,16,6,1,
  ;   "CANCEL"
  ld d, 2
  ld e, 16
  ld h, 6
  ld l, 1
  ld bc, CancelString
  call gbdk_SetBkgTiles

  DISPLAY_ON

  xor a
  ld [_y], a; y = 0;

  call MoveOptionsArrow; move_options_arrow(y);
  WAITPAD_UP

.moveOptionsArrowLoop; while (1) {
  call UpdateInput;   k = joypad();
.checkUpPressed;   if (button_state & PADF_UP && y > 0) {
  ld a, [button_state]
  and a, PADF_UP
  jr z, .checkDownPressed
  ld a, [_y]
  and a
  jp z, .checkDownPressed
  call gbdk_WaitVBL
  ld a, [_y]
  dec a
  ld [_y], a
  call MoveOptionsArrow;     move_options_arrow(--y);
  WAITPAD_UP
  jp .waitVBLAndLoop
.checkDownPressed;   else if (button_state & PADF_DOWN && y < 3) {
  ld a, [button_state]
  and a, PADF_DOWN
  jr z, .checkLeftPressed
  ld a, 3
  ld b, a
  ld a, [_y]
  cp b
  jr nc, .checkLeftPressed
  call gbdk_WaitVBL
  ld a, [_y]
  inc a
  ld [_y], a
  call MoveOptionsArrow;     move_options_arrow(++y);
  WAITPAD_UP
  jp .waitVBLAndLoop
.checkLeftPressed;   else if (button_state & PADF_LEFT && y < 3) {
  ld a, [button_state]
  and a, PADF_LEFT
  jr z, .checkRightPressed
  ld a, [_y]
  cp 3
  jr nc, .checkRightPressed
  call gbdk_WaitVBL
.moveTextSpeedLeft;     if (y == 0 && a > 0) --a;
  ld a, [_y]
  and a
  jr nz, .moveAnimationStyleLeft
  ld a, [text_speed]
  and a
  jr z, .moveAnimationStyleLeft
  dec a
  ld [text_speed], a
  jr .moveArrowLeft
.moveAnimationStyleLeft;     else if (y == 1 && b > 0) --b;
  ld a, [_y]
  cp 1
  jr nz, .moveCoachingStyleLeft
  ld a, [animation_style]
  and a
  jr z, .moveCoachingStyleLeft
  dec a
  ld [animation_style], a
  jr .moveArrowLeft
.moveCoachingStyleLeft;     else if (y == 2 && c > 0) --c;
  ld a, [_y]
  cp 2
  jr nz, .moveArrowLeft
  ld a, [coaching_style]
  and a
  jr z, .moveArrowLeft
  dec a
  ld [coaching_style], a
.moveArrowLeft
  call MoveOptionsArrow;     move_options_arrow(y);
  WAITPAD_UP
  jr .waitVBLAndLoop
.checkRightPressed;   else if (button_state & PADF_RIGHT && y < 3) {
  ld a, [button_state]
  and a, PADF_RIGHT
  jr z, .checkStartAPressed
  ld a, [_y]
  cp 3
  jr nc, .checkStartAPressed
  call gbdk_WaitVBL
.moveTextSpeedRight;     if (y == 0 && a < 2) ++a;
  ld a, [_y]
  and a
  jr nz, .moveAnimationStyleRight
  ld a, [text_speed]
  cp 2
  jr nc, .moveAnimationStyleRight
  inc a
  ld [text_speed], a
  jr .moveArrowRight
.moveAnimationStyleRight;     else if (y == 1 && b < 1) ++b;
  ld a, [_y]
  cp 1
  jr nz, .moveCoachingStyleRight
  ld a, [animation_style]
  cp 1
  jr nc, .moveCoachingStyleRight
  inc a
  ld [animation_style], a
  jr .moveArrowRight
.moveCoachingStyleRight;     else if (y == 2 && c < 1) ++c;
  ld a, [_y]
  cp 2
  jr nz, .moveArrowRight
  ld a, [coaching_style]
  cp 1
  jr nc, .moveArrowRight
  inc a
  ld [coaching_style], a
.moveArrowRight
  call MoveOptionsArrow;     move_options_arrow(y);
  WAITPAD_UP
  jr .waitVBLAndLoop
.checkStartAPressed;   if (button_state & (PADF_START | PADF_A) && y == 3) break;
  ld a, [_y]
  cp 3
  jr nz, .checkBPressed
  ld a, [button_state]
  and a, PADF_START | PADF_A
  jr nz, .exitMoveOptionsArrowLoop
.checkBPressed;   else if (button_state & PADF_B) break;
  ld a, [button_state]
  and a, PADF_B
  jr nz, .exitMoveOptionsArrowLoop
.waitVBLAndLoop
  call gbdk_WaitVBL
  jp .moveOptionsArrowLoop
.exitMoveOptionsArrowLoop

  call SaveOptions

  PLAY_SFX SelectSound
  POP_VAR _y
  ret

MoveTextEntryArrow: ; bc = from xy, de = to xy
  push bc ;from xy
  push de ;to xy
  call gbdk_WaitVBL
  ld hl, tile_buffer
  xor a
  ld [hl], a; tiles[0] = 0;
  ld a, c
  cp 5; if (from_y == 5) {
  jr nz, .notFromLineFive
  ld e, 15
  ld a, 1
  ld d, a
  ld h, a
  ld l, a
  ld bc, tile_buffer
  call gbdk_SetWinTiles ;set_win_tiles(1,15,1,1,tile_buffer);
  jr .setArrow
.notFromLineFive; else {
  ld a, b ;from_x
  add a, a ;from_x*2
  inc a ;from_x*2+1
  ld d, a
  ld a, c ;from_y
  add a, a ;from_y*2
  add a, 5 ;from_y*2+5
  ld e, a
  ld a, 1
  ld h, a
  ld l, a
  ld bc, tile_buffer
  call gbdk_SetWinTiles ;set_win_tiles(from_x*2+1,from_y*2+5,1,1,tile_buffer);
.setArrow
  pop de ;to xy
  pop bc ;from xy  
  ld hl, tile_buffer
  ld a, ARROW_RIGHT
  ld [hl], a; tiles[0] = ARROW_RIGHT;
  ld a, e
  cp 5; if (to_y == 5) {
  jr nz, .notToLineFive
  push bc ;from xy
  push de ;to xy
  ld e, 15
  ld a, 1
  ld d, a
  ld h, a
  ld l, a
  ld bc, tile_buffer
  call gbdk_SetWinTiles ;set_win_tiles(1,15,1,1,tile_buffer);
  pop de ;to xy
  pop bc ;from xy
  jr .waitPadUp
.notToLineFive; else {
  ld a, d ;to_x
  add a, a ;to_x*2
  inc a ;to_x*2+1
  ld d, a
  ld a, e ;to_y
  add a, a ;to_y*2
  add a, 5 ;to_y*2+5
  ld e, a
  ld a, 1
  ld h, a
  ld l, a
  ld bc, tile_buffer
  call gbdk_SetWinTiles ;set_win_tiles(to_x*2+1,to_y*2+5,1,1,tile_buffer);
.waitPadUp
  WAITPAD_UP; update_waitpadup();
  ret

UpdateTextEntryDisplay: ; hl = str, d = max_len
  push de; d = max_len
  push hl; str

  ld d, 10;x
  ld e, 2;y
  pop bc ;str
  pop hl; h = max_len = width
  push hl
  push bc ;str
  ld l, 1; l = height
  call gbdk_SetWinTiles; set_win_tiles(10,2,max_len,1,str);

  pop bc ;str
  pop de ;d =max_len
  push de
  push bc ;str
  ld c, d ;c = max_len
  xor a
  ld b, a
  ld a, "-"
  ld hl, tile_buffer
  call mem_Set

  pop hl ;str
  push hl
  call str_Length; w = strlen(str);
  ld hl, tile_buffer
  add hl, de
  ld a, "^"
  ld [hl], a

  ld d, 10;x
  ld e, 3;y
  pop bc ;str
  pop hl; h = max_len = width
  ld bc, tile_buffer
  ld l, 1; l = height
  call gbdk_SetWinTiles; set_win_tiles(10,2,max_len,1,str);

  ret

UIShowTextEntry:: ; de = title, hl = str, c = max_len
  PUSH_VAR _c
  PUSH_VAR _i
  PUSH_VAR _j
  PUSH_VAR _l
  PUSH_VAR _x
  PUSH_VAR _y

  push bc;c = max_len
  push hl;str
  push de;title
  DISPLAY_OFF

  xor a
  ld b, a;b = 0, c = max_len
  call mem_Set; for (i = 0; i != max_len; ++i) str[i] = 0;
  CLEAR_WIN_AREA 0,0,20,4," "
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a; move_win(7,0);

  
  pop hl;title
  push hl
  call str_Length; l = strlen(title);
  ld a, e ;assumes len < 256
  ld [_l], a
  and a
  jp z, .skipTiles; if (l > 0) 
  pop bc;title
  push bc
  xor a
  ld d, a
  ld a, 1
  ld e, a
  ld l, a
  ld a, [_l]
  ld h, a
  call gbdk_SetWinTiles;set_win_tiles(0,1,l,1,title);
.skipTiles
  pop bc; title
  pop hl; str
  pop de; e = max_len
  push de
  push hl ;str
  ld d, e; d = max_len
  call UpdateTextEntryDisplay; update_text_entry_display(str, max_len);
  xor a
  ld b, a
  ld a, 4
  ld c, a
  ld a, 20
  ld d, a
  ld a, 11
  ld e, a
  ld a, DRAW_FLAGS_WIN
  call DrawUIBox
  DISPLAY_ON
  pop hl ;str
  pop de; e = max_len
  push de; e = max_len
  push hl; str

  xor a
  ld [_x], a
  ld [_y], a
  ld [_c], a
  ld [_l], a
.drawTextBoxLoop; while (1) {
    ld de, str_buffer
    ld bc, 46
    ld a, [_c]
    and a
    jp nz, .shouldUseUpper
  .shouldUseLower;   if (c == 0) {
    ld hl, UpperCase
    call mem_Copy;     memcpy(str_buff, upper_case, 46);
    ld bc, LowerCaseTitle;set_win_tiles(2,15,10,1,"lower case");
    jr .setCaseTiles
  .shouldUseUpper;   else {
    ld hl, LowerCase
    call mem_Copy;     memcpy(str_buff, lower_case, 46);
    ld bc, UpperCaseTitle;set_win_tiles(2,15,10,1,"UPPER CASE");
  .setCaseTiles
    ld d, 2
    ld e, 15
    ld h, 10
    ld l, 1
    call gbdk_SetWinTiles
    xor a
    ld [_j], a
  .rowLoop;   for (j = 0; j < 5; ++j) {
      xor a
      ld [_i], a
      ld a, [_j]
      add a, a; j*2
      ld de, 18
      call math_Multiply; hl = 18 * j*2
      ld b, h
      ld c, l ;bc = j*2*18
      ld hl, tile_buffer
      add hl, bc ;tiles[j*2*18]
      push hl
      ld hl, str_buffer
      ld a, [_j]
      add a, a ;_j*2
      add a, a ;_j*4
      add a, a ;_j*8
      ld c, a
      ld a, [_j]
      add a, c ;_j*9
      ld c, a
      add hl, bc ;str_buff[j*9]
      ld d, h
      ld e, l
      pop hl ;tiles[j*2*18]
    .collumnLoop1;     for (i = 0; i < 9; ++i) {
        ld a, [_x]
        ld b, a
        ld a, [_i]
        sub a, b
        jr nz, .notArrowTile
        ld a, [_y]
        ld b, a
        ld a, [_j]
        sub a, b
        jr nz, .notArrowTile;(x==i && y==j) ?
        ld a, ARROW_RIGHT
        ld [hli], a;tiles[j*2*18+i*2] = ARROW_RIGHT
        jr .setCharTile
      .notArrowTile
        xor a
        ld [hli], a;tiles[j*2*18+i*2] = 0
      .setCharTile
        ld a, [de]
        ld [hli], a ;tiles[j*2*18+i*2+1] = str_buff[j*9+i];
        inc de
        ld a, [_i]
        inc a
        ld [_i], a
        sub 9
        jr nz, .collumnLoop1

      xor a
      ld [_i], a
      ld a, [_j]
      add a, a; j*2
      inc a ;j*2+1
      ld de, 18
      call math_Multiply; hl = 18 * (j*2+1)
      ld b, h
      ld c, l ;bc = (j*2+1)*18
      ld hl, tile_buffer
      add hl, bc ;tiles[(j*2+1)*18]
    .collumnLoop2 ;for (i = 0; i < 9; ++i) {
        xor a
        ld [hli], a ;tiles[(j*2+1)*18+i*2]   = 0;
        ld [hli], a ;tiles[(j*2+1)*18+i*2+1] = 0;
      ld a, [_i]
      inc a
      ld [_i], a
      sub 9
      jr nz, .collumnLoop2

    ld a, [_j]
    inc a
    ld [_j], a
    sub a, 5
    jr nz, .rowLoop

    ld d, 1
    ld e, 5
    ld h, 18
    ld l, 9
    ld bc, tile_buffer
    call gbdk_SetWinTiles;set_win_tiles(1,5,18,9,tile_buffer);

    WAITPAD_UP
  .moveArrowLoop;   while (1) {
      call UpdateInput;k = joypad();
      ld a, [_x]
      ld b, a
      ld d, a
      ld a, [_y]
      ld c, a
      ld e, a
    .moveUp;if (button_state & PADF_UP && y > 0) {
      ld a, [button_state]
      and PADF_UP
      jr z, .moveDown
      ld a, [_y]
      and a
      jr z, .moveDown
      dec e
      ld a, e
      ld [_y], a;--y;
      call MoveTextEntryArrow;  move_text_entry_arrow(x,y,x,y-1);
      jp .startOrAPressed
    .moveDown;else if (button_state & PADF_DOWN && y < 5) {
      ld a, [button_state]
      and PADF_DOWN
      jr z, .moveLeft
      ld a, [_y]
      sub a, 5
      jr z, .moveLeft
      inc e
      ld a, e
      ld [_y], a;++y;
      call MoveTextEntryArrow;  move_text_entry_arrow(x,y,x,y+1);
      jp .startOrAPressed
    .moveLeft;else if (button_state & PADF_LEFT && x > 0 && y < 5) {
      ld a, [button_state]
      and PADF_LEFT
      jr z, .moveRight
      ld a, [_y]
      sub a, 5
      jr z, .moveRight
      ld a, [_x]
      and a
      jr z, .moveRight
      dec d
      ld a, d
      ld [_x], a;  --x;
      call MoveTextEntryArrow;  move_text_entry_arrow(x,y,x-1,y);
      jp .startOrAPressed
    .moveRight;else if (button_state & PADF_RIGHT && x < 8 && y < 5) {
      ld a, [button_state]
      and PADF_RIGHT
      jr z, .startOrAPressed
      ld a, [_y]
      sub a, 5
      jr z, .startOrAPressed
      ld a, [_x]
      sub a, 8
      jr z, .startOrAPressed
      inc d
      ld a, d
      ld [_x], a;  ++x;
      call MoveTextEntryArrow;  move_text_entry_arrow(x,y,x+1,y);
    .startOrAPressed ;if (button_state & (PADF_START | PADF_A)) {
      ld a, [button_state]
      and PADF_START | PADF_A
      jp z, .bPressed
      ld a, [_y]
      sub a, 5
      jr nz, .testEnd;       if (y == 5) {
      PLAY_SFX SelectSound
      ld a, [_c]
      ld b, a
      ld a, 1
      sub a, b
      ld [_c], a ;c = 1-c;
      jp .exitMoveArrowLoop ;break;
    .testEnd ; else if (str_buff[y*9+x] == '\x1E') {
      ld hl, str_buffer
      xor a
      ld b, a
      ld a, [_y]
      add a, a;y*2
      add a, a;y*4
      add a, a;y*8
      ld c, a
      ld a, [_y]
      add a, c;y*9
      ld c, a
      ld a, [_x]
      add a, c;y*9+x
      ld c, a
      add hl, bc ;str_buff[y*9+x]
      ld a, [hl]
      cp "↵" ;0x1E
      jp nz, .testLength
      ld a, [_l]
      and a
      jp nz, .exitTextEntryLoop ; if (l > 0) return;
      jp .waitVBL
    .testLength;else if (l < max_len) {
      ld a, [_l]
      pop hl ;str
      pop de ;e = max_len
      push de
      push hl
      cp e
      jr nc, .waitVBL
      pop hl ;str
      push hl
      ld c, a; _l
      inc a
      ld [_l], a;_l++
      xor a
      ld b, a
      add hl, bc;hl = str[_l]
      push hl ;str[_l]
      ld hl, str_buffer
      ld a, [_y]
      add a, a;y*2
      add a, a;y*4
      add a, a;y*8
      ld c, a
      ld a, [_y]
      add a, c;y*9
      ld c, a
      ld a, [_x]
      add a, c;y*9+x
      ld c, a
      add hl, bc ;str_buff[y*9+x]
      pop bc;str[_l]
      ld a, [hl]
      ld [bc], a ;str[l++] = str_buff[y*9+x];

      inc bc ;make sure there is a 0 at the end of the string
      xor a
      ld [bc], a
      dec bc

      pop hl ;str
      pop de ;e = max_len
      push de
      ld d, e ;d = max_len
      xor a
      ld e, a
      push hl ;str
      call UpdateTextEntryDisplay;update_text_entry_display(str, max_len);
      PLAY_SFX SelectSound
      WAITPAD_UP
      jr .waitVBL
    .bPressed;     else if (button_state & PADF_B && l > 0) {
      ld a, [button_state]
      and PADF_B
      jr z, .waitVBL
      ld a, [_l]
      and a
      jr z, .waitVBL
      dec a
      ld [_l], a;--l
      ld c, a
      xor a
      ld b, a
      pop hl;str
      push hl
      add hl, bc;str[l]
      ld [hl], a;str[l] = 0;
      pop hl;str
      pop de ;e = max_len
      push de
      ld d, e ;d = max_len
      xor a
      ld e, a
      push hl;str
      call UpdateTextEntryDisplay ;update_text_entry_display(str, max_len);
      WAITPAD_UP
    .waitVBL
      call gbdk_WaitVBL
      jp .moveArrowLoop
  .exitMoveArrowLoop
    jp .drawTextBoxLoop
.exitTextEntryLoop
  PLAY_SFX SelectSound
  pop af;str
  pop af;a = max_len

  POP_VAR _y
  POP_VAR _x
  POP_VAR _l
  POP_VAR _j
  POP_VAR _i
  POP_VAR _c
  ret

DrawListEntry:; a=draw flags, bc=xy, de=wh, hl=text
  ;store register state
  push bc ;xy
  push de ;wh
  push hl ;text

  ;reorganize registers to use with gbdk_SetBkgTiles
  pop bc ;text
  pop hl ;wh
  pop de ;xy
  push de ;xy
  push hl ;wh
  push bc ;text

  push af ;draw flags

  ld a, d
  add a, 2
  ld d, a;x = x+2
  ld a, [_j]
  ld e, a;y = _j
  pop af ;draw flags
  push af ;draw flags
  and a, DRAW_FLAGS_PAD_TOP
  rr a
  add a, e
  ld e, a;+1 if pad
  ld a, [_l]
  ld h, a;w = _l
  ld a, 1
  ld l, a;h = 1
  ld bc, tile_buffer
  pop af;draw flags
  call SetTiles

  ;restore initial register state
  pop hl ;text
  pop de ;wh
  pop bc ;xy
  ret 

UIShowListMenu::; a = draw flags, bc = xy, de = wh, text = [str_buffer], title = [name_buff], returns choice in a
  ld h, a;draw flags
  PUSH_VAR _c
  PUSH_VAR _j
  PUSH_VAR _l
  ld a, h ;draw flags
  push af ;draw flags
  push bc ;xy
  push de ;wh
  call DrawUIBox
  pop de ;wh
  pop bc ;xy
  pop af ;draw flags
  push af ;draw flags

  xor a
  ld [_l], a ; length of current entry
  ld [_c], a ; number of rows (used later)
  ld a, c
  add a, 1
  ld [_j], a ;y position to draw entry
  ld hl, str_buffer ; first letter of current entry (from text)
  pop af ;draw flags
.drawListEntriesLoop
    push bc ;xy
    push de ;wh
    push hl ;text
    push af ;draw flags
  .testNewLine; if (text[k] == '\n') {
    ld a, [hl] ;text
    cp "\n"
    jr nz, .testStringEnd
    pop af ;draw flags
    push af
    call DrawListEntry
    xor a
    ld [_l], a
    pop af;draw flags
    push af;draw flags
    ld c, 2;spacing
    and a, DRAW_FLAGS_NO_SPACE
    jr z, .incrementY
    ld c, 1
  .incrementY
    ld a, [_j]
    add a, c;spacing
    ld [_j], a
    ld a, [_c]
    inc a
    ld [_c], a
    pop af;draw flags
    pop hl;text
    push af
    push hl
    jr .nextCharacter
  .testStringEnd; else if (text[k] == '\0') {
    and a
    jr nz, .copyCharacterToTiles
    pop af ;draw flags
    push af
    call DrawListEntry
    ld a, [_c]
    inc a
    ld [_c], a
    pop af ;draw flags
    pop hl ;text
    pop de ;wh
    pop bc ;xy
    jr .exitDrawListEntriesLoop ;break;
  .copyCharacterToTiles; else tiles[++l] = text[k];
    ld hl, tile_buffer
    xor a
    ld b, a
    ld a, [_l]
    ld c, a
    inc a
    ld [_l], a
    add hl, bc
    pop af;draw flags
    pop bc ;text
    push af;draw flags
    ld a, [bc]
    ld [hl], a
    push bc ;text
  .nextCharacter
    pop hl ;text
    pop af ;draw flags
    inc hl
    pop de ;wh
    pop bc ;xy
    jp .drawListEntriesLoop

.exitDrawListEntriesLoop
  push bc ;xy
  push de ;wh

  push af ;draw flags
  ld a, [list_selection]
  ld [_j], a
  
  ld d, b
  inc d
  ld e, c
  inc e
  pop af ;draw flags
  push af ;draw flags
  call DrawListMenuArrow
  pop af ;draw flags

  pop de ;wh
  pop bc ;xy
  
  push bc ;xy
  push de ;wh
  push af ;draw flags
.drawTitle
  push de ;wh
  ld hl, name_buffer
  call str_Length; puts length in de
  ld a, e ;assumes length is less than 256
  pop de ;wh
  ld e, a ;l = strlen(title);
  and a
  jr z, .skipTitle;if (l > 0) {
  ld a, d ;w
  sub a, e ;w-l
  srl a;i = (w-l)/2;
  add a, b;x+i
  ld b, a
  ld d, e ;w = l
  ld a, 1
  ld e, a ;h = 1
  ;surely there's a better way to do this than rearrange registers
  pop af ;draw flags
  push bc ;xy
  push de ;wh
  ld bc, name_buffer
  pop hl ;wh
  pop de ;xy
  push af
  call SetTiles ;set_bkg_tiles(x+i,y,l,1,title);
  pop af
  pop de
  push de
  push af
.skipTitle
  pop af
  pop de ;wh
  pop bc ;xy

  push bc ;xy
  push af;draw flags
  WAITPAD_UP;update_waitpadup();
  ld a, [list_selection]
  ld [_j], a ;j = 0;
.moveMenuArrowLoop ;while (1) {
    call UpdateInput
    pop af;draw flags
    pop de;xy
    push de
    inc d
    inc e
    push af;draw flags
    call MoveListMenuArrow
  .selectMenuItem ;if (button_state & (PADF_START | PADF_A)) 
    ld a, [button_state]
    and a, PADF_START | PADF_A
    jr z, .back
    PLAY_SFX SelectSound
    ld a, [_j]
    inc a ;return j+1;
    jr .exitMenu
  .back ;else if (button_state & PADF_B) 
    ld a, [button_state]
    and a, PADF_B
    jr z, .waitVBLThenLoop
    xor a ;return 0;
    jr .exitMenu
  .waitVBLThenLoop
    call gbdk_WaitVBL ;update_vbl();
    jp .moveMenuArrowLoop
.exitMenu
  pop de ;discard draw flags
  pop bc ;xy

  ld h, a;choice
  POP_VAR _l
  POP_VAR _j
  POP_VAR _c
  ld a, h;choice
  ret

UIShowNumberPicker::; a = draw flags, bc = xy, de = wh, hl = max/start nums, returns number in a (0 = cancel)
  push hl;max/start nums
  push bc;xy
  push af;draw flags
  call DrawUIBox

  ld a, "x"
  ld [name_buffer], a
  pop af;draw flags
  pop de;xy
  inc d
  inc e
  push de;xy
  push af;draw flags
  ld bc, name_buffer
  ld hl, $0101
  call SetTiles

  pop hl;draw flags
  pop de;xy
  inc d
  pop bc;max/start nums
.loop
    push hl;draw flags
    push de;xy
    push bc;max/current nums

    ld h, 0
    ld l, c
    ld de, name_buffer
    call str_Number

    pop bc;max/current nums
    push bc
    ld a, c
    cp a, 10
    jr nc, .drawDigits

    ld hl, name_buffer
    ld a, [hli]
    ld [hld], a
    ld a, "0"
    ld [hl], a

  .drawDigits
    pop bc;max/current nums
    pop de;xy
    pop af;draw flags
    push af;draw flags
    push de;xy
    push bc;max/current nums
    ld bc, name_buffer
    ld hl, $0201
    call SetTiles

  .inputLoop
      call gbdk_WaitVBL
      call UpdateInput
    .wait
      ld a, [last_button_state]
      and a
      jr nz, .inputLoop
    .checkUp
      ld a, [button_state]
      and a, PADF_UP
      jr z, .checkDown
      pop bc;max/current nums
      ld a, c;current num
      cp a, b
      jr c, .currentLessThanMax
      ld c, 0;wrap around
    .currentLessThanMax
      inc c
      push bc;max/current nums
      jr .finishInput

    .checkDown
      ld a, [button_state]
      and a, PADF_DOWN
      jr z, .checkStartA
      pop bc;max/current nums
      dec c
      jr nz, .currentGreaterThanZero
      ld c, b;wrap around
    .currentGreaterThanZero
      push bc;max/current nums
      jr .finishInput

    .checkStartA
      ld a, [button_state]
      and a, PADF_A | PADF_START
      jr z, .checkB
      PLAY_SFX SelectSound
      pop bc;max/current nums
      pop de;xy
      pop hl;draw flags
      ld a, c;selected num
      ret
    .checkB
      ld a, [button_state]
      and a, PADF_B
      jr z, .inputLoop
      pop bc;max/current nums
      pop de;xy
      pop hl;draw flags
      xor a
      ret

  .finishInput
    pop bc;max/current nums
    pop de;xy
    pop hl;draw flags
    jp .loop

UIDrawSaveStats::;a = draw flags, de = xy
  push de;xy
  push af;draw flags
  HIDE_ALL_SPRITES

  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  ld b, d
  ld c, e
  ld d, 16
  ld e, 10
  pop af;draw flags
  push af
  call DrawUIBox

.drawCoachText
  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  inc d;x+1
  inc e
  inc e;y+2
  ld h, 5
  ld l, 1
  ld bc, CoachStatText
  pop af;draw flags
  push af
  call SetTiles

  ld hl, user_name
  ld de, name_buffer
  ld bc, 8
  call mem_Copy

.drawCoachName
  ld hl, name_buffer
  call str_Length
  ld h, e
  ld l, 1
  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  ld a, 10
  add a, d
  ld d, a;x+10
  inc e
  inc e;y+2
  ld bc, name_buffer
  pop af;draw flags
  push af
  call SetTiles

.drawPennantsText
  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  inc d;x+1
  ld a, 4
  add a, e
  ld e, a;y+4
  ld h, 8
  ld l, 1
  ld bc, PennantsStatText
  pop af;draw flags
  push af
  call SetTiles

.drawPennantsCount
  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  ld a, 14
  add a, d
  ld d, a;x+14
  ld a, 4
  add a, e
  ld e, a;y+4
  ld h, 1
  ld l, 1
  ld bc, str_buffer
  ld a, "0"
  ld [bc], a
  pop af;draw flags
  push af
  call SetTiles

.drawRoledexText
  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  inc d;x+1
  ld a, 6
  add a, e
  ld e, a;y+6
  ld h, 7
  ld l, 1
  ld bc, RoledexStatText
  pop af;draw flags
  push af
  call SetTiles

.drawSignedCount
  call GetSeenSignedCounts
  ld h, 0
  ld l, e;signed
  ld de, name_buffer
  call str_Number

  ld hl, name_buffer
  call str_Length
  ld h, e;width
  ld l, 1;height
  ld a, 3
  sub a, h
  ld b, a;x offset

  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags

  ld a, 12
  add a, d;x+12
  add a, b;x+12+offset
  ld d, a;x = x+12+offset
  ld a, b
  ld a, 6
  add a, e
  ld e, a;y+6
  ld bc, name_buffer
  pop af;draw flags
  push af
  call SetTiles

.drawTimeText
  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  inc d;x+1
  ld a, 8
  add a, e
  ld e, a;y+8
  ld h, 4
  ld l, 1
  ld bc, TimeStatText
  pop af;draw flags
  push af
  call SetTiles

  TRAMPOLINE GetTimePlayedString
  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  ld hl, str_buffer
  call str_Length
  
  ld h, e;w
  ld l, 1;h
  pop af;draw flags
  ld b, a;draw flags
  pop de;xy
  ld a, 15
  add a, d;x
  sub a, h;x-w
  ld d, a
  ld a, 8
  add a, e
  ld e, a;y
  ld a, b;draw flags
  ld bc, str_buffer
  call SetTiles
  ret
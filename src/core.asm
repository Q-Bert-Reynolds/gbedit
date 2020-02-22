SECTION "Core", ROM0
Types:
DB "Normal", 0
DB "Fire", 0
DB "Water", 0
DB "Electric", 0
DB "Grass", 0
DB "Ice", 0
DB "Fighting", 0
DB "Poison", 0
DB "Ground", 0
DB "Flying", 0
DB "Psychic", 0
DB "Bug", 0
DB "Rock", 0
DB "Ghost", 0
DB "Dragon", 0

GetTypeString:: ;a = type, string in name_buffer
  ld hl, Types
  ld b, a
  dec b
.loop
    ld a, b
    and a
    jr z, .copy;found name
    ld a, [hli]
    and a
    jr nz, .loop
    dec b
    jr .loop
.copy
  ld de, name_buffer
  call str_Copy
  ret

SetBank:: ;a = BANK ;TODO: handle more than 255 banks
  ld [loaded_bank], a
  ld [rROMB0], a
  ret
  
LCDInterrupt::
  push af
  push bc
  push de
  push hl
  ld hl, rLCDInterrupt
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, b
  ld l, a
  jp hl
EndLCDInterrupt::; all interrupts should jump here 
  pop hl 
  pop de
  pop bc
  pop af
  reti

VBLInterrupt::
  push af
  push bc
  push de
  push hl
  call _HRAM
  call UpdateAudio
  ld a, 1
  ld [vbl_done], a
  pop hl 
  pop de
  pop bc
  pop af
  reti
 
UpdateInput::
  push hl

  ;copy button_state to last_button_state
  ld hl, button_state
  ld a, [hl]
  ld hl, last_button_state
  ld [hl], a

  ;read DPad
  ld hl, rP1
  ld a, P1F_5
  ld [hl], a ;switch to P15
  ld a, [hl] ;load DPad
  and %00001111 ;discard upper nibble
  swap a ;move low nibble to high nibble
  ld b, a ;store DPad in b

  ;read A,B,Select,Start
  ld hl, rP1
  ld a, P1F_4
  ld [hl], a ;switch to P14
  ld a, [hl] ;load buttons
  and %00001111 ;discard upper nibble
  or b ;combine DPad with other buttons
  cpl ;flip bits so 1 means pressed
  ld hl, button_state
  ld [hl], a

  pop hl
  ret

LoadFontTiles::
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank

  call UILoadFontTiles

  ld a, [temp_bank]
  call SetBank
  ret

SetBKGTilesWithOffset:: ;hl=wh, de=xy, bc=in_tiles, a=offset
  push de ;xy
  push hl ;wh
  push af ;offset
  push bc ;in_tiles

  xor a
  ld d, a
  ld a, h 
  ld e, a ;de = w
  ld a, l ;a = h
  call math_Multiply
  ld a, l ;assumes result is less than 256
  ld [_i], a ;i = w*h
  ld hl, tile_buffer
  pop bc ;in_tiles
.loop ;for (i = w*h; i > 0; --i)

  ld a, [bc]
  inc bc
  ld d, a
  pop af ;offset
  push af ;store off
  add a, d
  ld [hli], a; tiles[i] = in_tiles[i]+offset;
  
  ld a, [_i]
  dec a
  ld [_i], a
  jr nz, .loop

  pop af ;offset
  pop hl ;xy
  pop de ;wh
  ld bc, tile_buffer
  call gbdk_SetBKGTiles ;set_bkg_tiles(x,y,w,h,tiles);
  ret

RevealText:: ;hl = text
  ld de, str_buffer
  call str_Copy

  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank

  ld hl, str_buffer
  call UIRevealText

  ld a, [temp_bank]
  call SetBank
  ret

DrawUIBox: ;Entry: de = wh, Affects: hl
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
  ret

DrawBKGUIBox:: ; bc = xy, de = wh
  push bc ;xy
  push de ;wh
  call DrawUIBox
  pop hl ;wh
  pop de ;xy
  ld bc, tile_buffer
  call gbdk_SetBKGTiles
  ret

DrawWinUIBox:: ; bc = xy, de = wh
  push bc ;xy
  push de ;wh
  call DrawUIBox
  pop hl ;wh
  pop de ;xy
  ld bc, tile_buffer
  call gbdk_SetWinTiles
  ret

DisplayText:: ;hl = text
  push hl;text

  xor a
  ld b, a
  ld c, a
  ld d, 20
  ld e, 6
  call DrawWinUIBox

  pop hl;text
  ld bc, str_buffer
  ld e, 0;len
.loop
    ld a, [hl]
    cp "\n"
    jr z, .drawText
    and a;end of text
    jr z, .drawText
    ld [bc], a;copy text to str_buffer
    inc hl
    inc bc
    inc e;len
    jr .loop

.drawText
  push hl;text left
  ld h, e;w
  ld l, 1;h
  ld d, 1;x
  ld e, 2;y
  ld bc, str_buffer
  call gbdk_SetWinTiles;line 1
  pop hl;text left
  ld a, [hli]
  push hl
  pop bc;text left
  and a
  jr z, .show; if there's not a second line
  call str_Length
  ld h, e;w
  ld l, 1;h
  ld d, 1;x
  ld e, 4;y
  call gbdk_SetWinTiles;line 2

.show
  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a
  SHOW_WIN
  ret

ShowListMenu:: ; bc = xy, de = wh, [str_buffer] = text, [name_buffer] = title, returns a
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank

  call UIShowListMenu ;a = ui_show_list_menu(x,y,w,h,name_buffer,str_buffer);
  push af

  ld a, [temp_bank]
  call SetBank

  pop af
  ret; return a;

ShowTextEntry:: ;bc = title, de = str, l = max_len -> puts text in name_buffer
  push hl ;max_len
  push de ;str
  ld h, b
  ld l, c
  ld de, str_buffer
  call str_Copy; strcpy(str_buffer, title);

  pop hl ;str
  ld de, name_buffer
  call str_Copy; strcpy(name_buffer, str);

  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank
  
  ld de, str_buffer
  ld hl, name_buffer
  pop bc ;max_len
  call UIShowTextEntry ;ui_show_text_entry(str_buffer, name_buffer, max_len);

  ld a, [temp_bank]
  call SetBank
  ret

ShowOptions::
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank

  call UIShowOptions

  ld a, [temp_bank]
  call SetBank
  ret

ShowLineupFromGame::
  ld a, UI_BANK
  call SetBank

  ld a, 1
  call ShowLineup

  ld a, PLAY_BALL_BANK
  call SetBank
  ret

;; moves a grid of sprite tiles
MoveSprites:: ;bc = xy in screen space, hl = wh in tiles, a = first sprite index
  ld [_a], a
  xor a
  ld [_j], a
.rowLoop ;for (j = 0; j < h; j++)
    xor a
    ld [_i], a
.columnLoop ;for (i = 0; i < w; i++)
      ld a, [_i]
      add a ;i*2
      add a ;i*4
      add a ;i*8
      add a, b ;i*8+x
      ld d, a

      ld a, [_j]
      add a; j*2
      add a; j*4
      add a; j*8
      add a, c ;j*8+y
      ld e, a

      push bc
      ld a, [_a]
      ld c, a
      inc a
      ld [_a], a

      push hl
      call gbdk_MoveSprite;move_sprite(a++, i*8+x, j*8+y);
      pop hl
      pop bc

      ld a, [_i]
      inc a
      ld [_i], a
      sub a, h
      jr nz, .columnLoop

    ld a, [_j]
    inc a
    ld [_j], a
    sub a, l
    jr nz, .rowLoop

  ret

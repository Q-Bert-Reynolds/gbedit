SECTION "Core", ROM0
EmptyString::
  db "", 0

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
  SWITCH_ROM_MBC5 UI_BANK
  call UILoadFontTiles
  RETURN_BANK
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
  call Multiply
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

  SWITCH_ROM_MBC5 UI_BANK
  ld hl, str_buffer
  call UIRevealText
  RETURN_BANK
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
  push hl
  xor a ; draw_win_ui_box(0,0,20,6);
  ld b, a
  ld c, a
  ld a, 20
  ld d, a
  ld a, 6
  ld e, a
  call DrawWinUIBox
  pop hl
  push hl
  call str_Length
  ld a, e ; assumes that de is less than a byte
  ld [_l], a ; l = strlen(text);
  pop hl
  xor a
  ld [_w], a
  ld [_y], a
  ld [_i], a
.loopString; for (i = 0; i < l; ++i) {
  push hl
  xor a
  ld b, a
  ld a, [_i]
  ld c, a
  add hl, bc
  ld a, [hl]
  sub a, "\n"
  jr nz, .skip ;if (text[i] == '\n') {
  pop hl
  push hl
  xor a
  ld b, a
  ld a, [_w]
  ld c, a
  add hl, bc ;text+w
  ld de, str_buffer
  ld a, [_i]
  sub a, c
  ld c, a ;i-w
  call mem_Copy ;memcpy(str_buffer,text+w,i-w);
  ld a, 1
  ld d, a ;x
  ld l, a ;height
  ld a, [_y]
  add a ;*2
  add a, 2 ;2+y*2
  ld e, a ;y
  ld h, c ;i-w still in c
  ld bc, str_buffer
  call gbdk_SetWinTiles ;set_win_tiles(1, 2+y*2, i-w, 1, str_buffer);
  ld a, [_y]
  inc a
  ld [_y], a ;++y
  ld a, [_i]
  inc a
  ld [_w], a ;w = i+1;
.skip
  pop hl
  push hl
  ld a, [_i]
  inc a
  ld [_i], a
  ld b, a
  ld a, [_l]
  sub a, b
  jr nz, .loopString
  pop hl
  xor a
  ld b, a
  ld a, [_w]
  ld c, a
  add hl, bc ;text+w
  ld de, str_buffer
  ld a, [_i]
  sub a, c
  ld c, a ;i-w
  call mem_Copy ; memcpy(str_buffer,text+w,i-w);
  ld a, 1
  ld d, a ;x
  ld l, a ;height
  ld a, [_y]
  add a ;*2
  add a, 2 ;2+y*2
  ld e, a ;y
  ld h, c ;i-w still in c
  ld bc, str_buffer
  call gbdk_SetWinTiles ;set_win_tiles(1, 2+y*2, i-w, 1, str_buffer);
  ld a, 96
  ld hl, rWY
  ld [hli], a
  ld a, 7
  ld [hl], a ; move_win(7,96);
  SHOW_WIN
  ret

ShowListMenu:: ; bc = xy, de = wh, [str_buffer] = text, [name_buffer] = title, returns a
  SWITCH_ROM_MBC5 UI_BANK
  call UIShowListMenu ;a = ui_show_list_menu(x,y,w,h,name_buffer,str_buffer);
  RETURN_BANK
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

  SWITCH_ROM_MBC5 UI_BANK
  ld de, str_buffer
  ld hl, name_buffer
  pop bc ;max_len
  call UIShowTextEntry ;ui_show_text_entry(str_buffer, name_buffer, max_len);
  RETURN_BANK
  ret

ShowOptions::
  SWITCH_ROM_MBC5 UI_BANK
  call UIShowOptions
  RETURN_BANK
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
  
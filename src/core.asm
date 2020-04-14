SECTION "Core", ROM0
Types:
  DB "", 0
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

Status:
  DB "OK", 0
  DB "BRN", 0
  DB "FRZ", 0
  DB "PAR", 0
  DB "PSN", 0
  DB "SLP", 0

GetTypeString:: ;a = type, string in name_buffer
  ld hl, Types
  call GetStringAFromListHL
  ret

GetStatusString:: ;a = status, string in name_buffer
  ld hl, Status
  call GetStringAFromListHL
  ret

GetStringAFromListHL:: ;a = type, hl = list, returns string in name_buffer
  ld b, a
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
  ld bc, EndLCDInterrupt
  push bc ;put return addres on stack before jumping
  jp hl
EndLCDInterrupt::
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
  ld a, [vbl_timer]
  inc a
  ld [vbl_timer], a
  call UpdateAudio
  ld a, 1
  ld [vbl_done], a
  pop hl 
  pop de
  pop bc
  pop af
  reti
 
UpdateInput::
  push bc
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
  pop bc
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

DrawStateMap::
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank

  call UIDrawStateMap

  ld a, [temp_bank]
  call SetBank
  ret

SetTiles::;a = draw flags, hl=wh, de=xy, bc=firstTile
  and a, DRAW_FLAGS_WIN
  jr z, .skip
  call gbdk_SetWinTiles
  ret
.skip
  call gbdk_SetBkgTiles
  ret

SetBKGTilesWithOffset:: ;hl=wh, de=xy, bc=in_tiles, a=offset
  ld [_breakpoint], a
  push de ;xy
  push hl ;wh
  push af ;offset
  push bc ;in_tiles

  ld d, 0
  ld e, h ;de = width
  ld a, l ;a = height
  call math_Multiply
  pop bc;in_tiles
  pop af;offset
  push hl;count
  push af;offset
  ld hl, tile_buffer
.loop ;for (i = w*h; i > 0; --i)
    ld a, [bc]
    inc bc
    ld d, a
    pop af ;offset
    push af ;offset
    add a, d
    ld [hli], a; tiles[i] = in_tiles[i]+offset;
    
    pop af;offset
    pop de;count
    dec de
    push de;count
    push af;offset

    ld a, d
    and a
    jr nz, .loop
    ld a, e
    and a
    jr nz, .loop

  pop af ;count
  pop af ;offset
  pop hl ;xy
  pop de ;wh
  ld bc, tile_buffer
  call gbdk_SetBkgTiles ;set_bkg_tiles(x,y,w,h,tiles);
  ret

RevealTextAndWait:: ;hl = text
  ld de, str_buffer
  call str_Copy

  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank

  ld hl, str_buffer
  ld a, DRAW_FLAGS_PAD_TOP
  call UIRevealTextAndWait

  ld a, [temp_bank]
  call SetBank
  ret

RevealText:: ;a = draw flags, de = xy hl = text
  push af;draw flags
  push de;xy
  ld de, str_buffer
  call str_Copy

  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank

  pop de;xy
  pop af;draw flags
  ld hl, str_buffer
  call UIRevealText

  ld a, [temp_bank]
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

DisplayText:: ;a = draw flags, hl = text
  push hl;text
  push af;draw flags

  xor a
  ld b, a
  ld c, a
  ld d, 20
  ld e, 6
  pop af;draw flags
  push af
  call DrawUIBox

  pop af
  pop hl
  push af
  ld d, 2
  ld e, 2
  ld bc, 2
  call DrawText ;a = draw flags, hl = text, de = xy, bc = max lines

.show
  pop af;draw flags
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
  xor a
  ld [_i], a
  ld hl, tile_buffer
.tilesLoop; for (i = 0; i < c; ++i) {
    xor a
    ld [hli], a;   tiles[i*2] = 0;
    ld a, [_j]
    ld c, a
    ld a, [_i]
    sub a, c ;_i - _j
    jp nz, .setZero ;if (i == _j)
    ld a, ARROW_RIGHT ;tiles[i*2+1] = ARROW_RIGHT;
    jr .skip
.setZero
    xor a ;else tiles[i*2+1] = 0;
.skip
    ld [hli], a ;tiles[i*2+1]

    ld a, [_i]
    inc a
    ld [_i], a;++_i
    ld b, a
    ld a, [_c]
    sub a, b ;_c-_i
    jp nz, .tilesLoop

  xor a
  ld [hl], a

  ld a, 1
  ld h, a ;w=1
  ld a, [_c]
  add a, a
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
  ld [_j], a ;--j
  pop af;draw flags
  push af
  call DrawListMenuArrow;move_menu_arrow(--j);
.failMoveUp
  pop af;draw flags
  WAITPAD_UP ;update_waitpadup();
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
  ld [_j], a ;++j
  pop af;draw flags
  push af
  call DrawListMenuArrow;move_menu_arrow(++j);
.failMoveDown
  pop af;draw flags
  WAITPAD_UP ;update_waitpadup();
  ld a, 1
  ret
.noMove
  pop af
  xor a;0
  ret

ShowListMenu:: ;a = draw flags, bc = xy, de = wh, [str_buffer] = text, [name_buffer] = title, returns a
  push af;draw flags
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank
  
  pop af;draw flags
  call UIShowListMenu
  push af;choice

  ld a, [temp_bank]
  call SetBank

  pop af;choice
  ret; return a=choice;

ShowTextEntry:: ;bc = title, de = str, l = max_len -> puts text in name_buffer
  push hl ;max_len
  push de ;str
  ld h, b
  ld l, c
  ld de, str_buffer
  call str_Copy

  pop hl ;str
  ld de, name_buffer
  call str_Copy

  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank
  
  ld de, str_buffer
  ld hl, name_buffer
  pop bc ;max_len
  call UIShowTextEntry

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

DrawSaveStats::;draw flags, de = xy
  push af;draw flags
  push de;xy
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, UI_BANK
  call SetBank

  pop de;xy
  pop af;draw flags
  call UIDrawSaveStats

  ld a, [temp_bank]
  call SetBank
  ret

ShowRoledex::
  ld a, ROLEDEX_BANK
  call SetBank

  call ShowRoledexUI
  
  ld a, OVERWORLD_BANK
  call SetBank
  ret

LoadSimulation::;a = ball speed b = spray angle c = launch angle
  push af;ball speed
  ld a, SIM_BANK
  call SetBank

  pop af;ball speed
  call RunSimulation
  
  ld a, PLAY_BALL_BANK
  call SetBank
  ret

ShowLineupFromWorld::
  ld a, LINEUP_BANK
  call SetBank

  ld a, 0
  call ShowLineup

  ld a, OVERWORLD_BANK
  call SetBank
  ret

ShowLineupFromGame::
  ld a, LINEUP_BANK
  call SetBank

  ld a, 1
  call ShowLineup

  ld a, PLAY_BALL_BANK
  call SetBank
  ret

SetSpriteTiles:: ;bc = count, hl = map, de = offset\props
  xor a
  ld [_i], a
.loop
    push bc;count
    ld a, [_i]
    ld c, a
    ld a, [hli]
    push hl;map index
    add a, d;offset
    push de;offset\props
    ld d, a ;tile
    call gbdk_SetSpriteTile
    ld a, [_i]
    ld c, a
    pop de;offset\props
    push de;offset\props
    ld d, e
    call gbdk_SetSpriteProp
    pop de;offset\props
    pop hl;map index
    ld a, [_i]
    inc a
    ld [_i], a
    pop bc; count
    dec bc
    ld a, b
    or c
    jr nz, .loop
  ret

SetSpriteTilesProps:: ;bc = offset\count, hl = tilemap, de = propmap
  xor a
  ld [_i], a
.loop
    push bc;offset\count
    ld a, [_i]
    add a, b
    ld c, a
    ld a, [hli]
    push hl;tilemap index
    add a, b;offset
    push de;propmap
    ld d, a ;tile
    push bc;offset & sprite/prop num
    call gbdk_SetSpriteTile
    pop bc;offset & sprite/prop num
    pop de;propmap
    ld a, [de]
    inc de
    push de;propmap
    ld d, a
    call gbdk_SetSpriteProp
    pop de;propmap
    pop hl;tilemap
    ld a, [_i]
    inc a
    ld [_i], a
    pop bc; count
    dec c
    jr nz, .loop
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

;; sets and moves a grid of sprite tiles, skips tiles according to flags
SetSpriteTilesXY:: ;bc = xy in screen space, hl = wh in tiles, de = tilemap, a = VRAM offset
  ld [sprite_offset], a;offset
  ld [_a], a;first tile
  xor a
  ld [_j], a
.rowLoop ;for (j = 0; j < h; j++)
    xor a
    ld [_i], a
.columnLoop ;for (i = 0; i < w; i++)
      push bc;xy
      push hl;wh

      ld a, [sprite_flags]
      and SPRITE_FLAGS_SKIP
      jr z, .noSkip
      ld a, [sprite_skip_id]
      ld h, a
      ld a, [de]
      cp h;skip me
      jr z, .skip
.noSkip
      push de;tilemap
      
      ld a, [_a]
      ld e, a
      inc a
      ld [_a], a
      ld hl, oam_buffer
      sla e ;multiply e by 4
      sla e
      ld d, 0
      add hl, de

      ld a, [_j]
      add a; j*2
      add a; j*4
      add a; j*8
      add a, c ;j*8+y
      ld [hli], a;y

      ld a, [_i]
      add a ;i*2
      add a ;i*4
      add a ;i*8
      add a, b ;i*8+x
      ld [hli], a;x

      ld a, [sprite_offset];offset
      ld b, a
      pop de;tilemap
      ld a, [de]
      add a, b
      ld [hli], a;tile

      ld a, [sprite_props]
      ld [hli], a

.skip
      inc de;tile index
      pop hl;wh
      pop bc;xy

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

  ld a, [sprite_flags]
  and SPRITE_FLAGS_CLEAR_END
  ret z

  ld a, [_a]
  ld e, a
  ld hl, oam_buffer
  sla e ;multiply e by 4
  sla e
  ld d, 0
  add hl, de
  ld a, 40
  sub a, e
  sla a
  sla a
  ld b, 0
  ld c, a
  xor a
  call mem_Set

  ret

FlipTileMapX;hl=wh; bc=in_tiles, de=out_tiles
  push hl;wh
  xor a
  ld [_j], a
.rowLoop
    pop hl;wh
    push hl
    ld a, h
    ld [_i], a

    push de;out_tiles
    ld d, 0
    ld e, a
    ld a, [_j]
    inc a
    call math_Multiply
    dec hl
    add hl, bc
    pop de;out_tiles
.columnLoop
      ld a, [hld]
      ld [de], a
      inc de

      ld a, [_i]
      dec a
      ld [_i], a
      jr nz, .columnLoop
    ld a, [_j]
    inc a
    ld [_j], a
    pop hl;wh
    push hl
    cp l
    jr nz, .rowLoop

  pop hl
  ret

ReverseByte:;byte in a
  push bc
  ld b,a    ; a = 76543210
  rlca
  rlca      ; a = 54321076
  xor b
  and $AA
  xor b     ; a = 56341270
  ld b,a
  rlca
  rlca
  rlca      ; a = 41270563
  rrc b     ; b = 05634127
  xor b
  and $66
  xor b     ; a = 01234567
  pop bc
  ret

SetHPBarTiles::;de = player, hl = address
  push hl;address
  ld h, d
  ld l, e
  push hl;player
  call GetPlayerHP
  ld d, h
  ld e, l
  ld a, 96;makes the math easier than multiplying by 100
  call math_Multiply
  ld d, h
  ld e, l;hp*100
  pop hl;player
  call GetPlayerMaxHP
  ld b, h
  ld c, l;maxHP
  ld h, d
  ld l, e;hp*100
  call math_Divide16;de (remainder hl) = hl / bc
  ;de = HP * 100 / maxHP
  pop hl;address
  ld a, 128
  ld [hli], a

  ld b, 6
  ld c, 16
.loop
    ld a, c;tile*16
    sub a, e;hp pct
    jr nc, .drawPartial
    ld a, 129
    ld [hli], a
    jr .next
.drawPartial;c-e < 16
    cp 16
    jr nc, .drawEmpty
    srl a;(c-e)/2 < 8
    ld d, a
    ld a, 129
    add a, d
    ld [hli], a
    jr .next
.drawEmpty
    ld a, 137
    ld [hli], a
.next
    ld a, c
    add a, 16
    ld c, a
    
    dec b
    ld a, b
    and a
    jr nz, .loop  

  ld a, 138
  ld [hli], a
  ret

SetLevelTiles::;de = player, hl = address
  push hl;address
  push de;player
  ld a, LEVEL
  ld [hl], a

  pop hl;player
  call GetPlayerLevel
  ld h, 0
  ld l, a
  pop de; address
  cp 100
  jr z, .level100
  inc de
.level100
  call str_Number
  ret

SetMovePPTiles::;a = move, de = player, hl = tile address
  push hl;address
  push de;player

  pop hl;player
  push hl;player  
  push af;move
  call GetPlayerMove

  pop af;move
  pop hl;player
  call GetPlayerMovePP
  ld h, 0
  ld l, a
  ld de, str_buffer
  cp 10
  jr nc, .twoDigitPP
  ld a, " "
  ld [de], a
  inc de
.twoDigitPP
  call str_Number

  ld hl, name_buffer
  ld a, "/"
  ld [hli], a
  xor a
  ld [hld], a
  ld de, str_buffer
  call str_Append

  ld hl, move_data+2;max move pp
  ld a, [hl]
  ld de, name_buffer
  cp 10
  jr nc, .twoDigitMaxPP
  ld a, " "
  ld [de], a
  inc de
.twoDigitMaxPP
  ld a, [hl]
  ld h, 0
  ld l, a
  call str_Number
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

  ld hl, str_buffer
  pop de; address
  call str_Copy

  ret

ScrollXYToTileXY::;returns xy in de
  ld a, [rSCX]
  rra;x/2
  rra;x/4
  rra;x/8
  ld d, a ; x
  
  ld a, [rSCY]
  rra;x/2
  rra;x/4
  rra;x/8
  ld e, a ; y
  ret

DistanceToScreenOrVRAMEdge::;tile xy in de, returns wh in hl
  ld a, 32
  sub a, d
  ld h, a ; w
  ld a, 20
  cp h
  jr nc, .skipWidth
  ld h, a
.skipWidth

  ld a, 32
  sub a, e
  ld l, a ; h
  ld a, 18
  cp l
  jr nc, .skipHeight
  ld l, a
.skipHeight

  ret 

CopyBkgToWin::
  call ScrollXYToTileXY;de
  call DistanceToScreenOrVRAMEdge;hl
  
  push hl;wh
  push de;xy
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles

  pop de;xy
  pop hl;wh
  push hl
  push de
  ld de, 0
  ld bc, bkg_buffer
  call gbdk_SetWinTiles

  pop de;xy
  pop hl;wh
  push hl
  push de

    ld a, 32-20
    cp d
    jr nc, .skipRight
    ld d, h;x = left width
    ld a, 20
    sub a, h
    ld h, a; right width

    push hl;wh
    push de;xy
    ld d, 0
    ld bc, bkg_buffer
    call gbdk_GetBkgTiles

    pop de;xy
    pop hl;wh
    push hl
    push de
    ld e, 0
    ld bc, bkg_buffer
    call gbdk_SetWinTiles

    pop de;xy
    pop hl;wh
    
    ld a, 32-18
    cp e
    jr nc, .skipRight;skip bottom right
    ld e, l;y = upper height
    ld a, 18
    sub a, l
    ld l, a; bottom right height

    push hl;wh
    push de;xy
    ld de, 0
    ld bc, bkg_buffer
    call gbdk_GetBkgTiles

    pop de;xy
    pop hl;wh
    ld bc, bkg_buffer
    call gbdk_SetWinTiles
.skipRight

  pop de;xy
  pop hl;wh
  ld a, 32-18
  cp e
  jr nc, .skipBottom;skip bottom 
  ld e, l;y = upper height
  ld a, 18
  sub a, l
  ld l, a; bottom height

  push hl;wh
  push de;xy
  ld e, 0
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles

  pop de;xy
  pop hl;wh
  ld d, 0
  ld bc, bkg_buffer
  call gbdk_SetWinTiles
.skipBottom
  
  ret

YesNoText:
  DB "YES\nNO",0

SaveGameText:
  DB "Would you like to\nSAVE the game?",0

SaveGame::
  ld d, 4
  ld e, 0
  ld a, DRAW_FLAGS_WIN
  call DrawSaveStats

  ld de, 12;(0,12)
  ld hl, SaveGameText
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText

  ld hl, YesNoText
  ld de, str_buffer
  call str_Copy
  ld hl, name_buffer
  xor a
  ld [hl], a
  ld bc, 7;(0,7)
  ld d, 6
  ld e, 5
  ld a, DRAW_FLAGS_WIN
  call ShowListMenu
  ret

GetZeroPaddedNumber::;a = number, returns padded number in str_buffer, affects str_buffer, all registers
  ld h, 0
  ld l, a
  ld de, name_buffer
  call str_Number

  ld hl, str_buffer
  ld a, "0"
  ld [hli], a
  ld [hli], a
  ld [hli], a

  ld hl, name_buffer
  call str_Length
  ld a, 3
  sub a, e
  ld e, a
  ld hl, str_buffer
  add hl, de
  ld d, h
  ld e, l
  ld hl, name_buffer
  call str_Copy
  ret

SignedRandom: ;a = bitmask
  push af
  call gbdk_Random
  pop af
  push af
  and a, d
  ld b, a
  ld a, d
  and %10000000
  jr z, .skipD
  ld a, b
  xor a, $FF
  add a, 1
  ld b, a
.skipD
  ld d, b

  pop af
  and a, e
  ld b, a
  ld a, e
  and %10000000
  jr z, .skipE
  ld a, b
  xor a, $FF
  add a, 1
  ld b, a
.skipE
  ld e, b

  ret

;----------------------------------------------------------------------
;
; DistanceFromSpeedLaunchAngle - calculates distance speed and angle
;
;   input: 
;     a = speed (0 to 255)
;     b = launch angle (-127 to 127)
;   returns:
;     a = distance
;
;----------------------------------------------------------------------
DistanceFromSpeedLaunchAngle::;a = speed, b = launch angle, returns distance in a
  ;TODO
  ret
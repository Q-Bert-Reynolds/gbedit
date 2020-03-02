DrawStatScreen:;player in hl
  push hl
  DISPLAY_OFF
  CLEAR_TILES " "

  ld a, 40
  ld [_i], a
  ld bc, 4
  ld hl, oam_buffer+1
.hideSpritesLoop
    ld a, [hl]
    add a, 160; move off screen
    ld [hl], a
    add hl, bc
    ld a, [_i]
    dec a
    ld [_i], a
    and a
    jr nz, .hideSpritesLoop

  pop hl
  push hl
  call DrawPageOne
  DISPLAY_ON
  WAITPAD_UP
  call WaitForABStart

  pop hl
  call DrawPageTwo
  call WaitForABStart

  ld a, 40
  ld [_i], a
  ld bc, 4
  ld hl, oam_buffer+1
.showSpritesLoop
    ld a, [hl]
    sub a, 160; move on screen
    ld [hl], a
    add hl, bc
    ld a, [_i]
    dec a
    ld [_i], a
    and a
    jr nz, .showSpritesLoop
  ret 

WaitForABStart:
    call gbdk_WaitVBL
    call UpdateInput
    ld a, [button_state]
    and a, PADF_A | PADF_B | PADF_START
    jr z, WaitForABStart
  WAITPAD_UP
  ret

StatNames:
  DB "BAT  "
  DB "     "
  DB "FIELD"
  DB "     "
  DB "SPEED"
  DB "     "
  DB "THROW"

TypeString:
  DB "TYPE",0

DrawPageOne:
  push hl;player
  call GetPlayerNumber
  push af;num

  ld de, _UI_FONT_TILE_COUNT+64
  call LoadPlayerBkgDataXFlipped

  pop af;num
  push af
  call GetPlayerImgColumns
  ld b, a
  ld a, 7
  sub a, b
  ld c, a
  ld b, a
  and a
  jr nz, .setPlayerTiles
  inc b
.setPlayerTiles
  ld de, _UI_FONT_TILE_COUNT+64
  pop af;num
  push af
  call SetPlayerBkgTilesFlipped

  pop af;num
  pop hl;player
  push hl;player
  push af;num
  call GetUserPlayerName

  ld hl, name_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld d, 9
  ld e, 1
  ld bc, name_buffer
  call gbdk_SetBkgTiles

  pop af;num
  ld h, 0
  ld l, a
  ld de, name_buffer
  call str_Number

  ld hl, str_buffer
  ld a, "#"
  ld [hli], a
  ld a, "0"
  ld [hli], a
  ld [hli], a
  ld [hli], a

  ld hl, name_buffer
  call str_Length
  ld a, 4
  sub a, e
  ld e, a
  ld hl, str_buffer
  add hl, de
  ld d, h
  ld e, l
  ld hl, name_buffer
  call str_Copy

  ld h, 4
  ld l, 1
  ld d, 2
  ld e, 7
  ld bc, str_buffer
  call gbdk_SetBkgTiles

  ;stat box
  ld b, 0
  ld c, 8
  ld d, 10
  ld e, 10
  call DrawBKGUIBox

  ld d, 1
  ld e, 9
  ld h, 5
  ld l, 7
  ld bc, StatNames
  call gbdk_SetBkgTiles

  pop hl;player
  push hl
  call GetPlayerBat
  ld de, name_buffer
  call str_Number
  ld hl, name_buffer
  call str_Length
  ld a, 9
  sub a, e
  ld h, e
  ld l, 1
  ld d, a
  ld e, 10
  ld bc, name_buffer
  call gbdk_SetBkgTiles

  pop hl;player
  push hl
  call GetPlayerField
  ld de, name_buffer
  call str_Number
  ld hl, name_buffer
  call str_Length
  ld a, 9
  sub a, e
  ld h, e
  ld l, 1
  ld d, a
  ld e, 12
  ld bc, name_buffer
  call gbdk_SetBkgTiles

  pop hl;player
  push hl
  call GetPlayerSpeed
  ld de, name_buffer
  call str_Number
  ld hl, name_buffer
  call str_Length
  ld a, 9
  sub a, e
  ld h, e
  ld l, 1
  ld d, a
  ld e, 14
  ld bc, name_buffer
  call gbdk_SetBkgTiles

  pop hl;player
  push hl
  call GetPlayerThrow
  ld de, name_buffer
  call str_Number
  ld hl, name_buffer
  call str_Length
  ld a, 9
  sub a, e
  ld h, e
  ld l, 1
  ld d, a
  ld e, 16
  ld bc, name_buffer
  call gbdk_SetBkgTiles

  pop de;player
  push de
  ld hl, tile_buffer
  call SetLevelTiles;de = player, hl = address
  ld h, 3
  ld l, 1
  ld d, 15
  ld e, 2
  ld bc, tile_buffer
  call gbdk_SetBkgTiles

  pop de;player
  push de
  ld hl, tile_buffer
  call SetHPBarTiles
  ld h, 8
  ld l, 1
  ld d, 11
  ld e, 3
  ld bc, tile_buffer
  call gbdk_SetBkgTiles

  pop hl
  ret

DrawPageTwo:
  ;img and name already drawn
  push hl;player

  ;moves box
  ld b, 0
  ld c, 8
  ld d, 20
  ld e, 10
  call DrawBKGUIBox

  xor a
  ld [_i], a
.loopMoveNames
    pop hl;player
    push hl
    ld a, [_i]
    call GetPlayerMoveName

    ld hl, name_buffer
    call str_Length

    ld h, e
    ld l, 1
    ld d, 2
    ld a, [_i]
    add a, a;i*2
    add a, 9
    ld e, a
    ld bc, name_buffer
    call gbdk_SetBkgTiles
    
    ld a, [_i]
    inc a
    ld [_i], a
    cp 4
    jr nz, .loopMoveNames

  pop hl
  ret
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

StatScreenStatusText:
  DB "STATUS/", 0
StatScreenTypeText:
  DB "TYPE", 0
StatScreenPayText:
  DB "PAY/", 0

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
  jr nz, .setPlayerImg
  inc b
.setPlayerImg
  ld de, _UI_FONT_TILE_COUNT+64
  pop af;num
  push af
  call SetPlayerBkgTilesFlipped

.setPlayerName
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

.setPlayerNumber
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

.drawStatNames
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

.drawBattingStat
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

.drawFieldingStat
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

.drawSpeedStat
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

.drawThrowingStat
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

.drawLevel
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

.drawHPBar
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

.drawHPNumbers
  pop hl;player
  push hl
  call GetPlayerHP
  ld de, str_buffer
  call str_Number

  ld de, name_buffer
  ld a, "/"
  ld [de], a
  inc de
  xor a
  ld [de], a
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

  pop hl;player
  push hl
  call GetPlayerMaxHP
  ld de, name_buffer
  call str_Number

  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

  ld hl, str_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld a, 18
  sub a, e
  ld d, a
  ld e, 4
  ld bc, str_buffer
  call gbdk_SetBkgTiles

.drawStatus
  pop hl;player
  push hl
  call GetPlayerStatus
  call GetStatusString
  ld hl, StatScreenStatusText
  ld de, str_buffer
  call str_Copy
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

  ld hl, str_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld d, 9
  ld e, 6
  ld bc, str_buffer
  call gbdk_SetBkgTiles

.drawType1
  ld hl, StatScreenTypeText
  ld de, str_buffer
  call str_Copy
  ld hl, name_buffer
  ld a, "1"
  ld [hli], a
  ld a, "/"
  ld [hli], a
  xor a
  ld [hli], a
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

  ld h, 6
  ld l, 1
  ld d, 10
  ld e, 9
  ld bc, str_buffer
  call gbdk_SetBkgTiles

  pop hl;player
  push hl
  call GetPlayerNumber
  call LoadPlayerBaseData
  ld hl, player_base+1
  ld a, [hl]
  call GetTypeString

  ld hl, name_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld d, 11
  ld e, 10
  ld bc, name_buffer
  call gbdk_SetBkgTiles

.drawType2
  pop hl;player
  push hl
  call GetPlayerNumber
  call LoadPlayerBaseData
  ld hl, player_base+2
  ld a, [hl]
  and a
  jr z, .drawPay

  ld hl, StatScreenTypeText
  ld de, str_buffer
  call str_Copy
  ld hl, name_buffer
  ld a, "2"
  ld [hli], a
  ld a, "/"
  ld [hli], a
  xor a
  ld [hli], a
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

  ld h, 6
  ld l, 1
  ld d, 10
  ld e, 11
  ld bc, str_buffer
  call gbdk_SetBkgTiles

  ld hl, player_base+2
  ld a, [hl]
  call GetTypeString

  ld hl, name_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld d, 11
  ld e, 12
  ld bc, name_buffer
  call gbdk_SetBkgTiles
  
.drawPay
  ld bc, StatScreenPayText
  ld h, 4
  ld l, 1
  ld d, 10
  ld e, 13
  call gbdk_SetBkgTiles

  ld hl, name_buffer
  ld a, "$"
  ld [hl], a

  pop hl;player
  push hl
  call GetUserPlayerPay
  ld de, name_buffer+1
  call str_Number

  ld hl, name_buffer
  call str_Length
  ld h, e
  ld l, 1
  ld d, 11
  ld e, 14
  ld bc, name_buffer
  call gbdk_SetBkgTiles

.drawOriginalTrainer
  ; TODO: add OT to player data

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

SGBStatsPalSet: PAL_SET PALETTE_UI, PALETTE_DARK, PALETTE_GREY, PALETTE_GREY
SGBStatsAttrBlk:
  ATTR_BLK 3
  ATTR_BLK_PACKET %001, 0,0,0, 0,0, 20,18 ;main UI
  ATTR_BLK_PACKET %001, 2,2,2, 0,0,   8,7 ;player
  ATTR_BLK_PACKET %001, 3,3,3, 12,3,  6,1 ;hp
  
SetStatScreenColors:;hl = player
  push hl;player
  ld hl, SGBStatsPalSet               
  call SetPalettesIndirect
  ld hl, SGBStatsAttrBlk
  ; call sgb_PacketTransfer
  call SetColorBlocks

  ; ;GBC UI color
  ; ld hl, tile_buffer
  ; ld bc, 20*18
  ; ld a, 0
  ; call mem_Set
  ; ld d, 0;x
  ; ld e, 0;y
  ; ld h, 20;w
  ; ld l, 18;h
  ; ld bc, tile_buffer
  ; call GBCSetBkgPaletteMap

  ; ;GBC user player color
  ; ld hl, tile_buffer
  ; ld bc, 8*7
  ; ld a, 2
  ; call mem_Set
  ; ld d, 0;x
  ; ld e, 0;y
  ; ld h, 8;w
  ; ld l, 7;h
  ; ld bc, tile_buffer
  ; call GBCSetBkgPaletteMap
  
  pop hl;player
  push hl;player
  call GetPlayerNumber
  call LoadPlayerBaseData
  ld hl, player_base.sgb_pal
  ld a, [hli]
  ld c, a
  ld a, [hli]
  ld b, a
  
  pop hl;player
  push bc;player palette
  call GetHealthPct;de = HP*96/maxHP
  ld a, e;shouldn't be more than 96
.checkRed
  ld de, PaletteUI;red
  cp a, 16
  jr c, .setPalettes
.checkYellow
  ld de, PaletteWarning;yellow
  cp a, 48
  jr c, .setPalettes
.otherwiseGren
  ld de, PaletteGood;green
.setPalettes
  pop bc;player palette
  ld a, [sgb_Pal23]
  call SetPalettesDirect

  ret

DrawStatScreen::;player in hl
  push hl;player
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

  pop hl;player
  push hl;player
  call SetStatScreenColors
  pop hl;player
  push hl;player
  call DrawPageOne
  DISPLAY_ON
  WAITPAD_UP
  call WaitForABStart

  pop hl;player
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
  call GetZeroPaddedNumber

  ld a, "#"
  ld de, name_buffer
  ld [de], a
  inc de
  ld hl, str_buffer
  call str_Copy

  ld h, 4
  ld l, 1
  ld d, 2
  ld e, 7
  ld bc, name_buffer
  call gbdk_SetBkgTiles

.drawStatNames
  ld b, 0
  ld c, 8
  ld d, 10
  ld e, 10
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox

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

.drawAge
  pop de;player
  push de
  ld hl, tile_buffer
  call SetAgeTiles;de = player, hl = address
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
  call SetHPBarTiles;de = HP*96/maxHP
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
  ld hl, player_base.type1
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
  ld hl, player_base.type2
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

  ld hl, player_base.type2
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
  ld bc, name_buffer+1
  call str_Number24

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

StatScreenExperienceText:
 DB "          "
 DB "EXPERIENCE"
 DB "          "
 DB "NEXT AGE  "
 DB "      ℔ᚠ  ";to yr

DrawPageTwo:
  ;img and name already drawn
  push hl;player

  ;moves box
  ld b, 0
  ld c, 8
  ld d, 20
  ld e, 10
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox

  pop hl;player
  push hl
  ld d, ALL_MOVES
  call GetPlayerMoveCount
  ld b, a
  xor a
  ld [_i], a
.loopMoveNames
    pop hl;player
    push hl
    push bc;move count
    ld a, [_i]
    ld d, ALL_MOVES
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

    ld bc, name_buffer
    ld a, "ℙ"
    ld [bc], a
    inc bc
    ld [bc], a
    ld h, 2
    ld l, 1
    ld d, 12
    ld a, [_i]
    add a, a;i*2
    add a, 10
    ld e, a
    ld bc, name_buffer
    call gbdk_SetBkgTiles

    xor a
    ld hl, tile_buffer
    ld bc, 16
    call mem_Set

    pop bc;move count
    pop de;player
    push de;player
    push bc;move count
    ld a, [_i]
    ld hl, tile_buffer
    ld b, ALL_MOVES
    call SetMovePPTiles;a = move, b = move mask, de = player, hl = tile address

    ld h, 5
    ld l, 1
    ld d, 14
    ld a, [_i]
    add a, a;i*2
    add a, 10
    ld e, a
    ld bc, tile_buffer
    call gbdk_SetBkgTiles
    
    ld a, [_i]
    inc a
    ld [_i], a
    pop bc;move count
    cp b
    jr nz, .loopMoveNames

.drawExperience
  ld h, 10
  ld l, 5
  ld d, 9
  ld e, 2
  ld bc, StatScreenExperienceText
  call gbdk_SetBkgTiles

  pop hl;player
  push hl
  call GetUserPlayerXP
  ld bc, str_buffer
  call str_Number24

  ld hl, str_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld a, 19
  sub a, e
  ld d, a
  ld e, 4
  ld bc, str_buffer
  call gbdk_SetBkgTiles

.checkNextAge
  pop hl;player
  push hl
  call GetPlayerAge
  cp 100
  jr z, .atMaxAge
  inc a  
  pop hl;player
  push hl
  push af
  call GetUserPlayerXPToNextAge
  ld bc, str_buffer
  call str_Number24
  
  ld hl, str_buffer
  call str_Length

  ld a, 15
  sub e
  ld h, e
  ld l, 1
  ld d, a
  ld e, 6
  ld bc, str_buffer
  call gbdk_SetBkgTiles

  pop af
.atMaxAge
  ld h, 0
  ld l, a
  ld de, name_buffer
  call str_Number

  ld hl, name_buffer
  call str_Length
  ld a, e
  cp 3
  jr z, .is100
  ld h, e
  ld l, 1
  ld d, 17
  ld e, 6
  jr .drawNextAge
.is100
  ld h, 3
  ld l, 1
  ld d, 16
  ld e, 6
.drawNextAge
  ld bc, name_buffer
  call gbdk_SetBkgTiles

  pop hl
  ret
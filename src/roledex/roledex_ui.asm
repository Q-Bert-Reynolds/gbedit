INCLUDE "src/beisbol.inc"

SECTION "Roledex UI", ROMX, BANK[ROLEDEX_BANK]

RoledexHeadingText:
  DB "REPORTS"

RoledexSeenSignText:
  DB "SEEN    "
  DB "    SIGN"

RoledexMenuText:
  DB "DATA    "
  DB "CRY     "
  DB "AREA    "
  DB "QUIT"

SGBRoledexPalSet: PAL_SET PALETTE_UI, PALETTE_DARK, PALETTE_GREY, PALETTE_GREY
SGBRoledexPlayerAttrBlk:
  ATTR_BLK 2
  ATTR_BLK_PACKET %001, 0,0,0, 0,0, 20,18 ;main UI
  ATTR_BLK_PACKET %001, 2,2,2, 1,1,   8,7 ;player
SGBRoledexAttrBlk:
  ATTR_BLK 1
  ATTR_BLK_PACKET %001, 0,0,0, 0,0, 20,18 ;main UI

DrawRoledexBaseUI:
  CLEAR_BKG_AREA 0,0,20,18," "

.setPalettes
  ld hl, SGBRoledexPalSet               
  call SetPalettesIndirect
  ld hl, SGBRoledexAttrBlk
  ld b, DRAW_FLAGS_BKG
  call SetColorBlocks

.drawHeading
  ld de, $0101
  ld hl, $0701
  ld bc, RoledexHeadingText
  ld a, DRAW_FLAGS_BKG
  call SetTiles

.drawSeenSigned
  ld de, $1002
  ld hl, $0404
  ld bc, RoledexSeenSignText
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  call GetSeenSignedCounts
  push de;seen,signed

  ld h, 0
  ld l, d
  ld de, name_buffer
  call str_Number

  ld hl, name_buffer
  call str_Length
  
  ld h, e
  ld l, 1
  ld de, $1103
  ld bc, name_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  pop hl;seen,signed
  ld h, 0
  ld de, name_buffer
  call str_Number

  ld hl, name_buffer
  call str_Length
  
  ld h, e
  ld l, 1
  ld de, $1106
  ld bc, name_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

.drawMenu
  ld de, $100A
  ld hl, $0407
  ld bc, RoledexMenuText
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld hl, tile_buffer
  ld a, BOX_VERTICAL
  ld [hli], a
  ld c, 9
.loop
    ld a, BOX_VERTICAL
    ld [hli], a
    ld a, BOX_JUNCTION
    ld [hli], a
    dec c
    jr nz, .loop

  ld de, $0E00
  ld hl, $0112
  ld bc, tile_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld hl, tile_buffer
  ld a, BOX_HORIZONTAL
  ld bc, 5
  call mem_Set

  ld de, $0F08
  ld hl, $0501
  ld bc, tile_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ret

DrawRoledexListEntry:;a = number, de = xy
  push af;number
  push de;xy
  call GetZeroPaddedNumber

  pop de;xy
  push de;xy
  ld h, 4
  ld l, 1
  ld bc, str_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld hl, tile_buffer
  ld a, " "
  ld bc, NICKNAME_LENGTH
  call mem_Set

  pop de;xy
  inc d
  inc d;x+2
  inc e;y+1
  pop af;number
  push af;number
  push de;xy
  push af;number

  dec d
  ld h, NICKNAME_LENGTH
  ld l, 1
  ld bc, tile_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  pop af;number
  call CheckSeenSigned
  cp 1
  jr z, .setName
  cp 2
  jr z, .setSigned

  ld a, "-"
  ld hl, tile_buffer+1
  ld bc, 10
  call mem_Set
  xor a
  ld [hl], a
  jr .drawTiles

.setSigned
  ld a, BASEBALL
  ld hl, tile_buffer
  ld [hl], a

.setName
  pop de;xy
  pop af;number
  push af;number
  push de;xy
  call GetPlayerName
  
  ld hl, name_buffer
  ld de, tile_buffer+1
  call str_Copy

.drawTiles
  ld hl, tile_buffer
  call str_Length
  ld h, e
  ld l, 1
  pop de;xy
  push de
  ld bc, tile_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles
  
  pop de;xy
  pop af;num

  ret

ShowRoledexPage:
  ld a, [_s]
  and a
  cp 1
  jr c, .numTooLow
  cp 145;TODO; should be maxNum-6
  jr nc, .numTooHigh
  jr .draw
.numTooLow
  ld a, 1
  ld [_s], a
  jr .draw
.numTooHigh
  ld a, 145;TODO; should be maxNum-6
  ld [_s], a
.draw
  ld de, $0102
  ld c, 7
.loop
    push bc;count
    push af;num
    push de;xy
    call DrawRoledexListEntry
    pop de;xy
    inc e
    inc e;y+=2
    pop af;num
    inc a;num++
    pop bc;count
    dec c
    jr nz, .loop
  ret

HomeTownText:
  DB "'s FIELDS",0

ShowRoledexPlayerMap:; a = player number
  push af
  call DrawStateMap

  pop af
  call GetPlayerName

  ld hl, name_buffer
  ld de, str_buffer
  call str_Copy

  ld hl, HomeTownText
  ld de, str_buffer
  call str_Append

  ld hl, str_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld de, 0
  ld bc, str_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

.loop
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, (PADF_A | PADF_START | PADF_B)
    call gbdk_WaitVBL
    jr .loop
.exit
  ret

ShowRoledexPlayerData:;a player num
  push af;num
  call LoadPlayerBaseData
  DISPLAY_OFF

  ld hl, SGBRoledexPlayerAttrBlk
  ld b, DRAW_FLAGS_BKG
  call SetColorBlocks

  ld hl, player_base.sgb_pal
  ld a, [hli]
  ld c, a
  ld a, [hli]
  ld b, a
  ld a, [sgb_Pal23]
  call SetPalettesDirect

  ld bc, 0
  ld de, $1412
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox
  
  pop af;num
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
  inc c
  ld b, a
  and a
  jr nz, .setRoledexImg
  inc b
.setRoledexImg
  pop af;num
  push af
  ld de, _UI_FONT_TILE_COUNT+64
  call SetPlayerBkgTilesFlipped

.setRoledexName
  pop af;num
  push af
  call GetPlayerName

  ld hl, name_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld d, 9
  ld e, 2
  ld bc, name_buffer
  call gbdk_SetBkgTiles

.setRoledexNumber
  pop af;num
  push af
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
  ld e, 8
  ld bc, name_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

.checkCaught
  pop af;num
  push af
  call CheckSeenSigned
  push af;signed?

.checkHeight
  ld hl, name_buffer
  ld a, "H"
  ld [hli], a
  ld a, "T"
  ld [hl], a

  pop af;signed
  push af
  cp 2
  jr z, .getHeight

  ld hl, name_buffer+2
  ld a, " "
  ld [hli], a
  ld [hli], a
  ld a, "?"
  ld [hli], a
  ld a, "'"
  ld [hli], a
  ld a, "?"
  ld [hli], a
  ld [hli], a
  ld a, "\""
  ld [hli], a
  xor a
  ld [hl], a
  ld hl, name_buffer
  ld de, str_buffer
  call str_Copy
  jr .drawHeight

.getHeight
  ld h, 2
  ld l, 1
  ld d, 9
  ld e, 6
  ld bc, name_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld hl, player_base.height
  ld a, [hl];upper nibble is feet, lower is inches
  push af;ft,in
  swap a
  and a, %00001111;feet only
  ld h, 0
  ld l, a
  ld de, str_buffer
  call str_Number
  ld a, "'"
  ld [de], a
  inc de
  pop af;ft,in
  and a, %00001111;inches only
  ld h, 0
  ld l, a
  call str_Number
  ld a, "\""
  ld [de], a
  inc de
  xor a
  ld [de], a

.drawHeight
  ld hl, str_buffer
  call str_Length

  ld a, 18
  sub a, e
  ld h, e
  ld l, 1
  ld d, a
  ld e, 6
  ld bc, str_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles
  
.checkWeight
  ld hl, name_buffer
  ld a, "W"
  ld [hli], a
  ld a, "T"
  ld [hl], a

  pop af;signed
  push af
  cp 2
  jr z, .getWeight

  ld hl, name_buffer+4
  ld a, " "
  ld [hli], a
  ld a, "?"
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld a, "l"
  ld [hli], a
  ld a, "b"
  ld [hli], a
  xor a
  ld [hl], a
  ld hl, name_buffer
  ld de, str_buffer
  call str_Copy
  jr .drawWeight

.getWeight
  ld h, 2
  ld l, 1
  ld d, 9
  ld e, 8
  ld bc, name_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld hl, player_base.weight
  ld a, [hli];lower byte is lbs
  ld b, a
  ld a, [hl];upper byte, upper nibble is decimal, lower is lbs
  push af;dec,lbs
  and a, %00001111;lbs only
  ld h, a
  ld l, b
  ld de, str_buffer
  call str_Number

  ld hl, name_buffer
  ld a, "."
  ld [hli], a
  xor a
  ld [hld], a
  ld de, str_buffer
  call str_Append

  pop af;dec,lbs
  swap a
  and a, %00001111;dec only
  ld h, 0
  ld l, a
  ld de, name_buffer
  call str_Number
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

  ld hl, name_buffer
  ld a, "l"
  ld [hli], a
  ld a, "b"
  ld [hli], a
  xor a
  ld [hl], a
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

.drawWeight
  ld hl, str_buffer
  call str_Length

  ld a, 19
  sub a, e
  ld h, e
  ld l, 1
  ld d, a
  ld e, 8
  ld bc, str_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

.drawDividingLine
  ld hl, tile_buffer+1
  ld bc, 18
  ld a, BOX_HORIZONTAL
  call mem_Set
  ld a, BOX_JUNCTION
  ld [hl], a

  ld de, $0009
  ld hl, $1401
  ld bc, tile_buffer
  ld [bc], a
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  DISPLAY_ON
  pop af;signed
  pop bc;num
  cp 2
  jr nz, .waitForExit

  ld a, b;num
  call GetPlayerDescription
  ld hl, str_buffer
  ld bc, 3
  ld de, $010B
  ld a, DRAW_FLAGS_BKG
  call DrawText
  push hl

  ld de, $1210
  call FlashNextArrow

  CLEAR_BKG_AREA 1,10,18,7," "

  pop hl
  ld bc, 3
  ld de, $010B
  ld a, DRAW_FLAGS_BKG
  call DrawText

.waitForExit
  WAITPAD_UP
.waitForExitLoop
  call gbdk_WaitVBL
  call UpdateInput
  ld a, [button_state]
  and a, PADF_START | PADF_A | PADF_B
  jr z, .waitForExitLoop

  WAITPAD_UP

  ret

NoCryingText:
  DB "There's no crying\nin baseball.",0

ShowRoledexMenu:;returns exit code in a
  ld a, [_j];y
  push af;_j
  ld b, a
  add a, a
  add a, 3
  ld c, a
  ld a, [_s];page
  add a, b
  push af;player num

  push bc
  call CheckSeenSigned
  pop bc
  ld b, 0
  and a
  jp z, .exit
  
  ld a, 4
  ld [_c], a
  xor a
  ld [_j], a
.setArrowTile
  ld hl, $0101
  ld d, 0
  ld e, c
  ld a, ARROW_RIGHT_BLANK
  ld bc, tile_buffer
  ld [bc], a
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld d, 15
  ld e, 10
  ld a, DRAW_FLAGS_BKG
  call DrawListMenuArrow
  WAITPAD_UP_OR_FRAMES 20
.loop
    call UpdateInput
    ld d, 15
    ld e, 10
    ld a, DRAW_FLAGS_BKG
    call MoveListMenuArrow
    and a
    jr nz, .loop
.checkA
    ld a, [button_state]
    and a, PADF_A
    jr z, .checkB

      ld a, [_j]
.checkShowData
      and a
      jr nz, .checkShowCry
      pop af;player num
      push af;player num
      call ShowRoledexPlayerData
      pop bc;player num
      pop af;_j
      push af;_j
      push bc;player num
      ld [_j], a
      call DrawRoledexBaseUI
      call ShowRoledexPage

      ld hl, SGBRoledexAttrBlk
      ld b, DRAW_FLAGS_BKG
      call SetColorBlocks

      ld a, [_j];y
      add a, a
      add a, 3
      ld c, a
      xor a
      ld [_j], a
      jp .setArrowTile
.checkShowCry
      cp 1
      jr nz, .checkShowMap
      ld hl, NoCryingText
      ld a, [_j]
      push af
      call RevealTextAndWait
      pop af
      ld [_j], a
      HIDE_WIN
      WAITPAD_UP
      jp .loop
.checkShowMap
      cp 2
      jr nz, .doQuit
      pop af;player num
      push af;player num
      call ShowRoledexPlayerMap
      pop bc;player num
      pop af;_j
      push af;_j
      push bc;player num
      ld [_j], a
      call DrawRoledexBaseUI
      call ShowRoledexPage
      ld a, [_j];y
      add a, a
      add a, 3
      ld c, a
      ld a, 2
      ld [_j], a
      jp .setArrowTile
.doQuit
      ld b, -1;exit code
      jr .exit
.checkB
    ld b, 0
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
    call gbdk_WaitVBL
    jp .loop
.exit
  pop af;player num
  pop af;_j
  push bc;exit code
  ld [_j], a
  call DrawRoledexBaseUI
  call ShowRoledexPage
  ld a, 7
  ld [_c], a
  ld de, 3
  ld a, DRAW_FLAGS_BKG
  call DrawListMenuArrow
  WAITPAD_UP
  pop af;exit code
  ret

ShowRoledexUI::
  ld a, [rSCX]
  ld h, a
  ld a, [rSCY]
  ld l, a
  push hl
  xor a
  ld [rSCX], a
  ld [rSCY], a
  HIDE_ALL_SPRITES
  HIDE_WIN
  call DrawRoledexBaseUI

  xor a
  ld [_j], a
  ld a, 1
  ld [_s], a
  call ShowRoledexPage
  ld a, 7
  ld [_c], a
  ld de, 3
  ld a, DRAW_FLAGS_BKG
  call DrawListMenuArrow
  WAITPAD_UP
.loop
    call UpdateInput
    ld a, [_j]
    push af;old _j
    ld de, 3
    ld a, DRAW_FLAGS_BKG
    call MoveListMenuArrow;returns -1,0,1
    ld b, a;store dir
    pop af;old _j
    ld c, a;old _j in c
    ld a, [_j]
    sub a, c;change in _j
    cp b;check if change is same as expected
    jr z, .checkMovePageLeft
    ld a, [_s]
    add a, b
    ld [_s], a
    call ShowRoledexPage
    jp .waitAndLoop
.checkMovePageLeft
    ld a, [button_state]
    and a, PADF_LEFT
    jr z, .checkMovePageRight
    ld a, [_s]
    cp 7
    jr c, .showFirstPage
    sub a, 7
    ld [_s], a
    call ShowRoledexPage
    WAITPAD_UP_OR_FRAMES 20
    jr .waitAndLoop
.showFirstPage
    ld a, 1
    ld [_s], a
    call ShowRoledexPage
    WAITPAD_UP_OR_FRAMES 20
    jr .waitAndLoop
.checkMovePageRight
    ld a, [button_state]
    and a, PADF_RIGHT
    jr z, .checkAPressed
    ld a, [_s]
    add a, 7
    ld [_s], a
    call ShowRoledexPage
    WAITPAD_UP_OR_FRAMES 20
    jr .waitAndLoop
.checkAPressed
    ld a, [button_state]
    and a, PADF_A
    jr z, .checkBPressed
    call ShowRoledexMenu
    cp -1
    jr z, .exit
    jr .waitAndLoop
.checkBPressed
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
.waitAndLoop
    call gbdk_WaitVBL
    jp .loop
.exit
  SHOW_WIN
  pop hl
  ld a, h
  ld [rSCX], a
  ld a, l
  ld [rSCY], a
  ret
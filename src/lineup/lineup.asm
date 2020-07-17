INCLUDE "src/beisbol.inc"

SECTION "Lineup", ROMX, BANK[LINEUP_BANK]

INCLUDE "src/lineup/stats.asm"

INCLUDE "img/health_bar.asm"
INCLUDE "img/lineup_sprites.asm"

SGBLineupPalSet: PAL_SET PALETTE_UI, PALETTE_SEPIA, PALETTE_WARNING, PALETTE_GOOD
SGBLineupAttrBlk:
  ATTR_BLK 11
  ATTR_BLK_PACKET %001, 0,0,0, 3,0, 17,18 ;main UI
  ATTR_BLK_PACKET %001, 1,1,1, 0,0,  3,18 ;players
Player1HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,0,  6, 2
Player2HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,2,  6, 2
Player3HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,4,  6, 2
Player4HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,6,  6, 2
Player5HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,8,  6, 2
Player6HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,10, 6, 2
Player7HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,12, 6, 2
Player8HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,14, 6, 2
Player9HPBar:
  ATTR_BLK_PACKET %001, 3,3,3, 5,16, 6, 2
SGBLineupAttrBlkEnd:

SwapPositions: ;bc = player count, selected player
  ld a, b
  ld [_c], a
  ld a, c
  ld [_j], a
  ld [_k], a
  ld de, 0
  ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_PAD_TOP
  call DrawListMenuArrow
  WAITPAD_UP
.loop
    call UpdateInput
    ld de, 0
    ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_PAD_TOP
    call MoveListMenuArrow
    ld a, [_j]
    ld b, a
    ld a, [_k]
    cp b
    jr z, .checkA
    ld a, ARROW_RIGHT_BLANK
    ld hl, name_buffer
    ld [hl], a

    ld d, 0
    ld a, [_k]
    add a, a
    inc a
    ld e, a
    ld h, 1
    ld l, 1
    ld bc, name_buffer
    call gbdk_SetBkgTiles
.checkA
    ld a, [button_state]
    and a, PADF_A
    jr z, .checkB

    ld a, [_k]
    call GetUserPlayerInLineup
    call GetPlayerPosition
    push hl;store player k position location
    push af;store player k position
    ld a, [_j]
    call GetUserPlayerInLineup
    call GetPlayerPosition
    ld b, a;player j position
    pop af;get player k position
    ld [hl], a;set player j's new position
    pop hl;get player k position location
    ld a, b;player j's old position
    ld [hl], a;set player k to j's old position

    ld de, 40
    ld a, [_k]
    call math_Multiply
    ld bc, bkg_buffer
    add hl, bc
    ld bc, 3
    add hl, bc
    push hl ;k's position tile

    ld de, 40
    ld a, [_j]
    call math_Multiply
    ld bc, bkg_buffer
    add hl, bc
    ld bc, 3
    add hl, bc;j's position tile

    ld a, [hl]
    ld d, a
    pop bc;k's position tile
    ld a, [bc]
    ld [hl], a
    ld a, d
    ld [bc], a

    ret
.checkB
    ld a, [button_state]
    and a, PADF_B
    jp z, .loop
  ret

SwapLineupData:
  ld a, [_k]
  call GetUserPlayerInLineup
  push hl;player k
  ld de, tile_buffer
  ld bc, UserLineupPlayer2 - UserLineupPlayer1
  call mem_Copy

  ld a, [_j]
  call GetUserPlayerInLineup
  pop de;player k
  push hl;player j
  ld bc, UserLineupPlayer2 - UserLineupPlayer1
  call mem_Copy

  ld hl, tile_buffer
  pop de
  ld bc, UserLineupPlayer2 - UserLineupPlayer1
  call mem_Copy
  ret

SwapLineupTiles:
  ld de, 40
  ld a, [_k]
  call math_Multiply
  ld de, bkg_buffer
  add hl, de
  push hl;k's lineup card
  ld de, tile_buffer
  ld bc, 40
  call mem_Copy

  ld de, 40
  ld a, [_j]
  call math_Multiply
  ld de, bkg_buffer
  add hl, de
  pop de;k's lineup card
  push hl;j's lineup card
  ld bc, 40
  call mem_Copy

  ld hl, tile_buffer
  pop de;j's lineup card
  ld bc, 40
  call mem_Copy
  ret

MoveLineupSprites:;de sprites 1, hl sprites 2
  push de
  push hl

  ld a, [de]
  ld b, a
  ld a, [hl]
  sub a, b
  ld b, a

REPT 4
  ld a, [hl]
  sub a, b
  ld [hli], a
  inc hl
  inc hl
  inc hl
  ld a, [de]
  add a, b
  ld [de], a
  inc de
  inc de
  inc de
  inc de
ENDR

  pop hl
  pop de
  ret

SwapLineupSprites:
  ld hl, oam_buffer
  ld a, [_j]
  add a, a;y*2
  add a, a;y*4
  add a, a;y*8
  add a, a;y*16
  ld b, 0
  ld c, a
  add hl, bc;sprite id
  push hl;j's oam
  ld de, tile_buffer
  ld bc, 16
  call mem_Copy ;TODO: move sprites

  ld hl, oam_buffer
  ld a, [_k]
  add a, a;y*2
  add a, a;y*4
  add a, a;y*8
  add a, a;y*16
  ld b, 0
  ld c, a
  add hl, bc;sprite id
  ld de, tile_buffer
  call MoveLineupSprites
  pop de;j's oam
  push hl;k's oam
  ld bc, 16
  call mem_Copy

  ld hl, tile_buffer
  pop de;k's oam
  ld bc, 16
  call mem_Copy

  ret

ReorderLineup: ;bc = player count, selected player
  ld a, b
  ld [_c], a
  ld a, c
  ld [_j], a
  ld [_k], a
  WAITPAD_UP
.loop
    call UpdateInput
    ld de, 0
    ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_PAD_TOP
    call MoveListMenuArrow ;de = xy, _j = current index, _c = count, must call UpdateInput first
    ld a, [_j]
    ld b, a
    ld a, [_k]
    cp b
    jr z, .checkA
    ld a, ARROW_RIGHT_BLANK
    ld hl, name_buffer
    ld [hl], a

    ld d, 0
    ld a, [_k]
    add a, a
    inc a
    ld e, a
    ld h, 1
    ld l, 1
    ld bc, name_buffer
    call gbdk_SetBkgTiles
.checkA
    ld a, [button_state]
    and a, PADF_A
    jp z, .checkB
    
    call SwapLineupData
    call SwapLineupTiles
    call SwapLineupSprites
    ret
.checkB
    ld a, [button_state]
    and a, PADF_B
    jp z, .loop
  ret

DrawLineupPlayers:
  ld hl, UserLineup
  xor a
.loop
    ld [_j], a
    ld a, [hl]
    cp 0
    ret z
    call DrawLineupPlayer;doesn't change hl
    ld bc, UserLineupPlayer2 - UserLineupPlayer1
    add hl, bc
    ld a, [_j]
    inc a
    ld [_c], a;count, used for arrow
    cp 9
    jr nz, .loop
  ret

DrawLineupPlayer: ;hl = player, _j is order on screen, returns player in hl
  push hl
  ld hl, tile_buffer
  xor a
  ld bc, 40
  call mem_Set

  pop hl
  push hl
  call GetPlayerPosition
  ld hl, tile_buffer+3
  ld [hl], a

  pop hl
  push hl
  call GetUserPlayerName
  ld hl, name_buffer
  ld de, tile_buffer+4
  call str_Copy

  pop de;player
  push de
  ld hl, tile_buffer+15
  call SetAgeTiles

  pop de;player
  push de;player
  ld hl, tile_buffer+24
  call SetHPBarTiles;de = HP * 96 / maxHP
  ld d, 0
  ld a, [_j]
  add a, a
  ld e, a
  ld h, 20
  ld l, 2
  ld bc, tile_buffer
  call gbdk_SetBkgTiles

  pop hl;player
  push hl;player
  call DrawLineupPlayerSprites

  pop hl;player
  ret

SetHPBarColor:;e = HP*96/maxHP, [_j] = order
  ld a, e;shouldn't be more than 96
.checkRed
  ld b, 0;ui/red
  cp a, 16
  jr c, .setPalettes
.checkYellow
  ld b, 2;warning/yellow
  cp a, 48
  jr c, .setPalettes
.otherwiseGren
  ld b, 3;good/green
.setPalettes
  ld a, [_j]
  ld de, Player2HPBar-Player1HPBar
  call math_Multiply
  ld de, tile_buffer + (Player1HPBar-SGBLineupAttrBlk)
  add hl, de
  inc hl
  ld a, b;pal
  ld [hl], a
  ret

GetHPBarColors:;returns address of attribute block in hl
  ld hl, SGBLineupAttrBlk
  ld de, tile_buffer
  ld bc, SGBLineupAttrBlkEnd-SGBLineupAttrBlk
  call mem_Copy
  ld hl, UserLineup
  xor a
.loop
    ld [_j], a
    ld a, [hl]
    cp 0
    ret z
    push hl;player
    call GetHealthPct
    call SetHPBarColor
    pop hl;player
    ld bc, UserLineupPlayer2 - UserLineupPlayer1
    add hl, bc
    ld a, [_j]
    inc a
    cp 9
    jr nz, .loop
  ld hl, tile_buffer
  ret

BodyPartsLookup:;maps body ID to other body part offset or 0
  DB 0, 0, 0, 0, 0, 1, 0, -12, 0, 1, 0, 0

BodyHeightLookup:;maps body ID to height
  DB 2, 6, 6, 5, 6, 7, 0, 8, 7, 7, 0, 8

BodyHeadXLookup:;maps body ID to x offset
  DB -1, -1, -1, 0, 0, 0, 0, 2, 0, -1, 0, -1

HeadPartsLookup:;maps head ID to other head part offset or 0
  DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0

HeadHeightLookup:;maps head ID to height
  DB 6, 5, 5, 4, 4, 4, 4, 0, 4, 5, 5, 4

HatPartsLookup:;maps hat ID to other hat part offset or 0
  DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0

HatXLookup:;maps hat ID to x offset
  DB 0, 1, 1, 1, 1, 1, 1, 1, 1, -6, 0, -7

DrawLineupPlayerSprites:
  ld a, [hl]
  call LoadPlayerBaseData
  
  ld hl, oam_buffer
  ld a, [_j]
  add a, a;y*2
  add a, a;y*4
  add a, a;y*8
  add a, a;y*16 = 4bytes per sprite, 4 sprites per player
  ld b, 0
  ld c, a
  add hl, bc;sprite id
  push hl;oam 

  ld a, 0
  ld bc, 16
  call mem_Set;clear oam for player

  ld a, [_j]
  inc a
  ld de, 16
  call math_Multiply
  ld a, l
  add a, 8
  ld [_y], a

  ld hl, player_base.gb_pal
  ld a, [hl]
  and a
  cp 1
  jr z, .pal1
  ld a, OAMF_PAL0
  ld [_s], a
  jr .drawBody
.pal1
  ld a, OAMF_PAL1
  ld [_s], a

.drawBody
  ld hl, player_base.body_id
  ld a, [hl]
  ld b, 0
  ld c, a;body tile

  ld hl, BodyPartsLookup
  add hl, bc
  ld a, [hl];other body tile
  ld d, a

  ld hl, BodyHeadXLookup
  add hl, bc
  ld a, [hl];head x offset
  ld [_x], a

  ld hl, BodyHeightLookup
  add hl, bc
  ld a, [hl];body height
  ld e, a

  pop hl;oam start
  ld a, [_y]
  ld [hli], a;y
  ld a, d
  cp 1
  jr z, .shiftBodyLeft
  ld a, 20
  ld [hli], a;x
  jr .skipBodyShift
.shiftBodyLeft
  ld a, 16
  ld [hli], a;x
.skipBodyShift
  ld a, c
  add a, 24;tile
  ld [hli], a
  ld a, [_s]
  ld [hli], a;pal

  ld a, d
  cp 0
  jr z, .doneWithSecondBodyPart
  cp 1
  jr z, .shiftBody2Right
  ld a, [_y]
  sub a, 8
  ld [hli], a;y
  ld a, 20
  ld [hli], a;x
  jr .setSecondBodyTile
.shiftBody2Right
  ld a, [_y]
  ld [hli], a;y
  ld a, 24
  ld [hli], a;x
.setSecondBodyTile
  ld a, d
  add a, c
  add a, 24;tile
  ld [hli], a
  ld a, [_s]
  ld [hli], a;pal
.doneWithSecondBodyPart

  push hl
  ld a, [_y]
  sub a, e;sub body height
  ld [_y], a

  ld hl, player_base.head_id
  ld a, [hl]
  ld b, 0
  ld c, a;head tile

  ld hl, HeadHeightLookup
  add hl, bc
  ld a, [hl];head height
  ld e, a

  pop hl
  ld a, [_y];y pos - body height
  sub a, e;head height
  ld [_y], a;store hat pos
  add a, 8
  ld [hli], a

  ld a, [_x]
  add a, 20
  ld [hli], a

  ld a, c
  add a, 12;head tile
  ld [hli], a
  ld a, [_s]
  ld [hli], a;pal

  push hl
  ld hl, player_base.hat_id
  ld a, [hl]
  ld b, 0
  ld c, a;hat tile

  ld hl, HatPartsLookup;TODO: use me
  add hl, bc
  ld a, [hl];other hat tile
  ld d, a

  ld hl, HatXLookup
  add hl, bc
  ld a, [_x]
  ld b, a
  ld a, [hl];head x offset
  add a, b
  ld [_x], a

  pop hl
  ld a, [_y]
  ld [hli], a;y

  ld a, [_x]
  add a, 20
  ld [hli], a;x

  ld a, c
  ld [hli], a;tile

  ld a, [_s]
  ld [hli], a;pal

  ret

FromWorldMenuText:
  DB "STATS\nBAT ORDER\nPOSITION\nCANCEL", 0
FromGameMenuText:
  DB "STATS\nPOSITION\nCANCEL", 0

ShowPlayerMenu:
  ld a, [_c];number of players
  ld b, a
  ld a, [_j];selected player
  ld c, a
  push bc

  ld de, 0
  ld h, 20
  ld l, 18
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles
  
.showEmptyArrow
  ld a, ARROW_RIGHT_BLANK
  ld hl, name_buffer
  ld [hl], a

  ld d, 0
  ld a, [_j]
  add a, a
  inc a
  ld e, a
  ld h, 1
  ld l, 1
  ld bc, name_buffer
  call gbdk_SetBkgTiles

  ld a, [_a]
  and a
  jr z, .notPlaying
  ld hl, FromGameMenuText
  ld c, 3
  jr .setStrBuff
.notPlaying
  ld hl, FromWorldMenuText
  ld c, 4
.setStrBuff
  ld de, str_buffer
  call str_Copy

  ld hl, name_buffer
  xor a
  ld [hl], a

  ld d, 12
  ld a, c
  add a, c
  add a, 2
  ld e, a

.showList
  ld b, 8
  ld a, 18
  sub a, c
  sub a, c
  sub a, 2
  ld c, a
  ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_PAD_TOP
  call ShowListMenu; returns a, bc = xy, de = wh, text = [str_buffer], title = [name_buff]
  and a
  jr z, .exit
  cp 1
  jr z, .showStatScreen
  ld b, a;selection
  ld a, [_a]
  and a;if 0, can reorder lineup
  ld a, b
  jr z, .outOfGameMenu
.inGameMenu
  cp 2
  jr z, .swapPositions
  jr .exit
.outOfGameMenu
  cp 2
  jr z, .reorderLineup
  cp 3
  jr z, .swapPositions
  jr .exit
.showStatScreen
  pop bc
  push bc;player count, selected player
  ld a, c
  ld de, UserLineupPlayer2 - UserLineupPlayer1
  call math_Multiply
  ld bc, UserLineup
  add hl, bc
  call DrawStatScreen
  jr .exit
.reorderLineup
  pop bc
  push bc;player count, selected player
  call ReorderLineup
  jr .finishSwap
.swapPositions
  pop bc
  push bc;player count, selected player
  call SwapPositions
.finishSwap
  pop bc
  ld a, [_j]
  ld c, a
  push bc
.exit
  DISPLAY_OFF
  ld de, 0
  ld h, 20
  ld l, 18
  ld bc, bkg_buffer
  call gbdk_SetBkgTiles

  ld hl, SGBLineupPalSet               
  call SetPalettesIndirect
  call GetHPBarColors
  call sgb_PacketTransfer

  pop bc
  ld a, b
  ld [_c], a
  ld a, c
  ld [_j], a
  DISPLAY_ON
  ret 

ShowLineup::; a = playing_game?
  ld [_a], a

  DISPLAY_OFF
  ld hl, SGBLineupPalSet               
  call SetPalettesIndirect
  call GetHPBarColors
  call sgb_PacketTransfer

  ld hl, _LineupSpritesTiles
  ld de, $8000
  ld bc, _LINEUP_SPRITES_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, _HealthBarTiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _HEALTH_BAR_TILE_COUNT*16
  call mem_CopyVRAM

  CLEAR_SCREEN " "

  xor a
  ld [rSCX], a
  ld [rSCY], a

  ld hl, rOBP1
  ld [hl], %11111000

  call DrawLineupPlayers

  xor a
  ld [_j], a
  ld de, 0
  ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_PAD_TOP
  call DrawListMenuArrow

  DISPLAY_ON
  WAITPAD_UP
.loop
    call UpdateInput
    ld de, 0
    ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_PAD_TOP
    call MoveListMenuArrow
.testStartOrA
    ld a, [button_state]
    and a, PADF_A | PADF_START
    jr z, .testBButton
    call ShowPlayerMenu
    WAITPAD_UP
    jr .waitVBLAndLoop
.testBButton
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
.waitVBLAndLoop
    call gbdk_WaitVBL
    jr .loop
.exit

  DISPLAY_OFF
  ld hl, rOBP1
  ld [hl], DMG_PAL_DLWW
  
  xor a
  ld hl, bkg_buffer
  ld bc, BUFFER_SIZE
  call mem_Set

  CLEAR_SCREEN " "
  DISPLAY_ON
  ret
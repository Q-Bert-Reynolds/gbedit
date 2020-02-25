INCLUDE "src/beisbol.inc"

SECTION "Lineup", ROMX, BANK[LINEUP_BANK]

INCLUDE "img/health_bar.asm"
INCLUDE "img/lineup_sprites.asm"

DrawPlayers:
  ld hl, UserLineup
  xor a
.loop
    ld [_j], a
    ld a, [hl]
    cp 0
    ret z
    call DrawPlayer;doesn't change hl
    ld bc, UserLineupPlayer2 - UserLineupPlayer1
    add hl, bc
    ld a, [_j]
    inc a
    ld [_c], a;count, used for arrow
    cp 9
    jr nz, .loop
  ret

DrawPlayer: ;hl = player, _j is order on screen
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

  ld a, LEVEL
  ld hl, tile_buffer+15
  ld [hl], a

  pop hl
  push hl
  call GetPlayerLevel
  ld h, 0
  ld l, a
  ld de, tile_buffer+16
  call str_Number

  ;TODO: health bar doesn't work
  ; pop hl
  ; push hl
  ; call GetPlayerHP
  ; pop hl
  ; push hl
  ; call GetPlayerMaxHP
  ld hl, tile_buffer+24
  ld a, 128
  ld [hli], a
  ld a, 129
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld a, 138
  ld [hli], a

  ld d, 0
  ld a, [_j]
  add a, a
  ld e, a
  ld h, 20
  ld l, 2
  ld bc, tile_buffer
  call gbdk_SetBkgTiles

  pop hl
  push hl
  call DrawPlayerSprites

  pop hl
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

DrawPlayerSprites
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

  ld hl, player_base+14;palette
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
  ld hl, player_base+11;body
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

  ld hl, player_base+12;head
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
  ld hl, player_base+13;hat
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
  DB "ORDER\n"
FromGameMenuText:
  DB "SWITCH\nSTATS\nCANCEL", 0

ShowPlayerMenu:
  ld a, [_c]
  ld b, a
  ld a, [_j]
  ld c, a
  push bc
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

  ld h, 9
  ld a, c
  add a, c
  add a, 2
  ld l, a

  ld d, 11
  ld a, 18
  sub a, c
  sub a, c
  sub a, 2
  ld e, a

  push de;xy
  push hl;wh
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles

  pop de;wh
  pop bc;xy
  push de;wh
  push bc;xy
  call ShowListMenu; returns a, bc = xy, de = wh, text = [str_buffer], title = [name_buff]

  pop de;xy
  pop hl;wh
  ld bc, bkg_buffer
  call gbdk_SetBkgTiles
  WAITPAD_UP
  pop bc
  ld a, b
  ld [_c], a
  ld a, c
  ld [_j], a
  ret 

ShowLineup::; a = playing_game?
  ld [_a], a

  DISPLAY_OFF
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

  call DrawPlayers

  xor a
  ld [_j], a
  ld de, 0
  call DrawListMenuArrow

  DISPLAY_ON
  WAITPAD_UP
.loop
    call UpdateInput
    ld de, 0
    call MoveListMenuArrow
.testStartOrA
    ld a, [button_state]
    and a, PADF_A | PADF_START
    jr z, .testBButton
    call ShowPlayerMenu
    jr .waitVBLAndLoop
.testBButton
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
.waitVBLAndLoop
    call gbdk_WaitVBL
    jr .loop
.exit
  ld hl, rOBP1
  ld [hl], SPR_PALETTE_1
  HIDE_ALL_SPRITES
  ret
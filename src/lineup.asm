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
  call gbdk_SetWinTiles

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
  jr z, .shiftLeft
  ld a, 20
  ld [hli], a;x
  jr .skipShift
.shiftLeft
  ld a, 16
  ld [hli], a;x
.skipShift
  ld a, c
  add a, 24;tile
  ld [hli], a
  inc hl;skip pal

  ld a, d
  cp 0
  jr z, .doneWithSecondBodyPart
  cp 1
  jr z, .shiftRight
  ld a, [_y]
  sub a, 8
  ld [hli], a;y
  ld a, 20
  ld [hli], a;x
  jr .setSecondBodyTile
.shiftRight
  ld a, [_y]
  ld [hli], a;y
  ld a, 24
  ld [hli], a;x
.setSecondBodyTile
  ld a, d
  add a, c
  add a, 24;tile
  ld [hli], a
  inc hl;skip pal
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
  inc a;skip pal

  ret

ShowLineup::; a = playing_game?
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

  CLEAR_WIN_AREA 0, 0, 20, 18, " "
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a; move_win(7,0);
  call DrawPlayers
  SHOW_WIN
  DISPLAY_ON
.loop
    call UpdateInput
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
    call gbdk_WaitVBL
    jr .loop
.exit
  HIDE_WIN
  ret
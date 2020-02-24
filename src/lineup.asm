INCLUDE "src/beisbol.inc"

SECTION "Lineup", ROMX, BANK[LINEUP_BANK]

INCLUDE "img/health_bar.asm"
INCLUDE "img/lineup_sprites.asm"

DrawPlayers:
  ld hl, UserLineup
  xor a
.loop
    ld [_y], a
    ld a, [hl]
    ld [_breakpoint], a
    cp 0
    ret z
    call DrawPlayer;doesn't change hl
    ld bc, UserLineupPlayer2 - UserLineupPlayer1
    add hl, bc
    ld a, [_y]
    inc a
    cp 9
    jr nz, .loop
  ret

DrawPlayer: ;hl = player, _y is order on screen
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
  ld a, [_y]
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

DrawPlayerSprites
  ld a, [hl]
  call LoadPlayerBaseData
  
  ld hl, oam_buffer
  ld a, [_y]
  add a, a;y*2
  add a, a;y*4
  add a, a;y*8
  add a, a;y*16 = 4bytes per sprite, 4 sprites per player
  ld b, 0
  ld c, a
  add hl, bc;sprite id
  push hl

  ld a, [_y]
  inc a
  ld de, 16
  call math_Multiply
  ld a, l;y position
  pop hl
  ld [hli], a;y
  ld a, 20
  ld [hli], a;x
  
  ld bc, player_base+11
  ld a, [bc];body tile
  add a, 32
  ld [hli], a;tile

  ld de, player_base+14
  ld a, [de]
  ld [hli], a;palette

  inc bc
  ld a, [bc];head tile
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
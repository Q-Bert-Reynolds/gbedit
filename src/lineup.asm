INCLUDE "src/beisbol.inc"

SECTION "Lineup", ROMX, BANK[LINEUP_BANK]

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

  ld d, 0
  ld a, [_y]
  add a, a
  ld e, a
  ld h, 20
  ld l, 2
  ld bc, tile_buffer
  call gbdk_SetWinTiles
  pop hl
  ret

ShowLineup::; a = playing_game?
  CLEAR_WIN_AREA 0, 0, 20, 18, " "
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a; move_win(7,0);
  call DrawPlayers
  SHOW_WIN
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
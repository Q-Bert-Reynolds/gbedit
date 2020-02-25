DrawStatScreen:;player in hl
  push hl
  CLEAR_SCREEN " "

  pop hl
  push hl
  call DrawPageOne
.loop
    call gbdk_WaitVBL
    call UpdateInput
    ld a, [button_state]
    and a, PADF_A | PADF_B | PADF_START
    jr z, .loop
  WAITPAD_UP

  pop hl
  call DrawPageTwo
  ret 

DrawPageOne:
  push hl;player
  call GetPlayerNumber
  push af;num

  ld de, _UI_FONT_TILE_COUNT+64
  call LoadPlayerBkgData

  ld bc, 0
  ld de, _UI_FONT_TILE_COUNT+64
  pop af;num
  call SetPlayerBkgTiles

  pop hl;player
  call GetUserPlayerName

  ld hl, name_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld d, 9
  ld e, 1
  ld bc, name_buffer
  call gbdk_SetBkgTiles
  ret

DrawPageTwo:
  ;img and name already drawn
  ret
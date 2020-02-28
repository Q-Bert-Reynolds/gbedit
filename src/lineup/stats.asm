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
  DISPLAY_OFF
  
  pop hl
  call DrawPageTwo
  DISPLAY_ON
  
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
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
  ; DISPLAY_OFF
  
  pop hl
  call DrawPageTwo
  ; DISPLAY_ON
  
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
  ; push af
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

  ; pop af;num
  ; ld h, 0
  ; ld l, a
  ; ld de, name_buffer
  ; call str_Number

  ; ld hl, str_buffer
  ; ld a, "#"
  ; ld [hli], a
  ; ld a, "0"
  ; ld [hli], a
  ; ld [hli], a
  ; ld [hli], a

  ; ; ld hl, name_buffer
  ; ; call str_Length
  ; ; ld hl, str_buffer
  ; ; add hl, de
  ; ; ld d, h
  ; ; ld e, l
  ; ; ld hl, name_buffer
  ; ; call str_Copy

  ; ld h, 4
  ; ld l, 1
  ; ld d, 2
  ; ld e, 7
  ; ld bc, name_buffer
  ; call gbdk_SetBkgTiles

  ld b, 0
  ld c, 8
  ld d, 10
  ld e, 10
  call DrawBKGUIBox

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
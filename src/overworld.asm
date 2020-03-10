INCLUDE "src/beisbol.inc"

SECTION "Overworld", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "img/avatars/avatars.asm"
INCLUDE "img/maps/overworld.asm"
; INCLUDE "maps/billetTown.asm"
BilletTownTemp: INCBIN "./maps/billetTown10.tilemap"

Look:;a = button_state
  push af
  xor a
  ld [_i], a
.checkUp
  pop af
  push af
  and a, PADF_UP
  jr z, .checkDown
  ld hl, _CalvinAvatarIdleUpTileMap
  ld de, _CalvinAvatarIdleUpPropMap
  jr .apply
.checkDown
  pop af
  push af
  and a, PADF_DOWN
  jr z, .checkRight
  ld hl, _CalvinAvatarIdleDownTileMap
  ld de, _CalvinAvatarIdleDownPropMap
  jr .apply
.checkRight
  pop af
  push af
  and a, PADF_RIGHT
  jr z, .checkLeft
  ld hl, _CalvinAvatarIdleRightTileMap
  ld de, _CalvinAvatarIdleRightPropMap
  jr .apply
.checkLeft
  pop af
  push af
  and a, PADF_LEFT
  jr z, .exit
  ld hl, _CalvinAvatarIdleLeftTileMap
  ld de, _CalvinAvatarIdleLeftPropMap
.apply
  ld b, 0
  ld c, 4
  call SetSpriteTilesProps ;bc = offset\count, hl = tilemap, de = propmap
.exit
  pop af
  ret 

Move:;a = button_state
  push af
.checkUp
  pop af
  push af
  and a, PADF_UP
  jr z, .checkDown
  call MoveUp
  jr .exit
.checkDown
  pop af
  push af
  and a, PADF_DOWN
  jr z, .checkRight
  call MoveDown
  jr .exit
.checkRight
  pop af
  push af
  and a, PADF_RIGHT
  jr z, .checkLeft
  call MoveRight
  jr .exit
.checkLeft
  pop af
  push af
  and a, PADF_LEFT
  jr z, .exit
  call MoveLeft
.exit
  pop af
  ret 

MoveUp:
  ld hl, map_y
  ld a, [hl]
  sub a, 1
  ld [hli], a
  jr c, .move;skip if no borrow
  ld a, [hl]
  dec a
  ld [hl], a
.move
  ;TODO: load map tiles off screen
  ld b, 8
.loop
    ld a, [rSCY]
    dec a
    ld [rSCY], a
    call gbdk_WaitVBL
    dec b
    jr nz, .loop
  ret

MoveDown:
  ld hl, map_y
  ld a, [hl]
  add a, 1
  ld [hli], a
  jr nc, .move;skip if no carry
  ld a, [hl]
  inc a
  ld [hl], a
.move
  ;TODO: load map tiles off screen
  ld b, 8
.loop
    ld a, [rSCY]
    inc a
    ld [rSCY], a
    call gbdk_WaitVBL
    dec b
    jr nz, .loop
  ret

MoveLeft:
  ld hl, map_x
  ld a, [hl]
  sub a, 1
  ld [hli], a
  jr c, .move;skip if no borrow
  ld a, [hl]
  dec a
  ld [hl], a
.move
  ;TODO: load map tiles off screen
  ld b, 8
.loop
    ld a, [rSCX]
    dec a
    ld [rSCX], a
    call gbdk_WaitVBL
    dec b
    jr nz, .loop
  ret

MoveRight:
  ld hl, map_x
  ld a, [hl]
  add a, 1
  ld [hli], a
  jr nc, .move;skip if no carry
  ld a, [hl]
  inc a
  ld [hl], a
.move
  ;TODO: load map tiles off screen
  ld b, 8
.loop
    ld a, [rSCX]
    inc a
    ld [rSCX], a
    call gbdk_WaitVBL
    dec b
    jr nz, .loop
  ret

Overworld::
  DISPLAY_OFF
  
  ld hl, _AvatarsTiles
  ld de, $8000
  ld bc, _AVATARS_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, _OverworldTiles
  ld de, $8800
  ld bc, _OVERWORLD_TILE_COUNT*16
  call mem_CopyVRAM
  
  ;HACK
  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, 32 ; w
  ld l, 32 ; h
  ld bc, BilletTownTemp
  call gbdk_SetBkgTiles
  ;ENDHACK

  ld b, 72
  ld c, 76
  ld h, 2
  ld l, 2
  ld a, 0
  call MoveSprites ;bc = xy in screen space, hl = wh in tiles, a = first sprite index

  ld a, PADF_DOWN
  call Look
  
  ;TODO: load initial map position
  xor a
  ld [rSCX], a
  ld [rSCY], a

  DISPLAY_ON
.moveLoop
REPT 4
    call gbdk_WaitVBL
ENDR
    call UpdateInput
    ld a, [last_button_state]
    and a, PADF_LEFT|PADF_RIGHT|PADF_UP|PADF_DOWN
    jr nz, .move
    ld a, [button_state]
    call Look
    jr .moveLoop
.move
    ld a, [button_state]
    call Look
    call Move
    jr .moveLoop
  ret
INCLUDE "src/beisbol.inc"

SECTION "Overworld", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "img/avatars/avatars.asm"
INCLUDE "img/maps/overworld.asm"

Look:;a = button_state
  push af
  xor a
  ld [anim_frame], a
.checkUp
  pop af
  push af
  and a, PADF_UP
  jr z, .checkDown
  ld hl, WalkUpAnim
  call AnimateAvatar
  jr .exit
.checkDown
  pop af
  push af
  and a, PADF_DOWN
  jr z, .checkRight
  ld hl, WalkDownAnim
  call AnimateAvatar
  jr .exit
.checkRight
  pop af
  push af
  and a, PADF_RIGHT
  jr z, .checkLeft
  ld hl, WalkRightAnim
  call AnimateAvatar
  jr .exit
.checkLeft
  pop af
  push af
  and a, PADF_LEFT
  jr z, .exit
  ld b, 1;flip
  ld hl, WalkLeftAnim
  call AnimateAvatar
.exit
  pop af
  ret 

Move:;a = button_state
.checkUp
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

WalkLeftAnim:
  db 1
  dw _CalvinAvatarIdleRightTileMap
  dw _CalvinAvatarIdleRightPropMap
  db 1
  dw _CalvinAvatarWalkRightTileMap
  dw _CalvinAvatarWalkRightPropMap
  db 1
  dw _CalvinAvatarIdleRightTileMap
  dw _CalvinAvatarIdleRightPropMap
  db 1
  dw _CalvinAvatarWalkRightTileMap
  dw _CalvinAvatarWalkRightPropMap

WalkRightAnim:
  db 0
  dw _CalvinAvatarIdleRightTileMap
  dw _CalvinAvatarIdleRightPropMap
  db 0
  dw _CalvinAvatarWalkRightTileMap
  dw _CalvinAvatarWalkRightPropMap
  db 0
  dw _CalvinAvatarIdleRightTileMap
  dw _CalvinAvatarIdleRightPropMap
  db 0
  dw _CalvinAvatarWalkRightTileMap
  dw _CalvinAvatarWalkRightPropMap

WalkUpAnim:
  db 0
  dw _CalvinAvatarIdleUpTileMap
  dw _CalvinAvatarIdleUpPropMap
  db 0
  dw _CalvinAvatarWalkUpTileMap
  dw _CalvinAvatarWalkUpPropMap
  db 1
  dw _CalvinAvatarIdleUpTileMap
  dw _CalvinAvatarIdleUpPropMap
  db 1
  dw _CalvinAvatarWalkUpTileMap
  dw _CalvinAvatarWalkUpPropMap

WalkDownAnim:
  db 0
  dw _CalvinAvatarIdleDownTileMap
  dw _CalvinAvatarIdleDownPropMap
  db 0
  dw _CalvinAvatarWalkDownTileMap
  dw _CalvinAvatarWalkDownPropMap
  db 1
  dw _CalvinAvatarIdleDownTileMap
  dw _CalvinAvatarIdleDownPropMap
  db 1
  dw _CalvinAvatarWalkDownTileMap
  dw _CalvinAvatarWalkDownPropMap

WALK_ANIM_FRAMES EQU (WalkDownAnim-WalkUpAnim)/5

AnimateAvatar:;hl = animation
  ld a, [anim_frame]
  ld b, a
  add a, a;a*2
  add a, a;a*4
  add a, b;a*5
  ld d, 0
  ld e, a
  add hl, de

  ld a, [hli];flip
  push af

  ld a, [hli]
  ld c, a
  ld a, [hli]
  ld b, a;tilemap

  ld a, [hli]
  ld e, a
  ld a, [hl]
  ld d, a;propmap

  ld h, b
  ld l, c;tilemap

  pop af;flip
  and a
  jr z, .noFlip

  ld a, 4
  ld bc, tile_buffer
.flipPropsLoop
    push af
    ld a, [de]
    xor a, OAMF_XFLIP
    ld [bc], a
    inc de
    inc bc

    pop af
    dec a
    jr nz, .flipPropsLoop

  ld de, tile_buffer+4
  ld bc, 4
  call mem_Copy

  ld hl, tile_buffer
  ld c, 4
.swapLoop
    ld a, [hli]
    ld b, a
    ld a, [hld]
    ld [hli], a
    ld a, b
    ld [hli], a
    dec c
    jr nz, .swapLoop

  ld de, tile_buffer
  ld hl, tile_buffer+4

.noFlip

  ld b, 0
  ld c, 4
  call SetSpriteTilesProps ;bc = offset\count, hl = tilemap, de = propmap

  ld a, [anim_frame]
  inc a
  cp WALK_ANIM_FRAMES
  jr nz, .skipMod
  xor a
.skipMod
  ld [anim_frame], a

  ret

MoveUp:
  call SetMapTilesUp
  ld hl, map_y
  ld a, [hl]
  sub a, MAP_STEP_SIZE/8
  ld [hli], a
  jr nc, .move;skip if no borrow
  ld a, [hl]
  dec a
  ld [hl], a
.move
  ld hl, WalkUpAnim
  call AnimateAvatar
  ld a, MAP_STEP_SIZE
.loop
    push af
    ld b, MAP_STEP_SIZE/2
    cp b
    jr nz, .skipAnim
      ld hl, WalkUpAnim
    call AnimateAvatar
.skipAnim
    ld a, [rSCY]
    dec a
    ld [rSCY], a
    call gbdk_WaitVBL
    pop af
    dec a
    jr nz, .loop
  ret

MoveDown:
  call SetMapTilesDown
  ld hl, map_y
  ld a, [hl]
  add a, MAP_STEP_SIZE/8
  ld [hli], a
  jr nc, .move;skip if no carry
  ld a, [hl]
  inc a
  ld [hl], a
.move
  ld hl, WalkDownAnim
  call AnimateAvatar
  ld a, MAP_STEP_SIZE
.loop
    push af
    ld b, MAP_STEP_SIZE/2
    cp b
    jr nz, .skipAnim
    ld hl, WalkDownAnim
    call AnimateAvatar
.skipAnim
    ld a, [rSCY]
    inc a
    ld [rSCY], a
    call gbdk_WaitVBL
    pop af
    dec a
    jr nz, .loop
  ret

MoveLeft:
  call SetMapTilesLeft
  ld hl, map_x
  ld a, [hl]
  sub a, MAP_STEP_SIZE/8
  ld [hli], a
  jr nc, .move;skip if no borrow
  ld a, [hl]
  dec a
  ld [hl], a
.move
  ld hl, WalkLeftAnim
  call AnimateAvatar
  ld a, MAP_STEP_SIZE
.loop
    push af
    ld b, MAP_STEP_SIZE/2
    cp b
    jr nz, .skipAnim
    ld hl, WalkLeftAnim
    call AnimateAvatar
.skipAnim
    ld a, [rSCX]
    dec a
    ld [rSCX], a
    call gbdk_WaitVBL
    pop af
    dec a
    jr nz, .loop
  ret

MoveRight:
  call SetMapTilesRight
  ld hl, map_x
  ld a, [hl]
  add a, MAP_STEP_SIZE/8
  ld [hli], a
  jr nc, .move;skip if no carry
  ld a, [hl]
  inc a
  ld [hl], a
.move
  ld hl, WalkRightAnim
  call AnimateAvatar
  ld a, MAP_STEP_SIZE
.loop
    push af
    ld b, MAP_STEP_SIZE/2
    cp b
    jr nz, .skipAnim
      ld hl, WalkRightAnim
    call AnimateAvatar
.skipAnim
    ld a, [rSCX]
    inc a
    ld [rSCX], a
    call gbdk_WaitVBL
    pop af
    dec a
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
  ld [map_x], a
  ld [map_y], a
  ld [map_x+1], a
  ld [map_y+1], a
  call SetMapTiles

  DISPLAY_ON
.moveLoop
    call gbdk_WaitVBL
    call UpdateInput
    ld a, [last_button_state]
    and a, PADF_LEFT|PADF_RIGHT|PADF_UP|PADF_DOWN
    jr nz, .move
    ld a, [button_state]
    call Look
    jr .moveLoop
.move
    ld a, [button_state]
    call Move
    jr .moveLoop
  ret
INCLUDE "src/beisbol.inc"

SECTION "Overworld", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "img/overworld/overworld.asm"
INCLUDE "maps/billetTown.asm"

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

Overworld::
  DISPLAY_OFF
  
  ld hl, _OverworldTiles
  ld de, $8000
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
  
  DISPLAY_ON
.moveLoop
    call UpdateInput
    ld a, [last_button_state]
    and a, PADF_LEFT|PADF_RIGHT|PADF_UP|PADF_DOWN
    jr nz, .move
    ld a, [button_state]
    call Look
.move
    call Move
    call gbdk_WaitVBL
    jr .moveLoop
  ret
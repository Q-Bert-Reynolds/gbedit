INCLUDE "src/beisbol.inc"

SECTION "Overworld", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "img/overworld/overworld.asm"

Look:;a = button_state
  ld b, 0
  ld c, 4
  ld hl, _CalvinAvatarIdleDownTileMap
  ld de, _CalvinAvatarIdleDownPropMap
  call SetSpriteTilesProps ;bc = offset\count, hl = tilemap, de = propmap

  ret 

Move:

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
INCLUDE "src/beisbol.inc"

SECTION "Overworld", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "img/overworld/player_sprites/player_sprites.asm"

Overworld::
  DISPLAY_OFF

  ld hl, _SpritesTiles
  ld de, $8000
  ld bc, _SPRITES_TILE_COUNT*16
  call mem_CopyVRAM

  ;loop
    ;look
    ;move from current position to position in direction
  ret
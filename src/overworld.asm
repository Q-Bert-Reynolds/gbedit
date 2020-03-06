INCLUDE "src/beisbol.inc"

SECTION "Overworld", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "img/overworld/overworld.asm"

Overworld::
  DISPLAY_OFF

  ld hl, _OverworldTiles
  ld de, $8000
  ld bc, _OVERWORLD_TILE_COUNT*16
  call mem_CopyVRAM

.moveLoop
    ;look
    ;move from current position to position in direction
    call gbdk_WaitVBL
    jr .moveLoop
  ret
IF !DEF(MAP_LOADER)
MAP_LOADER SET 1

INCLUDE "maps/map_data.asm"

SECTION "Map Loader", ROM0
LoadMapData::; loads appropriate map from positional data
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, MAPS_BANK
  call SetBank

  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, 32 ; w
  ld l, 32 ; h
  ld bc, _BilletTown8Tiles
  call gbdk_SetBkgTiles

  ld a, [temp_bank]
  call SetBank
  ret

ENDC ;MAP_LOADER

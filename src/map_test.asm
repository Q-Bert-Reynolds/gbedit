INCLUDE "src/beisbol.inc"

SECTION "Map Test", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "maps/unity_test_map.gbmap"

DrawSparseMap:
  ld hl, UnityTestMap
.loop
    ld a, [hli]
    and a
    ret z
    cp a, MAP_STAMP
    jr z, .stamp
    cp a, MAP_FILL
    jr z, .fill
  .tile
    ld a, [hli];tile
    ld bc, tile_buffer
    ld [bc], a
    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a
    push hl;next map object
    ld hl, $0101
    jr .setTiles
  .stamp
    ld a, [hli];stamp lower address
    ld e, a
    ld a, [hli];stamp upper address
    ld d, a
    push hl
    call LoadStamp
    pop bc
    ld a, [bc]
    inc bc
    ld d, a;x
    ld a, [bc]
    inc bc
    ld e, a;y
    push bc;
    ld bc, tile_buffer
    jr .setTiles
  .fill;TODO
    ld a, [hli];tile
    ld a, [hli];x
    ld a, [hli];y
    ld a, [hli];w
    ld a, [hli];h
    jr .loop
  .setTiles
    call gbdk_SetBkgTiles
    pop hl
    jr .loop
  ret

LoadStamp:;de = stamp address, returns w,h in hl, tiles in tile_buffer
  ld a, [de];width
  inc de
  ld b, a
  ld a, [de];height
  ld c, a
  push bc;w,h
  inc de
  push de;tiles
  ld d, 0
  ld e, b
  call math_Multiply
  ld b, h
  ld c, l
  pop hl;tiles
  ld de, tile_buffer
  call mem_Copy
  pop hl;w,h
  ret

TestMap::
  DISPLAY_OFF
  SET_DEFAULT_PALETTE

  call LoadFontTiles
  call LoadOverworldTiles
  call DrawSparseMap

.loop
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, PADF_A | PADF_START
    call gbdk_WaitVBL
    jr .loop
.exit
  ret

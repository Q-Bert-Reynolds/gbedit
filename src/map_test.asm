INCLUDE "src/beisbol.inc"

SECTION "Map Test", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "maps/unity_test_map.gbmap"

DrawSparseMap:
  CLEAR_BKG_AREA 0,0,32,32,255
  ld hl, ChunkA+8
.loop
    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a
    push de;xy
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
    push hl;next map object
    ld hl, $0101
    jp .setTiles
  .stamp
    ld a, [hli];stamp lower address
    ld e, a
    ld a, [hli];stamp upper address
    ld d, a
    push hl
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
    pop bc
    ld a, [bc]
    inc bc
    ld d, a;x
    ld a, [bc]
    inc bc
    ld e, a;y
    push bc;
    ld bc, tile_buffer
    jp .setTiles
  .fill
    ld a, [hli];tile
    push af;tile
    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a;de = xy
    ld a, [hli];w
    ld b, a
    ld a, [hli];h
    ld c, a;bc = wh
    pop af;tile
    push hl;next map object
    push de;xy
    push bc;wh
    push af;tile
    ld d, 0
    ld e, b
    ld a, c
    call math_Multiply;hl = de * a = width * height
    ld b, h
    ld c, l
    pop af;tile
    ld hl, tile_buffer
    call mem_Set
    pop hl;wh
    pop de;xy
    ld bc, tile_buffer
  .setTiles
    pop de;xy
    call gbdk_SetBkgTiles
    pop hl;next map object
    jp .loop
  ret

TestMap::
  DISPLAY_OFF
  SET_DEFAULT_PALETTE

  call LoadFontTiles
  call LoadOverworldTiles
  call DrawSparseMap

  DISPLAY_ON

.loop
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, PADF_A | PADF_START
    call gbdk_WaitVBL
    jr .loop
.exit
  ret

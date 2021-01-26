INCLUDE "src/beisbol.inc"

SECTION "Map Test", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "maps/unity_test_map.gbmap"

SetupMapPalettes:
  ld a, %10000000
  ldh [rBCPS], a
  ld hl, MapPalettes
  ld c, 8*2*4;8 palettes * 2B / color * 4 colors / palette
.loop
    ld a, [hli]
    ldh [rBCPD], a
    dec c
    jr nz, .loop
  ret

DrawSparseMap:
  xor a
  ld [rVBK], a
  ld hl, InfieldChunk
.setChunkTile
  ld a, [hli];tile
  push hl
  ld bc, 32*32
  ld hl, _SCRN0
  call mem_Set
  pop hl

.setChunkPalette
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .drawMapObjects
  ld a, 1
  ld [rVBK], a
  ld a, [hl];tile
  push hl
  ld bc, 32*32
  ld hl, _SCRN0
  call mem_Set
  pop hl
  xor a
  ld [rVBK], a

.drawMapObjects
  ld bc, 9
  add hl, bc;skip neighboring chunks
.loop
    ld a, [hli];map object type
    and a
    ret z; done if 0
    ld b, a

    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a
    push de;xy

    ld a, b;map obj type
    cp a, MAP_STAMP
    jr z, .stamp
    cp a, MAP_FILL
    jr z, .fill
  .tile
    ld a, [hli];tile
    ld bc, tile_buffer
    ld [bc], a
    ld a, [hli];palette
    ld d, a;palette

    ld a, [sys_info]
    and a, SYS_INFO_GBC
    jr z, .skipTilePal
    ld a, 2
    ld [rSVBK], a
    ld a, d;palette
    ld [bc], a
    xor a
    ld [rSVBK], a
  .skipTilePal

    pop de;xy
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
    push bc;w*h
    call mem_Copy
    pop bc;w*h

    ld a, [sys_info]
    and a, SYS_INFO_GBC
    jr z, .skipStampPal
    ld a, 2
    ld [rSVBK], a
    ld a, [hl]
    bit 7, a
    jr z, .nonUniformPal
  .uniformPal
    and a, %01111111
    ld hl, tile_buffer
    call mem_Set
    jr .finishStampPal
  .nonUniformPal
    ld de, tile_buffer
    call mem_Copy
  .finishStampPal
    xor a
    ld [rSVBK], a
  .skipStampPal

    pop hl;w,h
    pop bc;next map object
    pop de;xy
    push bc;next map object
    ld bc, tile_buffer
    jp .setTiles

  .fill
    ld a, [hli];tile
    ld d, a;tile
    ld a, [hli];palette
    ld e, a;palette
    ld a, [hli];w
    ld b, a
    ld a, [hli];h
    ld c, a;bc = wh
    push hl;next map object
    push bc;wh
    push de;tile, pal
    ld d, 0
    ld e, b
    ld a, c
    call math_Multiply;hl = de * a = width * height
    ld b, h
    ld c, l

  .fillPaletteBuffer
    pop de;tile, palette
    ld a, [sys_info]
    and a, SYS_INFO_GBC
    jr z, .fillTileBuffer
    push bc;w*h
    ld a, 2
    ld [rSVBK], a
    ld a, e;palette
    ld hl, tile_buffer
    call mem_Set
    xor a
    ld [rSVBK], a

    pop bc;w*h
  .fillTileBuffer
    ld a, d;tile
    ld hl, tile_buffer
    call mem_Set

    pop hl;wh
    pop bc;next map obj
    pop de;xy
    push bc;next map obj
    ld bc, tile_buffer
  .setTiles
    push hl;wh
    push de;xy
    call gbdk_SetBkgTiles
    pop de;xy
    pop hl;wh
  .checkCGB
    ld a, [sys_info]
    and a, SYS_INFO_GBC
    jr z, .nextMapObject
    ld a, 1
    ld [rVBK], a
    inc a
    ld [rSVBK], a
    ld bc, tile_buffer
    call gbdk_SetBkgTiles
    xor a
    ld [rVBK], a
    ld [rSVBK], a
  .nextMapObject
    pop hl;next map object
    jp .loop
  ret

TestMap::
  DISPLAY_OFF
  SET_DEFAULT_PALETTE

  call LoadFontTiles
  call LoadOverworldTiles
  call SetupMapPalettes
  call DrawSparseMap

  DISPLAY_ON

.loop
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, PADF_A | PADF_START
    call gbdk_WaitVBL
    jr .loop
.exit
  ret

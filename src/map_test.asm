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

TestObject:
  ld a, 1
  or a
  ret 

DrawSparseMap:; hl = chunk address, de=xy, bc=wh
  push bc;wh
  ld a, d
  ld [_x], a;minX
  ld a, e
  ld [_y], a;minY
  ld a, b;w
  add a, d;x+w
  ld [_u], a;maxX
  ld a, c;h
  add a, e;y+h
  ld [_v], a;maxY
  pop bc;wh
  xor a
  ld [rVBK], a
.setChunkTile
  ld a, [hli];tile
  push hl;palette address
  push de;xy
  push bc;wh
  ld hl, _SCRN0
  call gbdk_SetTilesTo
  pop bc;wh
  pop de;xy
  pop hl;palette address

.setChunkPalette
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .drawMapObjects
  ld a, 1
  ld [rVBK], a
  ld a, [hl];pal
  push hl
  ld hl, _SCRN0
  call gbdk_SetTilesTo
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
    ld b, a;type

    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a
    
    ld a, b;type

    cp a, MAP_STAMP
    jp z, .testStampX
    cp a, MAP_FILL
    jp z, .testFillX
    ; cp a, MAP_TILE
    ; jp z, .testTileX

  .testTileX
    ld a, [_u];maxX
    cp a, d;x
    jr c, .tileOutOfRange;maxX < x
    jr z, .tileOutOfRange;maxX == x
    ld a, [_x];minX
    cp a, d;x
    jr z, .testTileY;minX == x
    jr nc, .tileOutOfRange;minX > x
  .testTileY
    ld a, [_v];maxY
    cp a, e;y
    jr c, .tileOutOfRange;maxY < y
    jr z, .tileOutOfRange;maxY == y
    ld a, [_y];minY
    cp a, e;y
    jr z, .drawTile;minY == y
    jr nc, .tileOutOfRange;minY > y
  .drawTile
    ld a, [hli];tile
    ld b, a
    ld a, [hli];palette
    push hl;next map object
    push af;palette
    ld a, b;tile
    ld bc, $0101
    ld hl, _SCRN0
    push de;xy
    call gbdk_SetTilesTo
    pop de;xy
    pop bc;palette
    ld a, [sys_info]
    and a, SYS_INFO_GBC
    jp z, .nextMapObject
    ld a, 1
    ld [rVBK], a
    ld a, b;palette
    ld bc, $0101
    ld hl, _SCRN0
    call gbdk_SetTilesTo
    xor a
    ld [rVBK], a
    jp .nextMapObject
  .tileOutOfRange
    inc hl
    inc hl
    jp .loop
  
  .testStampX
    ld a, [_u];maxX
    cp a, d;x
    jr c, .stampOutOfRange;maxX < x
    jr z, .stampOutOfRange;maxX == x
  .testStampY
    ld a, [_v];maxY
    cp a, e;y
    jr c, .stampOutOfRange;maxY < y
    jr z, .stampOutOfRange;maxY == y
  .drawStamp
    ld a, [hli];stamp lower address
    ld c, a
    ld a, [hli];stamp upper address
    ld b, a;bc = stamp address
    push hl;next object address
    ld a, [bc];stamp width
    ld h, a
    inc bc
    ld a, [bc];stamp height
    ld l, a
    inc bc;stamp tiles
    push hl;wh
    push de;xy
    call gbdk_SetBkgTiles;returns bc=stamp palette
    pop de;xy
    pop hl;wh
    ld a, [sys_info]
    and a, SYS_INFO_GBC
    jp z, .nextMapObject
    ld a, 1
    ld [rVBK], a
    ld a, [bc]
    bit 7, a
    jr z, .nonUniformPal
  .uniformPal
    and a, %01111111;tile
    ld b, h
    ld c, l;bc = wh
    ld hl, _SCRN0
    call gbdk_SetTilesTo
    jr .finishStampPal
  .nonUniformPal
    call gbdk_SetBkgTiles
  .finishStampPal
    xor a
    ld [rVBK], a
    jp .nextMapObject
  .stampOutOfRange
    inc hl
    inc hl
    jp .loop

  .testFillX
    ld a, [_u];maxX
    cp a, d;x
    jr c, .fillOutOfRange;maxX < x
    jr z, .fillOutOfRange;maxX == x
    ld a, [_x];minX
    cp a, d
    jr c, .testFillY
    ld d, a
  .testFillY
    ld a, [_v];maxY
    cp a, e;y
    jr c, .fillOutOfRange;maxY < y
    jr z, .fillOutOfRange;maxY == y
    ld a, [_y];minY
    cp a, e
    jr c, .drawFill
    ld e, a
  .drawFill
    ld a, [hli];tile
    ld [_a], a
    ld a, [hli];palette
    ld [_b], a
    ld a, [hli];fill maxX
    ld b, a;fill maxX
    ld a, [_u];chunk maxX
    cp a, b
    jr nc, .skipMaxXTruncate;chunk maxX >= fill maxX
    ld b, a;fill maxX = chunk maxX
  .skipMaxXTruncate
    ld a, [hli];fill maxY
    ld c, a;fill maxY
    ld a, [_v];chunk maxY
    cp a, c
    jr nc, .skipMaxYTruncate;chunk maxY >= fill maxY
    ld c, a;fill maxY = chunk maxY
  .skipMaxYTruncate
    ld a, b;maxX
    sub a, d;width
    jp c, .loop;if width<0
    jp z, .loop;if width==0
    ld b, a
    ld a, c;maxY
    sub a, e;height
    jp c, .loop;if height<0
    jp z, .loop;if height==0
    ld c, a
    push hl;next map object
    ld a, [_a];tile
    ld hl, _SCRN0
    push de;xy
    push bc;wh
    call gbdk_SetTilesTo
    pop bc;wh
    pop de;xy
    ld a, [sys_info]
    and a, SYS_INFO_GBC
    jr z, .nextMapObject
    ld a, 1
    ld [rVBK], a
    ld a, [_b];palette
    ld hl, _SCRN0
    call gbdk_SetTilesTo
    xor a
    ld [rVBK], a
  .fillOutOfRange
    ld bc, 4
    add hl, bc
    jp .loop
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
  ld hl, InfieldChunk
  ld de, $0800
  ld bc, $1412
  call DrawSparseMap

  DISPLAY_ON

.loop
    ld hl, InfieldChunk
    ld de, $0800
    ld bc, $1412
    call DrawSparseMap
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, PADF_A | PADF_START
    call gbdk_WaitVBL
    jr .loop
.exit
  pop hl;chunk
  ret

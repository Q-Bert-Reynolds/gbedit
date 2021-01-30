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
  cp a, 32
  jr c, .minXValid
  xor a
.minXValid
  ld [_x], a;minX
  ld a, e
  cp a, 32
  jr c, .minYValid
  xor a
.minYValid
  ld [_y], a;minY
  ld a, b;w
  add a, d;x+w
  cp a, 33
  jr c, .maxXValid
  ld a, 32
.maxXValid
  ld [_u], a;maxX
  ld a, c;h
  add a, e;y+h
  cp a, 33
  jr c, .maxYValid
  ld a, 32
.maxYValid
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
    jp z, .testStampMinX
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
  
  .testStampMinX
    ld a, [_u];chunk maxX
    cp a, d;stamp minX
    jr c, .stampOutOfRange;chunk maxX < stamp minX
    jr z, .stampOutOfRange;chunk maxX == stamp minX
  .testStampMinY
    ld a, [_v];chunk maxY
    cp a, e;stamp minY
    jr c, .stampOutOfRange;chunk maxY < stamp minY
    jr z, .stampOutOfRange;chunk maxY == stamp minY
  .drawStamp
    ld a, [hli];stamp lower address
    ld c, a
    ld a, [hli];stamp upper address
    ld b, a;bc = stamp address
    push hl;next object address
    ld a, [bc];stamp width
    add a, d;x+w
    ld h, a;stamp maxX
    inc bc
    ld a, [bc];stamp height
    add a, e;y+h
    ld l, a;stamp maxY

  .testStampMaxX
    ld a, [_x];chunk minX
    cp a, h;stamp maxX
    jp z, .nextMapObject;chunk minX == stamp maxX
    jp nc, .nextMapObject;chunk minX > stamp maxX
  .testStampMaxY
    ld a, [_y];chunk minX
    cp a, l;stamp maxy
    jp z, .nextMapObject;chunk minY == stamp maxY
    jp nc, .nextMapObject;chunk minY > stamp maxY

    inc bc;stamp tiles
    ld a, h;maxX
    sub a, d;maxX-x
    ld h, a;w
    ld a, l;maxY
    sub a, e;maxY-y
    ld l, a;w
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
    jr .nextMapObject
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
  ld a, 3
  ld [map_x], a
  ld [map_y], a
  ld d, a
  ld e, a
  sla a
  sla a
  sla a
  ld [rSCX], a
  ld [rSCY], a
  ld hl, InfieldChunk
  ld bc, $1513
  call DrawSparseMap

  DISPLAY_ON

.loop
    call UpdateInput
    ld a, [button_state]
    ld b, a;buttons
  .testUp
    and a, PADF_UP
    jr z, .testDown
    ld a, [rSCY]
    dec a
    push af
    ld e, a
    srl e
    srl e
    srl e
    ld a, [map_y]
    cp a, e
    jp z, .moveY
    ld a, e
    ld [map_y], a
    ld e, a
    ld a, [rSCX]
    ld d, a
    srl d
    srl d
    srl d
    jp .drawY
  .testDown
    ld a, b
    and a, PADF_DOWN
    jr z, .testLeft
    ld a, [rSCY]
    inc a
    push af
    ld e, a
    srl e
    srl e
    srl e
    ld a, [map_y]
    cp a, e
    jr z, .moveY
    ld a, e
    ld [map_y], a
    add a, 18
    ld e, a
    ld a, [rSCX]
    ld d, a
    srl d
    srl d
    srl d
    jp .drawY
  .testLeft
    ld a, b
    and a, PADF_LEFT
    jr z, .testRight
    ld a, [rSCX]
    dec a
    push af
    ld d, a
    srl d
    srl d
    srl d
    ld a, [map_x]
    cp a, d
    jr z, .moveX
    ld a, d
    ld [map_x], a
    ld d, a
    ld a, [rSCY]
    ld e, a
    srl e
    srl e
    srl e
    jp .drawX
  .testRight
    ld a, b
    and a, PADF_RIGHT
    jr z, .testStartA
    ld a, [rSCX]
    inc a
    push af
    ld d, a
    srl d
    srl d
    srl d
    ld a, [map_x]
    cp a, d
    jr z, .moveX
    ld a, d
    ld [map_x], a
    add a, 20
    ld d, a
    ld a, [rSCY]
    ld e, a
    srl e
    srl e
    srl e
  .drawX
    ld hl, InfieldChunk
    ld bc, $0113
    call DrawSparseMap
  .moveX
    pop af
    ld [rSCX], a
    jr .testStartA
  .drawY
    ld hl, InfieldChunk
    ld bc, $1501
    call DrawSparseMap
  .moveY
    pop af
    ld [rSCY], a
  .testStartA
    ld a, [last_button_state]
    and a, PADF_A | PADF_START
    jr nz, .wait
    ld a, [button_state]
    and a, PADF_A | PADF_START
    jr nz, .exit
  .wait
    call gbdk_WaitVBL
    jp .loop
.exit
  pop hl;chunk
  ret

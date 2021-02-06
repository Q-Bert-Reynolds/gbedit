IF !DEF(MAP_LOADER)
MAP_LOADER SET 1

INCLUDE "src/beisbol.inc"

SECTION "Map Loader", ROM0
; GetMapCollision              hl = chunk address, de = xy, returns z if no collision
; MoveMapLeft
; MoveMapRight
; MoveMapUp
; MoveMapDown
; SetupMapPalettes             hl = map palette address
; DrawMapLeftEdge
; DrawMapRightEdge
; DrawMapTopEdge
; DrawMapBottomEdge
; DrawMapToScreen
; DrawMapChunk                 hl = chunk address, de=xy, bc=wh
; GetCurrentMapChunk           returns chunk address in hl, index in a
; SetCurrentMapChunk           hl = chunk address, returns address in hl, index in a
; GetCurrentMapChunkNeighbor   a = direction, returns chunk in hl, index in a
; GetMapChunkNeighbor          a = direction, hl = map chunk, returns chunk in hl, index in a
; GetMapChunk                  a = jump table index; hl = jump table, returns chunk in hl, index in a
; GetMapChunkForOffset         de = xy pixel offset, returns chunk in hl, tile xy in de

GetMapCollision::;hl = chunk address, de = xy, returns z if no collision
  ld a, d
  ld [_x], a
  ld a, e
  ld [_y], a
  ld bc, 6;tile(1)+pal(1)+neighbors(4)
  add hl, bc
.loop
    ld a, [hli];map object type and collision
    and a
    ret z; done if 0
    
    ld b, a;map object type and collision
    and a, MAP_COLLISION_MASK
    ld c, a;collision type
    ld [_c], a
    
    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a
    
    ld a, b;map object type and collision
    and a, MAP_OBJ_TYPE_MASK
    cp a, MAP_OBJ_STAMP
    jp z, .stamp
    cp a, MAP_OBJ_FILL
    jp z, .fill
    ; cp a, MAP_OBJ_TILE
    ; jp z, .tile

  .tile
    inc hl;skip tile
    inc hl;skip palete
    ld a, [_x]
    cp a, d;x
    jp nz, .loop
    ld a, [_y]
    cp a, e;y
    jp z, .collisonFound
    jp .loop

  .stamp
    ld a, [_x]
    cp a, d;x
    jr c, .skip2Bytes
    ld a, [_y]
    cp a, e;y
    jr c, .skip2Bytes
    ld a, [hli];stamp lower address
    ld c, a
    ld a, [hli];stamp upper address
    ld b, a;bc = stamp address
    ld a, [bc];width
    inc bc
    add a, d;x+width
    ld d, a;x2
    ld a, [_x]
    cp a, d;x2
    jp nc, .loop
    ld a, [bc];height
    add a, e;y+height
    ld e, a;y2
    ld a, [_y]
    cp a, e;y2
    jp c, .collisonFound
    jp .loop

  .fill
    inc hl;skip tile
    inc hl;skip palete
    ld a, [_x]
    cp a, d;x1
    jr c, .skip2Bytes
    ld a, [_y]
    cp a, e;y1
    jr c, .skip2Bytes
    ld a, [hli];x2
    ld d, a
    ld a, [hli];y2
    ld e, a
    ld a, [_x]
    cp a, d;x2
    jp nc, .loop
    ld a, [_y]
    cp a, e;y2
    jp c, .collisonFound
    jp .loop

  .skip2Bytes
    inc hl
    inc hl
    jp .loop

.collisonFound
  ld a, [_c]
  cp a, MAP_COLLISION_NONE
  jp z, .loop
  cp a, MAP_COLLISION_DOOR
  ret

;HACK: rounds rSCX and rSCY to nearest multiple of 8
;  Walking around often results in off-by-one collision errors.
;  Visually, it's not noticable, but results in crashes when pausing.
;  This should really be corrected in the collision routine, but it's easier here.
FixMapScroll::
.fixX
  ld a, [rSCX]
  and a, %00000111
  jr z, .fixY
  ld a, [rSCX]
  inc a
  ld [rSCX], a
  srl a
  srl a
  srl a
  ld [map_x], a
.fixY
  ld a, [rSCY]
  and a, %00000111
  ret z
  ld a, [rSCY]
  inc a
  ld [rSCY], a
  srl a
  srl a
  srl a
  ld [map_y], a
  ret

MoveMapLeft::
  ld b, 63;left
  ld c, 76
  call GetMapChunkForOffset
  call GetMapCollision
  ret nz
  ld a, [rSCX]
  sub a, MAP_SCROLL_SPEED
  push af
  ld d, a
  jr nc, .noChunkChangeWest
  ld a, MAP_WEST
  call GetCurrentMapChunkNeighbor
  call SetCurrentMapChunk
.noChunkChangeWest
  srl d
  srl d
  srl d
  ld a, [map_x]
  cp a, d
  jp z, .move;if x == map_x, no draw
  ld a, d
  ld [map_x], a
  call DrawMapLeftEdge
.move
  pop af
  ld [rSCX], a
  ret

MoveMapRight::
  ld b, 81;right
  ld c, 76
  call GetMapChunkForOffset
  call GetMapCollision
  ret nz
  ld a, [rSCX]
  add a, MAP_SCROLL_SPEED
  push af
  ld d, a
  jr nc, .noChunkChangeEast
  ld a, MAP_EAST
  call GetCurrentMapChunkNeighbor
  call SetCurrentMapChunk
.noChunkChangeEast
  srl d
  srl d
  srl d
  ld a, [map_x]
  cp a, d
  jp z, .move;if x == map_x, no draw
  ld a, d
  ld [map_x], a
  call DrawMapRightEdge
.move
  pop af
  ld [rSCX], a
  ret

MoveMapUp::
  ld b, 76
  ld c, 63;up
  call GetMapChunkForOffset
  call GetMapCollision
  ret nz
  ld a, [rSCY]
  sub a, MAP_SCROLL_SPEED
  push af
  ld e, a
  jr nc, .noChunkChangeNorth
  ld a, MAP_NORTH
  call GetCurrentMapChunkNeighbor
  call SetCurrentMapChunk
.noChunkChangeNorth
  srl e
  srl e
  srl e
  ld a, [map_y]
  cp a, e
  jp z, .move;if y == map_y, no draw
  ld a, e
  ld [map_y], a
  call DrawMapTopEdge
.move
  pop af
  ld [rSCY], a
  ret

MoveMapDown::
  ld b, 76
  ld c, 81;down
  call GetMapChunkForOffset
  call GetMapCollision
  ret nz
  ld a, [rSCY]
  add a, MAP_SCROLL_SPEED
  push af
  ld e, a
  jr nc, .noChunkChangeSouth
  ld a, MAP_SOUTH
  call GetCurrentMapChunkNeighbor
  call SetCurrentMapChunk
.noChunkChangeSouth
  srl e
  srl e
  srl e
  ld a, [map_y]
  cp a, e
  jp z, .move;if y == map_y, no draw
  ld a, e
  ld [map_y], a
  call DrawMapBottomEdge
.move
  pop af
  ld [rSCY], a
  ret

SetupMapPalettes::;hl = map palette address
  ld a, %10000000
  ldh [rBCPS], a
  ld c, 8*2*4;8 palettes * 2B / color * 4 colors / palette
.loop
    ld a, [hli]
    ldh [rBCPD], a
    dec c
    jr nz, .loop
  ret

DrawMapLeftEdge:
  ld bc, $0113
  ld a, [map_x]
  ld d, a
  ld a, [map_y]
  ld e, a
.testY
  cp a, 14
  jr c, .drawCurrentChunk
  ld a, 32
  sub a, e;bottom-y
  ld c, a;h=bottom-y
.drawCurrentChunk
  push bc;wh
  push de;xy
  call GetCurrentMapChunk
  call DrawMapChunk
  pop de;xy
  pop bc;wh
.testSouth
  ld a, c;h
  cp a, 19;full h
  ret z
.drawSouthChunk
  ld e, 0
  ld a, 19;full h
  sub a, c;19-h
  ld c, a;h=19-h
  ld a, MAP_SOUTH
  call GetCurrentMapChunkNeighbor
  call DrawMapChunk
  ret

DrawMapRightEdge:
  call GetCurrentMapChunk
  ld bc, $0113
  ld a, [map_y]
  ld e, a
  ld a, [map_x]
  add a, 20
  ld d, a
.testX
  sub a, 32
  jr c, .testY
  ld d, a
  ld a, MAP_EAST
  call GetMapChunkNeighbor
.testY
  ld a, e;y
  cp a, 14
  jr c, .drawCurrentChunk
  ld a, 32
  sub a, e;bottom-y
  ld c, a;h=bottom-y
.drawCurrentChunk
  push bc;wh
  push de;xy
  push hl;chunk
  call DrawMapChunk
  pop hl;chunk
  pop de;xy
  pop bc;wh
.testSouth
  ld a, c;h
  cp a, 19;full h
  ret z
.drawSouthChunk
  ld e, 0
  ld a, 19;full h
  sub a, c;19-h
  ld c, a;h=19-h
  ld a, MAP_SOUTH
  call GetMapChunkNeighbor
  call DrawMapChunk
  ret

DrawMapTopEdge:
  ld a, [map_x]
  ld d, a
  ld a, [map_y]
  ld e, a
  ld bc, $1501
.testX
  ld a, d;x
  cp a, 12
  jr c, .drawCurrentChunk
  ld a, 32
  sub a, d;right-x
  ld b, a;w=right-x
.drawCurrentChunk
  push bc;wh
  push de;xy
  call GetCurrentMapChunk
  call DrawMapChunk
  pop de;xy
  pop bc;wh
.testEast
  ld a, b;w
  cp a, 21;full w
  ret z
.drawEastChunk
  ld d, 0
  ld a, 21;full w
  sub a, b;21-w
  ld b, a;w=21-w
  ld a, MAP_EAST
  call GetCurrentMapChunkNeighbor
  call DrawMapChunk
  ret

DrawMapBottomEdge:
  call GetCurrentMapChunk
  ld bc, $1501
  ld a, [map_x]
  ld d, a
  ld a, [map_y]
  add a, 18
  ld e, a
.testY
  sub a, 32
  jr c, .testX
  ld e, a
  ld a, MAP_SOUTH
  call GetMapChunkNeighbor
.testX
  ld a, d;x
  cp a, 12
  jr c, .drawCurrentChunk
  ld a, 32
  sub a, d;right-x
  ld b, a;w=right-x
.drawCurrentChunk
  push bc;wh
  push de;xy
  push hl;chunk
  call DrawMapChunk
  pop hl;chunk
  pop de;xy
  pop bc;wh
.testEast
  ld a, b;w
  cp a, 21;full w
  ret z
.drawEastChunk
  ld d, 0
  ld a, 21;full w
  sub a, b;21-w
  ld b, a;w=21-w
  ld a, MAP_EAST
  call GetMapChunkNeighbor
  call DrawMapChunk
  ret
  
DrawMapToScreen::
  ld a, [map_x]
  ld d, a
  sla a
  sla a
  sla a
  ld [rSCX], a
  ld a, [map_y]
  ld e, a
  sla a
  sla a
  sla a
  ld [rSCY], a
  ld bc, $1513;w+1,h+1
.testX
  ld a, d;x
  cp a, 12
  jr c, .testY
  ld a, 32
  sub a, d;right-x
  ld b, a;w=right-x
.testY
  ld a, e;y
  cp a, 14
  jr c, .drawCurrentChunk
  ld a, 32
  sub a, e;bottom-y
  ld c, a;h=bottom-y
.drawCurrentChunk
  push bc;wh
  push de;xy
  call GetCurrentMapChunk
  call DrawMapChunk
  pop de;xy
  pop bc;wh
.testEast
  ld a, b;w
  cp a, 21;full w
  jr z, .testSouth
.drawEastChunk
  push bc;wh
  push de;xy
  ld d, 0
  ld a, 21;full w
  sub a, b;21-w
  ld b, a;w=21-w
  ld a, MAP_EAST
  call GetCurrentMapChunkNeighbor
  call DrawMapChunk
  pop de;xy
  pop bc;wh
.testSouth
  ld a, c;h
  cp a, 19;full h
  ret z
.drawSouthChunk
  ld e, 0
  ld a, 19;full h
  sub a, c;19-h
  ld c, a;h=19-h
  push bc;wh
  push de;xy
  ld a, MAP_SOUTH
  call GetCurrentMapChunkNeighbor
  call DrawMapChunk
  pop de;xy
  pop bc;wh
.testSouthEast
  ld a, b;w
  cp a, 21;full w
  ret z
.drawSouthEastChunk
  ld d, 0
  ld a, 21;full w
  sub a, b;21-w
  ld b, a;w=21-w
  ld a, MAP_SOUTH
  call GetCurrentMapChunkNeighbor
  ld a, MAP_EAST
  call GetMapChunkNeighbor
  call DrawMapChunk
  ret

DrawMapChunk:; hl = chunk address, de=xy, bc=wh
.testWidth
  ld a, b;w
  and a
  ret z 
.testHeight 
  ld a, c;h
  and a
  ret z
.storeMinMax
  ld a, d
  ld [_x], a;minX
  ld a, e
  ld [_y], a;minY
  ld a, b
  add a, d;x+w
  ld [_u], a;maxX
  ld a, c
  add a, e;y+h
  ld [_v], a;maxY
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
  ld a, [hl];pal, no increment since this section can be skipped
  push hl
  ld hl, _SCRN0
  call gbdk_SetTilesTo
  pop hl
  xor a
  ld [rVBK], a
.drawMapObjects
  ld bc, 5;pal(1)+neighbors(4)
  add hl, bc;skip pal, neighboring chunks, and collision
.loop
    ld a, [hli];map object type and collision
    and a
    ret z; done if 0
    ld b, a;map object type and collision

    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a
    
    ld a, b;map object type and collision
    and a, MAP_OBJ_TYPE_MASK
    cp a, MAP_OBJ_STAMP
    jp z, .testStampMinX
    cp a, MAP_OBJ_FILL
    jp z, .testFillX
    ; cp a, MAP_OBJ_TILE
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

GetCurrentMapChunk:;returns chunk address in hl, index in a
  ld a, [map_chunk]
  ld hl, MapOverworldChunks;TODO: this should be the beginning of the current map bank
  call GetMapChunk
  ret

SetCurrentMapChunk:;a = chunk index, returns address in hl, index in a
  ld [map_chunk], a
  ld hl, MapOverworldChunks;TODO: this should be the beginning of the current map bank
  call GetMapChunk
  ret

GetCurrentMapChunkNeighbor:;a = direction, returns chunk in hl, index in a
  push af;dir
  call GetCurrentMapChunk
  pop af;dir
  ;fall through
GetMapChunkNeighbor:;a = direction, hl = map chunk, returns chunk in hl, index in a
  push bc
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hl];jump table index
  ld hl, MapOverworldChunks;TODO: this should be the beginning of the current map bank
  call GetMapChunk
  pop bc
  ret

GetMapChunk:;a = jump table index; hl = jump table, returns chunk in hl, index in a
  push bc
  push af;index
  add a, a;index * 2
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop af;index
  pop bc
  ret

GetMapChunkForOffset:;bc = xy pixel offset (-127,127), returns chunk in hl, tile xy in de
  call GetCurrentMapChunk
.testX
  ld a, [rSCX]
  add a, b;x+rSCX
  ld d, a;x+rSCX
  jr nc, .testY
.wrapX
  ld a, b;x
  cp a, 128
  jr c, .east
.west
  ld a, MAP_WEST
  call GetMapChunkNeighbor
  jr .testY
.east
  ld a, MAP_EAST
  call GetMapChunkNeighbor
  ;fall through to testY
.testY
  ld a, [rSCY]
  add a, c;y+rSCY
  ld e, a;y+rSCY
  jr nc, .finish
.wrapY
  ld a, c;y
  cp a, 128
  jr c, .south
.north
  ld a, MAP_NORTH
  call GetMapChunkNeighbor
  jr .finish
.south
  ld a, MAP_SOUTH
  call GetMapChunkNeighbor
.finish
  srl d
  srl d
  srl d
  srl e
  srl e
  srl e
  ret

ENDC ;MAP_LOADER

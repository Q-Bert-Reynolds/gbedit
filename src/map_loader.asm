IF !DEF(MAP_LOADER)
MAP_LOADER SET 1

INCLUDE "src/beisbol.inc"

SECTION "Map Loader", ROM0
; ROUTINES THAT SWITCH TO A BANK, DO SOME WORK, AND SWITCH BACK
; GetScreenCollision           bc = xy pixel offset (-127,127), returns z if no collision, collision type in a, extra data in b
; GetMapChunkCollision         hl = chunk address, de = xy, returns z if no collision
; GetSpriteCollision           returns z if no collision
; MoveMapLeft
; MoveMapRight
; MoveMapUp
; MoveMapDown
; SetMapPalettes
; SetMapTiles
; DrawMapToScreen              draws map to visible background
; GetMapText                   a = text index, returns text in str_buffer
; EnterMapDoor                 a = door index
; RunMapScript                 a = script index
; ClearMapSprites              removes map sprites from screen and buffer
; CopyMapSpritesToOAMBuffer    iterates through map sprites, copying values to oam_buffer

; ROUTINES THAT EXPECT TO ALREADY BE ON THE CURRENT MAP BANK
; DrawMapLeftEdge              draws column of map tile to background off-screen left
; DrawMapRightEdge             draws column of map tile to background off-screen right
; DrawMapTopEdge               draws row map tiles to background off-screen up
; DrawMapBottomEdge            draws row map tiles to background off-screen down
; DrawMapChunk                 hl = chunk address, de=xy, bc=wh
; GetCurrentMapChunk           returns chunk address in hl, index in a
; SetCurrentMapChunk           hl = chunk address, returns address in hl, index in a
; GetCurrentMapChunkNeighbor   a = direction, returns chunk in hl, index in a
; GetMapChunkNeighbor          a = direction, hl = map chunk, returns chunk in hl, index in a
; GetMapChunk                  a = jump table index, returns chunk in hl, index in a
; GetMapChunkForOffset         de = xy pixel offset, returns chunk in hl, tile xy in de

; ROUTINES THAT DO NOT REQUIRE BANK SWITCHING
; SetCurrentMap                a = map index, returns address in hl, bank in a
; GetCurrentMap                returns address in hl, bank in a
; FixMapScroll                 HACK: called after moving right or down to solve off-by-one collision issues

MAP_OVERWORLD  EQU 0
MAP_HOUSES     EQU 1
MAP_BUSINESSES EQU 2

MapBanks:
  DB BANK(MapOverworld)
  DB BANK(MapHouses)
  DB BANK(MapBusinesses)

MapAddresses:
  DW MapOverworld
  DW MapHouses
  DW MapBusinesses

MapTileBanks:
  DB BANK(_OverworldTiles)
  DB BANK(_HousesTiles)
  DB BANK(_BusinessesTiles)

MapTileAddresses:
  DW _OverworldTiles
  DW _HousesTiles
  DW _BusinessesTiles

GetMapText::;a = text index, returns text in str_buffer
  ld b, 0
  ld c, a
  ld a, [loaded_bank]
  push af;current bank
  push bc;index
  call GetCurrentMap
  call SetBank

  ld bc, 3
  add hl, bc;[hl] = lower byte of strings address
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc;index
  call str_FromArray
  ld de, str_buffer
  call str_Copy
  ld hl, str_buffer

  pop af;previous bank
  call SetBank
  ret

EnterMapDoor::;a = door index
  ld b, a;index
  ld a, [loaded_bank]
  push af;current bank
  push bc;index
  call GetCurrentMap
  call SetBank
  
  ld bc, 5
  add hl, bc;[hl] = lower byte of doors address
  ld a, [hli]
  ld c, a
  ld a, [hl]
  ld b, a
  pop af;index
  push bc;doors address

  ld de, 5
  call math_Multiply
  pop bc;doors address
  add hl, bc
  ld a, [hli]
  ld [map], a
  ld a, [hli]
  ld [map_chunk], a
  ld a, [hli]
  ld [map_x], a
  ld a, [hli]
  ld [map_y], a
  ld a, [hl]
  ld [last_map_button_state], a

  call SetMapTiles
  call SetMapPalettes
  call ClearMapSprites
  call DrawMapToScreen
  
  pop af;previous bank
  call SetBank

  ret

RunMapScript::;a = script index
  ld b, a;index
  ld a, [loaded_bank]
  push af;current bank
  push bc;index
  call GetCurrentMap
  call SetBank

  ld bc, 11
  add hl, bc;[hl] = lower byte of doors address
  ld a, [hli]
  ld c, a
  ld a, [hl]
  ld b, a
  pop af;index
  push bc;scripts address

  ld de, 3
  call math_Multiply
  pop bc;scripts address
  add hl, bc
  ld a, [hli];bank
  ld b, a;bank
  ld a, [hli];lower byte of script address
  ld c, a
  ld a, [hli];upper byte of script address
  ld h, a
  ld l, c;hl = script address
  ld a, b;bank
  call SetBank
  ld de, .return
  push de
  jp hl
.return 

  pop af;previous bank
  call SetBank
  ret

ClearMapSprites::
  xor a
  ld hl, oam_buffer+4*4
  ld bc, 36*4
  call mem_Set
  xor a
  ld [map_sprite_count], a
  ld hl, map_sprite_buffer
  ld bc, MAP_BUFFER_SIZE
  call mem_Set
  ret

CopyMapSpritesToOAMBuffer::;iterates through map sprites, copying values to oam_buffer
  ld a, [loaded_bank]
  push af;current bank
  ld hl, oam_buffer+16;4 sprites for user avatar * 4 bytes per sprite
  ld de, map_sprite_buffer
  ld a, [map_sprite_count]
  and a
  ret z
.loopMapSprites
    push af;count
    ld a, [rSCX]
    ld b, a;bg scroll x
    ld a, [de];x
    add a, 8;x+8
    sub a, b;x+8-scroll x
    ld b, a;x+8-scroll x
    BETWEEN 192, 224
    jr nz, .removeSprite
    inc de
    ld a, [rSCY]
    ld c, a;bg scroll y
    ld a, [de];y
    add a, 10;y+10... why isn't this 8? exporter?
    sub a, c;y+10-scroll y
    ld c, a
    BETWEEN 192, 224
    jr nz, .offScreenY
    inc de
    ld a, c;y
    ld [hli], a;y
    ld a, b;x
    ld [hli], a
    ld a, [de];bank
    inc de
    call SetBank
    ld a, [de];lower address
    ld c, a
    inc de
    ld a, [de];upper address
    ld b, a;bc = map sprite address, [bc] = map object type/collision flags
    inc de;next map sprite buffer address
    inc bc;initial x 
    inc bc;initial y
    inc bc;tile
    ld a, [bc];tile
    ld [hli], a;tile
    inc bc;palette
    ld a, [bc]
    ld [hli], a
    pop af;count
    dec a
    jp nz, .loopMapSprites
.clearRemainingOAM;TODO: set the rest of OAM to 0

.exit
  pop af;bank
  call SetBank
  ret
.offScreenY
  dec de;x
.removeSprite
  push hl;OAM
.removeLoop
    ld hl, 5
    ld bc, 5
    add hl, de;next sprite
    push hl;next sprite
    call mem_Copy
    pop de;last sprite
    ld a, [de]
    and a
    jr nz, .removeLoop
  pop hl;OAM
  pop af;sprites left
  dec a
  jp nz, .loopMapSprites
  jp .clearRemainingOAM

GetScreenCollision::;bc = xy pixel offset (-127,127), returns z if no collision, collision type in a, extra data in b
  ld a, [loaded_bank]
  push af;current bank
  call GetCurrentMap
  call SetBank
  call GetMapChunkForOffset
  call GetMapChunkCollision
  pop de;previous bank
  push af;collision type and flags
  ld a, [hl];extra data
  ld b, a
  ld a, d;previous bank
  call SetBank
  pop af;collision type and flags
  ret

GetMapChunkCollision:;hl = chunk address, de = xy, returns z if no collision, collision type in a, extra data in [hl]
  ld a, d
  srl a
  ld [_x], a
  ld a, e
  srl a
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
    push bc
    
    ld a, [hli];x
    srl a
    ld d, a
    ld a, [hli];y
    srl a
    ld e, a
    
    ld a, b;map object type and collision
    and a, MAP_OBJ_TYPE_MASK
    cp a, MAP_OBJ_STAMP
    jp z, .stamp
    cp a, MAP_OBJ_TILE
    jp z, .tile
    cp a, MAP_OBJ_NONE
    jp z, .blankTile
    cp a, MAP_OBJ_NONE_FILL
    jp z, .blankFill
    ; cp a, MAP_OBJ_STAMP_FILL
    ; jp z, .fill
    ; cp a, MAP_OBJ_TILE_FILL
    ; jp z, .fill
    ; cp a, MAP_OBJ_TEXT
    ; jp z, .fill
    ; cp a, MAP_OBJ_TEXT_FILL
    ; jp z, .fill
  
  .fill
    inc hl;skip tile/char/stringID
    inc hl;skip palete
  .blankFill
    ld a, [_x]
    cp a, d;x1
    jr c, .skip2Bytes
    ld a, [_y]
    cp a, e;y1
    jr c, .skip2Bytes
    ld a, [hli];x2
    inc a
    srl a
    ld d, a
    ld a, [hli];y2
    inc a
    srl a
    ld e, a
    ld a, [_x]
    cp a, d;x2
    jp nc, .checkExtraData
    ld a, [_y]
    cp a, e;y2
    jp c, .collisonFound
    jp .checkExtraData

  .tile
    inc hl;skip tile or stamp lower address
    inc hl;skip palete or stamp upper address
  .blankTile
    ld a, [_x]
    cp a, d;x
    jp nz, .checkExtraData
    ld a, [_y]
    cp a, e;y
    jp z, .collisonFound
    jp .checkExtraData

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
    inc a
    srl a
    inc bc
    add a, d;x+width
    ld d, a;x2
    ld a, [_x]
    cp a, d;x2
    jp nc, .checkExtraData
    ld a, [bc];height
    inc a
    srl a
    add a, e;y+height
    ld e, a;y2
    ld a, [_y]
    cp a, e;y2
    jp c, .collisonFound
    jp .checkExtraData

  .skip2Bytes
    inc hl
    inc hl

  .checkExtraData
    pop bc
    ld a, c
    cp a, MAP_COLLISION_TEXT
    jp z, .hasExtraData
    cp a, MAP_COLLISION_SCRIPT
    jp z, .hasExtraData
    cp a, MAP_COLLISION_LEDGE
    jr z, .hasExtraData
    cp a, MAP_COLLISION_DOOR
    jr z, .hasExtraData
    jp .loop
  .hasExtraData
    inc hl
    jp .loop

.collisonFound
  pop bc
  ld a, c
  cp a, MAP_COLLISION_NONE
  jp z, .loop
  cp a, MAP_COLLISION_GRASS
  ret

GetSpriteCollision::;de = xy, returns z if no collision, collision type in a, extra data in [hl]
  PUSH_VAR loaded_bank
  ld a, [map_sprite_count]
  and a
  ret z
  ld hl, map_sprite_buffer
.loop
    ld a, [hli];bank
    call SetBank
    ld a, [hli];lower byte of address
    ld c, a
    ld a, [hli];upper byte of address
    ld b, a
    push bc;jump address

.finish
  POP_VAR loaded_bank
  call SetBank
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
  ld a, [loaded_bank]
  push af;current bank
  call GetCurrentMap
  call SetBank
  ld a, [map_scroll_speed]
  ld b, a
  ld a, [rSCX]
  sub a, b
  push af;new scx
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
  pop af;new scx
  ld [rSCX], a
  pop af;previous bank
  call SetBank
  ret

MoveMapRight::
  ld a, [loaded_bank]
  push af;current bank
  call GetCurrentMap
  call SetBank
  ld a, [map_scroll_speed]
  ld b, a
  ld a, [rSCX]
  add a, b
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
  pop af;previous bank
  call SetBank
  ret

MoveMapUp::
  ld a, [loaded_bank]
  push af;current bank
  call GetCurrentMap
  call SetBank
  ld a, [map_scroll_speed]
  ld b, a
  ld a, [rSCY]
  sub a, b
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
  pop af;previous bank
  call SetBank
  ret

MoveMapDown::
  ld a, [loaded_bank]
  push af;current bank
  call GetCurrentMap
  call SetBank
  ld a, [map_scroll_speed]
  ld b, a
  ld a, [rSCY]
  add a, b
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
  pop af;previous bank
  call SetBank
  ret

SetMapPalettes::
  ld a, [loaded_bank]
  push af;current bank
  call GetCurrentMap
  call SetBank
  inc hl;[hl] = first byte of palette address
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b;hl = palette address
  push hl;palette address
  ld a, BCPSF_AUTOINC
  ldh [rBCPS], a
  ld c, 8*2*4;8 palettes * 2B / color * 4 colors / palette
.bgLoop
    ld a, [hli]
    ldh [rBCPD], a
    dec c
    jr nz, .bgLoop

  pop hl;palette address
  ld a, OCPSF_AUTOINC
  ldh [rOCPS], a
  ld c, 7*2*4;7 palettes * 2B / color * 4 colors / palette
.spriteLoop
    ld a, [hli]
    ldh [rOCPD], a
    dec c
    jr nz, .spriteLoop
  pop af;previous bank
  call SetBank
  ret

SetMapTiles::
  ld a, [loaded_bank]
  push af

  ld a, [map]
  ld b, 0
  ld c, a
  ld hl, MapTileBanks
  add hl, bc
  ld a, [hl]
  call SetBank

  ld hl, MapTileAddresses
  add hl, bc
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hli]
  ld h, a
  ld l, b
  ld de, $8800
  ld bc, 128*16;tiles*bytes/tile
  call mem_CopyVRAM

  pop af
  call SetBank
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
  ld a, [loaded_bank]
  push af;current bank
  call GetCurrentMap
  call SetBank
  
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
  jp z, .finish
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
  jp z, .finish
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
.finish
  pop af;previous bank
  call SetBank
  call CopyMapSpritesToOAMBuffer
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
.drawTilesLoop
    ld a, [hli];map object type and collision
    and a
    jp z, .loadSprites
    ld b, a;map object type and collision

    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a
    
    ld a, b;map object type and collision
    push af;map object type and collision
    and a, MAP_OBJ_TYPE_MASK
    cp a, MAP_OBJ_STAMP
    jp z, .stamp
    cp a, MAP_OBJ_STAMP_FILL
    jp z, .stampFill
    cp a, MAP_OBJ_TILE
    jp z, .tile
    cp a, MAP_OBJ_TILE_FILL
    jp z, .tileFill
    cp a, MAP_OBJ_TEXT
    jp z, .tileFill
    cp a, MAP_OBJ_TEXT_FILL
    jp z, .tileFill
    cp a, MAP_OBJ_NONE
    jr z, .checkExtraData
    ; else MAP_OBJ_NONE_FILL
  .noneFill
    inc hl
    inc hl
    jp .checkExtraData
  .tileFill
    call DrawMapTileFill;also does text
    jp .checkExtraData
  .tile
    call DrawMapTile
    jp .checkExtraData
  .stampFill
    call DrawMapStampFill
    jp .checkExtraData
  .stamp
    call DrawMapStamp
    ; jp .checkExtraData

  .checkExtraData
    pop af;map object type and collision
    and a, MAP_COLLISION_MASK
    cp a, MAP_COLLISION_SCRIPT
    jp z, .hasExtraData
    cp a, MAP_COLLISION_TEXT
    jp z, .hasExtraData
    cp a, MAP_COLLISION_LEDGE
    jr z, .hasExtraData
    cp a, MAP_COLLISION_DOOR
    jr z, .hasExtraData
    jp .drawTilesLoop
  .hasExtraData
    inc hl
    jp .drawTilesLoop

.loadSprites;convert coordinates from tiles to pixels
  ld a, [_x]
  sla a;*2
  sla a;*4
  sla a;*8
  ld [_x], a
  ld a, [_y]
  sla a;*2
  sla a;*4
  sla a;*8
  ld [_y], a
  ld a, [_u]
  sla a;*2
  sla a;*4
  sla a;*8
  ld [_u], a
  ld a, [_v]
  sla a;*2
  sla a;*4
  sla a;*8
  ld [_v], a
.loadSpritesLoop
    ld a, [hl];check done
    and a
    ret z
    push hl; current address
    
    inc hl
    ld a, [hli];x
    ld d, a
    ld a, [hli];y
    ld e, a

  ;TODO: figure out why clipping doesn't work correctly
  ; .testXY
  ;   call TestMapObjectMinXY
  ;   jr z, .outOfRange
  ;   call TestMapObjectMaxXY
  ;   jr z, .outOfRange

  .testBankAndAddress
    ld hl, map_sprite_buffer
    ld a, [map_sprite_count]
    and a
    jr z, .addSpritesToBuffer
    pop de;current sprite address
    push de;current sprite address
  .loopMapSprites
      push af;count
      inc hl;skip x
      inc hl;skip y
      ld a, [loaded_bank]
      ld b, a;bank
      ld a, [hli];bank
      cp a, b;check bank
      jr nz, .bankMismatch
      ld a, [hli];lower byte of address
      cp a, e;compare lower byte
      jr nz, .addressMismatch
      ld a, [hli];upper byte of address
      cp a, d;compare upper byte
      jr nz, .addressMismatch
      jr .spriteAlreadyInBuffer
    .bankMismatch
      inc hl;skip lower address byte
      inc hl;skip upper address byte
    .addressMismatch
      pop af;count
      dec a
      jr nz, .loopMapSprites

  .addSpritesToBuffer;hl = next map sprite buffer address
    ld a, [map_sprite_count]
    inc a
    ld [map_sprite_count], a
    pop de;current sprite address
    inc de;skip obj/collision type
    ld a, [de];x
    ld [hli], a;x
    inc de
    ld a, [de];y
    ld [hli], a;y
    dec de;x
    dec de;current sprite address
    ld a, [loaded_bank]
    ld [hli], a;bank
    ld a, e
    ld [hli], a;lower byte
    ld a, d
    ld [hli], a;upper byte
    ld hl, 5
    add hl, de
    jr .loadSpritesLoop
  .spriteAlreadyInBuffer
    pop af;discard count
    pop de;current sprite address
    ld hl, 5
    add hl, de
    jr .loadSpritesLoop
  .outOfRange
    pop de;toss current sprite address
    inc hl;tile
    inc hl;palette
    inc hl;next
    jr .loadSpritesLoop

TestMapObjectMinXY:; de = xy, max XY in _u,_v, returns xy in de, sets z if out of range
.testMinX
  ld a, [_u];chunk maxX
  cp a, d;stamp minX
  jr c, .outOfRange;chunk maxX < stamp minX
  jr z, .outOfRange;chunk maxX == stamp minX
.testMinY
  ld a, [_v];chunk maxY
  cp a, e;stamp minY
  jr c, .outOfRange;chunk maxY < stamp minY
  jr z, .outOfRange;chunk maxY == stamp minY
.inRange
  ret
.outOfRange
  xor a
  ret 

TestMapObjectMaxXY:; de = xy, min XY in _x,_y, returns xy in de, sets z if out of range
.testMaxX
  ld a, [_x];chunk minX
  cp a, h;stamp maxX
  jp z, .outOfRange;chunk minX == stamp maxX
  jp nc, .outOfRange;chunk minX > stamp maxX
.testMaxY
  ld a, [_y];chunk minX
  cp a, l;stamp maxy
  jp z, .outOfRange;chunk minY == stamp maxY
  jp nc, .outOfRange;chunk minY > stamp maxY
.inRange
  ret
.outOfRange
  xor a
  ret 
    
DrawMapStampFill:;hl = stamp fill data, de = xy, min/max XY in _x,_y,_u,_v
  call TestMapObjectMinXY
  jr z, .outOfRange

.draw
  ld a, [hli];stamp lower address
  ld c, a
  ld a, [hli];stamp upper address
  ld b, a;bc = stamp address
  push hl;maxX
  ld a, [bc];stamp width
  ld h, a
  inc bc
  ld a, [bc];stamp height
  ld c, a;height
  ld b, h;width
  pop hl;maxX
  ld a, [hli];a = maxX, [hl] = rows
.columnLoop
    push af;maxX
    push de;xy
    ld a, [hld];a = rows, [hl] = maxX
    dec hl;stamp upper address
    dec hl;stamp lower address
  .rowLoop
      push af;maxY
      push bc;wh
      push de;xy
      push hl;stamp data
      call DrawMapStamp;hl = stamp data, de = xy
      pop hl;stamp data
      pop de;xy
      pop bc;wh
      ld a, c;height
      add a, e;y+height
      ld e, a;next y
      pop af;maxY
      cp a, e
      jr nz, .rowLoop
    inc hl
    inc hl
    inc hl
    pop de;xy
    ld a, b;width
    add a, d;x+width
    ld d, a;next x
    pop af;maxX
    cp a, d
    jr nz, .columnLoop
  inc hl
  ret
.outOfRange
  ld bc, 4
  add hl, bc
  ret

DrawMapTileFill:;a = map obj type, hl = tile fill data, de = xy, min/max XY in _x,_y,_u,_v
  ld [_c], a;map obj type
  ld bc, 0
.testX
  ld a, [_u];maxX
  cp a, d;x
  jp c, .outOfRange;maxX < x
  jp z, .outOfRange;maxX == x
  ld a, [_x];minX
  cp a, d
  jr c, .testY
  ld d, a
.testY
  ld a, [_v];maxY
  cp a, e;y
  jp c, .outOfRange;maxY < y
  jp z, .outOfRange;maxY == y
  ld a, [_y];minY
  cp a, e
  jr c, .draw
  ld e, a
.draw
  ld a, [hli];tile/char/string
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
  ret c;if width<0
  ret z;if width==0
  ld b, a
  ld a, c;maxY
  sub a, e;height
  ret c;if height<0
  ret z;if height==0
  ld c, a
  push hl;next map object
  ld a, [_c];map obj type
  cp a, MAP_OBJ_TEXT_FILL
  ld a, [_a];tile
  push de;xy
  push bc;wh
  jr z, .stringFill
.singleTile
  ld hl, _SCRN0
  call gbdk_SetTilesTo
  jr .palettes
.stringFill
  call GetMapText
  call ClipMapText
  pop hl;wh
  pop de;xy
  push de;xy
  push hl;wh
  call gbdk_SetBkgTiles
.palettes
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
.nextMapObject
  pop hl;next map object
  ret
.outOfRange
  ld bc, 4
  add hl, bc
  ret

;str_buffer = text
;returns clipped text in bc
ClipMapText::;TODO - there's a bug and a feature listed for this function
  ld bc, str_buffer
  ret 

DrawMapStamp:;hl = stamp data, de = xy, min/max XY in _x,_y,_u,_v, returns wh in bc
  call TestMapObjectMinXY
  jr z, .outOfRange

.loadStampData
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
  add hl, de;maxXY = wh + xy, assumes l + e < 256

  call TestMapObjectMaxXY
  jp z, .nextMapObject

.clipStamp
  inc bc;stamp tiles
  call ClipStamp

.setTiles
  push hl;wh
  push de;xy
  ld bc, tile_buffer
  call gbdk_SetBkgTiles;returns bc=stamp palette
  pop de;xy
  pop hl;wh

.setPalettes
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jp z, .nextMapObject
  ld a, 1
  ld [rVBK], a
  ld a, 2
  ld [rSVBK], a
  ld bc, tile_buffer
  ld a, [bc]
  bit 7, a
  jr z, .nonUniformPal
.uniformPal
  and a, %01111111;tile
  ld b, h
  ld c, l;bc = wh
  ld hl, _SCRN0
  call gbdk_SetTilesTo
  jr .finishPal
.nonUniformPal
  call gbdk_SetBkgTiles
.finishPal
  xor a
  ld [rVBK], a
  ld [rSVBK], a
.nextMapObject
  pop hl
  ret
.outOfRange
  ld bc, 0
  inc hl
  inc hl
  ret

;bc = stamp tiles, de = stamp minXY, hl = stamp maxXY
;chunk min/max XY in _x,_y,_u,_v
;returns tilemap/palettemap in tile_buffer, xy in de, wh in hl
ClipStamp:
  push de;xy
  push bc;stamp tiles

  ld a, [_x];chunk minX
  sub a, d;stamp minX
  jr nc, .setMinX
  xor a
.setMinX
  ld [_a], a;x offset
  ld b, a

  ld a, [_y];chunk minY
  sub a, e;stamp minY
  jr nc, .setMinY
  xor a
.setMinY
  ld [_b], a;y offset
  ld c, a

  ld a, [_u];chunk maxX
  cp a, h;stamp maxX
  jr c, .setClippedWidth;chunk maxX >= stamp maxX
  ld a, h;maxX
.setClippedWidth
  sub a, d;maxX - stamp minX
  sub a, b;maxX - stamp minX - x offset
  ld [_c], a;clipped width

  ld a, [_v];chunk maxY
  cp a, l;stamp maxY
  jr c, .setClippedHeight;chunk maxY >= stamp maxY
  ld a, l;maxY
.setClippedHeight
  sub a, e;maxY - stamp minY
  sub a, c;maxY - stamp minY - y offset
  ld [_d], a;clipped height

.setFullWidthHeight;in hl
  ld a, h
  sub a, d;x2-x1
  ld d, a;full stamp width
  ld a, l
  sub a, e;y2-y1
  ld e, a;full stamp height

.copyTilesToBuffer
  push de;wh
  ld a, [_b];clip y
  ld e, a
  ld a, d;full width
  ld d, 0;de = clip y
  call math_Multiply
  ld b, h
  ld c, l;bc = y clip * width
  pop de;wh
  pop hl;stamp tiles
  push hl;stamp tiles start
  add hl, bc;stamp tiles + y clip * width
  ld b, 0
  ld a, [_a];x
  ld c, a
  add hl, bc;stamp tiles + y clip * width + x clip
  pop bc;stamp tiles
  push hl;stamp tiles + offset
  push bc;stamp tiles
  ld bc, tile_buffer
  ld a, e;full height
  ld e, d
  ld d, 0;de = full width
  push af;full height
  ld a, [_d];clip height
.loopTilemapRows
    push af;rows left
    push hl;stamp tiles
    ld a, [_c];clip width
  .loopTilemapColumns
      push af;columns left
      ld a, [hli]
      ld [bc], a
      inc bc
      pop af;columns left
      dec a
      jr nz, .loopTilemapColumns
    pop hl;stamp tiles
    add hl, de;next row
    pop af;rows left
    dec a
    jr nz, .loopTilemapRows

.checkGBC
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr nz, .copyPaletteToBuffer
.notGBC
  pop af;discard full height
  pop hl;discard stamp tiles address
  pop hl;discard stamp tiles + offset
  jp .done

.copyPaletteToBuffer
  ld a, 2
  ld [rSVBK], a
  pop af;full height
  call math_Multiply
  ld b, h
  ld c, l;bc = width * height
  pop hl;stamp tiles
  add hl, bc;palette start = stamp tiles + full width * full height
  ld a, [hl];check for uniform tile
  bit 7, a
  jr z, .nonUniformPal
.uniformPal
  pop hl;discard stamp tiles + offset
  ld [tile_buffer], a
  jp .finishPalette

.nonUniformPal
  pop hl;stamp tiles+offset
  add hl, bc;palette start + offset = stamp tiles + offset + full width * full height
  ld bc, tile_buffer
  ld a, [_d];clip height
.loopPalettemapRows
    push af;rows left
    push hl;stamp tiles
    ld a, [_c];clip width
  .loopPalettemapColumns
      push af;columns left
      ld a, [hli]
      ld [bc], a
      inc bc
      pop af;columns left
      dec a
      jr nz, .loopPalettemapColumns
    pop hl;stamp tiles
    add hl, de;next row
    pop af;rows left
    dec a
    jr nz, .loopPalettemapRows

.finishPalette
  xor a
  ld [rSVBK], a

.done
  pop de;xy
  ld a, [_a]
  add a, d
  ld d, a;x
  ld a, [_b]
  add a, e
  ld e, a;y
  ld a, [_c]
  ld h, a;w
  ld a, [_d]
  ld l, a;h
  ret

DrawMapTile:;hl = tile data, de = xy, min/max XY in _x,_y,_u,_v
.testX
  ld a, [_u];maxX
  cp a, d;x
  jr c, .tileOutOfRange;maxX < x
  jr z, .tileOutOfRange;maxX == x
  ld a, [_x];minX
  cp a, d;x
  jr z, .testY;minX == x
  jr nc, .tileOutOfRange;minX > x
.testY
  ld a, [_v];maxY
  cp a, e;y
  jr c, .tileOutOfRange;maxY < y
  jr z, .tileOutOfRange;maxY == y
  ld a, [_y];minY
  cp a, e;y
  jr z, .draw;minY == y
  jr nc, .tileOutOfRange;minY > y
.draw
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
.nextMapObject
  pop hl;next map object
  ret
.tileOutOfRange
  inc hl
  inc hl
  ret

SetCurrentMap::;a = map index, returns address in hl, bank in a
  ld [map], a
  ;fall through
GetCurrentMap::;returns address in hl, bank in a
  push bc
  push de
  ld a, [map]
  ld b, 0
  ld c, a
  ld hl, MapAddresses
  add hl, bc
  add hl, bc
  ld a, [hli]
  ld e, a
  ld a, [hl]
  ld d, a
  ld hl, MapBanks
  add hl, bc
  ld a, [hl]
  ld h, d
  ld l, e
  pop de
  pop bc
  ret

GetCurrentMapChunk:;returns chunk address in hl, index in a
  ld a, [map_chunk]
  ld hl, MapOverworldChunks
  call GetMapChunk
  ret

SetCurrentMapChunk::;a = chunk index, returns address in hl, index in a
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

GetMapChunk:;a = jump table index, returns chunk in hl, index in a
  push bc
  push af;index
  call GetCurrentMap;should already be in correct bank
  ld bc, 9
  add hl, bc;[hl] = lower byte of chunk jump table
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b;hl = chunk jump table address
  pop af;index
  push af;index
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop af;index
  pop bc
  ret

GetMapChunkForOffset::;bc = xy pixel offset (-127,127), returns chunk in hl, tile xy in de
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

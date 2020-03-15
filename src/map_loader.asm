IF !DEF(MAP_LOADER)
MAP_LOADER SET 1

INCLUDE "src/beisbol.inc"
INCLUDE "maps/overworld.asm"

SECTION "Map Loader", ROM0
SetMapTiles::; sets full background using positional data
  ld a, [loaded_bank]
  ld [temp_bank], a

  ld hl, map_x;little endian
  ld a, [hli]
  ld b, a
  ld a, [hli]
  ld h, a
  ld l, b
  ld c, 32
  call math_Divide
  ld d, l; assumes x/32 < 256

  ld hl, map_y;little endian
  ld a, [hli]
  ld b, a
  ld a, [hli]
  ld h, a
  ld l, b
  ld c, 32
  call math_Divide
  ld e, l; assumes y/32 < 256

  call LoadMapData
  push bc ;map id

  ld a, [rSCX]
  rra;x/2
  rra;x/4
  rra;x/8
  ld d, a ; x
  
  ld a, [rSCY]
  rra;x/2
  rra;x/4
  rra;x/8
  ld e, a ; y

  ld a, 32
  sub a, d
  ld h, a ; w
  ld a, 20
  cp h
  jr nc, .skipWidth
  ld h, a
.skipWidth

  ld a, 32
  sub a, e
  ld l, a ; h
  ld a, 18
  cp l
  jr nc, .skipHeight
  ld l, a
.skipHeight
  
  call DrawMapTilesChunk
  pop bc;map id
  push bc;map id
  
  push de;xy
  push hl;wh

  ld a, 12
  cp d
  jr nc, .skipRightMap
  ld a, 20
  sub a, h
  ld h, a; right map width
  push hl;wh
  ld hl, 1024
  add hl, bc
  ld b, h
  ld c, l
  pop hl;wh
  push bc
  ld d, 0;wrap x
  call DrawMapTilesChunk
  pop bc;map id to right

  ld a, 14
  cp e
  jr nc, .skipRightMap;skip bottom right
  ld a, 18
  sub a, l
  ld l, a; bottom right map height
  push hl;wh
  ld hl, 1024*_OVERWORLD_WIDTH;TODO: this needs to be dynamic
  add hl, bc
  ld b, h
  ld c, l

  pop hl;wh
  ld e, 0;wrap y
  call DrawMapTilesChunk

.skipRightMap

  pop hl;wh
  pop de;xy
  pop bc;map id
  
  ld a, 14
  cp e
  jr nc, .skipBottomMap
  ld a, 18
  sub a, l
  ld l, a; bottom map height
  push hl;wh
  ld hl, 1024*_OVERWORLD_WIDTH
  add hl, bc
  ld b, h
  ld c, l
  pop hl;wh
  ld e, 0;wrap y
  call DrawMapTilesChunk
.skipBottomMap

  ld a, [temp_bank]
  call SetBank
  ret

DrawMapTilesChunk:;bc = map id, hl=wh, de=xy; returns de=xy, hl=wh
  push hl;wh
  push de;xy
  push bc;map id... also on stack before wh
  
  ld a, e;y
  ld de, 32
  call math_Multiply
  pop bc;map id

  ld a, b
  cp $80
  jr c, .noOverflow
  ld a, b
  ld b, $40
  sub a, b
  ld b, a
  ld a, [map_bank]
  inc a
  call SetBank
.noOverflow

  pop de;xy
  push de;xy

  ld e, d
  ld d, 0
  add hl, de;first index
  add hl, bc;first index + map id

  pop de;xy
  pop bc;wh

  push bc;wh
  push de;xy
  ld a, c;c = height
  ld c, b
  ld b, 0;bc = width
  ld de, tile_buffer
.loop
    push af
    push bc
    push hl
    call mem_Copy
    pop hl
    ld bc, 32
    add hl, bc
    pop bc
    pop af
    dec a
    jr nz, .loop

  pop de;xy
  pop hl;wh
  push hl
  push de
  ld bc, tile_buffer
  call gbdk_SetBkgTiles

  pop de;xy
  pop hl;wh

  ld a, [map_bank]
  call SetBank
  ret

LoadMapData:;de = xy (map id, not position), returns map data in bc
  push de;xy
  ld a, e
  ld de, _OVERWORLD_WIDTH
  call math_Multiply
  pop de;xy
  ld e, d;x
  xor a
  ld d, a
  add hl, de
  ld c, 16;maps per bank
  call math_Divide ;hl = bank offset, a = map in bank
  push af;map
  ld a, MAPS_BANK
  add a, l;MAPS_BANK + bank offset
  ld [map_bank], a
  call SetBank

  pop af;map
  ld de, 1024;number of tiles per map
  call math_Multiply;first tile of map in hl
  ld bc, $4000
  add hl, bc
  ld b, h
  ld c, l
  ret

ENDC ;MAP_LOADER

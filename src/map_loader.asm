IF !DEF(MAP_LOADER)
MAP_LOADER SET 1

INCLUDE "src/beisbol.inc"
INCLUDE "maps/overworld.asm"

SECTION "Map Loader", ROM0
SetMapTilesLeftRight: ;hl = bank shift, a = screen offset
  push hl;bank shift
  push af;screen offset
  ld a, [loaded_bank]
  ld [temp_bank], a

  call LoadMapData

  pop af;screen offset
  add a, d
  ld d, a

  ld a, 31
  cp d
  pop hl;bank shift
  jr nc, .skipBankShift
  ld a, d
  ld d, 32
  sub a, d
  ld d, a
  add hl, bc
  ld b, h
  ld c, l
.skipBankShift

  ld h, 2 ;width

  ld a, 32
  sub a, e
  ld l, a ;height
  ld a, 18
  cp l
  jr nc, .skipHeight
  ld l, a
.skipHeight

  push bc;map id
  push de;xy
  push hl;wh

  call DrawMapTilesChunk
  
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

SetMapTilesUpDown: ;hl = bank shift, a = screen offset
  push hl;bank shift
  push af;screen offset
  ld a, [loaded_bank]
  ld [temp_bank], a

  call LoadMapData

  pop af;screen offset
  add a, e
  ld e, a

  ld a, 31
  cp e
  pop hl;bank shift
  jr nc, .skipBankShift
  ld a, e
  ld e, 32
  sub a, e
  ld e, a
  add hl, bc
  ld b, h
  ld c, l
.skipBankShift

  ld l, 2 ;height

  ld a, 32
  sub a, d
  ld h, a ;width
  ld a, 20
  cp h
  jr nc, .skipHeight
  ld h, a
.skipHeight

  push bc;map id
  push de;xy
  push hl;wh

  call DrawMapTilesChunk
  
  pop hl;wh
  pop de;xy
  pop bc;map id
  
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
  ld d, 0;wrap x
  call DrawMapTilesChunk
.skipRightMap

  ld a, [temp_bank]
  call SetBank
  ret

SetMapTilesRight:: ;sets 2 columns of tiles offscreen right
  ld hl, 1024
  ld a, 20
  call SetMapTilesLeftRight
  ret

SetMapTilesLeft:: ;sets 2 columns of tiles offscreen left
  ld hl, -1024
  ld a, -2
  call SetMapTilesLeftRight
  ret

SetMapTilesUp:: ;sets 2 rows of tiles offscreen up
  ld hl, -1024*_OVERWORLD_WIDTH
  ld a, -2
  call SetMapTilesUpDown
  ret

SetMapTilesDown:: ;sets 2 rows of tiles offscreen down
  ld hl, 1024*_OVERWORLD_WIDTH
  ld a, 18
  call SetMapTilesUpDown
  ret

SetMapTiles::; sets full background using positional data
  ld a, [loaded_bank]
  ld [temp_bank], a

  call LoadMapData;return bc = map id, de = xy
  push bc ;map id

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

LoadMapData:;returns bc = map data, de = screen tile xy
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

  ret

ENDC ;MAP_LOADER

SCALE_2X_CALC_A: MACRO
  ld a, [_b]
  swap a
  and %00001111
  ld b, 0
  ld c, a
  ld hl, ScaleLookupTable
  add hl, bc
  ld a, [hl]
ENDM

SCALE_2X_CALC_B: MACRO
  ld a, [_b]
  and %00001111
  ld b, 0
  ld c, a
  ld hl, ScaleLookupTable
  add hl, bc
  ld a, [hl]
ENDM

;sets tiles (j*2 + offset) and (j*2 + offset + 2)
SCALE_2X_SET_TILE: MACRO ;\1 = offset, a = data from calc
  push af ;calc

  ld hl, tile_buffer
  ld a, [_j]
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc ;tile_buffer + i*64 + j*2

  ld bc, \1
  add hl, bc ;tile_buffer + i*64 + j*2 + offset
  pop af ;calc
  ld [hli], a ;tile_buffer + i*64 + j*2 + offset = calc
  inc hl
  ld [hl], a ;tile_buffer + i*64 + j*2 + offset + 2 = calc
ENDM

SetBkgDataDoubled:: ;de = vram location, bc = num tiles, hl = data
  push bc;num tiles
  push de;vram location
  push hl;data

  call DoubleTile

  pop hl;data
  ld de, 16
  add hl, de;data+16
  pop de;vram
  push hl;data+16
  ld hl, 64
  add hl,de
  ld d, h
  ld e, l;vram+64
  pop hl;data+16
  
  pop bc;num tiles
  dec c
  jp nz, SetBkgDataDoubled
  ret

DoubleTile:;de = vram, hl = tile data 
  push de;vram
  push hl;tile data

  xor a
  ld [_j], a
.rowLoop ;for (j = 0; j < 8; j+=2) {
    pop hl;data
    ld a, [hli]
    ld [_b], a
    push hl;data+1

    SCALE_2X_CALC_A
    SCALE_2X_SET_TILE 0
    SCALE_2X_CALC_B
    SCALE_2X_SET_TILE 16

    pop hl;data+1
    ld a, [hli]
    ld [_b], a
    push hl;data+2
    ld bc, 6
    add hl, bc
    push hl;data+8

    SCALE_2X_CALC_A
    SCALE_2X_SET_TILE 1
    SCALE_2X_CALC_B
    SCALE_2X_SET_TILE 17

    pop hl;data+8
    ld a, [hli]
    ld [_b], a
    push hl;data+9

    SCALE_2X_CALC_A
    SCALE_2X_SET_TILE 32
    SCALE_2X_CALC_B
    SCALE_2X_SET_TILE 48

    pop hl;data+9
    ld a, [hld];data+8
    ld [_b], a

    SCALE_2X_CALC_A
    SCALE_2X_SET_TILE 33
    SCALE_2X_CALC_B
    SCALE_2X_SET_TILE 49

    ld a, [_j]
    add a, 2
    ld [_j], a
    cp 8
    jp nz, .rowLoop

  pop hl ;tile data - not used
  ld hl, tile_buffer
  pop de ;vram
  ld bc, 64
  call mem_CopyToTileData; set_bkg_data(vram, 64, tile_buffer);
  ret
      
ScaleLookupTable:
  db %00000000
  db %00000011
  db %00001100
  db %00001111
  db %00110000
  db %00110011
  db %00111100
  db %00111111  
  db %11000000
  db %11000011
  db %11001100
  db %11001111
  db %11110000
  db %11110011
  db %11111100
  db %11111111
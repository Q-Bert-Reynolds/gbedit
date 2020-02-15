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

;sets tiles (i*64 + j*2 + offset) and (i*4*16 + j*2 + offset + 2)
SCALE_2X_SET_TILE: MACRO ;\1 = offset, a = data from calc
  push af ;calc

  ld h, 0
  ld a, [_i]
  ld l, a
  add hl, hl;i*2
  add hl, hl;i*4
  add hl, hl;i*8
  add hl, hl;i*16
  add hl, hl;i*32
  add hl, hl;i*64

  ld bc, tile_buffer
  add hl, bc ;tile_buffer + i*64

  ld b, 0
  ld a, [_j]
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

;TODO: this can probably be cleaned up a bit
SetBkgDataDoubled: ;de = vram location, bc = nb_tiles, hl = data
  push de ;vram location
  push bc ;nb_tiles
  push hl ;data
  
  xor a
  ld [_i], a
.columnLoop ;for (i = 0; i < nb_tiles*16; i+=16) {
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

    pop hl;data+2*4
    ld bc, 8
    add hl, bc
    
    pop bc;nb_tiles
    push bc
    push hl;data+16

    ld a, [_i]
    inc a
    ld [_i], a
    cp c;nb_tiles
    jp nz, .columnLoop

.done
  pop hl ;data
  pop hl ;nb_tiles
  add hl, hl;nb_tiles*2
  add hl, hl;nb_tiles*4
  add hl, hl;nb_tiles*8
  add hl, hl;nb_tiles*16
  add hl, hl;nb_tiles*32
  add hl, hl;nb_tiles*64
  pop bc ;vram location
  ld d, b
  ld e, c ;de = vram
  ld b, h
  ld c, l ;bc = nb_tiles*4
  ld hl, tile_buffer
  call mem_CopyToTileData; set_bkg_data(vram, nb_tiles*64, tiles);
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
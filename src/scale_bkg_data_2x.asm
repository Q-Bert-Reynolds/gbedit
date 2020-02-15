INCLUDE "src/beisbol.inc"

SCALE_2X_CALC_A: MACRO
  ld a, [_b]
  and a, 128;b & 128
  ld b, a
  ld a, [_b]
  srl a;b >> 1
  and a, 96;(b>>1) & 96
  or a, b;(b&128)|((b>>1)&96)
  ld b, a
  ld a, [_b]
  srl a
  srl a;b >> 2
  and a, 24
  or a, b;(b&128)|((b>>1)&96)|((b>>2)&24)
  ld b, a
  ld a, [_b]
  srl a
  srl a
  srl a;b >> 3
  and a, 6;(b>>3) & 6
  or a, b;(b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)
  ld b, a
  ld a, [_b]
  swap a;similar to b >> 4 but leaves upper nibble
  and a, 1;(b>>4) & 1
  or a, b;(b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1)
ENDM

SCALE_2X_CALC_B: MACRO
  ld a, [_b]
  swap a;equivalent to b << 4 but leaves lower nible
  and a, 128;(b<<4)&128
  ld b, a
  ld a, [_b]
  sla a
  sla a
  sla a ;b << 3
  and a, 96;(b<<3) & 96
  or a, b
  ld b, a;((b<<4)&128)|((b<<3)&96)
  ld a, [_b]
  sla a
  sla a ;b << 2
  and a, 24;(b<<2) & 24
  or a, b ;((b<<4)&128)|((b<<3)&96)|((b<<2)&24)
  ld b, a
  ld a, [_b]
  sla a;b << 1
  and a, 6;(b<<1) & 6
  or a, b;((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)
  ld b, a
  ld a, [_b]
  and a, 1;b & 1
  or a, b;((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1)
ENDM

SCALE_2X_GET_DATA: MACRO ;\1 = offset
  ld d, 0
  ld a, [_i]
  ld e, a
  ld a, 16
  call math_Multiply ;hl = i*16

  pop bc ;data
  push bc ;data
  add hl, bc ;data + i*16

  ld b, 0
  ld a, [_j]
  ld c, a
  add hl, bc ;data + i*16 + j

  ld bc, \1
  add hl, bc ;data + i*16 + j + offset

  ld a, [hl]
  ld [_b], a ;data + i*16 + j + offset
ENDM

;sets tiles (i*64 + j*2 + offset) and (i*4*16 + j*2 + offset + 2)
SCALE_2X_SET_TILE: MACRO ;\1 = offset, a = data from calc
  push af ;calc

  ld d, 0
  ld a, [_i]
  ld e, a
  ld a, 64
  call math_Multiply ;hl = i*64

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
.columnLoop ;for (i = nb_tiles-1; i >= 0; i--) {
    xor a
    ld [_j], a 
.rowLoop ;for (j = 0; j < 8; j+=2) {

      SCALE_2X_GET_DATA 0
      SCALE_2X_CALC_A
      SCALE_2X_SET_TILE 0
      SCALE_2X_CALC_B
      SCALE_2X_SET_TILE 16

      SCALE_2X_GET_DATA 1
      SCALE_2X_CALC_A
      SCALE_2X_SET_TILE 1
      SCALE_2X_CALC_B
      SCALE_2X_SET_TILE 17

      SCALE_2X_GET_DATA 8
      SCALE_2X_CALC_A
      SCALE_2X_SET_TILE 32
      SCALE_2X_CALC_B
      SCALE_2X_SET_TILE 48

      SCALE_2X_GET_DATA 9
      SCALE_2X_CALC_A
      SCALE_2X_SET_TILE 33
      SCALE_2X_CALC_B
      SCALE_2X_SET_TILE 49

      ld a, [_j]
      add a, 2
      ld [_j], a
      cp 8
      jp nz, .rowLoop

    ld a, [_i]
    inc a
    ld [_i], a
    pop hl;data
    pop bc;nb_tiles
    push bc
    push hl
    sub a, c
    jp nz, .rowLoop

.done
  pop hl ;data
  pop de ;nb_tiles
  pop bc ;vram location
  ld a, 64
  call math_Multiply ;hl = nb_tiles*4
  ld d, b
  ld e, c ;de = vram
  ld b, h
  ld c, l ;bc = nb_tiles*4
  ld hl, tile_buffer
  call mem_CopyToTileData; set_bkg_data(vram, nb_tiles*64, tiles);
  ret
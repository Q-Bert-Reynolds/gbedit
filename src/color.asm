;Display palettes for the editor.
MACRO RGB ;red, green, blue
  DW (\3 << 10 | \2 << 5 | \1)
ENDM

MACRO SET_DEFAULT_PALETTE
  ld a, %11100100
  ldh [rBGP], a
  ldh [rOBP0], a
  ld a, %10010000
  ldh [rOBP1], a
ENDM

SECTION "Color Code", ROM0
GBCCopyPalettesFrom::;hl = source
  push hl;dest
  ld bc, 8*2*4
  add hl, bc
  ld d, h
  ld e, l;de = dest+8*2*4
  pop hl;dest
  ld a, BCPSF_AUTOINC
  ldh [rBCPS], a
  ldh [rOCPS], a
  ld c, 8*2*4;8 palettes * 2B / color * 4 colors / palette
.loop
    LCD_WAIT_VRAM
    ld a, [hli]
    ldh [rBCPD], a
    ld a, [de]
    ldh [rOCPD], a
    inc de
    dec c
    jr nz, .loop
  ret

SECTION "Palettes", ROM0
;Eight background and eight object palettes, all using the editor's greyscale.
;ROM0 also lets the Super Game Boy initialization read these directly.
DefaultPalettes::
REPT 16
  RGB 29, 29, 27
  RGB 23, 23, 23
  RGB 15, 15, 15
  RGB 0, 0, 0
ENDR

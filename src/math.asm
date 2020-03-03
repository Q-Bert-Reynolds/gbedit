; Math
;  Started 14-Jan-20
;
; Initials: NB = Nolan Baker
; V1.0 - 14-Jan-20 : Original Release - NB
;
; Library Subroutines:
;   Multiply
;     hl = de * a
;   Modulo
;     a = a % b
;   Divide
;     hl (remainder a) = hl / c

IF !DEF(MATH_ASM)
MATH_ASM SET 1

rev_Check_math_asm: MACRO
  IF \1 > 1
    WARN "Version \1 or later of 'math.asm' is required."
  ENDC
ENDM

SECTION "Math Code", ROM0
math_Multiply:: ; hl = de * a
  ld hl, 0
  and a
  ret z
.loop
    add hl, de
    dec a
    jr nz, .loop
  ret

MULTIPLY_16: MACRO ;\1 = register
  jr nc,.skip\@
  add hl,de           ; Add multiplicand to product.
  adc a,\1            ; (Product in AHL)
.skip\@
ENDM

; math_Multiply16 by Jon Tara
math_Multiply16:: ;bcde = de * hl
  push hl            ; Save multiplier.
  ld c, h            ; Save MSBs of multiplier.
  ld a, l            ; LSBs to A for an 8 x 16 multiply.

  ld b, 0            ; Handy 0 to B for carry propagation.
  ld h, b            ; Init LSBs of product.
  ld l, b

  add a, a           ; Test multiplier bit.
  MULTIPLY_16 b
REPT 7
  add hl, hl         ; Shift product left.
  adc a, a           ; Test multiplier bit.
  MULTIPLY_16 b
ENDR

  push hl            ; Save LSBs in stack.
  ld h, b            ; Zero second product.
  ld l, b            ; .
  ld b, a            ; Save MSBs of first product in B
  ld a, c            ; Get MSBs of multiplier.
  ld c, h            ; Handy 0 in C this time.

  add a, a           ; Test multiplier bit.
  MULTIPLY_16 c
REPT 7
  add hl, hl         ; Shift product left.
  adc a, a           ; Test multiplier bit.
  MULTIPLY_16 c
ENDR

  pop de             ; Fetch LSBs of 1st product.
  ld c,a             ; Add partial products.
  ld a,d             ; .
  add a,l            ; .
  ld d,a             ; .
  ld a,b             ; .
  adc a,h            ; .
  ld h,a             ; .
  ld a,c             ; .
  adc a,0            ; .
  ld b,a             ; .
  ld c,h             ; .
  pop hl             ; Restore multiplier.
  ret

math_Divide:: ; hl (remainder a) = hl / c
  xor a
  ld b, 16
.loop
    add hl, hl
    rla
    jr c, .skip
    cp c
    jr c, .skip
    sub c
    inc l
.skip
    dec b
    jr nz, .loop
  ret

math_Divide24:: ; ehl (remainder a) = ehl / d
  xor a
  ld b, 24
.loop
    add hl,hl
    rl e
    rla
    cp d
    jr c, .skip
    sub d
    inc l
.skip
    dec b
    jr nz, .loop
  ret

math_Sub24:: ;ehl = ehl - bcd
  ld a, l
  sub a, d
  ld l, a
  ld a, h
  sbc a, c
  ld h, a
  ld a, e
  sbc a, b
  ld e, a
  ret

ENDC
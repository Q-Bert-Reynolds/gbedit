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

adcHL: MACRO;\1 = r1, \2 = r2
  ld a, l
  jr c, .carry\@
  add a, \2
  jr .end\@
.carry\@
  adc a, \2
.end\@
  ld l, a
  ld a, h
  adc a, \1
  ld h, a
ENDM

sbcHL: MACRO;\1 = r1, \2 = r2
  ld a, l
  jr c, .borrow\@
  sub a, \2
  jr .end\@
.borrow\@
  sbc a, \2
.end\@
  ld l, a
  ld a, h
  sbc a, \1
  ld h, a
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

;TODO: this is slow, make it more like div and div24
math_Divide16:: ;de (remainder hl) = hl / bc
  ld de, 0 ;quotient
.loop ;while remainder ≥ denominator
    inc de
    sbcHL b, c;remainder − denominator
    jr nc, .loop
  add hl, bc
  dec de
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

math_CountBits:: ;a = byte, returns count in a
  push bc

  push af
  and a, %01010101
  ld b, a
  pop af
  srl a
  and a, %01010101
  add a, b

  push af
  and a, %00110011
  ld b, a
  pop af
  srl a
  srl a
  and a, %00110011
  add a, b

  push af
  and a, %00001111
  ld b, a
  pop af
  swap a
  and a, %00001111
  add a, b

  pop bc
  ret

math_Bitmasks::
  DB %00000001, %00000010, %00000100, %00001000
  DB %00010000, %00100000, %01000000, %10000000

math_TestBit:: ;tests bit d of byte e, affects z flag, all registers
  ld hl, math_Bitmasks
  ld b, 0
  ld c, d
  add hl, bc
  ld a, [hl]
  and a, e
  ret

math_AddSignedByteToWord:: ;a = byte, [hl] = word, result in [hl]
  ld e, a ;put 8bit in e
  add a, a ;bit 7 into carry
  sbc a, a ;0 if no carry, 255 if carry
  ld d, a
  push hl ;address of word in hl
  ld a, [hli]
  ld b, a  ;first byte of word in b
  ld a, [hld]
  ld c, a  ;second byte of word in c
  ld h, b 
  ld l, c ;contents of word now in hl
  add hl, de ;add byte (de) to word (hl)
  ld b, h
  ld c, l ;new word now in bc
  pop hl ;address of word back in hl
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a
  ret

ENDC
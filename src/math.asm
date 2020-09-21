; Math
;  Started 14-Jan-20
;
; Initials: NB = Nolan Baker
; V1.0 - 14-Jan-20 : Original Release - NB
;
; Library Subroutines:
;   math_Multiply
;     hl = de * a
;   math_Multiply16
;     bcde = de * hl
;   math_Divide
;     hl (remainder a) = hl / c
;   math_Divide16
;     de (remainder hl) = hl / bc
;   math_Divide24
;     ehl (remainder a) = ehl / d
;   math_Sub24
;     ehl = ehl - bcd
;   math_Sub16
;      hl = hl - bc
;   math_CountBits
;     a = byte, returns count in a
;   math_TestBit
;     tests bit d of byte e, affects z flag, all registers
;   math_AddSignedByteToWord
;     a = byte, [hl] = word, result in [hl], a -> 2=carry,3=borrow
;   math_Distance
;     hl = xy1, de = xy2, returns distance in a
;   math_Length
;     a = length(de)
;   math_Normalize
;     de = normalized(de)
;   math_Abs
;     a = |a|
;   math_Cos255
;     a = cos(a) * 255 where a in degrees <= 180
;   math_Sin255
;     a = sin(a) * 255 where a in degrees <= 180

IF !DEF(MATH_ASM)
MATH_ASM SET 1

rev_Check_math_asm: MACRO
  IF \1 > 1
    WARN "Version \1 or later of 'math.asm' is required."
  ENDC
ENDM

ADC_HL: MACRO;\1 = r1, \2 = r2
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

SBC_HL: MACRO;\1 = r1, \2 = r2
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

ADD_HL_DE_ADC_REG: MACRO ;\1 = register
  jr nc, .skip\@
  add hl,de           ; Add multiplicand to product.
  adc a,\1            ; (Product in AHL)
.skip\@
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

; math_Multiply16 by Jon Tara
math_Multiply16:: ;bcde = de * hl
  push hl            ; Save multiplier.
  ld c, h            ; Save MSBs of multiplier.
  ld a, l            ; LSBs to A for an 8 x 16 multiply.

  ld b, 0            ; Handy 0 to B for carry propagation.
  ld h, b            ; Init LSBs of product.
  ld l, b

  add a, a           ; Test multiplier bit.
  ADD_HL_DE_ADC_REG b
REPT 7
  add hl, hl         ; Shift product left.
  adc a, a           ; Test multiplier bit.
  ADD_HL_DE_ADC_REG b
ENDR

  push hl            ; Save LSBs in stack.
  ld h, b            ; Zero second product.
  ld l, b            ; .
  ld b, a            ; Save MSBs of first product in B
  ld a, c            ; Get MSBs of multiplier.
  ld c, h            ; Handy 0 in C this time.

  add a, a           ; Test multiplier bit.
  ADD_HL_DE_ADC_REG c
REPT 7
  add hl, hl         ; Shift product left.
  adc a, a           ; Test multiplier bit.
  ADD_HL_DE_ADC_REG c
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

;FIXME: This seems to be broken for large values of C ...
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

math_Divide16:: ;de (remainder hl) = hl / bc
  ld de, 0 ;quotient
.loop ;while remainder >= denominator
    inc de
    SBC_HL b, c;remainder − denominator
    jr nc, .loop
  add hl, bc
  dec de
  ret

;FIXME: This also seems to be broken for large values of D ...
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

math_Add24:: ;ehl = ehl + bcd
  ld a, l
  add a, d
  ld l, a
  ld a, h
  adc a, c
  ld h, a
  ld a, e
  adc a, b
  ld e, a
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

math_Sub16:: ;hl = hl - bc
  ld a, l
  sub a, c
  ld l, a
  ld a, h
  sbc a, b
  ld h, a
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

math_Bitmasks:
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

math_AddSignedByteToWord:: ;a = byte, [hl] = word, result in [hl], a -> 2=carry,3=borrow
  ld e, a ;put 8bit in e
  add a, a ;bit 7 into carry
  push af;pos/neg
  sbc a, a ;0 if no carry, 255 if carry
  ld d, a
  push hl ;address of word in hl
  ld a, [hli]
  ld b, a  ;first byte of word in b
  ld a, [hld]
  ld h, b 
  ld l, a  ;contents of word now in hl
  push hl;store old word
  add hl, de ;add byte (de) to word (hl)
  ld d, h
  ld e, l ;new word now in de
  pop bc;restore old word

  pop hl ;address of word back in hl
  ld a, d
  ld [hli], a
  ld a, e
  ld [hl], a;store de in [hl]

.checkForBorrowCarry;TODO: surely this could be faster
  pop hl;pos/neg flag
  ld a, d
  sub a, b;compare bc (old) to de (new)
  jr z, .exit
  jr c, .less
  push hl
  pop af;pos/neg flag
  jr nc, .exit ;if pos and new > old, return 0
  ld a, 3;else neg but new > old
  ret
.less
  push hl
  pop af;pos/neg flag
  jr c, .exit ;if neg and new < old, return 0
  ld a, 2;else pos but new < old
  ret
.exit
  xor a
  ret


math_Distance:: ;hl = xy1, de = xy2, returns distance in a
  ld a, d
  sub a, h
  ld d, a
  jr nc, .noBorrowX
  ld a, 255
  sub a, d
  ld d, a
.noBorrowX
  ld a, e
  sub a, l
  ld e, a
  jr nc, .noBorrowY
  ld a, 255
  sub a, e
  ld e, a
.noBorrowY
  ;fall through to length calculation

; Finds length of vector DE
; Uses the following approximation:
;   length = b + 0.5 * a * a / b     where 0 <= a <= b
;   b = x, a = y
math_Length:: ;de = xy, returns length in a
  ld a, d;x
  cp a, e;x < y?
  jr nc, .skip
  ld d, e
  ld e, a;swap
.skip
  ld c, d;b
  push bc
  ld a, e;a
  ld d, 0
  ld e, a
  call math_Multiply;a*a
  call math_Divide;a*a/b
  srl l;0.5*a*a/b
  pop bc
  ld a, c;b
  add a, l;b+0.5*a*a/b
  ret

math_Normalize:: ;de = xy, returns |xy| in de
  push de;xy
  call math_Length
  pop de;xy
  push de;xy
  push af;len
  ld h, d;x
  ld l, 0
  ld b, 0
  ld c, a
  call math_Divide16
  ld l, e
  pop af;len
  pop de;xy
  ld d, l;x/len
  push de;x/len,y
  ld h, e;y
  ld l, 0
  ld b, 0
  ld c, a
  call math_Divide16
  ld l, e
  pop de;x/len,y
  ld e, l;y/len
  ret

math_Lerp:: ;a = (a*(100-c)+b*c)/100 where 0 <= c <= 100
  ld d, a
  ld a, c
  cp a, 101
  ld c, a
  ld a, d
  jr c, _Lerp

  ld d, a
  ld a, c
  sub a, 100
  ld c, a
  ld a, d
  push bc
  ld d, a
  ld a, b
  sub a, d
  jr nc, .skip

  cpl;TODO: this seems unnecessary 
  ld b, a
  xor a
  call _Lerp
  pop bc
  ld c, a
  ld a, b
  sub a, c
  ret

.skip
  ld b, a
  xor a
  call _Lerp
  pop bc
  add a, b
  ret

_Lerp:
  push bc
  ld d, 0
  ld e, a
  ld a, 100
  sub a, c
  call math_Multiply
  pop bc
  push hl;a*(100-c)
  ld d, 0
  ld e, b
  ld a, c
  call math_Multiply
  pop de
  add hl, de;a*(100-c)+b*c
  ld c, 100
  call math_Divide
  ld a, l
  ret

math_Abs:: ;a = |a|
  cp a, 128
  ret c
  cpl
  inc a
  ret


math_Cos255:: ;a = cos(a) * 255 where a in degrees <= 180
  ld b, a;deg
  ld a, 90
  sub a, b
  jr nc, math_Sin255
  ld b, a
  ld a, 255
  sub a, b
  ;fall through to sin
  
math_Sin255:: ;a = sin(a) * 255 where a in degrees <= 180
  cp a, 91
  jr c, .lookup
  ld b, a
  ld a, 180
  sub a, b
.lookup
  ld hl, Sin255Table
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hl]
  ret
  
Sin255Table:;0 to 90 degrees (also 180 to 90, 0 to -90, and -180 to -90)
  DB   0,  4,  9, 13, 18, 22, 27, 31, 35, 40, 44, 49, 53, 57, 62
  DB  66, 70, 75, 79, 83, 87, 91, 96,100,104,108,112,116,120,124
  DB 127,131,135,139,143,146,150,153,157,160,164,167,171,174,177
  DB 180,183,186,190,192,195,198,201,204,206,209,211,214,216,219
  DB 221,223,225,227,229,231,233,235,236,238,240,241,243,244,245
  DB 246,247,248,249,250,251,252,253,253,254,254,254,255,255,255,255

ENDC
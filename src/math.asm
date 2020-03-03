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

ENDC
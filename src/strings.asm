; String Manipulation Code
;  Started 05-Jan-20
;
; Initials: NB = Nolan Baker
; V1.0 - 05-Jan-20 : Original Release - NB
;
; Library Subroutines:
;   str_Copy
;     Copy a string from hl to de
;     Entry: hl = src string, de = dest string
;   str_Length
;     Length of a string
;     Entry: hl = string
;     Return: de = length
;   str_FromArray
;     gets string by index
;     Entry: bc = index, hl = string array
;     Return: hl = string at index bc
;   str_CopyLine 
;     Copies line (\n) from hl to de
;     Entry: hl = src string, de = dest string
;     Return: bc = length of line, hl = start of next line
;   str_Append
;     Appends one string to another
;     Entry: hl = append string, de = dest string
;   str_Replace
;     Replaces string bc in source hl with string af in destination de
;     Entry: hl = src string, de = dest string, bc = replace string, af = with string
;   str_Number
;     Converts number hl to string de
;     Entry: hl = 16 bit number, de = dest string
;   str_Number24
;     Converts number ehl to string bc
;     Entry: ehl = 24 bit number, bc = dest string


IF !DEF(STRINGS_ASM)
STRINGS_ASM SET 1

rev_Check_strings_asm: MACRO
  IF \1 > 1
    WARN "Version \1 or later of 'strings.asm' is required."
  ENDC
ENDM

INCLUDE "src/math.asm"
  rev_Check_math_asm 1

SECTION "Strings Code", ROM0
;***************************************************************************
;
; str_Copy - Copy a string
;
; input:
;   hl - src string
;   de - dst string
;
;***************************************************************************
str_Copy::
  ld   a, [hli]
  ld   [de], a
  inc  de
  and  a
  jr   nz, str_Copy
  ret

;***************************************************************************
;
; str_Length - Length of a string
;
; input:
;   hl - string
; output:
;   de - length
;
;***************************************************************************
str_Length::
  ld de, 0
.loop
  ld a, [hli]
  and a
  ret z
  inc de
  jr .loop

;***************************************************************************
;
; str_FromArray - gets string by index
;
; input:
;   bc - index
;   hl - string array
; output:
;   hl - string at index bc
;
;***************************************************************************
str_FromArray::
  inc bc
  jr .test
.loop; find end of string
    ld a, [hli]
    and a
    jr nz, .loop
.test; check bc == 0
    xor a
    dec bc
    cp b
    jr nz, .loop
    cp c
    jr nz, .loop
  ret 

;***************************************************************************
;
; str_CopyLine - Copies line
;
; input:
;   hl - string
;   de - dest
; output:
;   bc - length of line
;   hl - start of next line
;
;***************************************************************************
str_CopyLine::
  ld bc, 0
.loop
  ld a, [hli]
  cp 128;"\n"
  ret z
  and a
  ret z
  ld [de], a
  inc de
  inc bc
  jr .loop

;***************************************************************************
;
; str_Append - Appends string hl to de
;
; input:
;   hl - append string
;   de - dest string
;
;***************************************************************************
str_Append::
  ld a, [de]
  inc de
  and a
  jr nz, str_Append
  dec de
  call str_Copy
  ret 

;***************************************************************************
;
; str_Replace - Replaces %s in src with bc, results in dest
;
; input:
;   hl - src string
;   de - dest string
;   bc - replace data
;
;***************************************************************************
str_Replace::
  ld a, [hli]
  and a
  jr z, .done
  cp "%"
  jp nz, .copyToDest
  ld a, [hli]
  cp "s"
  jr z, .stringReplace
  dec hl
  jr str_Replace
.copyToDest
  ld [de], a
  inc de
  jr str_Replace
.stringReplace
  ld a, [bc]
  and a
  jr z, str_Copy
  ld [de], a
  inc bc
  inc de
  jr .stringReplace
.done
  ld [de], a
  ret

;***************************************************************************
;
; str_Number - converts number hl to string de
;
; input:
;   hl - number
;   de - dest string
;
;***************************************************************************
str_Number::
  ld a, h ; if hl == 0, return "0",0
  and a
  jr nz, .skip
  ld a, l
  and a
  jr nz, .skip
  ld a, "0"
  ld [de], a
  inc de
  xor a
  ld [de], a
  ret
.skip
  push de ;dest string
  ld c, 0 ;num digits
.divLoop
    push bc
    ld c, 10
    call math_Divide
    add a, 48;convert num to string
    ld [de], a
    inc de
    pop bc
    inc c ;num digits
    ld a, h ; if hl > 0, loop
    and a
    jr nz, .divLoop
    ld a, l
    and a
    jr nz, .divLoop

  pop hl ;dest string
  xor a
  ld [de], a;terminate string
  ld a, c
  cp 1
  ret z ;no need to swap if only one digit

  srl c;num digits / 2
  dec de
.swapLoop
    ld a, [hl]
    ld b, a
    ld a, [de]
    ld [hli], a
    ld a, b
    ld [de], a
    dec de
    dec c
    jr nz, .swapLoop
  ret

;***************************************************************************
;
; str_Number24 - converts number ehl to string bc
;
; input:
;   ehl - number
;   bc - dest string
;
;***************************************************************************
str_Number24::
  ld d, 0
  ld a, e ; if ehl == 0, return "0",0
  and a
  jr nz, .skip
  ld a, h
  and a
  jr nz, .skip
  ld a, l
  and a
  jr nz, .skip
  ld a, "0"
  ld [bc], a
  inc bc
  xor a
  ld [bc], a
  ret

.skip
  xor a
  push bc ;dest string start
  push af ;num digits
  push bc ;dest string
.divLoop
    ld d, 10
    call math_Divide24
    add a, 48;convert num to string

    pop bc;dest string
    ld [bc], a
    inc bc
    pop af;num digits
    inc a 
    push af;num digits
    push bc;dest string
    
    ld a, e ; if ehl > 0, loop
    and a
    jr nz, .divLoop
    ld a, h
    and a
    jr nz, .divLoop
    ld a, l
    and a
    jr nz, .divLoop

  pop bc ;dest string
  xor a
  ld [bc], a;terminate string
  pop af;num digits
  cp 1
  ret z ;no need to swap if only one digit

  pop hl ;dest string start
  ld d, a;num digits
  srl d;num digits / 2
  dec bc
.swapLoop
  ld a, [hl]
  ld e, a
  ld a, [bc]
  ld [hli], a
  ld a, e
  ld [bc], a
  dec bc
  dec d
  jr nz, .swapLoop
  ret

ENDC ;STRINGS_ASM
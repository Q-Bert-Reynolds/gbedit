; String Manipulation Code
;  Started 05-Jan-20
;
; Initials: NB = Nolan Baker
; V1.0 - 05-Jan-20 : Original Release - NB
;
; Library Subroutines:
;   str_Copy
;     Copy a string
;     Entry: hl = src string, de = dst string
;   str_Length
;     Length of a string
;     Entry: hl = string
;     Return: de = length
;   str_Replace
;     Replaces string bc in source hl with string af in destination de
;     Entry: hl = src string, de = dest string, bc = replace string, af = with string

IF !DEF(STRINGS_ASM)
STRINGS_ASM  SET  1

rev_Check_strings_asm: MACRO
  IF \1 > 1
    WARN "Version \1 or later of 'strings.asm' is required."
  ENDC
ENDM

INCLUDE "src/memory1.asm"
  rev_Check_memory1_asm   1.2

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
  ld   de, 0
.loop
  ld   a, [hli]
  and  a
  ret z
  inc  de
  jr   .loop

;***************************************************************************
;
; str_Append - Appends string bc to source hl resulting in destination de
;
; input:
;   hl - src string
;   de - dest string
;   bc - append string
;
;***************************************************************************
str_Append::
  call str_Copy
  dec de
  ld h, b
  ld l, c
  call str_Copy
  ret 

;***************************************************************************
;
; str_Replace - Replaces %s with bc
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
  jr z, str_Replace
  ld [de], a
  inc bc
  inc de
  jr .stringReplace
  jr str_Replace
.done
  ld [de], a
  ret

ENDC ;STRINGS_ASM
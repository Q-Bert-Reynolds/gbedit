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
; str_Replace - Replaces string bc in source hl with string af in destination de
;
; input:
;   hl - src string
;   de - dest string
;   bc - target string
;   [name_buffer] - replace string
;
;***************************************************************************
str_Replace::
  push de;dest string
  push bc;target string
  push hl;src string
.findReplaceString
  pop hl ;src
  pop bc ;target
  ld a, [hli];src string
  ld e, a
  ld a, [bc];target string
  cp a, e
  jp z, .matchTarget
  ld a, e;char from src string
  pop de;dest string
  ld [de], a
  inc de
  push de;dest
  push bc;target
  push hl;src
  and a
  jp z, .done;if a == 0, done replacing 
  jr .findReplaceString
.matchTarget
  push bc;target
  push hl;store current src position
.matchTargetLoop
  inc bc; match already found, check next
  ld a, [bc]
  and a
  jr z, .replaceWithString; if end of target string, match found
  ld d, a ;otherwise, compare target replace src string
  ld a, [hli]
  cp d
  jp nz, .findReplaceString ;if not a match, back to copying src to dest
  jr .matchTargetLoop ;otherwise keep checking
.replaceWithString
  pop af ;discard old src string position
  pop bc ;target string
  pop de ;dest string
  push de ;dest string
  push bc ;target string
  push hl ;store new src string position

  ld hl, name_buffer ;put replacementment string in hl
.replaceWithStringLoop
  ld a, [hli]
  and a
  jr z, .doneReplacing ;if end of replacement string, exit
  ld [de], a
  inc de
  jr .replaceWithStringLoop
.doneReplacing
  pop hl ;src string
  pop bc ;target string
  pop af ;discard old dest string
  push de ;store new dest string
  push bc ;target string
  push hl ;src string
  jp .findReplaceString
.done
  pop hl;src string
  pop bc;target string
  pop de;dest string
  ret

ENDC ;STRINGS_ASM
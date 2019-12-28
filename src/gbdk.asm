IF !DEF(GBDK_ASM)
GBDK_ASM  SET  1

rev_Check_GBDK_ASM: MACRO
  IF \1 > 1
    WARN "Version \1 or later of 'gbdk.asm' is required."
  ENDC
ENDM

INCLUDE "src/memory1.asm"
  rev_Check_memory1_asm 1.1

SECTION "GBDK Code", ROM0
;***************************************************************************
;
; gbdk_SetXYWin - Sets window tile table from BC at XY = DE of size WH = HL
; wh >= (1,1)
;
; input:
;   hl - wh
;   de - xy
;   bc - firstTile
;
;***************************************************************************
gbdk_SetXYWin::
  push  hl    ; store wh
  ldh  a,[rLCDC]
  bit  6,a
  jr  nz,.innerLoop
  ld  hl,$9800  ; hl = origin
  jr  gbdk_SetXYTT
.innerLoop:
  ld  hl,$9c00  ; hl = origin
  jr  gbdk_SetXYTT


;***************************************************************************
;
; gbdk_SetXYBKG - Sets background tile table from (BC) at XY = DE of size WH = HL
; wh >= (1,1); 
;
; input:
;   hl - wh
;   de - xy
;   bc - firstTile
;
;***************************************************************************
gbdk_SetXYBKG::
  push  hl    ; store wh
  ldh  a,[rLCDC]
  bit  3,a
  jr  nz,.loop
  ld  hl,$9800  ; hl = origin
  jr  gbdk_SetXYTT
.loop:
  ld  hl,$9c00  ; hl = origin


gbdk_SetXYTT::
  push  bc    ; store source
  xor  a
  or  e
  jr  z,.loop2

  ld  bc,$20  ; one line is 20 tiles
.loop:
  add  hl,bc    ; y coordinate
  dec  e
  jr  nz,.loop
.loop2:
  ld  b,$00    ; x coordinate
  ld  c,d
  add  hl,bc

	pop	bc		; bc = source
	pop	de		; de = wh
	push	hl		; store origin
	push	de		; store wh
.loop3:
	ldh	a,[rSTAT]
	and	$02
	jr	nz,.loop3

	ld	a,[bc]		; copy w tiles
	ld	[hl+],a
	inc	bc
	dec	d
	jr	nz,.loop3
	pop	hl		; hl = wh
	ld	d,h		; restore d = w
	pop	hl		; hl = origin
	dec	e
	jr	z,.loop4

	push	bc		; next line
	ld	bc,$20	; one line is 20 tiles
	add	hl,bc
	pop	bc

	push	hl		; store current origin
	push	de		; store wh
	jr	.loop3
.loop4:
	ret

;***************************************************************************
;
; gbdk_Delay - delay de milliseconds
; 
; input:
;   de - number of milliseconds to delay (1 to 65536, 0 = 65536)
;
; registers used: af, de
;***************************************************************************
_CPMS EQU 4194/4  ; 4.194304 MHz
gbdk_Delay::
.delay               ; 6 cycles for the call
  push bc            ; 4 cycles
  call .dly          ; 12 cycles to return from .dly (6+1+5)
  ld b, (_CPMS/20)-2 ; 2 cycles
; =========
; 24 cycles

.ldlp  jr .ldlp1 ; 3 cycles
.ldlp1 jr .ldlp2 ; 3 cycles
.ldlp2 jr .ldlp3 ; 3 cycles
.ldlp3 jr .ldlp4 ; 3 cycles
.ldlp4 jr .ldlp5 ; 3 cycles
.ldlp5 dec b     ; 1 cycle
     jp nz, .ldlp ; 3 cycles (if true: 4 cycles)
     nop          ; 1 cycle
; =========
; 20 cycles

; exit in 16 cycles
       pop bc    ; 3 cycles
       jr .ldlp6 ; 3 cycles
.ldlp6 jr .ldlp7 ; 3 cycles
.ldlp7 jr .ldlp8 ; 3 cycles
.ldlp8 ret       ; 4 cycles
; =========
; 16 cycles

; delay all but last millisecond
.dly
  dec de             ; 2 cycles
  ld a,e             ; 1 cycle
  or d               ; 1 cycle
  ret z              ; 2 cycles (upon return: 5 cycles)
  ld b, (_CPMS/20)-1 ; 2 cycles
; =========
; 8 cycles

.dlp  jr .dlp1     ; 3 cycles
.dlp1 jr .dlp2     ; 3 cycles
.dlp2 jr .dlp3     ; 3 cycles
.dlp3 jr .dlp4     ; 3 cycles
.dlp4 jr .dlp5     ; 3 cycles
.dlp5 dec  b       ; 1 cycle
      jp nz, .dlp  ; 3 cycles (if true: 4 cycles)
      nop          ; 1 cycle
; =========
; 20 cycles
  
; exit in 15 cycles
      jr .dlp6 ; 3 cycles
.dlp6 jr .dlp7 ; 3 cycles
.dlp7 jr .dlp8 ; 3 cycles
.dlp8 jr .dly  ; 3 cycles
; =========
; 12 cycles
ret


ENDC ;GBDK_ASM

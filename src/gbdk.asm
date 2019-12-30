IF !DEF(GBDK_ASM)
GBDK_ASM  SET  1

rev_Check_GBDK_ASM: MACRO
  IF \1 > 1
    WARN "Version \1 or later of 'gbdk.asm' is required."
  ENDC
ENDM

INCLUDE "src/memory1.asm"
  rev_Check_memory1_asm 1.1

DISPLAY_ON: MACRO
  ld a, [rLCDC]
  or LCDCF_ON
  ld [rLCDC], a
ENDM

DISPLAY_OFF: MACRO
  call gbdk_DisplayOff
ENDM

SHOW_BKG: MACRO
  ld a, [rLCDC]
  or LCDCF_BGON
  ld [rLCDC], a
ENDM

HIDE_BKG: MACRO
  ld a, [rLCDC]
  and ~LCDCF_BGON
  ld [rLCDC], a
ENDM

SHOW_WIN: MACRO
  ld a, [rLCDC]
  or LCDCF_WINON
  ld [rLCDC], a
ENDM

HIDE_WIN: MACRO
  ld a, [rLCDC]
  and ~LCDCF_WINON
  ld [rLCDC], a
ENDM

SHOW_SPRITES: MACRO
  ld a, [rLCDC]
  or LCDCF_OBJON
  ld [rLCDC], a
ENDM

HIDE_SPRITES: MACRO
  ld a, [rLCDC]
  and ~LCDCF_OBJON
  ld [rLCDC], a
ENDM

SPRITES_8x16: MACRO
  ld a, [rLCDC]
  or LCDCF_OBJ16
  ld [rLCDC], a
ENDM

SPRITES_8x8: MACRO
  ld a, [rLCDC]
  and ~LCDCF_OBJ16
  ld [rLCDC], a
ENDM

; MBC5
SWITCH_ROM_MBC5: MACRO ;word \1
  ld hl, rROMB0
  ld [hl], \1 & $FF
  ld hl, rROMB1
  ld [hl], \1 >> 8
ENDM

SWITCH_RAM_MBC5: MACRO ;byte \1
  ld hl, rRAMB
  ld [hl], \1
ENDM

ENABLE_RAM_MBC5: MACRO
  ld hl, rRAMG
  ld [hl], $0A
ENDM

DISABLE_RAM_MBC5: MACRO
  xor a
  ld [rRAMG], a
ENDM

CGB_COMPATIBILITY: MACRO
  ld	a,$80
  ldh	[rBCPS], a	; set default bkg palette
  ld	a,$ff		; white
  ldh	[rBCPD], a
  ld	a,$7f
  ldh	[rBCPD], a
  ld	a,$b5		; light gray
  ldh	[rBCPD], a
  ld	a,$56
  ldh	[rBCPD], a
  ld	a,$4a		; dark gray
  ldh	[rBCPD], a
  ld	a,$29
  ldh	[rBCPD], a
  ld	a,$00		; black
  ldh	[rBCPD], a
  ld	a,$00
  ldh	[rBCPD], a
  ld	a,$80
  ldh	[rOCPS], a	; set default sprite palette
  ld	a,$ff		; white
  ldh	[rOCPD], a
  ld	a,$7f
  ldh	[rOCPD], a
  ld	a,$b5		; light gray
  ldh	[rOCPD], a
  ld	a,$56
  ldh	[rOCPD], a
  ld	a,$4a		; dark gray
  ldh	[rOCPD], a
  ld	a,$29
  ldh	[rOCPD], a
  ld	a,$00		; black
  ldh	[rOCPD], a
  ld	a,$00
  ldh	[rOCPD], a
ENDM

SECTION "GBDK Code", ROM0
;***************************************************************************
;
; gbdk_SetOAM - sets X, Y, tile ID, and flags of Sprite N
;   immediately ready to set bcde (x,y,tile,flags) on Sprite N+1
;
; input:
;   hl - _OAMRAM + N * 4
;   bc - xy
;   d - tile
;   e - flags
;
;***************************************************************************
gbdk_SetOAM
  ld a, c ;y pos
  ld [hli], a
  ld a, b ;x pos
  ld [hli], a
  ld a, d ;tile
  ld [hli], a
  ld a, e ;flags
  ld [hli], a
  ret

;***************************************************************************
;
; gbdk_DisplayOff - Waits for VBlank and turns off the LCD
;
;***************************************************************************
gbdk_DisplayOff::
  ldh a, [rLCDC]
  add a
  ret nc
  lcd_WaitVRAM  
  ldh a, [rLCDC]
  and %01111111
  ldh [rLCDC], A
  ret

;***************************************************************************
;
; gbdk_WaitVBLDone - Wait for VBL interrupt to be finished
;
;***************************************************************************
gbdk_WaitVBLDone::
  ld a, [rLY]
  cp 144
  jr nz, gbdk_WaitVBLDone
  ret

;***************************************************************************
;
; gbdk_SetWinTiles - Sets window tile table
; width and height >= (1,1); 
;
; input:
;   hl - width, height
;   de - x pos, y pos
;   bc - firstTile
;
;***************************************************************************
gbdk_SetWinTiles::
  push  hl    ; store wh
  ldh  a,[rLCDC]
  bit  6, a
  jr  nz,.innerLoop
  ld  hl,$9800  ; hl = origin
  jr  setTiles
.innerLoop:
  ld  hl,$9c00  ; hl = origin
  jr  setTiles


;***************************************************************************
;
; gbdk_SetBKGTiles - Sets background tile table
; width and height >= (1,1); 
;
; input:
;   hl - width, height
;   de - x pos, y pos
;   bc - firstTile
;
;***************************************************************************
gbdk_SetBKGTiles::
  push  hl    ; store wh
  ldh  a,[rLCDC]
  bit  3, a
  jr  nz,.loop
  ld  hl,$9800  ; hl = origin
  jr  setTiles
.loop:
  ld  hl,$9c00  ; hl = origin

setTiles:
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
  ld	[hl+], a
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

;***************************************************************************
;
; gbdk_CPUSlow - Sets GameBoy Color to DMG speed
;
;***************************************************************************
gbdk_CPUSlow::
  ldh	a,[rKEY1]
  and	$80		; is gbc in double speed mode?
  ret	z		; no, already in single speed

shift_speed:
  ldh	a,[rIE]
  push	af

  xor	a		; a = 0
  ldh	[rIE], a		; disable interrupts
  ldh	[rIF], a

  ld	a,$30
  ldh	[rP1], a

  ld	a,$01
  ldh	[rKEY1], a

  stop

  pop	af
  ldh	[rIE], a

  ret

;***************************************************************************
;
; gbdk_CPUFast - Sets GameBoy Color to double speed mode
;
;***************************************************************************
gbdk_CPUFast::
  ldh	a,[rKEY1]
  and	$80		; is gbc in double speed mode?
  ret	nz		; yes, exit
  jr	shift_speed


ENDC ;GBDK_ASM

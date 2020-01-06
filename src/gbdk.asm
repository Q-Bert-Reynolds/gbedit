; GBDK-like functions
;  Started 30-Dec-19
;
; Initials: NB = Nolan Baker, GBDK = Pascal Felber & Michael Hope
; V1.0 - 30-Dec-19 : Original Release - NB, based on GBDK 2.96
;
; Macros:
;   DISPLAY_ON
;   DISPLAY_OFF
;   SHOW_BKG
;   HIDE_BKG
;   SHOW_WIN
;   HIDE_WIN
;   SHOW_SPRITES
;   HIDE_SPRITES
;   SPRITES_8x16
;   SPRITES_8x8
;   SWITCH_ROM_MBC5
;   SWITCH_RAM_MBC5
;   ENABLE_RAM_MBC5
;   DISABLE_RAM_MBC5
;   CGB_COMPATIBILITY
;
; Library Subroutines:
;   gbdk_MoveSprite - Move sprite number C at XY = DE
;   gbdk_SetSpriteTile - Set sprite number C to tile D
;   gbdk_SetSpriteProp - Set properties of sprite number C to D
;   gbdk_DisplayOff
;   gbdk_WaitVBL
;   gbdk_SetWinTiles
;   gbdk_SetBKGTiles
;   gbdk_Delay
;   gbdk_CPUSlow
;   gbdk_CPUFast
;

IF !DEF(GBDK_ASM)
GBDK_ASM  SET  1

rev_Check_GBDK_ASM: MACRO
  IF \1 > 1
    WARN "Version \1 or later of 'gbdk.asm' is required."
  ENDC
ENDM

INCLUDE "src/memory1.asm"
  rev_Check_memory1_asm 1.2

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
  ld a,$80
  ldh [rBCPS], a ; set default bkg palette
  ld a,$ff  ; white
  ldh [rBCPD], a
  ld a,$7f
  ldh [rBCPD], a
  ld a,$b5  ; light gray
  ldh [rBCPD], a
  ld a,$56
  ldh [rBCPD], a
  ld a,$4a  ; dark gray
  ldh [rBCPD], a
  ld a,$29
  ldh [rBCPD], a
  ld a,$00  ; black
  ldh [rBCPD], a
  ld a,$00
  ldh [rBCPD], a
  ld a,$80
  ldh [rOCPS], a ; set default sprite palette
  ld a,$ff  ; white
  ldh [rOCPD], a
  ld a,$7f
  ldh [rOCPD], a
  ld a,$b5  ; light gray
  ldh [rOCPD], a
  ld a,$56
  ldh [rOCPD], a
  ld a,$4a  ; dark gray
  ldh [rOCPD], a
  ld a,$29
  ldh [rOCPD], a
  ld a,$00  ; black
  ldh [rOCPD], a
  ld a,$00
  ldh [rOCPD], a
ENDM

SECTION "GBDK Code", ROM0
;***************************************************************************
;
; gbdk_MoveSprite - Move sprite number C at XY = DE
;
; input:
;   c - sprite number
;   de - xy
;
;***************************************************************************
gbdk_MoveSprite::
  ld hl, _OAMRAM ;calculate origin of sprite info
  sla c ;multiply c by 4
  sla c
  ld b, 0
  add hl, bc
  di
  LCD_WAIT_VRAM
  LCD_WAIT_VRAM
  ld a,e  ;set y
  ld [hl], a
  inc l
  LCD_WAIT_VRAM
  LCD_WAIT_VRAM
  ld a,d  ;set x
  ld [hl], a
  reti

;***************************************************************************
;
; gbdk_SetSpriteTile - Set sprite number C to tile D
;
; input:
;   c - sprite number
;   d - tile
;
;***************************************************************************
gbdk_SetSpriteTile::
  ld hl, _OAMRAM+2 ;calculate origin of sprite info
  sla c ;multiply c by 4
  sla c
  ld b, 0
  add hl, bc
  di
  LCD_WAIT_VRAM ; WTF!? why twice?
  LCD_WAIT_VRAM
  ld a, d ;set sprite number
  ld [hl], a
  reti

;***************************************************************************
;
; gbdk_SetSpriteProp - Set properties of sprite number C to D
;
; input:
;   c - sprite number
;   d - properties
;
;***************************************************************************
gbdk_SetSpriteProp::
  ld hl, _OAMRAM+3 ; calculate origin of sprite info
  sla c ;multiply c by 4
  sla c
  ld b, 0
  add hl, bc
  di
  LCD_WAIT_VRAM
  ld a, d ;set sprite properties
  ld [hl], a
  reti

;***************************************************************************
;
; gbdk_DisplayOff - Waits for VBlank and turns off the LCD
;
;***************************************************************************
gbdk_DisplayOff::
  ldh a, [rLCDC]
  add a
  ret nc
  LCD_WAIT_VRAM  
  ldh a, [rLCDC]
  and %01111111
  ldh [rLCDC], A
  ret

;***************************************************************************
;
; gbdk_WaitVBL - Wait for VBL interrupt to start
;
;***************************************************************************
gbdk_WaitVBL::
  ld a, [rLY]
  cp 144
  jr c, gbdk_WaitVBL
  cp 145
  jr nc, gbdk_WaitVBL
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

  pop bc  ; bc = source
  pop de  ; de = wh
  push hl  ; store origin
  push de  ; store wh
.waitVRAM:
  ldh a,[rSTAT]
  and STATF_BUSY
  jr nz,.waitVRAM

  ld a,[bc]  ; copy w tiles
  ld [hl+], a
  inc bc
  dec d
  jr nz,.waitVRAM
  pop hl  ; hl = wh
  ld d,h  ; restore d = w
  pop hl  ; hl = origin
  dec e
  jr z,.exit

  push bc  ; next line
  ld bc,$20 ; one line is 20 tiles
  add hl,bc
  pop bc

  push hl  ; store current origin
  push de  ; store wh
  jr .waitVRAM
.exit:
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
  ldh a,[rKEY1]
  and $80  ; is gbc in double speed mode?
  ret z  ; no, already in single speed

shift_speed:
  ldh a,[rIE]
  push af

  xor a  ; a = 0
  ldh [rIE], a  ; disable interrupts
  ldh [rIF], a

  ld a,$30
  ldh [rP1], a

  ld a,$01
  ldh [rKEY1], a

  nop

  pop af
  ldh [rIE], a

  ret

;***************************************************************************
;
; gbdk_CPUFast - Sets GameBoy Color to double speed mode
;
;***************************************************************************
gbdk_CPUFast::
  ldh a,[rKEY1]
  and $80  ; is gbc in double speed mode?
  ret nz  ; yes, exit
  jr shift_speed

ENDC ;GBDK_ASM

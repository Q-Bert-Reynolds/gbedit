; GBDK-like functions
;  Started 30-Dec-19
;
; Initials: NB = Nolan Baker, GBDK = Pascal Felber & Michael Hope
; V1.0 - 30-Dec-19 : Original Release - NB, based on GBDK 2.96
;
; Macros:
;   SETUP_DMA_TRANSFER
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
;   SET_TILES
;
; Library Subroutines:
;   gbdk_MoveSprite    - moves sprite c, de=xy
;   gbdk_SetSpriteTile - set sprite c to tile d
;   gbdk_SetSpriteProp - Set properties of sprite c to d
;   gbdk_DisplayOff    - turns off screen
;   gbdk_WaitVBL       - halts until v-blank
;   gbdk_SetWinTiles   - sets window tiles, hl=wh, de=xy, bc=source
;   gbdk_SetBkgTiles   - sets background tiles, hl=wh, de=xy, bc=source
;   gbdk_CopyTilesTo      - jump only, stack=(return,wh), bc=src, hl=dst, de=xy
;   gbdk_GetWinTiles   - gets window tiles, hl=wh, de=xy, bc=source
;   gbdk_GetBkgTiles   - gets background tiles, hl=wh, de=xy, bc=source
;   gbdk_CopyTilesFrom      - jump only, stack=(return,wh), bc=dest, hl=src, de=xy
;   gbdk_Delay         - pauses for de miliseconds
;   gbdk_CPUSlow       - sets GBC CPU speed to DMG 
;   gbdk_CPUFast       - sets GBC CPU speed to 2x
;   gbdk_Random        - returns a random value to DE
;   gbdk_Seed          - seeds Random function
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

HRAM_START = $FF80
HRAM_LEFT = $FFFE - HRAM_START
SETUP_DMA_TRANSFER: MACRO
  ld c, _HRAM % $100
  ld b, .DMATransferEnd - .DMATransfer
  ld hl, .DMATransfer
.copy
  ld a, [hli]
  ld [$ff00+c], a
  inc c
  dec b
  jr nz, .copy
  jp .DMATransferEnd

.DMATransfer
  ld a, oam_buffer / $100
  ld [rDMA], a
  ld a, $28
.wait
  dec a
  jr nz, .wait
  ret
.DMATransferEnd

HRAM_START = HRAM_START + (.DMATransferEnd - .DMATransfer)
HRAM_LEFT = $FFFE - HRAM_START
PRINTT "DMA Transfer routine setup.\n"
PRINTT "{HRAM_LEFT} bytes of HRAM left.\n"
PRINTT "HRAM variables can start at {HRAM_START}\n"
ENDM

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

OP_COPY_TO   EQU 0
OP_COPY_FROM EQU 1
OP_SET_TO    EQU 2
SKIP_VRAM    EQU 0
WAIT_VRAM    EQU 1
;   width, height on stack
;   hl - 32x32 tile table (usually _SCRN0 or _SCRN1)
;   de - x pos, y pos
;   bc - source
COPY_TILE_BLOCK: MACRO; \1 = operation, \2 = wait VRAM?
  push bc ; store source
  xor a
  or e
  jp z,.skip\@

  ld bc, 32 ; one line is 32 tiles
.rowLoop\@
    add hl,bc ; y coordinate
    dec e
    jp nz, .rowLoop\@
  .skip\@
    ld b,0 ; x coordinate
    ld c,d
    add hl,bc

    pop bc ; bc = source
    pop de ; de = wh
    push hl ; store origin
    push de ; store wh
  .columnLoop\@
IF \2 == WAIT_VRAM
      ldh a,[rSTAT]
      and STATF_BUSY
      jp nz, .columnLoop\@
ENDC

IF \1 == OP_COPY_TO
      ld a, [bc]
      ld [hli], a
      inc bc
ELIF \1 == OP_COPY_FROM
      ld a, [hli]
      ld [bc], a
      inc bc
ELIF \1 == OP_SET_TO
      ld a, b; tile id
      ld [hli], a
ENDC

      dec d
      jp nz, .columnLoop\@
      pop hl ; hl = wh
      ld d,h ; restore d = w
      pop hl ; hl = origin
      dec e
      jp z, .exit\@

      push bc ; next line
      ld bc, 32 ; one line is 32 tiles
      add hl,bc
      pop bc

      push hl ; store current origin
      push de ; store wh
      jp .columnLoop\@
.exit\@
  ret
ENDM

SECTION "GBDK Vars", WRAM0[_RAM]
;ensure OAM buffer starts at $XX00 and is not in switchable WRAM, see SETUP_DMA_TRANSFER macro
oam_buffer:: DS 4*40
vbl_done:: DB;TODO: place in HRAM?
rand_hi:: DB
rand_lo:: DB

SECTION "GBDK Code", ROM0
;***************************************************************************
;
; gbdk_MoveSprite - Move sprite number C to XY = DE
;
; input:
;   c - sprite number
;   de - xy
;
;***************************************************************************
gbdk_MoveSprite::
  ld hl, oam_buffer ;calculate origin of sprite info
  sla c ;multiply c by 4
  sla c
  ld b, 0
  add hl, bc
  ld a,e  ;set y
  ld [hl], a
  inc l
  ld a,d  ;set x
  ld [hl], a
  ret

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
  ld hl, oam_buffer+2 ;calculate origin of sprite info
  sla c ;multiply c by 4
  sla c
  ld b, 0
  add hl, bc
  ld a, d ;set sprite number
  ld [hl], a
  ret

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
  ld hl, oam_buffer+3 ; calculate origin of sprite info
  sla c ;multiply c by 4
  sla c
  ld b, 0
  add hl, bc
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
  ldh a, [rLCDC]
  add a
  ret nc; return if screen is off
.loop
    halt; wait for any interrupt
    nop; halt sometimes skips the next instruction
    ld a, [vbl_done]  ; was it a vblank interrupt?
    ;; warning: we may lose a vblank interrupt, if it occurs now
    or a
    jr z, .loop ; no: back to sleep!
  xor a
  ld [vbl_done], a
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
  ld  hl, _SCRN0  ; hl = origin
  jr  gbdk_CopyTilesTo
.innerLoop:
  ld  hl,_SCRN1  ; hl = origin
  jr  gbdk_CopyTilesTo


;***************************************************************************
;
; gbdk_SetBkgTiles - Sets background tile table
; width and height >= (1,1); 
;
; input:
;   hl - width, height
;   de - x pos, y pos
;   bc - firstTile
;
;***************************************************************************
gbdk_SetBkgTiles::
  push hl ; store wh
  ldh a,[rLCDC]
  bit 3, a
  jr nz, .skip
  ld hl, _SCRN0 ; hl = origin
  jr gbdk_CopyTilesTo
.skip
  ld hl, _SCRN1 ; hl = origin
  ;falls through to gbdk_CopyTilesTo

;***************************************************************************
;
; gbdk_CopyTilesTo - Copies tiles to address
;   Cannot be called. Must be jumped to.
;
; input:
;   stack:
;     return address
;     width, height
;   hl - 32x32 tile destination (usually _SCRN0 or _SCRN1)
;   de - x pos, y pos
;   bc - source
;
;***************************************************************************
gbdk_CopyTilesTo::
  COPY_TILE_BLOCK OP_COPY_TO, WAIT_VRAM

;***************************************************************************
;
; gbdk_SetTilesTo - Set tiles to a
;
; input:
;   a  - tile id
;   hl - 32x32 tile destination (usually _SCRN0 or _SCRN1)
;   de - x pos, y pos
;   bc - width, height
;
;***************************************************************************
gbdk_SetTilesTo::
  push bc
  ld b, a
  COPY_TILE_BLOCK OP_SET_TO, WAIT_VRAM

;***************************************************************************
;
; gbdk_GetWinTiles - Gets window tile table
; wh >= (1,1)
;
; input:
;   hl - width, height
;   de - x pos, y pos
;   bc - target
;
;***************************************************************************
gbdk_GetWinTiles::
  push hl ; store wh
  ldh a, [rLCDC]
  bit 6, a
  jr nz, .skip
  ld hl, _SCRN0 ; hl = origin
  jr gbdk_CopyTilesFrom
.skip
  ld hl, _SCRN1 ; hl = origin
  jr gbdk_CopyTilesFrom

;***************************************************************************
;
; gbdk_GetBkgTiles - Gets background tile table
; wh >= (1,1)
;
; input:
;   hl - width, height
;   de - x pos, y pos
;   bc - target
;
;***************************************************************************
gbdk_GetBkgTiles::
  push hl  ; store wh
  ldh a, [rLCDC]
  bit 3, a
  jr nz, .skip
  ld hl, _SCRN0 ; hl = origin
  jr gbdk_CopyTilesFrom
.skip
  ld hl, _SCRN1 ; hl = origin
  ;falls through to gbdk_CopyTilesFrom

;***************************************************************************
;
; gbdk_CopyTilesFrom - Gets tiles from address
;   Cannot be called. Must be jumped to.
;
; input:
;   stack:
;     return address
;     width, height
;   hl - 32x32 tile source (usually _SCRN0 or _SCRN1)
;   de - x pos, y pos
;   bc - destination
;
;***************************************************************************
gbdk_CopyTilesFrom::
  COPY_TILE_BLOCK OP_COPY_FROM, WAIT_VRAM

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


;***************************************************************************
;
; gbdk_Random - generates a random number
;
; Random number generator using the linear congruential method
;    X(n+1) = (a*X(n)+c) mod m
; with a = 17, m = 16 and c = $5C93 (arbitrarily)
; The seed value is also chosen arbitrarily as $a27e
;
; Ref : D. E. Knuth, "The Art of Computer Programming" , Volume 2
;
; Note D is the low byte, E the high byte. This is intentional because
; the high byte can be slightly 'more random' than the low byte, and I presume
; most will cast the return value to a UBYTE. As if someone will use this, tha!
;
; output: de - random number (word)
; registers used: a, hl, de
;***************************************************************************
gbdk_Random::
  ld a, [rand_lo]
  ld l, a
  ld e, a  ; Save rand_lo
  ld a, [rand_hi]
  ld d, a  ; Save rand_hi

  sla l  ; * 16
  rla
  sla l
  rla
  sla l
  rla
  sla l
  rla
  ld h, a  ; Save rand_hi*16

  ld a, e  ; Old rand_lo
  add a, l  ; Add rand_lo*16
  ld l, a  ; Save rand_lo*17

  ld a, h  ; rand_hi*16
  adc a, d  ; Add old rand_hi
  ld h, a  ; Save rand_hi*17

  ld a, l  ; rand_lo*17
  add a, $93
  ld [rand_lo], a
  ld d, a  ; Return register
  ld a, h  ; rand_hi*17
  adc a, $5C
  ld [rand_hi], a
  ld e, a  ; Return register

  ret

;***************************************************************************
; gbdk_Seed - sets the random seed value to hl
;
; input: hl
; registers used: a, hl
;***************************************************************************
gbdk_Seed::
 ld a, h
 ld [rand_lo], a
 ld a, l
 ld [rand_hi], a
 ret

ENDC ;GBDK_ASM
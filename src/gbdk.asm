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
;   SET_TILES
;
; Library Subroutines:
;   gbdk_MoveSprite       - moves sprite c, de=xy
;   gbdk_SetSpriteTile    - set sprite c to tile d
;   gbdk_SetSpriteProp    - Set properties of sprite c to d
;   gbdk_DisplayOff       - turns off screen
;   gbdk_WaitVBL          - halts until v-blank
;   gbdk_SetWinTiles      - sets window tiles, hl=wh, de=xy, bc=source
;   gbdk_SetBkgTiles      - sets background tiles, hl=wh, de=xy, bc=source
;   gbdk_CopyTilesTo      - jump only, stack=(return,wh), bc=src, hl=dst, de=xy
;   gbdk_GetWinTiles      - gets window tiles, hl=wh, de=xy, bc=source
;   gbdk_GetBkgTiles      - gets background tiles, hl=wh, de=xy, bc=source
;   gbdk_CopyTilesFrom    - jump only, stack=(return,wh), bc=dest, hl=src, de=xy
;   gbdk_Delay            - pauses for de miliseconds
;   gbdk_CPUSlow          - sets GBC CPU speed to DMG 
;   gbdk_CPUFast          - sets GBC CPU speed to 2x
;   gbdk_Random           - returns a random value to DE
;   gbdk_Seed             - seeds Random function
;   gbdk_SetupDMATransfer - loads DMA routine into HRAM
;   gbdk_DMATransfer      - executes DMA routine in HRAM

IF !DEF(GBDK_ASM)
DEF GBDK_ASM EQU 1

MACRO rev_Check_GBDK_ASM
  IF \1 > 1
    WARN "Version \1 or later of 'gbdk.asm' is required."
  ENDC
ENDM

INCLUDE "src/memory1.asm"
  rev_Check_memory1_asm 1.2

DEF SYS_INFO_DMG EQU %00000000 ;Dot Matrix Game
DEF SYS_INFO_SGB EQU %00000001 ;Super Game Boy
DEF SYS_INFO_GBC EQU %00000010 ;Game Boy Color
DEF SYS_INFO_GBA EQU %00000100 ;Game Boy Advance
DEF SYS_INFO_GBP EQU %00001000 ;Game Boy Pocket and Super Game Boy 2

MACRO SYS_CHECK ;must happen first
  cp a, BOOTUP_A_DMG
  jr z, .dmg
  cp a, BOOTUP_A_MGB
  jr z, .gbp
.gbcCheck
  cp a, BOOTUP_A_CGB
  ld a, 0;don't xor here
  jr nz, .setSysInfo
  bit B_BOOTUP_B_AGB, b;is it also a GBA
  jr z, .gbc
.gba
  or a, SYS_INFO_GBA
.gbc
  or a, SYS_INFO_GBC
  jr .setSysInfo
.gbp
  ld a, SYS_INFO_GBP
  jr .sgbCheck
.dmg
  ld a, SYS_INFO_DMG
.sgbCheck
  ld b, a;sys info
  ld a, c
  cp a, BOOTUP_C_SGB
  ld a, b;sys info
  jr nz, .setSysInfo
.sgb
  or a, SYS_INFO_SGB
.setSysInfo
  ldh [sys_info], a
ENDM

MACRO COPY_TO_HRAM; \1 = dest address in HRAM, \2 = first address to copy, \3 = last address to copy
  ld c, LOW(\1)
  ld b, (\3 - \2)
  ld hl, \2
.copy
  ld a, [hli]
  ld [$ff00+c], a
  inc c
  dec b
  jr nz, .copy
ENDM

MACRO DISPLAY_ON
  ldh a, [rLCDC]
  or LCDCF_ON
  ldh [rLCDC], a
ENDM

MACRO DISPLAY_OFF
  call gbdk_DisplayOff
ENDM

MACRO SHOW_BKG
  ldh a, [rLCDC]
  or LCDCF_BGON
  ldh [rLCDC], a
ENDM

MACRO HIDE_BKG
  ldh a, [rLCDC]
  and ~LCDCF_BGON
  ldh [rLCDC], a
ENDM

MACRO SHOW_WIN
  ldh a, [rLCDC]
  or LCDCF_WINON
  ldh [rLCDC], a
ENDM

MACRO HIDE_WIN
  ldh a, [rLCDC]
  and ~LCDCF_WINON
  ldh [rLCDC], a
ENDM

MACRO SHOW_SPRITES
  ldh a, [rLCDC]
  or LCDCF_OBJON
  ldh [rLCDC], a
ENDM

MACRO HIDE_SPRITES
  ldh a, [rLCDC]
  and ~LCDCF_OBJON
  ldh [rLCDC], a
ENDM

MACRO SPRITES_8x16
  ldh a, [rLCDC]
  or LCDCF_OBJ16
  ldh [rLCDC], a
ENDM

MACRO SPRITES_8x8
  ldh a, [rLCDC]
  and ~LCDCF_OBJ16
  ldh [rLCDC], a
ENDM

; MBC5
MACRO SWITCH_ROM_MBC5 ;word \1
  ld hl, rROMB0
  ld [hl], \1 & $FF
  ld hl, rROMB1
  ld [hl], \1 >> 8
ENDM

MACRO SWITCH_RAM_MBC5 ;byte \1
  ld hl, rRAMB
  ld [hl], \1
ENDM

MACRO ENABLE_RAM_MBC5
  ld hl, rRAMG
  ld [hl], $0A
ENDM

MACRO DISABLE_RAM_MBC5
  xor a
  ld [rRAMG], a
ENDM

MACRO CGB_COMPATIBILITY
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

DEF OP_COPY_TO   EQU 0
DEF OP_COPY_FROM EQU 1
DEF OP_SET_TO    EQU 2
DEF SKIP_VRAM    EQU 0
DEF WAIT_VRAM    EQU 1
;   width, height on stack
;   hl - 32x32 tile table (usually _SCRN0 or _SCRN1)
;   de - x pos, y pos
;   bc - source
MACRO COPY_TILE_BLOCK; \1 = operation, \2 = wait VRAM?
  push bc ;source

  ;y fits in 5 bits and y*32 is the same as y<<5
  ;because of this, we can rotate in place
  ;high nybble of y becomes low byte of y*32 
  ;low nybble of y becomes high byte of y*32 
  swap e;YYYY000Y
  rlc e;YYY000YY
  ld a, e
  and %00000011 ;high byte of y*32
  add a, h
  ld h, a
  ld a, %11100000
  and a, e ;low byte of y*32 
  add a, d ;low byte of y*32+x
  ld l, a

  pop bc ;source
  pop de ;wh
IF \1 == OP_SET_TO
  ld a, b ;tile id
ENDC

.rowLoop\@
    push de ;wh
  .columnLoop\@
IF \2 == WAIT_VRAM
      ldh a,[rSTAT]
      and STATF_BUSY
      jr nz, .columnLoop\@
  IF \1 == OP_SET_TO
      ld a, b ;tile id
  ENDC
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
      ld [hli], a
ENDC

      dec d
      jr nz, .columnLoop\@
      
    pop de ;wh
    dec e
    ret z

    ld a, 32
    sub a, d 
    add a, l
    ld l, a
    jr nc, .rowLoop\@
    inc h
    jr .rowLoop\@
ENDM

SECTION "GBDK WRAM Vars", WRAM0, ALIGN[8]
;ensure OAM buffer starts at $XX00 and is not in switchable WRAM, see gbdk_SetupDMATransfer
oam_buffer:: DS 4*40

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
  ld a, c
  add a, a ;c*2
  add a, a ;c*4
  ld l, a
  ld h, HIGH(oam_buffer);buffer is page aligned to $XX00
  ld [hl], e ;y
  inc l
  ld [hl], d ;x
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
  ld a, c
  add a, a;c*2
  add a, a;c*4
  add a, 2;c*4+2 (tile id offset)
  ld l, a
  ld h, HIGH(oam_buffer);buffer is page aligned to $XX00
  ld [hl], d;tile id
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
  ld a, c
  add a, a;c*2
  add a, a;c*4
  add a, 3;c*4+3 (props offset)
  ld l, a
  ld h, HIGH(oam_buffer);buffer is page aligned to $XX00
  ld [hl], d;props
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
  and a, LCDCF_ON
  ret z; return if screen is off
  xor a
  ldh [vbl_done], a;clear stale data
.loop
    halt; wait for any interrupt
    nop; halt sometimes skips the next instruction
    ldh a, [vbl_done]  ; was it a vblank interrupt?
    ; warning: we may lose a vblank interrupt if it occurs now
    and a
    jr z, .loop; no: back to sleep!
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
  push hl ;wh
  ldh a, [rLCDC]
  bit LCDCB_WIN9C00, a
  ld hl, _SCRN0
  jr z, gbdk_CopyTilesTo
  ld hl,_SCRN1
  jr gbdk_CopyTilesTo


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
  push hl ;wh
  ldh a, [rLCDC]
  bit LCDCB_BG9C00, a
  ld hl, _SCRN0
  jr z, gbdk_CopyTilesTo
  ld hl, _SCRN1
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
gbdk_CopyTilesTo:
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
  push hl ;wh
  ldh a, [rLCDC]
  bit LCDCB_WIN9C00, a
  ld hl, _SCRN0
  jr z, gbdk_CopyTilesFrom
  ld hl,_SCRN1
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
  bit LCDCB_BG9C00, a
  ld hl, _SCRN0
  jr z, gbdk_CopyTilesFrom
  ld hl, _SCRN1
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
; registers used: af, bc, de
;***************************************************************************
gbdk_Delay::
  DEF _CPMS EQU 4194/4  ; 4.194304 MHz
  ldh a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .cpuSlow
.checkFast
  ldh a,[rKEY1]
  and a, KEY1F_DBLSPEED
  jr z, .cpuSlow
.cpuFast
  ld bc, (2*_CPMS)/7
  jr .loop
.cpuSlow
  ld bc, _CPMS/7         ; 3 cycles
.loop
    dec bc                 ; 2 cycles
    ld a, b                ; 1 cycle
    or c                   ; 1 cycle
    jr nz, .loop           ; 3 cycles (2 when false)

  dec de                 ; 2 cycles
  ld a, d                ; 1 cycle
  or e                   ; 1 cycle
  jr nz, gbdk_Delay      ; 3 cycles
  ret                    ; 4 cycles

;***************************************************************************
;
; gbdk_CPUSlow - Sets GameBoy Color to DMG speed
;
;***************************************************************************
gbdk_CPUSlow::
  ldh a,[rKEY1]
  and a, KEY1F_DBLSPEED
  ret z

shift_speed:
  ldh a,[rIE]
  push af

  xor a
  ldh [rIE], a
  ldh [rIF], a

  ld a, P1F_GET_NONE
  ldh [rP1], a

  ld a, KEY1F_PREPARE
  ldh [rKEY1], a

  stop

  pop af
  ldh [rIE], a

  ret

;***************************************************************************
;
; gbdk_CPUFast - Sets GameBoy Color to double speed mode
;
;***************************************************************************
gbdk_CPUFast::
  ldh a, [rKEY1]
  and KEY1F_DBLSPEED
  ret nz
  jr shift_speed


;Copy the sprite DMA routine to HRAM.
gbdk_SetupDMATransfer::
  COPY_TO_HRAM gbdk_DMATransfer, .DMATransfer, .DMATransferEnd
  ret

.DMATransfer
  ld a, HIGH(oam_buffer)
  ldh [rDMA], a
  ld a, OAM_COUNT
.wait
  dec a
  jr nz, .wait
  ret
.DMATransferEnd

DEF DMA_SIZE EQU (.DMATransferEnd - .DMATransfer)

SECTION "GBDK HRAM Vars", HRAM
gbdk_DMATransfer:: DS DMA_SIZE
vbl_done:: DB
sys_info:: DB

ENDC ;GBDK_ASM
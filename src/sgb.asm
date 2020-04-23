; Super Game Boy development (step by step)
; Made by Imanol Barriuso (Imanolea) for Games aside
; https://imanoleasgames.blogspot.com/2016/12/games-aside-1-super-game-boy.html

; Super Game boy command packets definition
INCLUDE "src/memory1.asm"

MLT_REQ: MACRO
  DB ($11 << 3) + 1
  DB \1 - 1
  DS 14
ENDM

CHR_TRN: MACRO
  DB ($13 << 3) + 1
  DB \1 + (\2 << 1)
  DS 14
ENDM

PCT_TRN: MACRO
  DB ($14 << 3) + 1
  DS 15
ENDM

PAL_SET: MACRO
  DB ($A << 3) + 1
  DW \1, \2, \3, \4
  DS 7
ENDM

PAL_TRN: MACRO
  DB ($B<< 3) + 1
  DS 15
ENDM

MASK_EN: MACRO
  DB ($17 << 3) + 1
  DB \1
  DS 14
ENDM

RGB: MACRO
  DW (\3 << 10 | \2 << 5 | \1)
ENDM

SECTION "Super GameBoy", ROMX, BANK[SGB_BANK]

; Super Game Boy frame tiles
SGBBorderTiles::
INCLUDE "src/sgb/sgb_tileset.z80"
EndSGBBorderTiles::
; Super Game Boy frame
SGBBorder::
INCLUDE "src/sgb/sgbborder.z80"
EndSGBBorder::

; We assign the first palette (0) to the four palettes that are available for the game graphics
PalSet:: PAL_SET 0, 0, 0, 0

MltReqTwoPlayers:: MLT_REQ 2
MltReqOnePlayer:: MLT_REQ 1
; First 128 tile block transfer
ChrTrn1:: CHR_TRN 0, 0
; Second 128 tile block transfer
ChrTrn2:: CHR_TRN 1, 0
PctTrn:: PCT_TRN
PalTrn:: PAL_TRN
MaskEnFreeze: MASK_EN 1
MaskEnCancel: MASK_EN 0

; Initialization packets extracted from the official documentation
DataSnd0:: DB $79, $5D, $08, $00, $0B, $8C, $D0, $F4, $60, $00, $00, $00, $00, $00, $00, $00
DataSnd1:: DB $79, $52, $08, $00, $0B, $A9, $E7, $9F, $01, $C0, $7E, $E8, $E8, $E8, $E8, $E0
DataSnd2:: DB $79, $47, $08, $00, $0B, $C4, $D0, $16, $A5, $CB, $C9, $05, $D0, $10, $A2, $28
DataSnd3:: DB $79, $3C, $08, $00, $0B, $F0, $12, $A5, $C9, $C9, $C8, $D0, $1C, $A5, $CA, $C9
DataSnd4:: DB $79, $31, $08, $00, $0B, $0C, $A5, $CA, $C9, $7E, $D0, $06, $A5, $CB, $C9, $7E
DataSnd5:: DB $79, $26, $08, $00, $0B, $39, $CD, $48, $0C, $D0, $34, $A5, $C9, $C9, $80, $D0
DataSnd6:: DB $79, $1B, $08, $00, $0B, $EA, $EA, $EA, $EA, $EA, $A9, $01, $CD, $4F, $0C, $D0
DataSnd7:: DB $79, $10, $08, $00, $0B, $4C, $20, $08, $EA, $EA, $EA, $EA, $EA, $60, $EA, $EA

SGBSuperPalettes::
  ; Default palette
  RGB 27, 31, 31
  RGB 22, 19, 31
  RGB 21,  7, 15
  RGB  1,  1,  4

; Super Game Boy initialization
SGBInit::
  call check_sgb
  ret nc ; We return if the game is not running on a Super Game Boy
  di
  ld hl, MaskEnFreeze
  call  sgbpackettransfer ; Freezes the visualization of the Super Game Boy screen to hide the graphic garbage during the VRAM transfers
  call init_sgb_default ; 8 initialization data packet sending, according to the official documentation
  xor a
  ld de, ChrTrn1
  ld hl, SGBBorderTiles
  call copysnes ; Copies to SNES RAM the first 128 tiles of the frame (256 Game Boy tiles)
  xor a
  ld de, ChrTrn2
  ld hl, SGBBorderTiles + 4096
  call copysnes ; Copies to SNES RAM the second 128 tiles of the frame (256 Game Boy tiles)
  xor a
  ld de, PctTrn
  ld hl, SGBBorder
  call copysnes ; Copies to SNES RAM the frame map
  xor a
  ld de, PalTrn
  ld hl, SGBSuperPalettes
  call copysnes ; Copies to SNES RAM the custom game palettes
  ; VRAM reset
  ld hl, _VRAM
  ld bc, $2000
  xor a
  call mem_Set
  ; Default game palette set
  ld hl, PalSet
  call sgbpackettransfer
  ld hl, MaskEnCancel
  call sgbpackettransfer ; Super Game Boy screen visualization unfreezing
  ret

; @output   Carry: Flag raised if the system in which the game is running is a Super Game Boy
check_sgb:
  di
  ld  hl, MltReqTwoPlayers ; Two player mode selection
  call  sgbpackettransfer
  ei
  ld a, P1F_4 | P1F_5
  ld [rP1], a ; We disable key and pad reading to read the joypad id
  ld a, [rP1]
  ld a, [rP1]
  ld a, [rP1]
  ld a, [rP1]                ; Many readings to avoid the "bouncing" of values
  ld b, a ; We store the id of the first joypad
  ; Joypad reading simulation
  ld a, P1F_5
  ld [rP1], a ; Pad reading activated
  ld a, P1F_4
  ld [rP1], a ; Key reading activated
  ld a, P1F_4 | P1F_5
  ld [rP1], a ; We disable key and pad reading to read the next joypad id
  ld a, [rP1]
  ld a, [rP1]
  ld a, [rP1]
  ld a, [rP1]
  cp b ; If the id is the same then there has not been reply to the two player mode request, and therefore we are not in a Super Game Boy
  jr nz, check_sgb_0
  and a ; We lower the carry flag
  ret ; We are not in a Super Game Boy
check_sgb_0:
  ld  hl, MltReqOnePlayer
  call  sgbpackettransfer ; We return to one player mode
  scf ; We raise the carry flag
  ret ; We are in a Super Game Boy

; We send the 8 default initialization data packets specified in the official documentation
init_sgb_default:
  ld hl, DataSnd0
  call sgbpackettransfer
  ld hl, DataSnd1
  call sgbpackettransfer
  ld hl, DataSnd2
  call sgbpackettransfer
  ld hl, DataSnd3
  call sgbpackettransfer
  ld hl, DataSnd4
  call sgbpackettransfer
  ld hl, DataSnd5
  call sgbpackettransfer
  ld hl, DataSnd6
  call sgbpackettransfer
  ld hl, DataSnd7
  call sgbpackettransfer
  ret

; Copies data to the SNES RAM
; @input    DE: Packet data
; @input    HL: Graphical data address
; @input    A: Flag that indicates if we are copying 2bpp tile data
copysnes:
  di
  push de
  push af;2bpp flag
  DISPLAY_OFF ; We disble interruptions and turn off the LCD because we are going to modify the VRAM data
  ld a, %11100100
  ld [rBGP], a ; VRAM-transfer background palette value
  ld de, _VRAM + 2048
  pop af;2bpp flag
  and a
  jr z, .copysnes_0
  call parsesgbbordertiles ; Turns the 2bpp graphics into 4bpp
  jr .copysnes_1
.copysnes_0:
  ld bc, 4096
  call mem_Copy ; We copy to the Game Boy VRAM the 4KB data that is going to be transferred to the SNES RAM
.copysnes_1:
  ; We copy to the visible _SCRN0 background the 4KB data that is going to be transferred to the SNES RAM by VRAM-transfer
  ld hl, _SCRN0
  ld de, 12 ; Background additional width
  ld a, $80 ; VRAM address of the first tile
  ld c, 13 ; Rows of data to be copied
.copysnes_2:
  ld b, 20 ; Visible background width
.copysnes_3:
  ld [hli], a ; Tile set
  inc a
  dec b
  jr nz, .copysnes_3
  add hl, de ; Next visible background tile row
  dec c
  jr nz, .copysnes_2
  ld a, LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON|LCDCF_WIN9C00|LCDCF_WINON
  ld [rLCDC], a ; We turn on the LCD so the transfer can be made
  pop hl ; Packet definition
  call sgbpackettransfer ; We send the packet that will produce the transfer
  xor a
  ld [rBGP], a ; We restore the background palette
  ret

; Turns the 2bbp graphics pointed by HL to 4bpp and stores them in the address pointed by DE
parsesgbbordertiles:
  ld b, 128
.parsesgbbordertiles_0:
  ; We copy the data of the 1 and 2 bit planes of the tiles
  ld c, 16
.parsesgbbordertiles_1:
  ld a, [hli]
  ld [de], a
  inc de
  dec c
  jr nz, .parsesgbbordertiles_1
  ; The 3 and 4 bit planes are set to zero
  ld c, 16
  xor a
.parsesgbbordertiles_2:
  ld [de], a
  inc de
  dec c
  jr nz, .parsesgbbordertiles_2
  dec b
  jr nz, .parsesgbbordertiles_0
  ret

; Super Game Boy packet transfer
; @entrada HL: Packet address
sgbpackettransfer:
  ld a, [hl]
  and %00000111 ; The three lower bits indicate the number of packets to send
  ret z ; We return if there are no packets to send
  ld b, a ; We store the number of packets to send
.sgbpackettransfer_0:
  push bc
  xor a
  ld [rP1], a ; Initial pulse (Start write). P14 = LOW and P15 = LOW
  ld a, P1F_4 | P1F_5
  ld [rP1], a ; P14 = HIGH and P15 = HIGH between pulses
  ld b, 16 ; Number of bytes per packet
.sgbpackettransfer_1:
  ld e, 8 ; Bits per byte
  ld a, [hli]
  ld d, a ; Next byte of the packet
.sgbpackettransfer_2:
  bit 0, d
  ld a, P1F_4 ; P14 = HIGH and P15 = LOW (Write 1)
  jr nz, .sgbpackettransfer_3
  ld a, P1F_5 ; P14 = LOW and P15 = HIGH (Write 0)
.sgbpackettransfer_3:
  ld [rP1], a ; We send one bit
  ld a, P1F_4 | P1F_5
  ld [rP1], a ; P14 = HIGH and P15 = HIGH between pulses
  rr d ; We rotate the register so that the next bit goes to position 0
  dec e
  jr nz, .sgbpackettransfer_2; We jump while there are bits left to be sent
  dec b
  jr nz, .sgbpackettransfer_1; We jump while there are bytes left to be sent
  ld a, P1F_5
  ld [rP1], a ; Bit 129, stop bit (Write 0)
  ld a, P1F_4 | P1F_5
  ld [rP1], a ; P14 = HIGH and P15 = HIGH between pulses
  call sgbpackettransfer_wait ; 280048 clock cycles are consumed (66.768646240234375 milliseconds) at 4.194304 mhz | 24 cycles
  pop bc
  dec b
  ret z
  jr .sgbpackettransfer_0 ; We jump while there are packets left to be sent

; 280024 clock cycles are consumed
sgbpackettransfer_wait:
  ld de, 7000 ; 12 cycles
.sgbpackettransfer_wait_0:
  nop ; 4 cycles
  nop ; 4 cycles
  nop ; 4 cycles
  dec de ; 8 cycles
  ld a, d ; 4 cycles
  or e ; 4 cycles
  jr nz, .sgbpackettransfer_wait_0 ; 12 cycles if jumps, 8 if not
  ret ; 16 cycles

;Super Game Boy display initialization and border transfers.
;Based on code by Imanol Barriuso and Martin Ahrnbom.
INCLUDE "src/hardware.inc"
INCLUDE "src/memory1.asm"

DEF SGB_CODE_PAL_SET  EQU $0A ;Set SGB Palette Indirect
DEF SGB_CODE_PAL_TRN  EQU $0B ;Set System Color Palette Data
DEF SGB_CODE_TEST_EN  EQU $0D ;Speed Function (unavailable)
DEF SGB_CODE_CHR_TRN  EQU $13 ;Transfer Character Font Data
DEF SGB_CODE_PCT_TRN  EQU $14 ;Set Screen Data Color Data
DEF SGB_CODE_MASK_EN  EQU $17 ;Game Boy Window Mask
DEF SGB_CODE_OBJ_TRN  EQU $18 ;SNES OBJ Mode (unavailable)
DEF SGB_CODE_PAL_PRI  EQU $19 ;System palette priority

MACRO SGB_HEADER ;\1 = code, \2 = num packets
  DB (\1 << 3) + \2
ENDM

MACRO PAL_SET ;\1 = Pal0, \2 = Pal1, \3 = Pal2, \4 = Pal3
  SGB_HEADER SGB_CODE_PAL_SET, 1
  DW \1, \2, \3, \4
  DS 7
ENDM

MACRO PAL_TRN
  SGB_HEADER SGB_CODE_PAL_TRN, 1
  DS 15
ENDM

MACRO CHR_TRN ;\1 = tile table (0=$00-$7F, 1=$80-$FF), \2 = tile type (0=BG, 1=OBJ)
  SGB_HEADER SGB_CODE_CHR_TRN, 1
  DB \1 | (\2 << 1)
  DS 14
ENDM

MACRO PCT_TRN
  SGB_HEADER SGB_CODE_PCT_TRN, 1
  DS 15
ENDM

MACRO MASK_EN ;\1 = screen mask (0=cancel,1=freeze)
  SGB_HEADER SGB_CODE_MASK_EN, 1
  DB \1
  DS 14
ENDM

MACRO PAL_RPI ;\1 = priority (0=user,1=game)
  SGB_HEADER SGB_CODE_PAL_PRI, 1
  DB \1
  DS 14
ENDM

SECTION "Super GameBoy Banked", ROMX

INCLUDE "img/default_sgb_border.asm"

; Initialization packets extracted from the official documentation
DataSnd0: DB $79, $5D, $08, $00, $0B, $8C, $D0, $F4, $60, $00, $00, $00, $00, $00, $00, $00
DataSnd1: DB $79, $52, $08, $00, $0B, $A9, $E7, $9F, $01, $C0, $7E, $E8, $E8, $E8, $E8, $E0
DataSnd2: DB $79, $47, $08, $00, $0B, $C4, $D0, $16, $A5, $CB, $C9, $05, $D0, $10, $A2, $28
DataSnd3: DB $79, $3C, $08, $00, $0B, $F0, $12, $A5, $C9, $C9, $C8, $D0, $1C, $A5, $CA, $C9
DataSnd4: DB $79, $31, $08, $00, $0B, $0C, $A5, $CA, $C9, $7E, $D0, $06, $A5, $CB, $C9, $7E
DataSnd5: DB $79, $26, $08, $00, $0B, $39, $CD, $48, $0C, $D0, $34, $A5, $C9, $C9, $80, $D0
DataSnd6: DB $79, $1B, $08, $00, $0B, $EA, $EA, $EA, $EA, $EA, $A9, $01, $CD, $4F, $0C, $D0
DataSnd7: DB $79, $10, $08, $00, $0B, $4C, $20, $08, $EA, $EA, $EA, $EA, $EA, $60, $EA, $EA

; Super Game boy command packets
sgb_PalSetDefault:    PAL_SET 0, 0, 0, 0

; Super Game Boy initialization
sgb_Init::
  ldh a, [sys_info]
  and a, SYS_INFO_SGB
  ret z

  di
  DISPLAY_OFF
  call sgb_SendInitPackets        ; 8 initialization data packet sending, according to the official documentation

.success
  ld hl, sgb_MaskEnFreeze
  call  _sgb_PacketTransfer       ; Freezes the visualization of the Super Game Boy screen to hide the graphic garbage during the VRAM transfers  

  ld de, sgb_ChrTrn1
  ld hl, DefaultSgbBorderTiles
  call _sgb_VRAMTransfer          ; Copies first 128 tiles of the frame (256 Game Boy tiles) to SNES RAM

  ld de, sgb_ChrTrn2
  ld hl, DefaultSgbBorderTiles+$1000
  call _sgb_VRAMTransfer          ; Copies second 128 tiles of the frame (256 Game Boy tiles) SNES RAM

  ld de, sgb_PctTrn
  ld hl, DefaultSgbBorderTileMap
  call _sgb_VRAMTransfer          ; Copies frame map to SNES RAM 

  ld de, sgb_PalTrn
  ld hl, DefaultPalettes
  call _sgb_VRAMTransfer          ; Copies editor palettes to SNES RAM

  ld hl, sgb_PalSetDefault               
  call _sgb_PacketTransfer        ; Default editor palette set

  ld hl, sgb_PalPriGame
  call _sgb_PacketTransfer        ; override user palettes

  ld hl, sgb_MaskEnCancel
  call _sgb_PacketTransfer        ; Super Game Boy screen visualization unfreezing
  reti

sgb_SendInitPackets:
  ld hl, DataSnd0
  call _sgb_PacketTransfer
  ld hl, DataSnd1
  call _sgb_PacketTransfer
  ld hl, DataSnd2
  call _sgb_PacketTransfer
  ld hl, DataSnd3
  call _sgb_PacketTransfer
  ld hl, DataSnd4
  call _sgb_PacketTransfer
  ld hl, DataSnd5
  call _sgb_PacketTransfer
  ld hl, DataSnd6
  call _sgb_PacketTransfer
  ld hl, DataSnd7
  call _sgb_PacketTransfer
  ret

SECTION "Super GameBoy Main", ROM0

; Super Game boy command packets
sgb_ChrTrn1:      CHR_TRN 0, 0 ; First 128 tile block transfer
sgb_ChrTrn2:      CHR_TRN 1, 0 ; Second 128 tile block transfer
sgb_PctTrn:       PCT_TRN
sgb_PalTrn:       PAL_TRN
sgb_MaskEnFreeze: MASK_EN 1
sgb_MaskEnCancel: MASK_EN 0
sgb_PalPriGame:   PAL_RPI 1

; Copies data from GB VRAM to SNES RAM
; input: DE = Packet data
;        HL = Graphical data address
sgb_VRAMTransfer::
  ldh a, [sys_info]
  and a, SYS_INFO_SGB
  ret z
_sgb_VRAMTransfer:
  ; store screen state
  di
  ldh a, [rLCDC]
  push af
  ldh a, [rSCX]
  push af
  ldh a, [rSCY]
  push af
  ldh a, [rBGP]
  push af

  push de                     ; packet data
  DISPLAY_OFF                 ; We disble interruptions and turn off the LCD because we are going to modify the VRAM data
  xor a
  ldh [rSCX], a
  ldh [rSCY], a
  ld a, %11100100
  ldh [rBGP], a                ; VRAM-transfer background palette value
  ld de, _VRAM + 2048
  ld bc, 4096
  call mem_Copy               ; We copy to the Game Boy VRAM the 4KB data that is going to be transferred to the SNES RAM

  ; We copy to the visible _SCRN0 background the 4KB data that is going to be transferred to the SNES RAM by VRAM-transfer
  ld hl, _SCRN0
  ld de, 12                   ; Background additional width
  ld a, $80                   ; VRAM address of the first tile
  ld c, 13                    ; Rows of data to be copied
.rowLoop:
    ld b, 20                  ; Visible background width
  .columnLoop:
      ld [hli], a             ; Tile set
      inc a
      dec b
      jr nz, .columnLoop
    add hl, de                ; Next visible background tile row
    dec c
    jr nz, .rowLoop

  ld a, LCDCF_ON | LCDCF_BGON
  ldh [rLCDC], a

  pop hl                      ; Packet data
  call _sgb_PacketTransfer    ; We send the packet that will produce the transfer

  ;restore screen state
  pop af
  ldh [rBGP], a
  pop af
  ldh [rSCX], a
  pop af
  ldh [rSCY], a
  pop af
  ldh [rLCDC], a
  reti

; Super Game Boy packet transfer
; input: HL = Packet address
sgb_PacketTransfer::
  ldh a, [sys_info]
  and a, SYS_INFO_SGB
  ret z
_sgb_PacketTransfer:
  ld a, [hl]
  and %00000111               ; The three lower bits indicate the number of packets to send
  ret z                       ; We return if there are no packets to send
  ld b, a                     ; We store the number of packets to send

  ld a, [hl]
  rra
  rra
  rra
  and %00011111
  cp a, SGB_CODE_PAL_PRI+1        ;last code available
  ret nc
  cp a, SGB_CODE_OBJ_TRN
  ret z
  cp a, SGB_CODE_TEST_EN
  ret z
.sendPacketsLoop
    push bc
    xor a
    ldh [rP1], a               ; Initial pulse (Start write). P14 = LOW and P15 = LOW
    ld a, P1F_4 | P1F_5
    ldh [rP1], a               ; P14 = HIGH and P15 = HIGH between pulses
    ld b, 16                  ; Number of bytes per packet
  .sendBytesLoop
      ld e, 8                 ; Bits per byte
      ld a, [hli]
      ld d, a                 ; Next byte of the packet
    .sendBitsLoop
        bit 0, d
        ld a, P1F_4           ; P14 = HIGH and P15 = LOW (Write 1)
        jr nz, .skip
        ld a, P1F_5           ; P14 = LOW and P15 = HIGH (Write 0)
      .skip
        ldh [rP1], a           ; We send one bit
        ld a, P1F_4 | P1F_5
        ldh [rP1], a           ; P14 = HIGH and P15 = HIGH between pulses
        rr d                  ; We rotate the register so that the next bit goes to position 0
        dec e
        jr nz, .sendBitsLoop  ; We jump while there are bits left to be sent
      dec b
      jr nz, .sendBytesLoop   ; We jump while there are bytes left to be sent
    ld a, P1F_5
    ldh [rP1], a               ; Bit 129, stop bit (Write 0)
    ld a, P1F_4 | P1F_5
    ldh [rP1], a               ; P14 = HIGH and P15 = HIGH between pulses

    ; 280048 clock cycles are consumed (66.768646240234375 milliseconds) at 4.194304 mhz | 24 cycles
    ld de, 7000               ; 12 cycles
.wait24Cycles
      nop                     ; 4 cycles
      nop                     ; 4 cycles
      nop                     ; 4 cycles
      dec de                  ; 8 cycles
      ld a, d                 ; 4 cycles
      or e                    ; 4 cycles
      jr nz, .wait24Cycles    ; 12 cycles if jumps, 8 if not

    pop bc
    dec b
    jr nz, .sendPacketsLoop       ; We jump while there are packets left to be sent
  ret

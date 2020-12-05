; Super Game Boy
;
;   based on code from Imanol Barriuso (Imanolea) - https://imanoleasgames.blogspot.com/2016/12/games-aside-1-super-game-boy.html
;                    and Martin Ahrnbom (ahrnbom) - https://github.com/ahrnbom/gingerbread
;

INCLUDE "src/hardware.inc"
INCLUDE "src/memory1.asm"

; Bank SGB_BANK Subroutines:
;   sgb_Init
;     Checks to see if game is running on SGB, and updates sys_info.
;     Sends initialization packet to SNES. Sets default palette and border.

; Bank 0 Subroutines:
;   sgb_SetDefaultBorder
;     Sets the default Super Game Boy border.
;   sgb_SetBorder
;     Sets the Super Game Boy border.
;     Input: a = bank, hl = tiles, de = tile map
;   sgb_SetPal
;     Directly sets 2 SNES palettes. Packet can only be codes 0-3.
;     Input: a = packet header, bc = paletteA, de = paletteB
;   sgb_SetBlock
;     Indirectly sets inside of screen block to palette b, border to palette c.
;     Input: bc = palette indices, de = xy, hl = wh
;   sgb_VRAMTransfer
;     Copies data to GB VRAM then to SNES.
;     Input: de = packet, hl = graphical data
;   sgb_PacketTransfer
;     Transfers data to SNES.
;     Input: hl = packet address

; Super Game boy command packets definitions
;  Code  Name      Expl.
;  $00   PAL01     Set SGB Palette 0,1 Data
;  $01   PAL23     Set SGB Palette 2,3 Data
;  $02   PAL03     Set SGB Palette 0,3 Data
;  $03   PAL12     Set SGB Palette 1,2 Data
;  $04   ATTR_BLK  "Block" Area Designation Mode
;  $05   ATTR_LIN  "Line" Area Designation Mode
;  $06   ATTR_DIV  "Divide" Area Designation Mode
;  $07   ATTR_CHR  "1CHR" Area Designation Mode
;  $08   SOUND     Sound On/Off
;  $09   SOU_TRN   Transfer Sound PRG/DATA
;  $0A   PAL_SET   Set SGB Palette Indirect
;  $0B   PAL_TRN   Set System Color Palette Data
;  $0C   ATRC_EN   Enable/disable Attraction Mode
;  $0D   TEST_EN   Speed Function
;  $0E   ICON_EN   SGB Function
;  $0F   DATA_SND  SUPER NES WRAM Transfer 1
;  $10   DATA_TRN  SUPER NES WRAM Transfer 2
;  $11   MLT_REG   Controller 2 Request
;  $12   JUMP      Set SNES Program Counter
;  $13   CHR_TRN   Transfer Character Font Data
;  $14   PCT_TRN   Set Screen Data Color Data
;  $15   ATTR_TRN  Set Attribute from ATF
;  $16   ATTR_SET  Set Data to ATF
;  $17   MASK_EN   Game Boy Window Mask
;  $18   OBJ_TRN   Super NES OBJ Mode

SGB_PACKET: MACRO ;\1 = code, \2 = num packets
  db (\1 << 3) + \2
ENDM

ATTR_BLK: MACRO ;\1 = num packets
  SGB_PACKET $4, ((\1 * 6)/16) + 1
	db \1
ENDM

ATTR_BLK_PACKET: MACRO ;\1 = control code, \2\3\4 = palettes, \5\6 = xy, \7\8 = wh
	db \1 ;bit 2 = outside block, bit 1 = on border, bit 0 = inisde block
	db (\2 << 4) + (\3 << 2) + \4 ;\2 = outside, \3 = border, \4 = inside
	db \5, \6, \5+\7-1, \6+\8-1
ENDM

MLT_REQ: MACRO ;\1 = player count
  SGB_PACKET $11, 1
  db \1 - 1
  ds 14
ENDM

CHR_TRN: MACRO ;\1 = tile table (0=$00-$7F, 1=$80-$FF), \2 = tile type (0=BG, 1=OBJ)
  SGB_PACKET $13, 1
  db \1 + (\2 << 1)
  ds 14
ENDM

PCT_TRN: MACRO
  SGB_PACKET $14, 1
  ds 15
ENDM

PAL_SET: MACRO ;\1 = Pal0, \2 = Pal1, \3 = Pal2, \4 = Pal3
  SGB_PACKET $0A, 1
  dw \1, \2, \3, \4
  ds 7
ENDM

PAL_TRN: MACRO
  SGB_PACKET $0B, 1
  ds 15
ENDM

MASK_EN: MACRO ;\1 = screen mask (0=cancel,1=freeze)
  SGB_PACKET $17, 1
  db \1
  ds 14
ENDM 

SECTION "Super GameBoy Banked", ROMX, BANK[SGB_BANK]

IF DEF(_HOME)
INCLUDE "img/home_version/home_version_sgb_border.asm"
ELSE
INCLUDE "img/away_version/away_version_sgb_border.asm"
ENDC

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
sgb_PalSetDefault:    PAL_SET PALETTE_CALVIN, PALETTE_GREY, PALETTE_UI, PALETTE_SEPIA
sgb_MltReqTwoPlayers: MLT_REQ 2
sgb_MltReqOnePlayer:  MLT_REQ 1

; Super Game Boy initialization
sgb_Init::
  call sgb_Check
  ret nc                         ; We return if the game is not running on a Super Game Boy
  
  ld a, [sys_info]
  or a, SYS_INFO_SGB
  ld [sys_info], a

  call sgb_SendInitPackets       ; 8 initialization data packet sending, according to the official documentation

  di
  ld hl, sgb_MaskEnFreeze
  call  _sgb_PacketTransfer       ; Freezes the visualization of the Super Game Boy screen to hide the graphic garbage during the VRAM transfers  

  ld de, sgb_ChrTrn1
  ld hl, VersionSgbBorderTiles
  call _sgb_VRAMTransfer          ; Copies first 128 tiles of the frame (256 Game Boy tiles) to SNES RAM

  ld de, sgb_ChrTrn2
  ld hl, VersionSgbBorderTiles+$1000
  call _sgb_VRAMTransfer          ; Copies second 128 tiles of the frame (256 Game Boy tiles) SNES RAM

  ld de, sgb_PctTrn
  ld hl, VersionSgbBorderTileMap
  call _sgb_VRAMTransfer          ; Copies frame map to SNES RAM 

  ld de, sgb_PalTrn
  ld hl, DefaultPalettes
  call _sgb_VRAMTransfer          ; Copies custom game palettes to SNES RAM

  ld hl, sgb_PalSetDefault               
  call _sgb_PacketTransfer        ;Default game palette set

  ld hl, sgb_MaskEnCancel
  call _sgb_PacketTransfer        ; Super Game Boy screen visualization unfreezing
  reti

; Carry Flag raised if the system in which the game is running is a Super Game Boy
sgb_Check:
  di
  ld  hl, sgb_MltReqTwoPlayers   ; Two player mode selection
  call  _sgb_PacketTransfer
  ei
  ld a, P1F_4 | P1F_5
  ld [rP1], a                    ; We disable key and pad reading to read the joypad id
  ld a, [rP1]
  ld a, [rP1]
  ld a, [rP1]
  ld a, [rP1]                    ; Many readings to avoid the "bouncing" of values
  ld b, a                        ; We store the id of the first joypad
  
  ; Joypad reading simulation
  ld a, P1F_5
  ld [rP1], a                    ; Pad reading activated
  ld a, P1F_4
  ld [rP1], a                    ; Key reading activated
  ld a, P1F_4 | P1F_5
  ld [rP1], a                    ; We disable key and pad reading to read the next joypad id
  ld a, [rP1]
  ld a, [rP1]
  ld a, [rP1]
  ld a, [rP1]
  cp b                           ; If the id is the same then there has not been reply to the two-
  jr nz, check_sgb_0             ; player mode request, and therefore we are not in a Super Game Boy
  and a                          ; We lower the carry flag
  ret                            ; We are not in a Super Game Boy
check_sgb_0:
  ld  hl, sgb_MltReqOnePlayer
  call  _sgb_PacketTransfer       ; We return to one player mode
  scf                            ; We raise the carry flag
  ret                            ; We are in a Super Game Boy

; We send the 8 default initialization data packets specified in the official documentation
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
sgb_Pal01:        SGB_PACKET $00, 1
sgb_Pal23:        SGB_PACKET $01, 1
sgb_Pal03:        SGB_PACKET $02, 1
sgb_Pal12:        SGB_PACKET $03, 1
sgb_ChrTrn1:      CHR_TRN 0, 0 ; First 128 tile block transfer
sgb_ChrTrn2:      CHR_TRN 1, 0 ; Second 128 tile block transfer
sgb_PctTrn:       PCT_TRN
sgb_PalTrn:       PAL_TRN
sgb_MaskEnFreeze: MASK_EN 1
sgb_MaskEnCancel: MASK_EN 0

sgb_SetDefaultBorder::
  ld a, SGB_BANK
  ld hl, VersionSgbBorderTiles
  ld de, VersionSgbBorderTileMap
sgb_SetBorder:: ;a = bank, hl = tiles, de = tile map
  ld b, a;bank
  ld a, [sys_info]
  and a, SYS_INFO_SGB
  ret z

  di
  ld a, [loaded_bank]
  push af;old bank
  ld a, b;new bank
  push de;tile map
  push hl;tiles
  call SetBank

  ld hl, sgb_MaskEnFreeze
  call  _sgb_PacketTransfer      ; Freezes the visualization of the Super Game Boy screen to hide the graphic garbage during the VRAM transfers

  pop hl;tiles
  push hl;tiles
  ld de, sgb_ChrTrn1
  call _sgb_VRAMTransfer          ; Copies first 128 tiles of the frame (256 Game Boy tiles) to SNES RAM

  ld de, sgb_ChrTrn2
  pop hl;tiles
  ld bc, $1000
  add hl, bc
  call _sgb_VRAMTransfer          ; Copies second 128 tiles of the frame (256 Game Boy tiles) SNES RAM

  ld de, sgb_PctTrn
  pop hl;tile map
  call _sgb_VRAMTransfer          ; Copies frame map to SNES RAM 

  ld hl, sgb_MaskEnCancel
  call _sgb_PacketTransfer       ; Super Game Boy screen visualization unfreezing

  pop af;old bank
  call SetBank
  reti

sgb_SetPal:: ;a = packet header, bc = paletteA, de = paletteB
  ld hl, tile_buffer
  ld [hli], a

  ld a, [sys_info]
  and a, SYS_INFO_SGB
  ret z

  push de;paletteB
  push bc;paletteA
  pop hl;paletteA
  ld de, tile_buffer+1
  ld bc, 8
  call mem_Copy

  pop hl;paletteB
  inc hl
  inc hl
  ld de, tile_buffer+9
  ld bc, 6
  call mem_Copy

  xor a
  ld [hli], a

  ld hl, tile_buffer
  call _sgb_PacketTransfer

  ret

; Indirectly sets inside of screen block to palette b, border to palette c.
; Input: bc = palettes, de = xy, hl = wh
sgb_SetBlock::
  ld a, [sys_info]
  and a, SYS_INFO_SGB
  ret z

  push hl;wh
  push de;xy
  push bc;palettes

  ld hl, tile_buffer

  ld a, ($4 << 3) + 1;ATTR_BLK
  ld [hli], a

  ld a, 1;num blocks
  ld [hli], a

  ld a, %011;control code
  ld [hli], a

  pop bc;palettes
  sla c
  sla c
  ld a, b
  add a, c;palA + palB<<2
  sla c
  sla c
  add a, c;palA + palB<<2 + palB<<4
  ld [hli], a

  pop de;xy
  pop bc;wh

  ld a, d
  ld [hli], a;x
  add a, b;x+w
  ld d, a;x+w

  ld a, e
  ld [hli], a;y
  add a, c;y+h
  ld e, a;y+h

  ld a, d;x+w
  ld [hli], a

  ld a, e;y+h
  ld [hl], a
  
  ld hl, tile_buffer
  jp _sgb_PacketTransfer

; Copies data from GB VRAM to SNES RAM
; input: DE = Packet data
;        HL = Graphical data address
sgb_VRAMTransfer::
  ld a, [sys_info]
  and a, SYS_INFO_SGB
  ret z
_sgb_VRAMTransfer:
  ; store screen state
  ld a, [rLCDC]
  push af
  ld a, [rSCX]
  push af
  ld a, [rSCY]
  push af
  ld a, [rBGP]
  push af

  di
  push de                     ; packet data
  DISPLAY_OFF                 ; We disble interruptions and turn off the LCD because we are going to modify the VRAM data
  xor a
  ld [rSCX], a
  ld [rSCY], a
  ld a, %11100100
  ld [rBGP], a                ; VRAM-transfer background palette value
  ld de, _VRAM + 2048
  ld bc, 4096
  call mem_CopyVRAM           ; We copy to the Game Boy VRAM the 4KB data that is going to be transferred to the SNES RAM

  ; We copy to the visible _SCRN0 background the 4KB data that is going to be transferred to the SNES RAM by VRAM-transfer
  ld hl, _SCRN0
  ld de, 12                   ; Background additional width
  ld a, $80                   ; VRAM address of the first tile
  ld c, 13                    ; Rows of data to be copied
.rowLoop:
    ld b, 20                  ; Visible background width
.columnLoop:
      push af
      LCD_WAIT_VRAM
      pop af
      ld [hli], a             ; Tile set
      inc a
      dec b
      jr nz, .columnLoop
    add hl, de                ; Next visible background tile row
    dec c
    jr nz, .rowLoop

  ld a, LCDCF_ON | LCDCF_BGON
  ld [rLCDC], a

  pop hl                      ; Packet data
  call _sgb_PacketTransfer     ; We send the packet that will produce the transfer

  ;restore screen state
  pop af
  ld [rBGP], a
  pop af
  ld [rSCX], a
  pop af
  ld [rSCY], a
  pop af
  ld [rLCDC], a
  ret

; Super Game Boy packet transfer
; input: HL = Packet address
sgb_PacketTransfer::
  ld a, [sys_info]
  and a, SYS_INFO_SGB
  ret z
_sgb_PacketTransfer:
  ld a, [hl]
  and %00000111               ; The three lower bits indicate the number of packets to send
  ret z                       ; We return if there are no packets to send
  ld b, a                     ; We store the number of packets to send
.sendPacketsLoop:
    push bc
    xor a
    ld [rP1], a               ; Initial pulse (Start write). P14 = LOW and P15 = LOW
    ld a, P1F_4 | P1F_5
    ld [rP1], a               ; P14 = HIGH and P15 = HIGH between pulses
    ld b, 16                  ; Number of bytes per packet
.sendBytesLoop:
      ld e, 8                 ; Bits per byte
      ld a, [hli]
      ld d, a                 ; Next byte of the packet
.sendBitsLoop:
        bit 0, d
        ld a, P1F_4           ; P14 = HIGH and P15 = LOW (Write 1)
        jr nz, .skip
        ld a, P1F_5           ; P14 = LOW and P15 = HIGH (Write 0)
.skip:
        ld [rP1], a           ; We send one bit
        ld a, P1F_4 | P1F_5
        ld [rP1], a           ; P14 = HIGH and P15 = HIGH between pulses
        rr d                  ; We rotate the register so that the next bit goes to position 0
        dec e
        jr nz, .sendBitsLoop  ; We jump while there are bits left to be sent
      dec b
      jr nz, .sendBytesLoop   ; We jump while there are bytes left to be sent
    ld a, P1F_5
    ld [rP1], a               ; Bit 129, stop bit (Write 0)
    ld a, P1F_4 | P1F_5
    ld [rP1], a               ; P14 = HIGH and P15 = HIGH between pulses

    ; 280048 clock cycles are consumed (66.768646240234375 milliseconds) at 4.194304 mhz | 24 cycles
    ld de, 7000               ; 12 cycles
.wait24Cycles:
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
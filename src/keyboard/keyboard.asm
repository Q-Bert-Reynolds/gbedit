KB_MODE_PS2     EQU 0
KB_MODE_USB_HID EQU 1

PS2_START_BIT_ERROR  EQU %100
PS2_PARITY_BIT_ERROR EQU %010
PS2_FINISH_BIT_ERROR EQU %001
INCLUDE "src/keyboard/usb_hid_keys.asm";USB HID key codes
INCLUDE "src/keyboard/ps2_keys.asm";PS/2 keys codes

SECTION "PS/2 Keyboard Vars", WRAM0
;PS/2 scan codes are 11 bits (S0123456 7PFxxxxx):
; - (S)tart (always 0)
; - Data Bits (0-7) in reverse order, 
; - Odd (P)arity Bit - if the sum of bits 1-A (data bits + parity) is even, error
; - (F)inish Bit (always 1)
kb_scan_code:: DB
kb_buffer:: DS 8
kb_buffer_write:: DB
kb_buffer_read:: DB;TODO: r/w only use 4 bit, could be one byte
kb_interrupt_count:: DB
kb_errors:: DB;xxxxxSPF shows (S)tart, (P)arity, and (F)inish

SECTION "PS/2 Keyboard Code", ROM0
INCLUDE "src/keyboard/ascii_keymaps.asm"

PS2KeyboardInterrupt::;de not used
  push af
  ld a, [rSB]; do this ASAP
  push bc
  ld b, a;store first 8 bits of scan code (S0123456)

  xor a
  ld [kb_errors], a

  bit 7, b;test start bit, should always be 0
  jr z, .loadLastDataBit
.startBitError
  ld a, PS2_START_BIT_ERROR
  ld [kb_errors], a
.loadLastDataBit
  ld a, b
  and a
  ld a, %10000001
  ld [rSC], a;ask for bits using internal clock 
  jr nz, .loadLastDataBitLoop
  ld b, %10000000;if byte is 0, flip start bit to detect shift
.loadLastDataBitLoop
    ld a, [rSB]
    cp a, b
    jr z, .loadLastDataBitLoop

  push de
  push hl
  ld d, a;store data bits
  ld b, a

  cp a, $FF
  jr nz, .loadParityBit
  ld b, %01111111;if byte is all 1s, parity bit will also be 1, so flip bit 7 to detect shift
.loadParityBit
    ld a, [rSB]
    cp a, b
    jr z, .loadParityBit
  ld e, a;bit 0 is parity
  ld b, a

  cp a, $FF
  jr nz, .loadFinishBit
  ld b, %01111111;if byte is all 1s, since stop bit is also 1, flip bit 7 to detect shift
.loadFinishBit
    ld a, [rSB]
    cp a, b
    jr z, .loadFinishBit
  and a, %00000001
  jr nz, .allBitsRead
.finishBitError
  ld a, [kb_errors]
  or a, PS2_FINISH_BIT_ERROR
  ld [kb_errors], a

.allBitsRead
  xor a
  ld [rSB], a;done reading bits
  ld a, %10000000
  ld [rSC], a;ask for bits using keyboard clock 
  ld a, [kb_interrupt_count]
  inc a
  ld [kb_interrupt_count], a

; ;data (d) is 01234567, needs to be 76543210 in a
; ;we can count bits as we do so to test Parity Bit 
.reverseAndCountDataBits
  ld b, 8;bits left
  ld c, 0;bit sum
.reverseAndCountLoop
    srl d;shift data right out of d into carry
    rl a;rotate data left from carry into a
    bit 0, a
    jr z, .decrementBitsLeft
  .addBit
    inc c;if new bit is 1, increment sum
  .decrementBitsLeft
    dec b;bits left
    jr nz, .reverseAndCountLoop
.storeScanCode
  ld [kb_scan_code], a

  ld a, c
.testParityBit
  xor a, e;Bit 0 of e is parity, and bit 0 of a is even/odd. These should never be equal.
  jr nz, .writeScanCodeToBuffer
.parityBitError
  ld a, [kb_errors]
  or a, PS2_PARITY_BIT_ERROR
  ld [kb_errors], a

.writeScanCodeToBuffer
  ld hl, kb_buffer
  ld a, [kb_buffer_write]
  ld b, 0
  ld c, a
  inc a
  and a, %00000111;a%8
  ld [kb_buffer_write], a
  add hl, bc
  ld a, [kb_scan_code]
  ld [hl], a

  and %01111111;HACK; upper bit is often wrong
  ld [kb_scan_code], a

.restoreRegistersAndReturn
  pop hl
  pop bc
  pop de
  pop af
  ret

KeyboardDemo::
  di
  DISPLAY_OFF
  ld a, " "
  call ClearScreen
  DISPLAY_ON
  ei
  
  xor a
  ld [_x], a
  ld [_y], a
  ld [rSB], a
  ld a, %10000000
  ld [rSC], a;ask for bits using keyboard clock 
  ld [kb_scan_code], a
.loop
    call gbdk_WaitVBL
    call PrintKeyPresses
    ; call DrawKeyboardDebugData

    call UpdateInput
    ld a, [button_state]
    and a, PADF_A
    jr z, .loop

  .pressedAbutton

    jp .loop
  ret

PrintKeyPresses:
  ld a, [kb_buffer_write]
  ld b, a;b = write index
  ld a, [kb_buffer_read]
  ld d, 0
  ld e, a;de = read index
  cp a, b
  ret z;if read == write, done

.loop
    ld hl, kb_buffer
    add hl, de;[hl] = current scan code
    ld a, [hli];scan code
    ; cp a, $E0;check extended code
    ; cp a, $F0;check release code

    push bc
    push de
  .lookupASCII
    ld hl, PS2toASCIIKeymap
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl];ASCII value
    ld [str_buffer], a

    ld a, [_y]
    ld e, a
    ld a, [_x]
    ld d, a;de = xy
  .testXWrap
    inc a
    ld [_x], a
    cp a, 20
    jr c, .setTiles
    xor a
    ld [_x], a
  .testYWrap
    ld a, [_y]
    inc a
    ld [_y], a
    cp a, 18
    jr c, .setTiles
    xor a
    ld [_y], a
  .setTiles
    ld hl, $0101
    ld bc, str_buffer
    call gbdk_SetBkgTiles
    pop de
    pop bc

  .incrementReadIndex
    ld a, e
    inc a
    and a, %00000111;read%8
    ld e, a;de = read index

  .checkDone
    cp a, b;if read == write, done
    jr nz, .loop

  ld a, e
  ld [kb_buffer_read], a
  ret

DrawBinaryString:;b = byte to draw, hl = screen location
  ld c, 8
.loop
    LCD_WAIT_VRAM
    ld a, "1"
    sla b
    jr c, .setBuffer
    ld a, "0"
  .setBuffer
    ld [hli], a
    dec c
    jr nz, .loop
  ret


HexNumbers: DB "0123456789ABCDEF"
BlankSpace: DB "  ",0
InterruptsText: DB " interrupts ",0
DrawKeyboardDebugData:
  LCD_WAIT_VRAM
.drawScanCode
  ld a, "$"
  ld [_SCRN0], a

  ld hl, HexNumbers
  ld d, 0
  ld a, [kb_scan_code]
  and $F0
  swap a
  ld e, a
  add hl, de
  ld a, [hl]
  ld [_SCRN0+1], a

  ld hl, HexNumbers
  ld d, 0
  ld a, [kb_scan_code]
  and $0F
  ld e, a
  add hl, de
  ld a, [hl]
  ld [_SCRN0+2], a


  ld a, [kb_scan_code]
  ld h, 0
  ld l, a
  ld de, str_buffer
  call str_Number
  ld hl, BlankSpace
  ld de, str_buffer
  call str_Append

  ld a, DRAW_FLAGS_BKG
  ld hl, str_buffer
  ld de, $0500
  ld bc, 1
  call DrawText

  ld hl, _SCRN0+10
  ld a, [kb_scan_code]
  ld b, a
  call DrawBinaryString

.drawInterruptCount
  ld a, [kb_interrupt_count]
  ld h, 0
  ld l, a
  ld de, str_buffer
  call str_Number
  ld hl, InterruptsText
  ld de, str_buffer
  call str_Append

  ld a, DRAW_FLAGS_BKG
  ld hl, str_buffer
  ld de, $0003
  ld bc, 1
  call DrawText

.drawKeyASCII
  ld hl, PS2toASCIIKeymap
  ld a, [kb_scan_code]
  ld b, 0
  ld c, a
  add hl, bc
  LCD_WAIT_VRAM
  ld a, [hl]
  ld [_SCRN0+32*8], a

.drawErrors
  ld hl, str_buffer
  ld a, [kb_errors]
  ld b, a

.testStartBitError
  bit 2, b
  ld a, "S"
  jr nz, .drawStartBitError
.noStartBitError
  ld a, "_"
.drawStartBitError
  ld [hli], a

.testParityBitError
  bit 1, b
  ld a, "P"
  jr nz, .drawParityBitError
.noParityBitError
  ld a, "_"
.drawParityBitError
  ld [hli], a

.testFinishBitError
  bit 0, b
  ld a, "F"
  jr nz, .drawFinishBitError
.noFinishBitError
  ld a, "_"
.drawFinishBitError
  ld [hli], a

  xor a
  ld [hl], a;end string

  ld a, DRAW_FLAGS_BKG
  ld hl, str_buffer
  ld bc, 1
  ld de, 16
  call DrawText
  ret
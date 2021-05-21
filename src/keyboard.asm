PS2_START_BIT  EQU %00000100
PS2_PARITY_BIT EQU %00000010
PS2_FINISH_BIT EQU %00000001

SECTION "PS/2 Keyboard Vars", WRAM0
;PS/2 scan codes are 11 bits (S0123456 7PFxxxxx):
; - (S)tart (always 0)
; - Data Bits (0-7) in reverse order, 
; - Odd (P)arity Bit - if the sum of bits 1-A (data bits + parity) is even, error
; - (F)inish Bit (always 1)
ps2_bits_received:: DB
ps2_bits_processed:: DB
ps2_bit_errors:: DB;xxxxxSPF, set if (S)tart, (P)arity, or (F)inish bits have errors
ps2_buffer:: DW;S0123456 7PFxxxxx, shifted right by 11-ps2_bits_processed
ps2_scan_code:: DB
ps2_timeout:: DB

SECTION "PS/2 Keyboard Code", ROM0
PS2KeyboardInterrupt::
  push af
  push bc
  push de
  push hl
  ld a, [ps2_bits_received]
  and a, %00001111;received % 16
  ld a, [rSB]
  jr nz, .secondByte

.firstByte
  ld [ps2_buffer], a
  jr .incrementBits

.secondByte
  ld [ps2_buffer+1], a

.incrementBits
  ld a, [ps2_bits_received]
  add a, 8
  ld [ps2_bits_received], a

  call ProcessScanCode

  ld a, %10000000
  ld [rSC], a;request transfer using keyboard clock
    
  pop hl
  pop de
  pop bc
  pop af
  ret

ProcessScanCode::
  ld e, 0;errors
  ld a, [ps2_bits_processed]
  ld b, a
  ld a, [ps2_bits_received]
  sub a, b;unprocessed = received - processed
  cp a, 11
  ret c;return early if there aren't 11 bits to process

  xor a
  ld [ps2_timeout], a
  ld a, [ps2_buffer]
  ld h, a
  ld a, [ps2_buffer+1]
  ld l, a;hl = [ps2_buffer]

  ld a, b;processed bits
  and a, %00001111;processed % 16
  cp a, 8
  jr c, .shiftBits

.swapBytes
  sub a, 8
  ld b, l
  ld l, h
  ld h, b

.shiftBits
  and a
  jr z, .testStartBit
.shiftBitsLoop
    sla l;shift l left into carry
    rl h;rotate h left through carry
    dec a
    jr nz, .shiftBitsLoop

.testStartBit
  bit 7, h;bit 7 of h is start bit
  jr z, .shiftDataIntoFirstByte;start bit should always be 0
.startBitError
  ld e, PS2_START_BIT

.shiftDataIntoFirstByte
  sla l;shift data bit 7 left out of l into carry
  rl h;rotate data bit 7 left from carry into h, start bit out

.testFnishBit
  bit 6, l;bit 6 (bit 5 shifted left) is of l is finish bit
  jr nz, .reverseAndCountDataBits;finish bit should always be 1
.finishBitError
  ld a, PS2_FINISH_BIT
  or a, e
  ld e, a

;data (h) is 01234567, needs to be 76543210 in a
;we can count bits as we do so to test Parity Bit 
.reverseAndCountDataBits
  ld b, 8;bits left
  ld c, 0;bit sum
.reverseAndCountLoop
    srl h;shift data right out of h into carry
    rl a;rotate data left from carry into a
    bit 0, a
    jr z, .bit0Not1 
    inc c;if new bit is 1, increment sum
  .bit0Not1
    dec b;bits left
    jr nz, .reverseAndCountLoop

.storeScanCode
  ld [ps2_scan_code], a

.testParityBit
  bit 7, l;bit 7 (bit 6 shifted left) of l is parity bit
  jr z, .bit7Not1
  inc c;add parity bit to sum
.bit7Not1
  bit 0, c
  jr nz, .storeErrors
.parityBitError
  ld a, PS2_PARITY_BIT
  or a, e
  ld e, a

.storeErrors
  ld a, e
  ld [ps2_bit_errors], a

.incrementBitsProcessed
  ld a, [ps2_bits_processed]
  add a, 11
  ld [ps2_bits_processed], a

.testCountReset
  ld a, [ps2_bits_received]
  cp a, 88
  ret nz;if bits received isn't a multiple of 8 and 11, return early
  ;fall through

PS2ResetBits::
  xor a
  ld [ps2_bits_received], a
  ld [ps2_bits_processed], a
  ret

PS2KeyboardUpdate::;wait for V-Blank first
  ld a, [ps2_timeout]
  inc a
  ld [ps2_timeout], a
  cp a, 60
  ret c

  call ProcessScanCode

  xor a
  ld [ps2_timeout], a
  ld [ps2_bits_received], a
  ld [ps2_bits_processed], a
  ret

HexNumbers: DB "0123456789ABCDEF"
BlankSpace: DB "                ",0
KeyboardDemo::
  di
  DISPLAY_OFF
  ld a, " "
  call ClearScreen
  DISPLAY_ON
  ei

  xor a
  ld [rSB], a
  ld a, %10000000
  ld [rSC], a
  ld [ps2_scan_code], a
.loop
    ld a, [ps2_scan_code]
    push af;scan code
    call gbdk_WaitVBL
    ; call PS2KeyboardUpdate
    pop bc;old scan code
    call DrawKeyboardDebugData

    call UpdateInput
    ld a, [button_state]
    and a, PADF_A
    jr z, .loop

    call PS2ResetBits
    ld b, 0
    call DrawKeyboardDebugData

    jp .loop
  ret

DrawKeyboardDebugData: ;b = old scan code
  ld a, [ps2_scan_code]
  cp a, b
  ret z;no need to draw if there's no scan code change
  ld b, a;scan code

.drawScanCode
  ld hl, HexNumbers
  ld de, 0
  and $F0
  swap a
  ld e, a
  add hl, de
  ld a, [hl]
  ld [_SCRN0], a

  ld hl, HexNumbers
  ld de, 0
  ld a, b
  and $0F
  ld e, a
  add hl, de
  ld a, [hl]
  ld [_SCRN0+1], a

.drawErrors
  ld hl, HexNumbers
  ld de, 0
  ld a, [ps2_bit_errors]
  and $0F
  inc a
  ld e, a
  add hl, de
  ld a, [hl]
  ld [_SCRN0+3], a

.drawBytesReceived
  ld a, [ps2_bits_received]
  srl a
  srl a
  srl a
  ld h, 0
  ld l, a
  ld de, str_buffer
  call str_Number
  ld hl, BlankSpace
  ld de, str_buffer
  call str_Append

  ld a, DRAW_FLAGS_BKG
  ld hl, str_buffer
  ld de, $0001
  call DrawText
  ret
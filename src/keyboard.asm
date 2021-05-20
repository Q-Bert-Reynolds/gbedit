SECTION "PS/2 Keyboard Vars", WRAM0
;PS/2 scan codes are 11 bits (S0123456 7PFxxxxx):
; - (S)tart (always 0)
; - Data Bits (0-7) in reverse order, 
; - Odd (P)arity Bit - if the sum of bits 1-A (data bits + parity) is even, error
; - (F)inish Bit (always 1)
ps2_bits_received:: DB
ps2_bits_processed:: DB
ps2_buffer:: DW;S0123456 7PFxxxxx, shifted right by 11-ps2_bits_processed
ps2_scan_code:: DB

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
  xor a
  ld [rSB], a

  call ProcessScanCode

  ld a, %10000000
  ld [rSC], a;request transfer using keyboard clock
    

  pop hl
  pop de
  pop bc
  pop af
  ret

ProcessScanCode::
  ld a, [ps2_bits_processed]
  ld b, a
  ld a, [ps2_bits_received]
  sub a, b;unprocessed = received - processed
  cp a, 11
  ret c;return early if there aren't 11 bits to process

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
.startBitError;TODO

.shiftDataIntoFirstByte
  sla l;shift data bit 7 left out of l into carry
  rl h;rotate data bit 7 left from carry into h, start bit out

.testStopBit
  bit 6, l;bit 6 (bit 5 shifted left) is of l is stop bit
  jr nz, .reverseAndCountDataBits;stop bit should always be 1
.stopBitError;TODO

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
  ret nz
.parityBitError;TODO
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

  ld a, %10000000
  ld [rSC], a
.loop
    ld a, [ps2_scan_code]
    push af;scan code
    call gbdk_WaitVBL
    
    pop bc;old scan code
    ld a, [ps2_scan_code]
    cp a, b
    ; jr z, .loop;no need to draw if there's no scan code change

  .drawScanCode
    ld hl, HexNumbers
    ld de, 0
    ld b, a;scan code
    and $F0
    swap a
    inc a
    ld e, a
    add hl, de
    ld a, [hl]
    ld [_SCRN0], a

    ld hl, HexNumbers
    ld de, 0
    ld a, b
    and $0F
    inc a
    ld e, a
    add hl, de
    ld a, [hl]
    ld [_SCRN0+1], a

    ld a, [ps2_bits_received]
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

    jp .loop

  ret
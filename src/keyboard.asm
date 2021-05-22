PS2_START_BIT  EQU %00000100
PS2_PARITY_BIT EQU %00000010
PS2_FINISH_BIT EQU %00000001

SECTION "PS/2 Keyboard Vars", WRAM0
;PS/2 scan codes are 11 bits (S0123456 7PFxxxxx):
; - (S)tart (always 0)
; - Data Bits (0-7) in reverse order, 
; - Odd (P)arity Bit - if the sum of bits 1-A (data bits + parity) is even, error
; - (F)inish Bit (always 1)
ps2_scan_code:: DB
ps2_timeout:: DB

SECTION "PS/2 Keyboard Code", ROM0
PS2KeyboardInterrupt::
  push af
  push bc
  push de
  push hl

  ld a, [rSB]
  ld b, a
  ; bit 7, a;test start bit
  ; jr nz, .startBitError
  and a
  jr nz, .loadLastDataBit
  ld b, %10000000;if byte is 0, flip start bit to detect shift

.loadLastDataBit
    ld a, [rSB]
    cp a, b
    jr z, .loadLastDataBit
  ld h, a;store data bits

.loadParityBit
    ld a, [rSB]
    cp a, h
    jr z, .loadParityBit
  ld l, a;store parity

.loadFinishBit
    ld a, [rSB]
    cp a, l
    jr z, .loadFinishBit
  and a, %00000001
  ; jr z, .finishBitError

.allBitsRead
  xor a
  ld [rSC], a;stop waiting for bits
  ld a, %10000000
  ld [rSC], a;ask for bits using keyboard clock 

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
  
; .testParityBit
;   bit 7, l;bit 7 (bit 6 shifted left) of l is parity bit
;   jr z, .bit7Not1
;   inc c;add parity bit to sum
; .bit7Not1
;   bit 0, c
;   jr nz, .noError

  pop hl
  pop de
  pop bc
  pop af
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
    pop bc;old scan code
    call DrawKeyboardDebugData

    call UpdateInput
    ld a, [button_state]
    and a, PADF_A
    jr z, .loop

  .pressedAbutton

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
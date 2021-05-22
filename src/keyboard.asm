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
ps2_interrupt_count:: DB
ps2_interrupt_started:: DB

SECTION "PS/2 Keyboard Code", ROM0
PS2KeyboardInterrupt::
  push af
  push bc
  push de
  push hl

  ld a, [ps2_interrupt_count]
  inc a
  ld [ps2_interrupt_count], a
  ld a, 1
  ld [ps2_interrupt_started], a

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
  ld b, a

  cp a, $FF
  jr nz, .loadParityBit
  ld b, %01111111;if byte is all 1s, parity bit will also be 1, so flip bit 7 to detect shift
.loadParityBit
    ld a, [rSB]
    cp a, b
    jr z, .loadParityBit
  ld l, a;store parity
  ld b, a

  cp a, $FF
  jr nz, .loadFinishBit
  ld b, %01111111;if byte is all 1s, since stop bit is also 1, flip bit 7 to detect shift
.loadFinishBit
    ld a, [rSB]
    cp a, b
    jr z, .loadFinishBit
  and a, %00000001
  ; jr z, .finishBitError

.allBitsRead
  xor a
  ld [rSC], a;stop waiting for bits
  ld [rSB], a
  ld [ps2_interrupt_started], a
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
StartedText: DB "STARTED",0
StoppedText: DB "STOPPED",0
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
    call gbdk_WaitVBL
    call DrawKeyboardDebugData

    call UpdateInput
    ld a, [button_state]
    and a, PADF_A
    jr z, .loop

  .pressedAbutton

    jp .loop
  ret

DrawKeyboardDebugData:
  ld a, [ps2_scan_code]

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

.drawCount
  ld a, [ps2_interrupt_count]
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
  ld bc, 1
  call DrawText

.drawStartStop
  ld hl, StoppedText
  ld a, [ps2_interrupt_started]
  and a
  jr z, .drawStop
.drawStart
  ld hl, StartedText
.drawStop
  ld a, DRAW_FLAGS_BKG
  ld de, $0002
  ld bc, 1
  call DrawText
  ret
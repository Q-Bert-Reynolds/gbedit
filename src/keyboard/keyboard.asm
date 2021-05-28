INCLUDE "src/keyboard/usb_hid_keys.asm";USB HID key codes
INCLUDE "src/keyboard/ps2_keys.asm";PS/2 keys codes

KB_MODE_PS2     EQU 0
KB_MODE_USB_HID EQU 1

PS2_ERROR_TIMEOUT      EQU %100000
PS2_ERROR_UNKNOWN_CODE EQU %010000
PS2_ERROR_KEYBOARD     EQU %001000
PS2_ERROR_START_BIT    EQU %000100
PS2_ERROR_PARITY_BIT   EQU %000010
PS2_ERROR_FINISH_BIT   EQU %000001

KB_FLAG_RELEASE  EQU %00000001 ;$PS2 code $F0
KB_FLAG_EXTENDED EQU %00000010 ;$PS2 code $E0

KB_MOD_SCROLL_LOCK EQU PS2_LED_SCROLL_LOCK
KB_MOD_NUM_LOCK    EQU PS2_LED_NUM_LOCK
KB_MOD_CAPS_LOCK   EQU PS2_LED_CAPS_LOCK
KB_MOD_SUPER       EQU %00001000
KB_MOD_ALT         EQU %00010000
KB_MOD_CTRL        EQU %00100000
KB_MOD_SHIFT       EQU %01000000
KB_MOD_FUNCTION    EQU %10000000

SECTION "PS/2 Keyboard Vars", WRAM0
;PS/2 scan codes are 11 bits (S0123456 7PFxxxxx):
; - (S)tart (always 0)
; - Data Bits (0-7) in reverse order, 
; - Odd (P)arity Bit - if the sum of bits 1-A (data bits + parity) is even, error
; - (F)inish Bit (always 1)
kb_scan_code:: DB
kb_scan_code_buffer:: DS 8;holds last 8 scan codes
kb_error_buffer:: DS 8;holds last 8 error codes
kb_buffer_write:: DB
kb_buffer_read:: DB
kb_interrupt_count:: DB
kb_error:: DB;xxTUKSPF - (T)imeout, (U)nknown Scan Code, (K)eyboard $00 or $FF, (S)tart Bit, (P)arity Bit, (F)inish Bit
kb_error_count:: DB
kb_modifiers:: DB ;FSCAUPNL - (F)unction, (S)hift, (C)trl, (A)lt, S(U)per, Ca(P)s Lock, (N)um Lock, Scro(L)l Lock
kb_flags:: DB;xxxxxxER - (E)xtended key flag, (R)elease key flag
;WRAM used but defined elsewhere:
;   _x and _y for character position on screen
;   _i is the toggle between typing and debug displays

SECTION "PS/2 Keyboard Code", ROM0
INCLUDE "src/keyboard/ps2_ascii_keymaps.asm"
INCLUDE "src/keyboard/ps2_handlers.asm"
INCLUDE "src/keyboard/ps2_jump_table.asm"
INCLUDE "src/keyboard/ps2_interrupt.asm"
INCLUDE "src/keyboard/ps2_debug.asm"

KeyboardDemo::
  di
  call LoadFontTiles
  DISPLAY_OFF
  ld a, " "
  call ClearScreen
  DISPLAY_ON
  ei

  ld a, 7
  ld [rWX], a
  ld a, 104
  ld [rWY], a
  SHOW_WIN
  
  xor a
  ld [_x], a
  ld [_y], a
  ld [_i], a
  ld [kb_scan_code], a
  ld [rSB], a

  ld a, SCF_TRANSFER_START | SCF_CLOCK_EXTERNAL
  ld [rSC], a;ask for bits using keyboard clock 
  ld b, 0
.loop
    call gbdk_WaitVBL
    call ProcessPS2Keys
    call gbdk_WaitVBL
    call DrawKeyboardDebugData
    call UpdateInput
  .testAButton
    ld a, [button_state]
    and a, PADF_A
    jr z, .loop
    ld a, [last_button_state]
    and a, PADF_A
    jr nz, .loop
  .pressedAButton;clear screen
    ld a, " "
    ld bc, 32*32+20*18
    ld hl, _SCRN1
    call mem_SetVRAM
    ld a, [_i]
    xor a, 1
    ld [_i], a
    jr z, .hideDebug
  .showDebug
    ld a, 104
    ld [rWY], a
    jp .loop
  .hideDebug
    ld a, 144
    ld [rWY], a
    jp .loop
  ret

ProcessPS2Keys:
  ld a, [kb_buffer_write]
  ld b, a;b = write index
  ld a, [kb_buffer_read]
  ld d, 0
  ld e, a;de = read index
  cp a, b
  ret z;if read == write, done

.loop
    ld hl, kb_error_buffer
    add hl, de;[hl] = current error
    ld a, [hl];error code
    and a;check for errors
    jr nz, .incrementReadIndex;if errors found, don't process keycode

  .processKeyCode
    ld hl, kb_scan_code_buffer
    add hl, de;[hl] = current scan code
    ld a, [hli];scan code
    push de;store read index
    push bc;store write index
    call PS2HandleKeycode
    pop bc;restore write index
    pop de;restore read index

  .incrementReadIndex
    ld a, e
    inc a
    and a, %00000111;read%8
    ld e, a;de = read index
    ld [kb_buffer_read], a

  .checkDone
    cp a, b;if read == write, done
    jp nz, .loop
  ret

DrawCharacter:;a = ASCII value
  ld [tile_buffer], a

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
  ld bc, tile_buffer
  call gbdk_SetBkgTiles
  ret

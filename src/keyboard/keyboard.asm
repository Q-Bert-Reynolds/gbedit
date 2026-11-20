INCLUDE "src/keyboard/usb_hid_keys.asm";USB HID key codes
INCLUDE "src/keyboard/ps2_keys.asm";PS/2 keys codes

;kb_type
DEF KB_TYPE_NONE EQU 0
DEF KB_TYPE_PS2  EQU 1
DEF KB_TYPE_IGKB EQU 2

;kb_mode
DEF KB_MODE_NONE    EQU 0
DEF KB_MODE_EDITOR  EQU 4;key presses are queued as key events

DEF KB_EVENT_COUNT EQU 16;must be a power of 2
DEF KB_SCAN_CODE_COUNT EQU 64;must be a power of 2

;kb_error
DEF PS2_ERROR_TIMEOUT      EQU %100000
DEF PS2_ERROR_UNKNOWN_CODE EQU %010000
DEF PS2_ERROR_KEYBOARD     EQU %001000
DEF PS2_ERROR_START_BIT    EQU %000100
DEF PS2_ERROR_PARITY_BIT   EQU %000010
DEF PS2_ERROR_FINISH_BIT   EQU %000001

DEF KB_FLAG_RELEASE  EQU %00000001 ;$PS2 code $F0
DEF KB_FLAG_EXTENDED EQU %00000010 ;$PS2 code $E0

SECTION "Keyboard Vars", WRAM0
;PS/2 scan codes are 11 bits (S0123456 7PFxxxxx):
; - (S)tart (always 0)
; - Data Bits (0-7) in reverse order
; - Odd (P)arity Bit - if the sum of bits 1-A (data bits + parity) is even, error
; - (F)inish Bit (always 1)
;insideGadgets' USB scan codes are 8-bit
; - most data sent directly as ASCII, including shifted keys
; - some data comes through as USB HID codes
; - the rest are incorrectly converted ASCII codes that can sometimes be converted back to HID codes

kb_scan_code:: DB
kb_scan_code_buffer:: DS KB_SCAN_CODE_COUNT;holds last scan codes
kb_error_buffer:: DS KB_SCAN_CODE_COUNT;holds last error codes
kb_buffer_write:: DB
kb_buffer_read:: DB
kb_interrupt_count:: DB
kb_error:: DB;xxTUKSPF - (T)imeout, (U)nknown Scan Code, (K)eyboard $00 or $FF, (S)tart Bit, (P)arity Bit, (F)inish Bit
kb_error_count:: DB
kb_modifiers:: DB ;FSCAUPNL - (F)unction, (S)hift, (C)trl, (A)lt, S(U)per, Ca(P)s Lock, (N)um Lock, Scro(L)l Lock
kb_flags:: DB;xxxxxxER - (E)xtended key flag, (R)elease key flag
kb_type:: DB
kb_mode:: DB
kb_event_buffer:: DS KB_EVENT_COUNT*2;key, modifiers
kb_event_write:: DB
kb_event_read:: DB

SECTION "Keyboard Code Bank 0", ROM0
INCLUDE "src/keyboard/ps2_interrupt.asm"

_KBPopEvent::
KBPopEvent::;returns key in c (KEY_NONE if queue is empty), modifiers in b
  ld bc, 0
  ld a, [kb_event_read]
  ld hl, kb_event_write
  cp a, [hl]
  ret z
  ld l, a
  inc a
  and a, KB_EVENT_COUNT-1
  ld [kb_event_read], a
  ld h, 0
  add hl, hl
  ld de, kb_event_buffer
  add hl, de
  ld a, [hli]
  ld c, a
  ld b, [hl]
  ret

SECTION "Keyboard Code Bank X", ROMX
INCLUDE "src/keyboard/kb_jump_table.asm"
INCLUDE "src/keyboard/kb_handlers.asm"
INCLUDE "src/keyboard/ps2_ascii_keymaps.asm"
INCLUDE "src/keyboard/ps2_handlers.asm"
INCLUDE "src/keyboard/igkb_handlers.asm"

DetectKeyboard::
  xor a
  ld a, KB_TYPE_PS2
  ld [kb_type], a;assume PS2 keyboard connected
  xor a
  ldh [rSB], a
  ld a, SCF_START | SCF_SOURCE
  ldh [rSC], a ;ask for byte using gb clock
  ld de, 5
  call gbdk_Delay
  ld a, [kb_error]
  cp a, PS2_ERROR_TIMEOUT | PS2_ERROR_PARITY_BIT | PS2_ERROR_FINISH_BIT
  jr nz, .usePS2Clock;if magic error code not received, PS2 connected
  ld a, KB_TYPE_NONE;KB_TYPE_IGKB
  ld [kb_type], a
  ret
.usePS2Clock
  ld a, SCF_START
  ldh [rSC], a;ask for bits using keyboard clock 
  ret

SetKeyboardMode::;a = mode
  ld b, a
  ld a, [kb_mode]
  cp a, b
  ret z
.clearFlags
  xor a
  ld [kb_flags], a
.setMode
  ld a, b
  ld [kb_mode], a
  ret

ProcessKeyCodes::
  ld a, [kb_mode]
  and a
  ret z;exit early if KB_MODE_NONE
  ld a, [kb_type]
.processPS2
  cp a, KB_TYPE_PS2
  jr z, ProcessPS2KeyCodes
.processIGKB
  cp a, KB_TYPE_IGKB
  ret nz;unknown mode
  ;fall through to process IG key codes

ProcessIGKeyCodes:
  xor a
  ldh [rSB], a
  ld a, SCF_START | SCF_SOURCE
  ldh [rSC], a ;ask for byte using gb clock
  ld de, 5
  call gbdk_Delay
  ldh a, [rSB]
  and a
  ret z
  cp a, $FF
  ret z
  jp IGKBHandleCode

ProcessPS2KeyCodes:
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
    and a, KB_SCAN_CODE_COUNT-1
    ld e, a;de = read index
    ld [kb_buffer_read], a

  .checkDone
    cp a, b;if read == write, done
    jp nz, .loop
  ret
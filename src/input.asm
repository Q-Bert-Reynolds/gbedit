SECTION "Input Vars", HRAM
_last_button_state::
last_button_state:: DB
_button_state::
button_state:: DB
pad_latch: DB;buttons pressed since PadPressed was last called
pad_latch_last: DB

SECTION "Input Code", ROM0
DEF INPUT_REPEAT EQU 6

UpdateInput::;https://gbdev.io/pandocs/Joypad_Input.html
  PUSH_ALL

  ;copy button_state to last_button_state
  ldh a, [button_state]
  ldh [last_button_state], a

  ;read DPad
  ld hl, rP1
  ld a, P1F_GET_DPAD
  ld [hl], a ;switch to P15
REPT INPUT_REPEAT;multiple cycles to avoid button bounce
  ld a, [hl] ;load DPad
ENDR
  and %00001111 ;discard upper nibble
  swap a ;move low nibble to high nibble
  ld b, a ;store DPad in b

  ;read A,B,Select,Start
  ld a, P1F_GET_BTN
  ld [hl], a ;switch to P14
REPT INPUT_REPEAT
  ld a, [hl] ;load buttons
ENDR
  and %00001111 ;discard upper nibble
  or b ;combine DPad with other buttons
  cpl ;flip bits so 1 means pressed
  ldh [button_state], a

  ;read keyboard
  TRAMPOLINE ProcessKeyCodes
  POP_ALL
  ret

LatchPad::;called from VBlank, ORs newly pressed buttons into pad_latch
  ld hl, rP1
  ld a, [hl]
  and a, P1F_GET_NONE
  ld e, a;restore P1 select when done, UpdateInput may be mid read
  ld a, P1F_GET_DPAD
  ld [hl], a
REPT INPUT_REPEAT
  ld a, [hl]
ENDR
  and a, %00001111
  swap a
  ld b, a
  ld a, P1F_GET_BTN
  ld [hl], a
REPT INPUT_REPEAT
  ld a, [hl]
ENDR
  and a, %00001111
  or a, b
  cpl
  ld b, a;pressed
  ld [hl], e
  ldh a, [pad_latch_last]
  cpl
  and a, b;newly pressed
  ld c, a
  ld a, b
  ldh [pad_latch_last], a
  ldh a, [pad_latch]
  or a, c
  ldh [pad_latch], a
  ret

_PadPressed::
PadPressed::;returns gamepad buttons pressed since the last call in a, keyboard buttons aren't included
  di
  ldh a, [pad_latch]
  ld b, a
  xor a
  ldh [pad_latch], a
  ei
  ld a, b
  ret

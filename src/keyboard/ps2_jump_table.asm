PS2ExtendedJumpTable::
DW PS2HandleEndKey;PS2_KEY_END EQU $69
DW PS2HandleError;$6A
DW PS2HandleArrowKey;PS2_KEY_LEFT_ARROW EQU $6B
DW PS2HandleHomeKey;PS2_KEY_HOME EQU $6C
DW PS2HandleError;$6D
DW PS2HandleError;$6E
DW PS2HandleError;$6F
DW PS2HandleInsertKey;PS2_KEY_INSERT EQU $70
DW PS2HandleDeleteKey;PS2_KEY_DELETE EQU $71
DW PS2HandleArrowKey;PS2_KEY_DOWN_ARROW EQU $72
DW PS2HandleError;$73
DW PS2HandleArrowKey;PS2_KEY_RIGHT_ARROW EQU $74
DW PS2HandleArrowKey;PS2_KEY_UP_ARROW EQU $75
DW PS2HandleError;$76
DW PS2HandleError;$77
DW PS2HandleError;$78
DW PS2HandleError;$79
DW PS2HandlePageDown;PS2_KEY_PAGE_DOWN EQU $7A
DW PS2HandleError;$7B
DW PS2HandlePrintScreen; PS2_KEY_PRINT_SCREEN_SEND EQU $7C;Print screen presses 12, presses 7C, releases 7C, releases 12
DW PS2HandlePageUp;PS2_KEY_PAGE_UP EQU $7D
;any extended scan code values less than $7E will use this table

PS2JumpTable::
DW PS2HandleError;PS2_NULL EQU $00
DW PS2HandleFunctionKey;PS2_KEY_F9 EQU $01
DW PS2HandleError;02
DW PS2HandleFunctionKey;PS2_KEY_F5 EQU $03
DW PS2HandleFunctionKey;PS2_KEY_F3 EQU $04
DW PS2HandleFunctionKey;PS2_KEY_F1 EQU $05
DW PS2HandleFunctionKey;PS2_KEY_F2 EQU $06
DW PS2HandleFunctionKey;PS2_KEY_F12 EQU $07
DW PS2HandleError;08
DW PS2HandleFunctionKey;PS2_KEY_F10 EQU $09
DW PS2HandleFunctionKey;PS2_KEY_F8 EQU $0A
DW PS2HandleFunctionKey;PS2_KEY_F6 EQU $0B
DW PS2HandleFunctionKey;PS2_KEY_F4 EQU $0C
DW PS2HandleTab;PS2_KEY_TAB EQU $0D
DW PS2HandleCharacter;PS2_KEY_GRAVE EQU $0E
DW PS2HandleError;$0F

DW PS2HandleError;$10
DW PS2HandleAlt;PS2_KEY_ALT_LEFT EQU $11
DW PS2HandleShift;PS2_KEY_SHIFT_LEFT EQU $12
DW PS2HandleError;$13
DW PS2HandleCtrl;PS2_KEY_CTRL_LEFT EQU $14
DW PS2HandleCharacter;PS2_KEY_Q EQU $15
DW PS2HandleCharacter;PS2_KEY_1 EQU $16
DW PS2HandleError;$17
DW PS2HandleError;$18
DW PS2HandleError;$19
DW PS2HandleCharacter;PS2_KEY_Z EQU $1A
DW PS2HandleCharacter;PS2_KEY_S EQU $1B
DW PS2HandleCharacter;PS2_KEY_A EQU $1C
DW PS2HandleCharacter;PS2_KEY_W EQU $1D
DW PS2HandleCharacter;PS2_KEY_2 EQU $1E
DW PS2HandleError;$1F

DW PS2HandleError;$20
DW PS2HandleCharacter;PS2_KEY_C EQU $21
DW PS2HandleCharacter;PS2_KEY_X EQU $22
DW PS2HandleCharacter;PS2_KEY_D EQU $23
DW PS2HandleCharacter;PS2_KEY_E EQU $24
DW PS2HandleCharacter;PS2_KEY_4 EQU $25
DW PS2HandleCharacter;PS2_KEY_3 EQU $26
DW PS2HandleError;$27
DW PS2HandleError;$28
DW PS2HandleCharacter;PS2_KEY_SPACEBAR EQU $29
DW PS2HandleCharacter;PS2_KEY_V EQU $2A
DW PS2HandleCharacter;PS2_KEY_F EQU $2B
DW PS2HandleCharacter;PS2_KEY_T EQU $2C
DW PS2HandleCharacter;PS2_KEY_R EQU $2D
DW PS2HandleCharacter;PS2_KEY_5 EQU $2E
DW PS2HandleError;$2F

DW PS2HandleError;$30
DW PS2HandleCharacter;PS2_KEY_N EQU $31
DW PS2HandleCharacter;PS2_KEY_B EQU $32
DW PS2HandleCharacter;PS2_KEY_H EQU $33
DW PS2HandleCharacter;PS2_KEY_G EQU $34
DW PS2HandleCharacter;PS2_KEY_Y EQU $35
DW PS2HandleCharacter;PS2_KEY_6 EQU $36
DW PS2HandleError;$37
DW PS2HandleError;$38
DW PS2HandleError;$39
DW PS2HandleCharacter;PS2_KEY_M EQU $3A
DW PS2HandleCharacter;PS2_KEY_J EQU $3B
DW PS2HandleCharacter;PS2_KEY_U EQU $3C
DW PS2HandleCharacter;PS2_KEY_7 EQU $3D
DW PS2HandleCharacter;PS2_KEY_8 EQU $3E
DW PS2HandleError;$3F

DW PS2HandleError;$40
DW PS2HandleCharacter;PS2_KEY_COMMA EQU $41
DW PS2HandleCharacter;PS2_KEY_K EQU $42
DW PS2HandleCharacter;PS2_KEY_I EQU $43
DW PS2HandleCharacter;PS2_KEY_O EQU $44
DW PS2HandleCharacter;PS2_KEY_0 EQU $45
DW PS2HandleCharacter;PS2_KEY_9 EQU $46
DW PS2HandleError;$47
DW PS2HandleCharacter;PS2_KEY_L EQU $4B
DW PS2HandleCharacter;PS2_KEY_PERIOD EQU $49
DW PS2HandleCharacter;PS2_KEY_SLASH EQU $4A
DW PS2HandleError;$4B
DW PS2HandleCharacter;PS2_KEY_SEMI_COLON EQU $4C
DW PS2HandleCharacter;PS2_KEY_P EQU $4D
DW PS2HandleCharacter;PS2_KEY_MINUS EQU $4E
DW PS2HandleError;$4F

DW PS2HandleError;$50
DW PS2HandleError;$51
DW PS2HandleCharacter;PS2_KEY_APOSTROPHE EQU $52
DW PS2HandleError;$53
DW PS2HandleCharacter;PS2_KEY_LEFT_SQUARE_BRACKET EQU $54
DW PS2HandleCharacter;PS2_KEY_EQUALS EQU $55
DW PS2HandleError;$56
DW PS2HandleError;$57
DW PS2HandleCapsLock;PS2_KEY_CAPS_LOCK EQU $58
DW PS2HandleShift;PS2_KEY_SHIFT_RIGHT EQU $59
DW PS2HandleEnter;PS2_KEY_ENTER EQU $5A
DW PS2HandleCharacter;PS2_KEY_RIGHT_SQUARE_BRACKET EQU $5B
DW PS2HandleError;$5C
DW PS2HandleCharacter;PS2_KEY_BACKSLASH EQU $5D
DW PS2HandleError;$5E
DW PS2HandleError;$5F

DW PS2HandleError;$60
DW PS2HandleError;$61
DW PS2HandleError;$62
DW PS2HandleError;$63
DW PS2HandleError;$64
DW PS2HandleError;$65
DW PS2HandleBackspace;PS2_KEY_BACKSPACE EQU $66
DW PS2HandleError;$67
DW PS2HandleError;$68
DW PS2HandleCharacter;PS2_KEY_KEYPAD_1 EQU $69
DW PS2HandleError;$6A
DW PS2HandleCharacter;PS2_KEY_KEYPAD_4 EQU $6B
DW PS2HandleCharacter;PS2_KEY_KEYPAD_7 EQU $6C
DW PS2HandleError;$6D
DW PS2HandleError;$6E
DW PS2HandleError;$6F

DW PS2HandleCharacter;PS2_KEY_KEYPAD_0 EQU $70
DW PS2HandleCharacter;PS2_KEY_KEYPAD_PERIOD EQU $71
DW PS2HandleCharacter;PS2_KEY_KEYPAD_2 EQU $72
DW PS2HandleCharacter;PS2_KEY_KEYPAD_5 EQU $73
DW PS2HandleCharacter;PS2_KEY_KEYPAD_6 EQU $74
DW PS2HandleCharacter;PS2_KEY_KEYPAD_8 EQU $75
DW PS2HandleEscape;PS2_KEY_ESC EQU $76
DW PS2HandleNumLock;PS2_KEY_NUM_LOCK EQU $77
DW PS2HandleFunctionKey;PS2_KEY_F11 EQU $78
DW PS2HandleCharacter;PS2_KEY_KEYPAD_PLUS EQU $79
DW PS2HandleCharacter;PS2_KEY_KEYPAD_3 EQU $7A
DW PS2HandleCharacter;PS2_KEY_KEYPAD_MINUS EQU $7B
DW PS2HandleCharacter;PS2_KEY_KEYPAD_ASTERISK EQU $7C
DW PS2HandleCharacter;PS2_KEY_KEYPAD_9 EQU $7D
DW PS2HandleScrollLock;PS2_KEY_SCROLL_LOCK EQU $7E
DW PS2HandleError;$7F

DW PS2HandleError;$80
DW PS2HandleError;$81
DW PS2HandleError;$82
DW PS2HandleFunctionKey;PS2_KEY_F7 EQU $83
;any scan code values less than $84 will use this table

PS2HandleKeycode::;a = scan code
  cp a, PS2_EXTENDED_KEY_PREFIX;$E0
  jp z, PS2HandleExtendedKey

  cp a, PS2_RELEASED_KEY_PREFIX;$F0
  jp z, PS2HandleReleaseKey

  cp a, PS2_ACK;$FA
  jp z, PS2HandleAcknowledge

  cp a, PS2_ERROR;$FF
  jp z, PS2HandleError

  cp a, $84;size of the jump table
  jp nc, PS2HandleError;if code isn't one of 4 above and is over $83, error

  ld b, 0
  ld c, a;scan code

  call PS2CheckExtendedFlag
  ld hl, PS2JumpTable
  jr z, .lookupAddress;if not extended, lookup

.extendedKeys
  ld a, c;otherwise check a few special cases
  cp a, PS2_KEY_SUPER_LEFT; $1F
  jp z, PS2HandleSuper
  cp a, PS2_KEY_ALT_RIGHT            ;$11
  jp z, PS2HandleAlt
  cp a, PS2_KEY_CTRL_RIGHT           ;$14
  jp z, PS2HandleCtrl
  cp a, PS2_KEY_PRINT_SCREEN_INIT    ;$12
  jp z, PS2HandlePrintScreen
  cp a, PS2_KEY_SUPER_RIGHT          ;$27
  jp z, PS2HandleSuper
  cp a, PS2_KEY_MENUS                ;$2F
  jp z, PS2HandleMenus
  cp a, PS2_KEY_KEYPAD_SLASH         ;$4A ;same as non-extended
  jr z, .lookupAddress
  cp a, PS2_KEY_KEYPAD_ENTER         ;$5A ;same as non-extended 
  jr z, .lookupAddress
  cp a, $7E;size of extended jump table
  jp nc, PS2HandleError
  cp a, $69;lowest index in jump table
  jp c, PS2HandleError
  ld hl, PS2ExtendedJumpTable-$69;nice
.lookupAddress
  add hl, bc
  ld a, [hli]
  ld b, a;lower byte of jump address
  ld a, [hl]
  ld h, a;upper byte of jump address
  ld l, b;hl = keycode jump address
  ld a, c;scan code
  jp hl

PS2HandleReleaseKey:
  ld a, [kb_flags]
  or a, KB_FLAG_RELEASE
  ld [kb_flags], a
  ret

PS2HandleExtendedKey:
  ld a, [kb_flags]
  or a, KB_FLAG_EXTENDED
  ld [kb_flags], a
  ret

PS2HandleAcknowledge:
  ;TODO
  xor a;ACK shouldn't have flags
  ld [kb_flags], a
  ret

PS2HandleError:;a = scan code  
  cp a, PS2_NULL
  jr z, .keyboardError
  cp a, PS2_ERROR
  jr z, .keyboardError
.unknownScanCode
  ld a, [kb_error]
  or a, PS2_ERROR_UNKNOWN_CODE
  ld [kb_error], a
  jr .clearFlags
.keyboardError
  ld a, [kb_error]
  or a, PS2_ERROR_KEYBOARD
  ld [kb_error], a
.clearFlags
  xor a
  ld [kb_flags], a
  ret 

PS2HandleFunctionKey:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ;TODO
  ret 

PS2HandleTab:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ld c, 4
.loop
    push bc
    ld a, " "
    call DrawCharacter
    pop bc
    dec c
    jr nz, .loop
  ret 

PS2HandleShift:
  call PS2CheckReleaseFlag
  ret nz
  ret
PS2HandleAlt:
  call PS2CheckReleaseFlag
  ret nz
  ret
PS2HandleSuper:
  call PS2CheckReleaseFlag
  ret nz
  ret
PS2HandleCtrl:
  call PS2CheckReleaseFlag
  ret nz
  ret
PS2HandleFn:
  call PS2CheckReleaseFlag
  ret nz
  ret

PS2HandleCharacter:;a = scan code
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early

.lookupASCII
  ld b, 0
  ld c, a;scan code
  ld hl, PS2toASCIIKeymap
  ld a, [kb_modifiers]
  and a, KB_MOD_SHIFT
  jr z, .unshifted
.shifted
  ld hl, PS2toASCIIShiftedKeymap
.unshifted
  add hl, bc
  ld a, [hl];ASCII value
  ;fall through to DrawCharacter

DrawCharacter:;a = ASCII value
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
  ld a, 5
  ld [_y], a
.setTiles
  ld hl, $0101
  ld bc, str_buffer
  call gbdk_SetBkgTiles
  pop de
  pop bc
  ret

;TODO these should toggle lock bits in kb_modifiers
;     should also disable and enable keyboard lights
PS2HandleCapsLock:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ;if previous keycode is not caps lock, toggle caps lock in kb_modifiers, toggle light
  ret
PS2HandleScrollLock:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ;if previous keycode is not scroll lock, toggle caps lock in kb_modifiers, toggle light
  ret
PS2HandleNumLock:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ;if previous keycode is not num lock, toggle caps lock in kb_modifiers, toggle light
  ret 

PS2HandleBackspace:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ld a, [_x]
  dec a
  and a, %00000111
  ld [_x], a
  ret 

PS2HandleEscape:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ;TODO
  ret 

PS2HandleEnter:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  xor a
  ld [_x], a
  ld a, [_y]
  inc a
  and a, %00000111
  ld [_y], a
  ret

PS2HandleEndKey:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret

PS2HandleHomeKey:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret

PS2HandleInsertKey:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret

PS2HandleDeleteKey:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret

PS2HandleArrowKey:;scan code in a
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret

PS2HandlePageDown:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret

PS2HandlePageUp:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret


PS2HandlePrintScreen:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret

PS2HandleMenus:
  call PS2CheckReleaseFlag
  ret nz;if release flag set, return early
  ret

;sets z if release flag was already zero
;otherwise, sets release flag to 0
;only affects af
PS2CheckReleaseFlag:
  ld a, [kb_flags]
  and a, KB_FLAG_RELEASE
  push af;flags to return
  ld a, [kb_flags]
  and a, ~KB_FLAG_RELEASE
  ld [kb_flags], a
  pop af
  ret

;sets z if extended flag was already zero
;otherwise, sets extended flag to 0
;only affects af
PS2CheckExtendedFlag:
  ld a, [kb_flags]
  and a, KB_FLAG_EXTENDED
  push af;flags to return
  ld a, [kb_flags]
  and a, ~KB_FLAG_EXTENDED
  ld [kb_flags], a
  pop af
  ret

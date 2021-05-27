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
DW PS2HandleError;$48
DW PS2HandleCharacter;PS2_KEY_PERIOD EQU $49
DW PS2HandleCharacter;PS2_KEY_SLASH EQU $4A
DW PS2HandleCharacter;PS2_KEY_L EQU $4B
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

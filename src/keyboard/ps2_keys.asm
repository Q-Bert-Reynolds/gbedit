IF !DEF(PS2_KEYS)
PS2_KEYS SET 1

PS2_EXTENDED_KEY_PREFIX EQU $E0
PS2_RELEASED_KEY_PREFIX EQU $F0

;No press prefix. Release prefix is $F0
PS2_KEY_ESC                  EQU $76
PS2_KEY_F1                   EQU $05
PS2_KEY_F2                   EQU $06
PS2_KEY_F3                   EQU $04
PS2_KEY_F4                   EQU $0C
PS2_KEY_F5                   EQU $03
PS2_KEY_F6                   EQU $0B
PS2_KEY_F7                   EQU $83
PS2_KEY_F8                   EQU $0A
PS2_KEY_F9                   EQU $01
PS2_KEY_F10                  EQU $09
PS2_KEY_F11                  EQU $78
PS2_KEY_F12                  EQU $07

PS2_KEY_GRAVE                EQU $0E
PS2_KEY_1                    EQU $16
PS2_KEY_2                    EQU $1E
PS2_KEY_4                    EQU $25
PS2_KEY_3                    EQU $26
PS2_KEY_5                    EQU $2E
PS2_KEY_6                    EQU $36
PS2_KEY_7                    EQU $3D
PS2_KEY_8                    EQU $3E
PS2_KEY_9                    EQU $46
PS2_KEY_0                    EQU $45
PS2_KEY_MINUS                EQU $4E
PS2_KEY_EQUALS               EQU $55
PS2_KEY_BACKSPACE            EQU $66

PS2_KEY_TAB                  EQU $0D
PS2_KEY_Q                    EQU $15
PS2_KEY_W                    EQU $1D
PS2_KEY_E                    EQU $24
PS2_KEY_R                    EQU $2D
PS2_KEY_T                    EQU $2C
PS2_KEY_Y                    EQU $35
PS2_KEY_U                    EQU $3C
PS2_KEY_I                    EQU $43
PS2_KEY_O                    EQU $44
PS2_KEY_P                    EQU $4D
PS2_KEY_LEFT_SQUARE_BRACKET  EQU $54
PS2_KEY_RIGHT_SQUARE_BRACKET EQU $5B
PS2_KEY_BACKSLASH            EQU $5D

PS2_KEY_CAPS_LOCK            EQU $58
PS2_KEY_A                    EQU $1C
PS2_KEY_S                    EQU $1B
PS2_KEY_D                    EQU $23
PS2_KEY_F                    EQU $2B
PS2_KEY_G                    EQU $34
PS2_KEY_H                    EQU $33
PS2_KEY_J                    EQU $3B
PS2_KEY_K                    EQU $42
PS2_KEY_L                    EQU $4B
PS2_KEY_SEMI_COLON           EQU $4C
PS2_KEY_APOSTROPHE           EQU $52
PS2_KEY_ENTER                EQU $5A

PS2_KEY_SHIFT_LEFT           EQU $12
PS2_KEY_Z                    EQU $1A
PS2_KEY_X                    EQU $22
PS2_KEY_C                    EQU $21
PS2_KEY_V                    EQU $2A
PS2_KEY_B                    EQU $32
PS2_KEY_N                    EQU $31
PS2_KEY_M                    EQU $3A
PS2_KEY_COMMA                EQU $41
PS2_KEY_PERIOD               EQU $49
PS2_KEY_SLASH                EQU $4A
PS2_KEY_SHIFT_RIGHT          EQU $59

PS2_KEY_CTRL_LEFT            EQU $14
PS2_KEY_ALT_LEFT             EQU $11
PS2_KEY_SPACEBAR             EQU $29

PS2_KEY_SCROLL_LOCK          EQU $7E
PS2_KEY_NUM_LOCK             EQU $77
PS2_KEY_KEYPAD_PERIOD        EQU $71
PS2_KEY_KEYPAD_ASTERISK      EQU $7C
PS2_KEY_KEYPAD_MINUS         EQU $7B
PS2_KEY_KEYPAD_PLUS          EQU $79
PS2_KEY_KEYPAD_0             EQU $70
PS2_KEY_KEYPAD_1             EQU $69
PS2_KEY_KEYPAD_2             EQU $72
PS2_KEY_KEYPAD_3             EQU $7A
PS2_KEY_KEYPAD_4             EQU $6B
PS2_KEY_KEYPAD_5             EQU $73
PS2_KEY_KEYPAD_6             EQU $74
PS2_KEY_KEYPAD_7             EQU $6C
PS2_KEY_KEYPAD_8             EQU $75
PS2_KEY_KEYPAD_9             EQU $7D

;Pressed prefix $E0, released prefix $E0F0
PS2_KEY_KEYPAD_SLASH         EQU $4A
PS2_KEY_KEYPAD_ENTER         EQU $5A

PS2_KEY_SUPER_LEFT           EQU $1F
PS2_KEY_SUPER_RIGHT          EQU $27
PS2_KEY_ALT_RIGHT            EQU $11
PS2_KEY_CTRL_RIGHT           EQU $14

PS2_KEY_MENUS                EQU $2F
PS2_KEY_INSERT               EQU $70
PS2_KEY_HOME                 EQU $6C
PS2_KEY_PAGE_UP              EQU $7D
PS2_KEY_DELETE               EQU $71
PS2_KEY_END                  EQU $69
PS2_KEY_PAGE_DOWN            EQU $7A

PS2_KEY_UP_ARROW             EQU $75
PS2_KEY_LEFT_ARROW           EQU $6B
PS2_KEY_DOWN_ARROW           EQU $72
PS2_KEY_RIGHT_ARROW          EQU $74

PS2_KEY_PRINT_SCREEN_INIT    EQU $12
PS2_KEY_PRINT_SCREEN_SEND    EQU $7C;Print screen presses 12, presses 7C, releases 7C, releases 12

;$E1 prefix, CTRL, NUM LOCK, $E1 prefix, release CTRL, $E0 prefix, NUM LOCK
PS2_KEY_PAUSE_BREAK          EQU $E11477E1F014E077

ENDC ;PS2_KEYS

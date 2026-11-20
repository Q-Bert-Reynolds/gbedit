#ifndef CONSTANTS
#define CONSTANTS

// ram banks 
#define MAIN_SRAM_BANK 3//banks 0-2 hold the text buffer

//text buffer
#define TB_SIZE  0x6000//SRAM banks 0-2
#define TB_COLS  20
#define TB_ROWS  18

//on screen keyboard
#define OSK_COLS    10
#define OSK_ROWS    5
#define OSK_LOWER   0
#define OSK_SHIFT   1
#define OSK_SYMBOLS 2
#define ASCII_TAB 9
#define ASCII_LF  10
#define ASCII_CR  13

//key events, printable keys use their character code
#define KEY_NONE      0
#define KEY_BACKSPACE 8
#define KEY_TAB       9
#define KEY_ENTER     10
#define KEY_ESCAPE    27
#define KEY_DELETE    127
#define KEY_LEFT      0x80
#define KEY_RIGHT     0x81
#define KEY_UP        0x82
#define KEY_DOWN      0x83
#define KEY_HOME      0x84
#define KEY_END       0x85
#define KEY_PAGE_UP   0x86
#define KEY_PAGE_DOWN 0x87
#define KEY_INSERT    0x88

//kb_modifiers
#define KB_MOD_SCROLL_LOCK 0b00000001//same as PS2_LED_SCROLL_LOCK
#define KB_MOD_NUM_LOCK    0b00000010//same as PS2_LED_NUM_LOCK
#define KB_MOD_CAPS_LOCK   0b00000100//same as PS2_LED_CAPS_LOCK
#define KB_MOD_SUPER       0b00001000
#define KB_MOD_ALT         0b00010000
#define KB_MOD_CTRL        0b00100000
#define KB_MOD_SHIFT       0b01000000
#define KB_MOD_FUNCTION    0b10000000

//sizes
#define STACK_SIZE 128
#define BUFFER_SIZE 1024//32x32 tiles

#endif // CONSTANTS

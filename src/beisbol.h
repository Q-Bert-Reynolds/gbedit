#ifndef BEISBOL
#define BEISBOL

#include <gb/gb.h>
#include <gb/cgb.h>
#include <stdio.h>
#include "audio.c"

// GameBoy palettes
#define BG_PALETTE    0xE4
#define SPR_PALETTE_0 0xE4
#define SPR_PALETTE_1 0xD0

// GB color palettes
#define RGB_LT_YELLOW RGB(31, 31, 20)
#define RGB_DK_YELLOW RGB(30, 28, 17)
#define RGB_MUTE_RED  RGB(23, 14, 14)
#define RBG_LT_BLUE   RGB(18, 21, 28)

// sprite props
#define USE_PAL 0x10
#define FLIP_X_PAL (S_FLIPX | USE_PAL)
#define FLIP_Y_PAL (S_FLIPY | USE_PAL)
#define FLIP_XY_PAL (FLIP_X_PAL | FLIP_Y_PAL)
#define FLIP_XY (S_FLIPX | S_FLIPY)

// global vars
int save_data;
int_handler vblank_handler;
int a, b, c, d, i, j, k, l, w, x, y, z;
extern const unsigned char blank_tile[];
unsigned char tiles[1024];

// options
unsigned char text_speed;
unsigned char animation_style;
unsigned char coaching_style;

// drawing
void clear_screen();
void draw_ui_box(UBYTE x, UBYTE y, UBYTE w, UBYTE h);

// audio
void setup_audio();
void update_audio();

// start screen
void start_screen();
#endif

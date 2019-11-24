#ifndef BEISBOL
#define BEISBOL

#include <gb/gb.h>
#include <gb/cgb.h>
#include <stdio.h>
#include <string.h>
#include "../res/font.h"
#include "../res/ui.h"

// banks
#define START_BANK    1
#define TITLE_BANK    2
#define NEW_GAME_BANK 3
#define GAME_BANK     4

// bank entry points
void start();
UBYTE title();
void new_game();
void start_game();

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
#define FLIP_X_PAL  (S_FLIPX    | USE_PAL   )
#define FLIP_Y_PAL  (S_FLIPY    | USE_PAL   )
#define FLIP_XY_PAL (FLIP_X_PAL | FLIP_Y_PAL)
#define FLIP_XY     (S_FLIPX    | S_FLIPY   )

// UI Tiles
#define DOTTED_CIRCLE     10
#define BASEBALL          11
#define ARROW_LEFT        12
#define ARROW_RIGHT       13
#define ARROW_RIGHT_BLANK 14
#define ARROW_DOWN        28
#define ARROW_UP          29

#define BOX_UPPER_LEFT    17
#define BOX_UPPER_RIGHT   18
#define BOX_LOWER_LEFT    19
#define BOX_LOWER_RIGHT   20
#define BOX_HORIZONTAL    21
#define BOX_VERTICAL      22

#define LEVEL             16
#define EARNED_RUN_AVG    25
#define BATTING_AVG       26
#define INNING_BOTTOM     28
#define INNING_TOP        29

// global vars
int a, b, c, d, i, j, k, l, w, x, y, z;
UBYTE tiles[1024];
char str_buff[256];
char name_buff[16];

// save data
extern char user_name[8];
extern char rival_name[8];

// options
UBYTE text_speed;
UBYTE animation_style;
UBYTE coaching_style;

// drawing
void clear_screen();
void clear_bkg_area (UBYTE x, UBYTE y, UBYTE w, UBYTE h);
void draw_bkg_ui_box(UBYTE x, UBYTE y, UBYTE w, UBYTE h);
void draw_win_ui_box(UBYTE x, UBYTE y, UBYTE w, UBYTE h);
UBYTE show_list_menu (UBYTE x, UBYTE y, UBYTE w, UBYTE h, char *title, char *text);
char *show_text_entry (char *title, char *str, int max_len);
void display_text (UBYTE *text);
void fade_out();
void fade_in();

// audio
void setup_audio();
void update_audio();

#endif

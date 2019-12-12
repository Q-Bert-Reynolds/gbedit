#ifndef BEISBOL
#define BEISBOL

#include <gb/gb.h>
#include <gb/cgb.h>
#include <stdio.h>
#include <string.h>
#include "../img/ui_font.h"

// banks
#define UI_BANK         2
#define START_BANK      3
#define TITLE_BANK      4
#define NEW_GAME_BANK   5
#define PLAY_BALL_BANK  6
#define PLAYER_IMG_BANK 10 

// GameBoy palettes
#define BG_PALETTE    0xE4
#define SPR_PALETTE_0 0xE4 
#define SPR_PALETTE_1 0x90

// GB color palettes
#define RGB_LT_YELLOW RGB(31, 31, 20)
#define RGB_DK_YELLOW RGB(30, 28, 17)
#define RGB_MUTE_RED  RGB(23, 14, 14)
#define RBG_LT_BLUE   RGB(18, 21, 28)

// sprite props
#define FLIP_X_PAL  (S_FLIPX    | S_PALETTE )
#define FLIP_Y_PAL  (S_FLIPY    | S_PALETTE )
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
#define NUMBERS           48
#define BOX_UPPER_LEFT    17
#define BOX_UPPER_RIGHT   18
#define BOX_LOWER_LEFT    19
#define BOX_LOWER_RIGHT   20
#define BOX_HORIZONTAL    21
#define BOX_VERTICAL      22
#define EMPTY_BASE        23
#define OCCUPIED_BASE     24
#define LEVEL             16
#define EARNED_RUN_AVG    25
#define BATTING_AVG       26
#define INNING_BOTTOM     28
#define INNING_TOP        29

// save data
extern char user_name[8];
extern char rival_name[8];
extern unsigned char text_speed;
extern unsigned char animation_style;
extern unsigned char coaching_style;

// global vars
WORD a, b, c, d;
WORD i, j, k, l;
WORD s, t, u, v;
WORD w, x, y, z;
unsigned char tiles[512];
unsigned char bkg_buff[512];
char str_buff[64];
char name_buff[16];

// baseball
#define BALLS_MASK   0x70
#define STRIKES_MASK 0x0C
#define OUTS_MASK    0x03
UBYTE balls_strikes_outs; //0bxBBBSSOO

#define FIRST_BASE_MASK  0x000F
#define SECOND_BASE_MASK 0x00F0
#define THIRD_BASE_MASK  0x0F00
#define HOME_MASK        0xF000
UWORD runners_on_base; //0bHHHHTTTTSSSSFFFF

UBYTE frame;
UBYTE home_team;
UBYTE home_score;
UBYTE away_score;

extern const UBYTE *types[15];
struct move {
    char name[10];
    UBYTE pp;
    UBYTE type;
};
struct base_player {
    char name[10];
    UBYTE hp, bat, field, speed, throw;
    UBYTE bank;
    UBYTE *tile_data;
    UBYTE *tile_map;
};
struct player {
    char nickname[10];
    struct base_player *base;
    struct move *moves[4];
    UBYTE level, hp;
    UBYTE position, batting_order;
    UWORD hits, at_bats;//, plate_appearances, walks;
    UWORD outs_recorded, runs_allowed;//, walks_allowed, strikeouts;
};

// drawing
void hide_sprites ();
void clear_screen (UBYTE tile);
void clear_bkg_area (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE tile);
void clear_win_area (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE tile);
void set_bkg_tiles_with_offset (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE offset, unsigned char *in_tiles);

// ui
void load_font_tiles (WORD return_bank);
void draw_bkg_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h);
void draw_win_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h);
void show_text_entry (char *title, char *str, WORD max_len, WORD return_bank);
void reveal_text (UBYTE *text, WORD return_bank);
void display_text (UBYTE *text);
UBYTE show_list_menu (UBYTE x, UBYTE y, UBYTE w, UBYTE h, char *title, char *text, WORD return_bank);
void show_options (WORD return_bank);

// fx
void fade_out ();
void fade_in ();

// images
void load_player_bkg_data (UBYTE number, UBYTE vram_offset, WORD return_bank);
UBYTE get_player_img_columns (UBYTE number, WORD return_bank);
void set_player_bkg_tiles(UBYTE x, UBYTE y, UBYTE number, UBYTE vram_offset, WORD return_bank);

// audio
// void setup_audio();
// void update_audio();

// banked entry points
void start();
UBYTE title();
void new_game();
void start_game();

#endif

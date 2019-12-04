#ifndef BEISBOL
#define BEISBOL

#include <gb/gb.h>
#include <gb/cgb.h>
#include <stdio.h>
#include <string.h>
#include "../res/ui_font.h"

// banks
#define START_BANK      2
#define TITLE_BANK      3
#define NEW_GAME_BANK   4
#define PLAY_BALL_BANK  5
#define PLAYER_IMG_BANK 10 

// banked entry points
void start();
UBYTE title();
void new_game();
void start_game();

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

// global vars
WORD a, b, c, d;
WORD i, j, k, l;
WORD s, t, u, v;
WORD w, x, y, z;
unsigned char tiles[1024];
unsigned char bkg_buff[1024];
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

UBYTE move_choice;
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

// options, TODO: move to save file
UBYTE text_speed;
UBYTE animation_style;
UBYTE coaching_style;

// drawing
void hide_sprites ();
void clear_screen (UBYTE tile);
void clear_bkg_area (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE tile);
void clear_win_area (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE tile);
void set_bkg_tiles_with_offset (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE offset, unsigned char *in_tiles);
void draw_bkg_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h);
void draw_win_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h);
UBYTE show_list_menu (UBYTE x, UBYTE y, UBYTE w, UBYTE h, char *title, char *text);
char *show_text_entry (char *title, char *str, WORD max_len);
void reveal_text (UBYTE *text);
void display_text (UBYTE *text);
void fade_out ();
void fade_in ();

// images
extern const char* player_tiles0[];
extern const char* player_tiles1[];
extern const char* player_tiles2[];
extern const char* player_tiles3[];
extern const char* player_tiles4[];
extern const char* player_tiles5[];
extern const unsigned char player_tile_counts0[];
extern const unsigned char player_tile_counts1[];
extern const unsigned char player_tile_counts2[];
extern const unsigned char player_tile_counts3[];
extern const unsigned char player_tile_counts4[];
extern const unsigned char player_tile_counts5[];
extern const unsigned char player_columns0[];
extern const unsigned char player_columns1[];
extern const unsigned char player_columns2[];
extern const unsigned char player_columns3[];
extern const unsigned char player_columns4[];
extern const unsigned char player_columns5[];
extern const char* player_maps0[];
extern const char* player_maps1[];
extern const char* player_maps2[];
extern const char* player_maps3[];
extern const char* player_maps4[];
extern const char* player_maps5[];
void load_player_bkg_data (UBYTE number, UBYTE vram_offset, WORD return_bank);
UBYTE get_player_img_columns (UBYTE number, WORD return_bank);
void set_player_bkg_tiles(UBYTE x, UBYTE y, UBYTE number, UBYTE vram_offset, WORD return_bank);

// audio
// void setup_audio();
// void update_audio();

#endif

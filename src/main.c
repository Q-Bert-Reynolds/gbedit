#include "beisbol.h"

const UBYTE *types[15] = { 
    "NORMAL", "FIRE", "WATER", "ELECTRIC", "GRASS", 
    "ICE", "FIGHTING", "POISON", "GROUND", "FLYING", 
    "PSYCHIC", "BUG", "ROCK", "GHOST", "DRAGON",
};

void ui_load_font_tiles ();
void load_font_tiles (WORD return_bank) {
    SWITCH_ROM_MBC5(UI_BANK);
    ui_load_font_tiles();
    SWITCH_ROM_MBC5(return_bank);
}

void hide_sprites () {
    for (i = 0; i < 40; ++i) move_sprite(i, 0, 0);
}

void clear_screen (UBYTE tile) {
    for (i = 0; i < 1024; ++i) tiles[i] = tile;
    set_bkg_tiles(0,0,32,32,tiles);
    set_win_tiles(0,0,20,18,tiles);
    move_win(167,144);
    hide_sprites();
}

void clear_bkg_area (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE tile) {
    l = w*h;
    for (i = 0; i < l; ++i) tiles[i] = tile;
    set_bkg_tiles(x,y,w,h,tiles);
}

void clear_win_area (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE tile) {
    l = w*h;
    for (i = 0; i < l; ++i) tiles[i] = tile;
    set_win_tiles(x,y,w,h,tiles);
}

void set_bkg_tiles_with_offset (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE offset, unsigned char *in_tiles) {
    for (i = 0; i < w*h; ++i) tiles[i] = in_tiles[i]+offset;
    set_bkg_tiles(x,y,w,h,tiles);
}

void draw_ui_box (UBYTE w, UBYTE h) {
    for (j = 0; j < h; ++j) {
        for (i = 0; i < w; ++i) {
            k = 0;
            if (j == 0) {
                if (i == 0) k = BOX_UPPER_LEFT;
                else if (i == w-1) k = BOX_UPPER_RIGHT;
                else k = BOX_HORIZONTAL;
            }
            else if (j == h-1) {
                if (i == 0) k = BOX_LOWER_LEFT;
                else if (i == w-1) k = BOX_LOWER_RIGHT;
                else k = BOX_HORIZONTAL;
            }
            else if (i == 0 || i == w-1) k = BOX_VERTICAL;

            tiles[j*w+i] = k;
        }
    }
}

void draw_bkg_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h) {
    draw_ui_box(w,h);
    set_bkg_tiles(x,y,w,h,tiles);
}

void draw_win_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h) {
    draw_ui_box(w,h);
    set_win_tiles(x,y,w,h,tiles);
}

void ui_reveal_text (unsigned char *text);
void reveal_text (unsigned char *text, WORD return_bank) {
    strcpy(str_buff, text);
    SWITCH_ROM_MBC5(UI_BANK);
    ui_reveal_text(str_buff);
    SWITCH_ROM_MBC5(return_bank);
}

void display_text (unsigned char *text) {
    draw_win_ui_box(0,0,20,6);
    l = strlen(text);
    w = 0;
    y = 0;
    for (i = 0; i < l; ++i) {
        if (text[i] == '\n') {
            memcpy(str_buff,text+w,i-w);
            set_win_tiles(1, 2+y*2, i-w, 1, str_buff);
            ++y;
            w = i+1;
        }
    }
    memcpy(str_buff,text+w,i-w);
    set_win_tiles(1, 2+y*2, i-w, 1, str_buff);
    move_win(7,96);
    SHOW_WIN;
}

UBYTE ui_show_list_menu (UBYTE x, UBYTE y, UBYTE w, UBYTE h, char *title, char *text);
UBYTE show_list_menu (UBYTE x, UBYTE y, UBYTE w, UBYTE h, char *title, char *text, WORD return_bank) {
    strcpy(str_buff, text);
    strcpy(name_buff, title);
    SWITCH_ROM_MBC5(UI_BANK);
    a = ui_show_list_menu(x,y,w,h,name_buff,str_buff);
    SWITCH_ROM_MBC5(return_bank);
    return a;
}

void ui_show_text_entry (char *title, char *str, WORD max_len);
void show_text_entry (char *title, char *str, WORD max_len, WORD return_bank) {
    strcpy(str_buff, title);
    strcpy(name_buff, str);
    SWITCH_ROM_MBC5(UI_BANK);
    ui_show_text_entry(str_buff, name_buff, max_len);
    SWITCH_ROM_MBC5(return_bank);
    strcpy(title, str_buff);
    strcpy(str, name_buff);
    
}

void ui_show_options ();
void show_options (WORD return_bank) {
    SWITCH_ROM_MBC5(UI_BANK);
    ui_show_options();
    SWITCH_ROM_MBC5(return_bank);
}

void fade_out () {
    disable_interrupts();
    BGP_REG = 0x90;
    OBP0_REG = 0x90;
    delay(200);
    BGP_REG = 0x40;
    OBP0_REG = 0x40;
    delay(200);
    BGP_REG = 0x00;
    OBP0_REG = 0x00;
    delay(200);
}

void fade_in () {
    disable_interrupts();
    BGP_REG = 0x40;
    OBP0_REG = 0x40;
    delay(200);
    BGP_REG = 0x90;
    OBP0_REG = 0x90;
    delay(200);
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    OBP1_REG = SPR_PALETTE_1;
    delay(200);
}

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
void load_player_bkg_data (UBYTE number, UBYTE vram_offset, WORD return_bank) {
    if (number <= 25) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK);
        set_bkg_data(vram_offset, player_tile_counts0[number-1], player_tiles0[number-1]);
    }
    else if (number <= 50) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+1);
        set_bkg_data(vram_offset, player_tile_counts1[number-26], player_tiles1[number-26]);
    }
    else if (number <= 75) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+2);
        set_bkg_data(vram_offset, player_tile_counts2[number-51], player_tiles2[number-51]);
    }
    else if (number <= 100) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+3);
        set_bkg_data(vram_offset, player_tile_counts3[number-76], player_tiles3[number-76]);
    }
    else if (number <= 125) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+4);
        set_bkg_data(vram_offset, player_tile_counts4[number-101], player_tiles4[number-101]);
    }
    else {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+5);
        set_bkg_data(vram_offset, player_tile_counts5[number-126], player_tiles5[number-126]);
    }
    SWITCH_ROM_MBC5(return_bank);
}

UBYTE get_player_img_columns (UBYTE number, WORD return_bank) {
    i = 0;
    if (number <= 25) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK);
        i = player_columns0[number-1];
    }
    else if (number <= 50) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+1);
        i = player_columns1[number-26];
    }
    else if (number <= 75) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+2);
        i = player_columns2[number-51];
    }
    else if (number <= 100) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+3);
        i = player_columns3[number-76];
    }
    else if (number <= 125) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+4);
        i = player_columns4[number-101];
    }
    else {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+5);
        i = player_columns5[number-126];
    }
    SWITCH_ROM_MBC5(return_bank);
    return i;
}

void set_player_bkg_tiles(UBYTE x, UBYTE y, UBYTE number, UBYTE vram_offset, WORD return_bank) {
    if (number <= 25) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK);
        set_bkg_tiles_with_offset(x, y, player_columns0[number-1], player_columns0[number-1], vram_offset, player_maps0[number-1]);
    }
    else if (number <= 50) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+1);
        set_bkg_tiles_with_offset(x, y, player_columns1[number-26], player_columns1[number-26], vram_offset, player_maps1[number-26]);
    }
    else if (number <= 75) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+2);
        set_bkg_tiles_with_offset(x, y, player_columns2[number-51], player_columns2[number-51], vram_offset, player_maps2[number-51]);
    }
    else if (number <= 100) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+3);
        set_bkg_tiles_with_offset(x, y, player_columns3[number-76], player_columns3[number-76], vram_offset, player_maps3[number-76]);
    }
    else if (number <= 125) {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+4);
        set_bkg_tiles_with_offset(x, y, player_columns4[number-101], player_columns4[number-101], vram_offset, player_maps4[number-101]);
    }
    else {
        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+5);
        set_bkg_tiles_with_offset(x, y, player_columns5[number-126], player_columns5[number-126], vram_offset, player_maps5[number-126]);
    }
    SWITCH_ROM_MBC5(return_bank);
}

void main () {
    DISPLAY_OFF;
    disable_interrupts();
    cgb_compatibility();
    cpu_fast();
    enable_interrupts();
    // setup_audio();
    SPRITES_8x8;
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    OBP1_REG = SPR_PALETTE_1;
    SHOW_SPRITES;
    SHOW_BKG;
    SWITCH_RAM_MBC5(0);
    SWITCH_ROM_MBC5(START_BANK);
    start();    
    SWITCH_ROM_MBC5(TITLE_BANK);
    if (!title()) {
        SWITCH_ROM_MBC5(NEW_GAME_BANK);
        new_game();
    }
    SWITCH_ROM_MBC5(PLAY_BALL_BANK);
    start_game();
}

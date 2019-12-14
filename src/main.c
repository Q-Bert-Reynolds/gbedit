#include "beisbol.h"
#include "../data/roledex.c"

const UBYTE *types[15] = { 
    "NORMAL", "FIRE", "WATER", "ELECTRIC", "GRASS", 
    "ICE", "FIGHTING", "POISON", "GROUND", "FLYING", 
    "PSYCHIC", "BUG", "ROCK", "GHOST", "DRAGON",
};

extern void ui_load_font_tiles ();
void load_font_tiles (WORD return_bank) {
    SWITCH_ROM_MBC5(UI_BANK);
    ui_load_font_tiles();
    SWITCH_ROM_MBC5(return_bank);
}

void set_bkg_tiles_with_offset (UBYTE x, UBYTE y, UBYTE w, UBYTE h, UBYTE offset, unsigned char *in_tiles) {
    for (i = 0; i < w*h; ++i) tiles[i] = in_tiles[i]+offset;
    set_bkg_tiles(x,y,w,h,tiles);
}

extern void ui_reveal_text (unsigned char *text);
void reveal_text (unsigned char *text, WORD return_bank) {
    strcpy(str_buff, text);
    SWITCH_ROM_MBC5(UI_BANK);
    ui_reveal_text(str_buff);
    SWITCH_ROM_MBC5(return_bank);
}

void draw_ui_box(UBYTE w, UBYTE h) {
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

void draw_bkg_ui_box(UBYTE x, UBYTE y, UBYTE w, UBYTE h) {
    draw_ui_box(w,h);
    set_bkg_tiles(x,y,w,h,tiles);
}

void draw_win_ui_box(UBYTE x, UBYTE y, UBYTE w, UBYTE h) {
    draw_ui_box(w,h);
    set_win_tiles(x,y,w,h,tiles);
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

extern UBYTE ui_show_list_menu (UBYTE x, UBYTE y, UBYTE w, UBYTE h, char *title, char *text);
UBYTE show_list_menu (UBYTE x, UBYTE y, UBYTE w, UBYTE h, char *title, char *text, WORD return_bank) {
    strcpy(str_buff, text);
    strcpy(name_buff, title);
    SWITCH_ROM_MBC5(UI_BANK);
    a = ui_show_list_menu(x,y,w,h,name_buff,str_buff);
    SWITCH_ROM_MBC5(return_bank);
    return a;
}

extern void ui_show_text_entry (char *title, char *str, WORD max_len);
void show_text_entry (char *title, char *str, WORD max_len, WORD return_bank) {
    strcpy(str_buff, title);
    strcpy(name_buff, str);
    SWITCH_ROM_MBC5(UI_BANK);
    ui_show_text_entry(str_buff, name_buff, max_len);
    SWITCH_ROM_MBC5(return_bank);
    strcpy(title, str_buff);
    strcpy(str, name_buff);
}

extern void ui_show_options ();
void show_options (WORD return_bank) {
    SWITCH_ROM_MBC5(UI_BANK);
    ui_show_options();
    SWITCH_ROM_MBC5(return_bank);
}

void update_vbl(WORD return_bank) {
    wait_vbl_done();
    SWITCH_ROM_MBC5(AUDIO_BANK);
    update_audio();
    SWITCH_ROM_MBC5(return_bank);
}

void update_waitpadup(WORD return_bank) {
    SWITCH_ROM_MBC5(AUDIO_BANK);
    while (joypad()) {
        wait_vbl_done();
        update_audio();
    }
    SWITCH_ROM_MBC5(return_bank);
}

void update_delay(UBYTE time, WORD return_bank) {
    SWITCH_ROM_MBC5(AUDIO_BANK);
    for (t = 0; t < time; t+=60) {
        wait_vbl_done();
        update_audio();
    }
    SWITCH_ROM_MBC5(return_bank);
}

void main () {
    DISPLAY_OFF;
    disable_interrupts();
    cgb_compatibility();
    cpu_fast();
    enable_interrupts();
    
    NR52_REG = 0xFFU;
    NR51_REG = 0x00U;
    NR50_REG = 0x77U;
    
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

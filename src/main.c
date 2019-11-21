#include "beisbol.h"
#include "../res/font.c"
#include "../res/ui.c"

const unsigned char blank_tile[] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
void clear_screen () {
    set_bkg_data(0, 1, blank_tile);
    for (i = 0; i < 1024; ++i) tiles[i] = 0;
    set_bkg_tiles(0,0,32,32,tiles);
    for (i = 0; i < 40; i++) move_sprite(i, 0, 0);
}

void draw_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h) {
    for (j = 0; j < h; j++) {
        for (i = 0; i < w; i++) {
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
    set_bkg_tiles(x,y,w,h,tiles);
}

void flash_next_arrow (UBYTE x, UBYTE y) {
    while (1) {
        tiles[0] = ARROW_DOWN;
        set_bkg_tiles(x, y, 1, 1, tiles);
        waitpadup();
        for (a = 0; a < 20; a++) {
            if (joypad() & J_A) return;
            wait_vbl_done();
        }
        tiles[0] = 0;
        set_bkg_tiles(x, y, 1, 1, tiles);
        for (a = 0; a < 20; a++) {
            if (joypad() & J_A) return;
            wait_vbl_done();
        }
    }
}

void display_text (unsigned char *text) {
    draw_ui_box(0,12,20,6);
    x = 0;
    y = 0;
    l = strlen(text);
    for (i = 0; i < l; i++) {
        if (text[i] == '\n') {
            x = 0;
            ++y;
            if (y == 2) {
                y = 1;
                flash_next_arrow(18,16);
                get_bkg_tiles(1, 16, 17, 1, tiles);
                set_bkg_tiles(1, 14, 17, 1, tiles);
                for (j = 0; j < 17; ++j) tiles[j] = 0;
                set_bkg_tiles(1, 16, 17, 1, tiles);
            }
        }
        else {
            set_bkg_tiles(x+1,y*2+14,1,1,text+i);
            x++;
        }        
        delay(10);
    }
    flash_next_arrow(18,16);
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
    delay(200);
}

void main () {
    cgb_compatibility();
    DISPLAY_OFF;
    // setup_audio();
    SPRITES_8x8;
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    OBP1_REG = SPR_PALETTE_1;
    SHOW_SPRITES;
    SHOW_BKG;
    SWITCH_ROM_MBC5(START_BANK);
    start();
    SWITCH_ROM_MBC5(TITLE_BANK);
    if (title()) {
        // continue
    }
    else {
        SWITCH_ROM_MBC5(NEW_GAME_BANK);
        new_game();
    }
}

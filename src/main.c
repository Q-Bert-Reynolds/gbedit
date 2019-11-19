#include "beisbol.h"
#include "start.c"

const unsigned char blank_tile[] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
void clear_screen () {
    set_bkg_data(0, 1, blank_tile);
    for (i = 0; i < 1024; ++i) tiles[i] = 0;
    set_bkg_tiles(0,0,32,32,tiles);
    for (i = 0; i < 40; i++) move_sprite(i, 0, 0);
}

void main () {
    cgb_compatibility();
    DISPLAY_OFF;
    setup_audio();
    SPRITES_8x8;
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    OBP1_REG = SPR_PALETTE_1;
    SHOW_SPRITES;
    SHOW_BKG;
    while (1) {
        start_screen();
    }
}

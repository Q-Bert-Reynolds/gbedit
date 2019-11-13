#include "beisbol.h"
#include "start.c"

void main () {
    cgb_compatibility();
    DISPLAY_OFF;
    setup_audio();
    SPRITES_8x16;
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    OBP1_REG = SPR_PALETTE_1;
    SHOW_SPRITES;
    SHOW_BKG;
    while (1) {
        start_screen();
    }
}

#include "beisbol.h"
#include "start.c"

void main () {
    cgb_compatibility();
    DISPLAY_OFF;
    setup_audio();
    SPRITES_8x16;
    OBP0_REG = PALETTE_0;
    OBP1_REG = PALETTE_1;
    // set_sprite_palette(0, 7, sprite_palette);
    SHOW_SPRITES;
    SHOW_BKG;
    while (1) {
        start_screen();
    }
}

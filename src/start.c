#include "beisbol.h"
#include "../res/title/title.c"

void start_screen () {
    VBK_REG = 0;
    set_bkg_data(0, _TITLE_TILE_COUNT, _title_tiles);
    set_bkg_tiles(0, 0, _COPYRIGHT_COLUMNS, _COPYRIGHT_ROWS, _copyright_map);
    SHOW_BKG;
    DISPLAY_ON;
    delay(3000);
    set_bkg_tiles(0, 0, _BEISBOL_LOGO_COLUMNS, _BEISBOL_LOGO_ROWS, _beisbol_logo_map);

    while (1) {
        wait_vbl_done();
    }
}

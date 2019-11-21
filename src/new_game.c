#include "beisbol.h"
#include "../res/coaches/doc_hickory.c"
#include "../res/coaches/calvin.c"
#include "../res/coaches/nolan0.c"
#include "../res/font.c"
#include "../res/ui.c"

void new_game() {
    DISPLAY_OFF;
    clear_screen();
    set_bkg_data(0, _UI_TILE_COUNT, _ui_tiles);
    set_bkg_data(32, _FONT_TILE_COUNT, _font_tiles);
    set_bkg_data(32+_FONT_TILE_COUNT, _DOC_HICKORY_TILE_COUNT, _doc_hickory_tiles);
    for (i = 0; i < _DOC_HICKORY_ROWS*_DOC_HICKORY_COLUMNS; ++i) {
        tiles[i] = _doc_hickory_map[i]+32+_FONT_TILE_COUNT;
    }
    set_bkg_tiles(6,4,_DOC_HICKORY_COLUMNS,_DOC_HICKORY_ROWS,tiles);
    DISPLAY_ON;

    fade_in();
    display_text("Hello there!\nWelcome to the\nworld of Baseball.");
    
    while (1);
}

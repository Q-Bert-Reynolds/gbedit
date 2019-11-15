#include "beisbol.h"
#include "../res/title/title.c"

#ifdef HOME
    #include "../res/home_version/version.c"
#else
    #include "../res/away_version/version.c"
#endif

void start_screen () {
    VBK_REG = 0;
    set_bkg_data(0, _TITLE_TILE_COUNT, _title_tiles);
    set_bkg_data(_TITLE_TILE_COUNT, _VERSION_TILE_COUNT, _version_tiles);
    set_bkg_tiles(0, 0, _COPYRIGHT_COLUMNS, _COPYRIGHT_ROWS, _copyright_map);
    SHOW_BKG;
    DISPLAY_ON;
    delay(3000);
    set_bkg_tiles(0, 0, _INTRO_LIGHTS_COLUMNS, _INTRO_LIGHTS_ROWS, _intro_lights_map);
    delay(3000);
    set_bkg_tiles(0, 0, _BEISBOL_LOGO_COLUMNS, _BEISBOL_LOGO_ROWS, _beisbol_logo_map);

    for (i = 0; i < _VERSION_COLUMNS; i++) tiles[i] = _version_map[i] + _TITLE_TILE_COUNT;
    set_bkg_tiles(7,8,_VERSION_COLUMNS,_VERSION_ROWS,tiles);
    
    while (1) {
        wait_vbl_done();
    }
}

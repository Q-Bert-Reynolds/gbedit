#include "beisbol.h"
#include "../res/title/copyrights/copyrights.c"
#include "../res/title/lights/lights.c"
#include "../res/title/pitch/pitch.c"
#include "../res/title/title/title.c"
#include "../res/title/title/sprites/sprites.c"

#ifdef HOME
    #include "../res/home_version/version.c"
    #include "../res/players/004Ginger.c"
	#include "../res/players/007Squirt.c"
	#include "../res/players/001Bubbi.c"
	#include "../res/players/013Weeds.c"
	#include "../res/players/032Chico.c"
	#include "../res/players/123Scissors.c"
	#include "../res/players/025Chu.c"
	#include "../res/players/035Fairy.c"
	#include "../res/players/112Don.c"
	#include "../res/players/063Bruh.c"
	#include "../res/players/092Gas.c"
	#include "../res/players/132YeahYeah.c"
	#include "../res/players/017Gio.c"
	#include "../res/players/095Onyx.c"
	#include "../res/players/077Pinto.c"
	#include "../res/players/129Fish.c"
#else
    #include "../res/away_version/version.c"
    #include "../res/players/007Squirt.c"
    #include "../res/players/004Ginger.c"
    #include "../res/players/001Bubbi.c"
    #include "../res/players/056Man.c"
    #include "../res/players/106Bruce.c"
    #include "../res/players/037Vulfpek.c"
    #include "../res/players/113Chance.c"
    #include "../res/players/142Arrowhead.c"
    #include "../res/players/135Jolt.c"
    #include "../res/players/143Bear.c"
    #include "../res/players/044Gloomy.c"
    #include "../res/players/060Polly.c"
    #include "../res/players/084Duce.c"
    #include "../res/players/137Polygon.c"
    #include "../res/players/094Macobb.c"
    #include "../res/players/026Rai.c"
    const char* intro_player_tiles[] = {
        &_007Squirt_tiles,
        &_004Ginger_tiles,
        &_001Bubbi_tiles,
        &_056Man_tiles,
        &_106Bruce_tiles,
        &_037Vulfpek_tiles,
        &_113Chance_tiles,
        &_142Arrowhead_tiles,
        &_135Jolt_tiles,
        &_143Bear_tiles,
        &_044Gloomy_tiles,
        &_060Polly_tiles,
        &_084Duce_tiles,
        &_137Polygon_tiles,
        &_094Macobb_tiles,
        &_026Rai_tiles,
    };
    const char* intro_player_maps[] = {
        &_007Squirt_map,
        &_004Ginger_map,
        &_001Bubbi_map,
        &_056Man_map,
        &_106Bruce_map,
        &_037Vulfpek_map,
        &_113Chance_map,
        &_142Arrowhead_map,
        &_135Jolt_map,
        &_143Bear_map,
        &_044Gloomy_map,
        &_060Polly_map,
        &_084Duce_map,
        &_137Polygon_map,
        &_094Macobb_map,
        &_026Rai_map,
    };
    const int intro_player_columns[] = {
        _007SQUIRT_COLUMNS,
        _004GINGER_COLUMNS,
        _001BUBBI_COLUMNS,
        _056MAN_COLUMNS,
        _106BRUCE_COLUMNS,
        _037VULFPEK_COLUMNS,
        _113CHANCE_COLUMNS,
        _142ARROWHEAD_COLUMNS,
        _135JOLT_COLUMNS,
        _143BEAR_COLUMNS,
        _044GLOOMY_COLUMNS,
        _060POLLY_COLUMNS,
        _084DUCE_COLUMNS,
        _137POLYGON_COLUMNS,
        _094MACOBB_COLUMNS,
        _026RAI_COLUMNS,
    };
    const int intro_player_tile_count[] = {
        _007SQUIRT_TILE_COUNT,
        _004GINGER_TILE_COUNT,
        _001BUBBI_TILE_COUNT,
        _056MAN_TILE_COUNT,
        _106BRUCE_TILE_COUNT,
        _037VULFPEK_TILE_COUNT,
        _113CHANCE_TILE_COUNT,
        _142ARROWHEAD_TILE_COUNT,
        _135JOLT_TILE_COUNT,
        _143BEAR_TILE_COUNT,
        _044GLOOMY_TILE_COUNT,
        _060POLLY_TILE_COUNT,
        _084DUCE_TILE_COUNT,
        _137POLYGON_TILE_COUNT,
        _094MACOBB_TILE_COUNT,
        _026RAI_TILE_COUNT,
    };
#endif

void drop_title_lcd_interrupt(void) {
    if (LY_REG < 64) SCY_REG = y;
    else SCY_REG = 0;
}

void show_version_lcd_interrupt(void) {
    if (LY_REG >= 64 && LY_REG < 72) SCX_REG = x;
    else SCX_REG = 0;
}

void cycle_players_lcd_interrupt(void) {
    if (LY_REG >= 72 && LY_REG < 136) SCX_REG = x;
    else SCX_REG = 0;
}

void show_copyrights () {
    HIDE_BKG;
    set_bkg_data(0, _COPYRIGHTS_TILE_COUNT, _copyrights_tiles);
    set_bkg_tiles(0, 0, _COPYRIGHT_COLUMNS, _COPYRIGHT_ROWS, _copyright_map);
    SHOW_BKG;
    DISPLAY_ON;
    delay(3000);
}

void show_lights_sequence () {
    HIDE_BKG;
    set_bkg_data(0, _LIGHTS_TILE_COUNT, _lights_tiles);
    set_bkg_tiles(0, 0, _INTRO_LIGHTS_COLUMNS, _INTRO_LIGHTS_ROWS, _intro_lights_map);
    SHOW_BKG;
    // show ball hitting light
    delay(3000);
}

void show_pitch_sequence () {
    set_bkg_data(0, _PITCH_TILE_COUNT, _pitch_tiles);
    set_bkg_tiles(0, 0, _INTRO_PITCH_COLUMNS, _INTRO_PITCH_ROWS, _intro_pitch_map);
    delay(3000);
}

void show_title () {    
    HIDE_BKG;
    STAT_REG = 8;
    disable_interrupts();
    add_LCD(drop_title_lcd_interrupt);
    enable_interrupts();
    
    set_bkg_data(0, _TITLE_TILE_COUNT, _title_tiles);
    set_bkg_data(_TITLE_TILE_COUNT, _VERSION_TILE_COUNT, _version_tiles);
    set_bkg_tiles(0, 0, _BEISBOL_LOGO_COLUMNS, _BEISBOL_LOGO_ROWS, _beisbol_logo_map);
    y = 64;
    set_interrupts(LCD_IFLAG|VBL_IFLAG);
    
    SHOW_BKG;
    DISPLAY_ON;
    for (i = 0; i < 64; ++i) {
        y = 64-i;
        wait_vbl_done();
    }

    disable_interrupts();
    remove_LCD(drop_title_lcd_interrupt);
    add_LCD(show_version_lcd_interrupt);
    enable_interrupts();
    x = 64;

    for (i = 0; i < _VERSION_COLUMNS; ++i) tiles[i] = _version_map[i] + _TITLE_TILE_COUNT;
    wait_vbl_done();
    set_bkg_tiles(7,8,_VERSION_COLUMNS,_VERSION_ROWS,tiles);
    for (i = 0; i < 64; ++i) {
        x  = 64-i;
        wait_vbl_done();
    }

    while (1) {
        set_bkg_data(_TITLE_TILE_COUNT+_VERSION_TILE_COUNT, _007SQUIRT_TILE_COUNT, _007Squirt_tiles);
        for (j = 0; j < _007SQUIRT_TILE_COUNT; ++j) tiles[j] = _007Squirt_map[j]+_TITLE_TILE_COUNT+_VERSION_TILE_COUNT;
        k = _007SQUIRT_COLUMNS;
        set_bkg_tiles(11-k, 17-k, k, k, tiles);
        for (i = 1; i < 16; ++i) {
            delay(2000);
            for (j = 0; j < 49; ++j) tiles[j] = 0;
            set_bkg_tiles(4, 10, 7, 7, tiles);
            set_bkg_data(_TITLE_TILE_COUNT+_VERSION_TILE_COUNT, intro_player_tile_count[i], intro_player_tiles[i]);
            for (j = 0; j < intro_player_tile_count[i]; ++j) tiles[j] = intro_player_maps[i][j]+_TITLE_TILE_COUNT+_VERSION_TILE_COUNT;
            k = intro_player_columns[i];
            set_bkg_tiles(11-k, 17-k, k, k, tiles);
        }
        delay(2000);
        for (j = 0; j < 49; ++j) tiles[j] = 0;
        set_bkg_tiles(4, 10, 7, 7, tiles);
    }
}

void show_start_menu () {

}

void start_screen () {
    VBK_REG = 0;
    set_bkg_data(0, _TITLE_TILE_COUNT, _title_tiles);
    // show_copyrights();
    // show_lights_sequence();
    // show_pitch_sequence();
    show_title();
    show_start_menu();
}
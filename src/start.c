#include "beisbol.h"
#include "../res/title/copyrights/copyrights.c"
#include "../res/title/intro/intro.c"
#include "../res/title/intro/intro_sprites/intro_sprites.c"
#include "../res/title/title/title.c"
#include "../res/title/title/title_sprites/title_sprites.c"
#include "../res/font.c"

#ifdef HOME
    #include "../res/home_version/version.c"
    #include "../res/home_version/version_sprites/version_sprites.c"
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
    const char* intro_player_tiles[] = {
        &_004Ginger_tiles,
        &_007Squirt_tiles,
        &_001Bubbi_tiles,
        &_013Weeds_tiles,
        &_032Chico_tiles,
        &_123Scissors_tiles,
        &_025Chu_tiles,
        &_035Fairy_tiles,
        &_112Don_tiles,
        &_063Bruh_tiles,
        &_092Gas_tiles,
        &_132YeahYeah_tiles,
        &_017Gio_tiles,
        &_095Onyx_tiles,
        &_077Pinto_tiles,
        &_129Fish_tiles,
    };
    const char* intro_player_maps[] = {
        &_004Ginger_map,
        &_007Squirt_map,
        &_001Bubbi_map,
        &_013Weeds_map,
        &_032Chico_map,
        &_123Scissors_map,
        &_025Chu_map,
        &_035Fairy_map,
        &_112Don_map,
        &_063Bruh_map,
        &_092Gas_map,
        &_132YeahYeah_map,
        &_017Gio_map,
        &_095Onyx_map,
        &_077Pinto_map,
        &_129Fish_map,
    };
    const int intro_player_columns[] = {
        _004GINGER_COLUMNS,
        _007SQUIRT_COLUMNS,
        _001BUBBI_COLUMNS,
        _013WEEDS_COLUMNS,
        _032CHICO_COLUMNS,
        _123SCISSORS_COLUMNS,
        _025CHU_COLUMNS,
        _035FAIRY_COLUMNS,
        _112DON_COLUMNS,
        _063BRUH_COLUMNS,
        _092GAS_COLUMNS,
        _132YEAHYEAH_COLUMNS,
        _017GIO_COLUMNS,
        _095ONYX_COLUMNS,
        _077PINTO_COLUMNS,
        _129FISH_COLUMNS,
    };
    const int intro_player_tile_count[] = {
        _004GINGER_TILE_COUNT,
        _007SQUIRT_TILE_COUNT,
        _001BUBBI_TILE_COUNT,
        _013WEEDS_TILE_COUNT,
        _032CHICO_TILE_COUNT,
        _123SCISSORS_TILE_COUNT,
        _025CHU_TILE_COUNT,
        _035FAIRY_TILE_COUNT,
        _112DON_TILE_COUNT,
        _063BRUH_TILE_COUNT,
        _092GAS_TILE_COUNT,
        _132YEAHYEAH_TILE_COUNT,
        _017GIO_TILE_COUNT,
        _095ONYX_TILE_COUNT,
        _077PINTO_TILE_COUNT,
        _129FISH_TILE_COUNT,
    };
#else
    #include "../res/away_version/version.c"
    #include "../res/away_version/version_sprites/version_sprites.c"
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

#define PLAYER_INDEX _TITLE_TILE_COUNT+_VERSION_TILE_COUNT

void show_title_lcd_interrupt(void) {
    switch (LY_REG) {
        case 0:
        case 255:
            LYC_REG = 63;
            SCX_REG = 0;
            SCY_REG = y;
            break;
        case 63:
            LYC_REG = 71;
            SCX_REG = x;
            SCY_REG = 0;
            break;
        case 71:
            LYC_REG = 135;
            SCX_REG = 128;
            SCY_REG = 0;
            break;
        case 135:
            LYC_REG = 0;
            SCX_REG = 0;
            SCY_REG = 0;
            break;
    }
}

void cycle_players_lcd_interrupt(void) {
    if (LY_REG == 72){
        LYC_REG = 135;
        SCX_REG = x;
    }
    else if (LY_REG == 135) {
        LYC_REG = 72;
        SCX_REG = 0;
    }
}

void show_copyrights () {
    HIDE_BKG;
    set_bkg_data(0, _COPYRIGHTS_TILE_COUNT, _copyrights_tiles);
    set_bkg_tiles(0, 0, _COPYRIGHT_COLUMNS, _COPYRIGHT_ROWS, _copyright_map);
    SHOW_BKG;
    DISPLAY_ON;
    delay(1500);
}

const unsigned char lights_pal_seq[] = {
    0xE0, 0xE0, 0xE0, 0xE0, 0xE8, 0xE8, 0xE8, 0xE8, 0xE0, 0xE0,
    0xE0, 0xE0, 0xE8, 0xE8, 0xE8, 0xE8, 0xE0, 0xE0, 0xE0, 0xE0,
    0xE8, 0xE8, 0xE8, 0xE8, 0xE0, 0xE0, 0xE0, 0xE0, 0xE8, 0xE8,
    0xE8, 0xE8, 0xEC, 0xEC, 0xEC, 0xEC, 0xEC, 0xEC, 0xEC, 0xEC,
};
void lights_sequence () {
    for (i = 0; i < 60; i++) {
        if (joypad() & (J_START | J_A)) return;
        wait_vbl_done();
    }
    y = 0;
    for (x = 152; x > 88; x-=2) {
        move_sprite(0, x, y+=3);
        if (joypad() & (J_START | J_A)) return;
        wait_vbl_done();
    }
    set_bkg_tiles(10, 8, _INTRO_LIGHT_OUT_COLUMNS, _INTRO_LIGHT_OUT_ROWS, _intro_light_out_map);
    // start playing stars animation
    for (x = 0; x < 40; ++x) {
        move_sprite(0, x+88, y+=4);
        BGP_REG = lights_pal_seq[x];
        if (joypad() & (J_START | J_A)) return;
        wait_vbl_done();
    }
    for (i = 0; i < 60; i++) {
        if (joypad() & (J_START | J_A)) return;
        wait_vbl_done();
    }
}

void pitch_sequence () {
    BGP_REG = BG_PALETTE;
    wait_vbl_done();
    set_bkg_tiles(0, 0, _INTRO_PITCH_COLUMNS, _INTRO_PITCH_ROWS, _intro_pitch_map);
    for (i = 0; i < _INTRO0_COLUMNS*_INTRO0_ROWS; i++) {
        set_sprite_tile(i, _intro0_map[i]+_INTRO_SPRITES_TILE_COUNT);
        set_sprite_prop(i, S_PRIORITY);
    }
    for (k = 0; k <= 128; k+=2) {
        move_bkg(k+32, 0);
        a = 0;
        for (j = 0; j < _INTRO0_ROWS; j++) {
            for (i = 0; i < _INTRO0_COLUMNS; i++) {
                move_sprite(a++, k+i*8-32, j*8+80);
                if (joypad() & (J_START | J_A)) return;
            }
        }
    }
    for (i = 0; i < 60; i++) {
        if (joypad() & (J_START | J_A)) return;
        wait_vbl_done();
    }
}

void show_intro_sequence () {
    DISPLAY_OFF;
    BGP_REG = 0xE0;
    set_bkg_data(0, _INTRO_TILE_COUNT, _intro_tiles);
    set_bkg_tiles(0, 0, _INTRO_LIGHTS_COLUMNS, _INTRO_LIGHTS_ROWS, _intro_lights_map);
    set_sprite_data(0, _INTRO_SPRITES_TILE_COUNT, _intro_sprites_tiles);
    set_sprite_data(_INTRO_SPRITES_TILE_COUNT, _VERSION_SPRITES_TILE_COUNT, _version_sprites_tiles);
    set_sprite_tile(0, 0);
    move_sprite(0, 152,0);
    DISPLAY_ON;

    lights_sequence();
    pitch_sequence();

    disable_interrupts();
    delay(200);
    BGP_REG = 0x90;
    OBP0_REG = 0x90;
    delay(200);
    BGP_REG = 0x40;
    OBP0_REG = 0x40;
    delay(200);
    BGP_REG = 0x00;
    OBP0_REG = 0x00;
}

void show_player (int p) {
    set_bkg_data(PLAYER_INDEX, intro_player_tile_count[p], intro_player_tiles[p]);
    a = intro_player_columns[p];
    b = 7-a;
    k = 0;
    for (j = 0; j < 7; ++j) {
        for (i = 0; i < 7; ++i) {
            if (i < b || j < b) tiles[j*7+i] = 0;
            else tiles[j*7+i] = intro_player_maps[p][k++]+PLAYER_INDEX;
        }
    }
    set_bkg_tiles(20, 10, 7, 7, tiles);
}

void cycle_players_vbl_interrupt(void) {
    if (c==z) return;
    show_player(z);
    c=z;
}

void show_title () {
    DISPLAY_OFF;
    clear_screen();
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;

    set_sprite_data(0, _TITLE_SPRITES_TILE_COUNT, _title_sprites_tiles);
    a = 0;
    for (j = 0; j < _CALVIN_TITLE_ROWS; ++j) {
        for (i = 0; i < _CALVIN_TITLE_COLUMNS; ++i) {
            b = _calvin_title_map[j*_CALVIN_TITLE_COLUMNS+i];
            if (b == 0) continue;
            set_sprite_tile(a, b);
            set_sprite_prop(a, 0);
            move_sprite(a, i*8+96, j*8+96);
            a++;
        }
    }

    disable_interrupts();
    add_LCD(show_title_lcd_interrupt);
    enable_interrupts();
    set_bkg_data(0, _TITLE_TILE_COUNT, _title_tiles);
    set_bkg_data(_TITLE_TILE_COUNT, _VERSION_TILE_COUNT, _version_tiles);
    set_bkg_tiles(0, 0, _BEISBOL_LOGO_COLUMNS, _BEISBOL_LOGO_ROWS, _beisbol_logo_map);
    show_player(0);
    y = 64;
    x = 64;
    DISPLAY_ON;
    for (i = 0; i <= 64; i+=2) {
        y = 64-i;
        wait_vbl_done();
    }

    for (i = 0; i < _VERSION_COLUMNS; ++i) tiles[i] = _version_map[i] + _TITLE_TILE_COUNT;

    set_bkg_tiles(7,8,_VERSION_COLUMNS,_VERSION_ROWS,tiles);
    for (i = 0; i <= 64; i+=2) {
        x = -64+i;
        wait_vbl_done();
    }

    disable_interrupts();
    remove_LCD(show_title_lcd_interrupt);
    x = 128;
    add_LCD(cycle_players_lcd_interrupt);
    add_VBL(cycle_players_vbl_interrupt);
    enable_interrupts();
    z = 0;
    c = 0;
    while (1) {
        for (i = 0; i < 60; i++) {
            if (joypad() & (J_START | J_A)) return;
            wait_vbl_done();
        }
        for (j = 0; j <= 128; j+=6) {
            x = j+128;
            if (joypad() & (J_START | J_A)) return;
            wait_vbl_done();
        }
        z++;
        if (z == 16) z = 0;
        for (j = 0; j <= 128; j+=6) {
            x = j;
            if (joypad() & (J_START | J_A)) return;
            wait_vbl_done();
        }
    }
}

int show_start_menu () {
    DISPLAY_OFF;
    disable_interrupts();
    remove_LCD(cycle_players_lcd_interrupt);
    // remove_VBL(cycle_players_vbl_interrupt);
    enable_interrupts();
    clear_screen();

    set_bkg_data(0, _FONT_TILE_COUNT, _font_tiles);
    set_bkg_tiles(0, 0, 15, 8, 
        // "▛▄▄▄▄▄▄▄▄▄▄▄▄▄▜"
        // "▌             ▌"
        // "▌ CONTINUE    ▌"
        // "▌             ▌"
        // "▌ NEW GAME    ▌"
        // "▌             ▌"
        // "▌ OPTION      ▌"
        // "▙▄▄▄▄▄▄▄▄▄▄▄▄▄▟"

        "               "
        "               "
        "  CONTINUE     "
        "               "
        "  NEW GAME     "
        "               "
        "  OPTION       "
        "               " 
    );

    DISPLAY_ON;
    waitpadup();
    while (1) {
        k = joypad();
        if (k & (J_START | J_A)) return 1;
        else if (k & J_B) return 0;
        wait_vbl_done(); 
    }
    return 0;
}

void start_screen () {
    VBK_REG = 0;
    STAT_REG = 72;
    set_interrupts(LCD_IFLAG|VBL_IFLAG);
    show_copyrights();
    show_intro_sequence();
    d = 0;
    while (d == 0) {
        show_title();
        d = show_start_menu();
    }
}

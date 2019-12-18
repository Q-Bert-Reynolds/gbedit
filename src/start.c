#include "beisbol.h"
#include "../img/title/copyrights/copyrights.c"
#include "../img/title/intro/intro.c"
#include "../img/title/intro/intro_sprites/intro_sprites.c"

#ifdef HOME
    #include "../img/home_version/version_sprites/version_sprites.c"
#else
    #include "../img/away_version/version_sprites/version_sprites.c"
#endif

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
        update_vbl();
    }
    y = -8;
    for (x = 156; x > 94; x-=2) {
        move_sprite(0, x, y+=3);
        if (joypad() & (J_START | J_A)) return;
        update_vbl();
    }
    set_bkg_tiles(10, 8, _INTRO_LIGHT_OUT_COLUMNS, _INTRO_LIGHT_OUT_ROWS, _intro_light_out_map);
    // start playing stars animation
    for (x = 0; x < 40; ++x) {
        move_sprite(0, x+94, y+=4);
        BGP_REG = lights_pal_seq[x];
        if (joypad() & (J_START | J_A)) return;
        update_vbl();
    }
    for (i = 0; i < 60; i++) {
        if (joypad() & (J_START | J_A)) return;
        update_vbl();
    }
}

void pitch_sequence () {
    update_vbl();
    set_bkg_tiles(0, 0, _INTRO_PITCH_COLUMNS, _INTRO_PITCH_ROWS, _intro_pitch_map);
    BGP_REG = BG_PALETTE;
    for (i = 0; i < _INTRO0_COLUMNS*_INTRO0_ROWS; i++) {
        set_sprite_tile(i, _intro0_map[i]+_INTRO_SPRITES_TILE_COUNT);
        set_sprite_prop(i, S_PRIORITY);
    }
    for (k = 0; k <= 128; ++k) {
        if (joypad() & (J_START | J_A)) return;
        move_bkg(k+32, 0);
        a = 0;
        for (j = 0; j < _INTRO0_ROWS; j++) {
            for (i = 0; i < _INTRO0_COLUMNS; i++) {
                move_sprite(a++, k+i*8-32, j*8+80);
            }
        }
        update();
    }
    for (i = 0; i < 60; i++) {
        if (joypad() & (J_START | J_A)) return;
        update_vbl();
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
    FADE_OUT();
}

void start () {
    VBK_REG = 0;
    STAT_REG = 0;
    set_interrupts(VBL_IFLAG);
    show_copyrights();
    show_intro_sequence();
}

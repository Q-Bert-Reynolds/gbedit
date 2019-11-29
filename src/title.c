#include "beisbol.h"
#include "../res/title/title/title.c"
#include "../res/title/title/title_sprites/title_sprites.c"

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

const unsigned char ball_toss[] = {16,15,15,14,14,13,13,12,12,11,11,10,10,10,9,9,9,8,8,7,7,7,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,7,7,7,8,8,9,9,9,10,10,10,11,11,12,12,13,13,14,14,15,15};
void show_title () {
    DISPLAY_OFF;
    clear_screen();
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    OBP1_REG = SPR_PALETTE_1;

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
    move_sprite(5, 94, 117); // move ball to hand

    disable_interrupts();
    add_LCD(show_title_lcd_interrupt);
    enable_interrupts();
    set_interrupts(LCD_IFLAG|VBL_IFLAG);
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

    set_bkg_tiles_with_offset(7,8,_VERSION_COLUMNS,_VERSION_ROWS,_TITLE_TILE_COUNT,_version_map);
    for (i = 0; i <= 64; i+=2) {
        x = -64+i;
        wait_vbl_done();
    }
    wait_vbl_done();
    disable_interrupts();
    remove_LCD(show_title_lcd_interrupt);
    x = 128;
    add_LCD(cycle_players_lcd_interrupt);
    enable_interrupts();
    z = 0;
    while (1) {
        for (i = 0; i < 60; i++) {
            if (joypad() & (J_START | J_A)) return;
            wait_vbl_done();
        }
        for (j = 0; j <= 128; j+=6) {
            x = j+128;
            if (joypad() & (J_START | J_A)) return;
            if (z == 0) move_sprite(5, 94, 101 + ball_toss[j]);
            wait_vbl_done();
        }
        z++;
        if (z == 16) z = 0;
        disable_interrupts();
        show_player(z);
        enable_interrupts();
        for (j = 0; j <= 128; j+=6) {
            x = j;
            if (joypad() & (J_START | J_A)) return;
            wait_vbl_done();
        }
    }
}

UBYTE show_start_menu () {
    DISPLAY_OFF;
    disable_interrupts();
    remove_LCD(cycle_players_lcd_interrupt);
    enable_interrupts();
    set_interrupts(VBL_IFLAG);
    clear_screen();
    set_bkg_data(0, _UI_FONT_TILE_COUNT, _ui_font_tiles);
    DISPLAY_ON;

    disable_interrupts();
    ENABLE_RAM_MBC5;
    memcpy(name_buff, user_name, 7);
    DISABLE_RAM_MBC5;
    enable_interrupts();
    while (name_buff[0] > 0) {
        c = 3; // even though c is set in show_list_menu, it gets reset to original value when it returns
        y = show_list_menu(0,0,15,8,"","CONTINUE\nNEW GAME\nOPTION");
        if (y == 1) {
            wait_vbl_done();
            draw_bkg_ui_box(4,7,16,10);
            set_bkg_tiles(5,9,5,1,"COACH");
            set_bkg_tiles(11,9,strlen(name_buff),1,name_buff);
            set_bkg_tiles(5,11,8,1,"PENNANTS");
            set_bkg_tiles(18,11,1,1,"0");//+penant_count);
            set_bkg_tiles(5,13,7,1, "ROLeDEX"); // "ROL\x7FDEX" draws trash here for some reason
            set_bkg_tiles(8,13,1,1,"\x7F"); // HACK: wouldn't be necessary if "ROL\x7FDEX" worked above
            sprintf(str_buff, "%d", 151);
            set_bkg_tiles(16,13,3,1,str_buff);
            set_bkg_tiles(5,15,4,1,"TIME");
            sprintf(str_buff, "%d:%d", 999, 59);
            l = strlen(str_buff);
            set_bkg_tiles(19-l,15,l,1,str_buff);
            waitpadup();
            while (1) {
                if (joypad() & J_A) return y;
                else if (joypad() & J_B) {
                    clear_bkg_area(4,7,16,10);
                    break;
                }
                wait_vbl_done();
            }
        }
        else return y;
    }
    c = 2;
    return show_list_menu(0,0,15,6,"","NEW GAME\nOPTION");
}

void move_options_arrow (int y) {
    tiles[0] = 0;
    tiles[1] = ARROW_RIGHT;
    tiles[2] = ARROW_RIGHT_BLANK;
    set_bkg_tiles(1,3,1,1,tiles + (text_speed==0 ? 2 : 0) - (y==0 ? 1 : 0));
    set_bkg_tiles(7,3,1,1,tiles + (text_speed==1 ? 2 : 0) - (y==0 ? 1 : 0));
    set_bkg_tiles(14,3,1,1,tiles + (text_speed==2 ? 2 : 0) - (y==0 ? 1 : 0));
    set_bkg_tiles(1,8,1,1,tiles + (animation_style==0 ? 2 : 0) - (y==1 ? 1 : 0));
    set_bkg_tiles(10,8,1,1,tiles + (animation_style==1 ? 2 : 0) - (y==1 ? 1 : 0));
    set_bkg_tiles(1,13,1,1,tiles + (coaching_style==0 ? 2 : 0) - (y==2 ? 1 : 0));
    set_bkg_tiles(10,13,1,1,tiles + (coaching_style==1 ? 2 : 0) - (y==2 ? 1 : 0));
    set_bkg_tiles(1,16,1,1,tiles + (y==3 ? 1 : 2));
}

void show_options () {
    DISPLAY_OFF;
    draw_bkg_ui_box(0,0,20,5);
    set_bkg_tiles(1,1,18,3,
        "TEXT SPEED        "
        "                  "
        " FAST  MEDIUM SLOW"
    );

    draw_bkg_ui_box(0,5,20,5);
    set_bkg_tiles(1,6,18,3,
        "AT-BAT ANIMATIONS "
        "                  "
        " ON       OFF     "
    );

    draw_bkg_ui_box(0,10,20,5);
    set_bkg_tiles(1,11,18,3,
        "COACHING STYLE    "
        "                  "
        " SHIFT    SET     "
    );
    set_bkg_tiles(2,16,6,1,
        "CANCEL"
    );

    DISPLAY_ON;
    waitpadup();
    y = 0;
    move_options_arrow(y);
    while (1) {
        k = joypad();
        if (k & J_UP && y > 0) {
            wait_vbl_done(); 
            move_options_arrow(--y);
            waitpadup();
        }
        else if (k & J_DOWN && y < 3) {
            wait_vbl_done(); 
            move_options_arrow(++y);
            waitpadup();
        }
        else if (k & J_LEFT && y < 3) {
            wait_vbl_done(); 
            if (y == 0 && text_speed > 0) --text_speed;
            else if (y == 1 && animation_style > 0) --animation_style;
            else if (y == 2 && coaching_style > 0) --coaching_style;
            move_options_arrow(y);
            waitpadup();
        }
        else if (k & J_RIGHT && y < 3) {
            wait_vbl_done(); 
            if (y == 0 && text_speed < 2) ++text_speed;
            else if (y == 1 && animation_style < 1) ++animation_style;
            else if (y == 2 && coaching_style < 1) ++coaching_style;
            move_options_arrow(y);
            waitpadup();
        }

        if (k & (J_START | J_A) && y == 3) return;
        else if (k & J_B) return;
        wait_vbl_done(); 
    }
}

UBYTE title () {
    VBK_REG = 0;
    STAT_REG = 72;
    set_interrupts(LCD_IFLAG|VBL_IFLAG);
    d = 0;
    while (d == 0 || d == c) {
        if (d == 0) show_title();
        else if (d == c) {
            show_options();
            d = 0;
        }
        d = show_start_menu();
    }
    return (UBYTE)(c-d-1);
}

#include "beisbol.h"
#include "../img/title/title/title.c"
#include "../img/title/title/title_sprites/title_sprites.c"

#ifdef HOME
    #include "../img/home_version/version.c"
    const unsigned char intro_player_nums[] = { 4, 7, 1, 13, 32, 123, 25, 35, 112, 63, 092, 132, 17, 095, 77, 129, };
#else
    #include "../img/away_version/version.c"
    const unsigned char intro_player_nums[] = { 7, 4, 1, 56, 106, 37, 113, 142, 135, 143, 44, 60, 84, 137, 94, 26 };
#endif

#define PLAYER_INDEX _TITLE_TILE_COUNT+_VERSION_TILE_COUNT

void show_player (UBYTE p) {
    load_player_bkg_data(intro_player_nums[p], PLAYER_INDEX, TITLE_BANK);
    a = 7-get_player_img_columns (intro_player_nums[p], TITLE_BANK);
    CLEAR_BKG_AREA(20,10,7,7,0);
    set_player_bkg_tiles(20+a, 10+a, intro_player_nums[p], PLAYER_INDEX, TITLE_BANK);
}

const unsigned char ball_toss[] = {16,15,15,14,14,13,13,12,12,11,11,10,10,10,9,9,9,8,8,7,7,7,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,7,7,7,8,8,9,9,9,10,10,10,11,11,12,12,13,13,14,14,15,15};
void show_title () {
    DISPLAY_OFF;
    CLEAR_SCREEN(0);
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    OBP1_REG = 0xE0;

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
    set_sprite_prop(5, S_PALETTE);

    disable_interrupts();
    lcd_i = 0;
    lcd_count = 4;
    lcd_line[0] = 0;
    lcd_line[1] = 63;
    lcd_line[2] = 71;
    lcd_line[3] = 135;
    lcd_x[0] = 0;
    lcd_x[1] = 64;
    lcd_x[2] = 128;
    lcd_x[3] = 0;
    lcd_y[0] = 64;
    lcd_y[1] = 0; 
    lcd_y[2] = 0;
    lcd_y[3] = 0; 
    add_LCD(lcd_interrupt);
    enable_interrupts();
    set_interrupts(LCD_IFLAG|VBL_IFLAG);
    set_bkg_data(0, _TITLE_TILE_COUNT, _title_tiles);
    set_bkg_data(_TITLE_TILE_COUNT, _VERSION_TILE_COUNT, _version_tiles);
    set_bkg_tiles(0, 0, _BEISBOL_LOGO_COLUMNS, _BEISBOL_LOGO_ROWS, _beisbol_logo_map);
    show_player(0);
    DISPLAY_ON;
    x = 64;
    y = 64;
    for (i = 0; i <= 64; i+=2) {
        lcd_y[0] = 64-i;
        y = 64-i;
        update_vbl(TITLE_BANK);
    }

    set_bkg_tiles_with_offset(7,8,_VERSION_COLUMNS,_VERSION_ROWS,_TITLE_TILE_COUNT,_version_map);
    for (i = 0; i <= 64; i+=2) {
        lcd_x[1] = -64+i;
        x = -64+i;
        update_vbl(TITLE_BANK);
    }
    
    disable_interrupts();
    lcd_i = 0;
    lcd_count = 2;
    lcd_line[0] = 72;
    lcd_line[1] = 135;
    lcd_x[0] = 128;
    lcd_x[1] = 0;
    lcd_y[0] = 0;
    lcd_y[1] = 0; 
    enable_interrupts();
    
    z = 0;
    while (1) {
        for (i = 0; i < 60; i++) {
            if (joypad() & (J_START | J_A)) return;
            update_vbl(TITLE_BANK);
        }
        for (j = 0; j <= 128; j+=6) {
            lcd_x[0] = j+128;
            if (joypad() & (J_START | J_A)) return;
            if (z == 0) move_sprite(5, 94, 101 + ball_toss[j]);
            update_vbl(TITLE_BANK);
        }
        z++;
        if (z == 16) z = 0;
        disable_interrupts();
        show_player(z);
        enable_interrupts();
        for (j = 0; j <= 128; j+=6) {
            lcd_x[0] = j;
            if (joypad() & (J_START | J_A)) return;
            update_vbl(TITLE_BANK);
        }
    }
}

UBYTE show_start_menu () {
    DISPLAY_OFF;
    disable_interrupts();
    remove_LCD(lcd_interrupt);
    enable_interrupts();
    set_interrupts(VBL_IFLAG);
    CLEAR_SCREEN(0);
    load_font_tiles(TITLE_BANK);
    DISPLAY_ON;

    disable_interrupts();
    ENABLE_RAM_MBC5;
    memcpy(name_buff, user_name, 7);
    DISABLE_RAM_MBC5;
    enable_interrupts();
    while (name_buff[0] > 0) {
        c = 3; // even though c is set in show_list_menu, it gets reset to original value when it returns
        y = show_list_menu(0,0,15,8,"","CONTINUE\nNEW GAME\nOPTION",TITLE_BANK);
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
                    CLEAR_BKG_AREA(4,7,16,10,0);
                    break;
                }
                update_vbl(TITLE_BANK);
            }
        }
        else return y;
    }
    c = 2;
    return show_list_menu(0,0,15,6,"","NEW GAME\nOPTION",TITLE_BANK);
}

UBYTE title () {
    VBK_REG = 0;
    STAT_REG = 72;
    set_interrupts(LCD_IFLAG|VBL_IFLAG);
    d = 0;
    while (d == 0 || d == c) {
        if (d == 0) show_title();
        else if (d == c) {
            show_options(TITLE_BANK);
            d = 0;
        }
        d = show_start_menu();
    }
    return (UBYTE)(c-d-1);
}

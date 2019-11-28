#include "beisbol.h"
#include "../res/baseball.c"
#include "../res/circle.c"
#include "../res/play/righty_batter_user/righty_batter_user.c"
#include "../res/play/lefty_batter_user/lefty_batter_user.c"
#include "../res/coaches/calvin_back.c"
#include "../res/players/080Laggard.c"

struct player test_player;
struct move move1;
struct move move2;

UBYTE balls   () { return (balls_strikes_outs & BALLS_MASK  ) >> 4; }
UBYTE strikes () { return (balls_strikes_outs & STRIKES_MASK) >> 2; }
UBYTE outs    () { return (balls_strikes_outs & OUTS_MASK   ); }

void move_coach () {
    LYC_REG = 0;
    SCX_REG = 256-x;
    for (j = 0; j < 3; ++j) {
        for (i = 0; i < _CALVIN_BACK_COLUMNS-1; ++i) {
            move_sprite(j*(_CALVIN_BACK_COLUMNS-1)+i, i*8+x+16, j*8+56);
        }
    }
}

void slide_in_lcd_interrupt(void) {
    if (LY_REG == 0){
        LYC_REG = 56;
        SCX_REG = x;
    }
    else if (LY_REG == 56) move_coach();
}

void slide_out_lcd_interrupt(void) {
    if (LY_REG == 0){
        LYC_REG = 56;
        SCX_REG = 0;
    }
    else if (LY_REG == 56) move_coach();
}

char *health_pct (struct player *p) {
    a = p->hp; // * 100 / max_hp; 
    if (a >= 100) strcpy(str_buff, "100");
    if (a < 10) sprintf(str_buff, "0%d%c", a, '%');
    else sprintf(str_buff, "%d%c", a, '%');
    return str_buff;
}

char *batting_avg (struct player *p) {
    a = p->hits * 1000 / p->at_bats;
    if (a >= 1000) strcpy(str_buff, "1.000");
    else if (a < 10) sprintf(str_buff, ".00%d", a);
    else if (a < 100) sprintf(str_buff, ".0%d", a);
    else sprintf(str_buff, ".%d", a);
    return str_buff;
}

char *earned_run_avg (struct player *p) {
    a = p->runs_allowed * 2700 / p->outs_recorded;
    b = a/100;
    c = a%100;
    if (b >= 1000) sprintf(str_buff, "%d", b);
    else sprintf(str_buff, "%d.%d", b, c);
    return str_buff;
}

// TODO: this can probably be cleaned up a bit
void set_bkg_data_doubled (UINT8 first_tile, UINT8 nb_tiles, unsigned char *data) {
    for (i = 0; i < nb_tiles*16; i+=16) {
        for (j = 0; j < 8; j+=2) {
            b = data[i+j];
            tiles[i*4+j*2]    = (b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1);
            tiles[i*4+j*2+16] = ((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1);
            tiles[i*4+j*2+2]  = tiles[i*4+j*2];
            tiles[i*4+j*2+18] = tiles[i*4+j*2+16];
            b = data[i+j+1];
            tiles[i*4+j*2+1]  = (b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1);
            tiles[i*4+j*2+17] = ((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1);
            tiles[i*4+j*2+3]  = tiles[i*4+j*2+1];
            tiles[i*4+j*2+19] = tiles[i*4+j*2+17];
            b = data[i+j+8];
            tiles[i*4+j*2+32] = (b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1);
            tiles[i*4+j*2+48] = ((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1);
            tiles[i*4+j*2+34] = tiles[i*4+j*2+32];
            tiles[i*4+j*2+50] = tiles[i*4+j*2+48];
            b = data[i+j+9];
            tiles[i*4+j*2+33] = (b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1);
            tiles[i*4+j*2+49] = ((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1);
            tiles[i*4+j*2+35] = tiles[i*4+j*2+33];
            tiles[i*4+j*2+51] = tiles[i*4+j*2+49];
        }
    }
    set_bkg_data(first_tile, nb_tiles*4, tiles);
}

void play_intro () {
    set_bkg_data_doubled(32+_FONT_TILE_COUNT, _CALVIN_BACK_TILE_COUNT, _calvin_back_tiles); 
    set_bkg_data(207, _080LAGGARD_TILE_COUNT, _080Laggard_tiles);
    draw_win_ui_box(0,0,20,6);
    move_win(0,96);
    SHOW_WIN;

    for (j = 0; j < _CALVIN_BACK_ROWS-1; ++j) {
        for (i = 0; i < _CALVIN_BACK_COLUMNS-1; ++i) {
            if (j < 3) {
                set_sprite_tile(
                    j*(_CALVIN_BACK_COLUMNS-1)+i, 
                    _calvin_back_map[j*_CALVIN_BACK_COLUMNS+i]+32+_FONT_TILE_COUNT
                );
            }
            else {
                tiles[(j-3)*(_CALVIN_BACK_COLUMNS-1)+i] = 
                    _calvin_back_map[j*_CALVIN_BACK_COLUMNS+i]+32+_FONT_TILE_COUNT;
            }
        }
    }
    set_bkg_tiles(1,16-_CALVIN_BACK_ROWS,_CALVIN_BACK_COLUMNS-1,_CALVIN_BACK_ROWS-4,tiles);
    set_bkg_tiles_with_offset(19-_080LAGGARD_COLUMNS,7-_080LAGGARD_ROWS,_080LAGGARD_COLUMNS,_080LAGGARD_ROWS,207,_080Laggard_map);

    move_bkg(160,0);
    VBK_REG = 0;
    STAT_REG = 72;
    set_interrupts(LCD_IFLAG|VBL_IFLAG);
    disable_interrupts();
    add_LCD(slide_in_lcd_interrupt);
    enable_interrupts();
    DISPLAY_ON;
    for (x = 160; x >= 0; x-=2) {
        wait_vbl_done();
    }
    disable_interrupts();
    remove_LCD(slide_in_lcd_interrupt);
    enable_interrupts();
    set_interrupts(VBL_IFLAG);
    
    sprintf(str_buff, "Unsigned %s\nappeared!", "LAGGARD");
    reveal_text(str_buff);

    disable_interrupts();
    add_LCD(slide_out_lcd_interrupt);
    enable_interrupts();
    set_interrupts(VBL_IFLAG | LCD_IFLAG);
    for (x = 0; x > -80; x-=2) {
        wait_vbl_done();
    }
    disable_interrupts();
    remove_LCD(slide_out_lcd_interrupt);
    clear_bkg_area(1,16-_CALVIN_BACK_ROWS,_CALVIN_BACK_COLUMNS-1,_CALVIN_BACK_ROWS-4);
    enable_interrupts();
    set_interrupts(VBL_IFLAG);
    hide_sprites();
    wait_vbl_done();
    move_bkg(0,0);

    set_bkg_data(32+_FONT_TILE_COUNT, _RIGHTY_BATTER_USER_TILE_COUNT, _righty_batter_user_tiles); 
    set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,32+_FONT_TILE_COUNT,_righty_batter_user0_map);
    reveal_text("Let's go!");
    HIDE_WIN;
}

void draw_player_ui (UBYTE team, struct player *p) {
    if (team) x = 0, y = 2;
    else x = 8, y = 10;

    b = (team == home_team) != (frame % 2);

    tiles[0] = 0;
    for (i = 0; i < 10; i++) tiles[i+2] = BOX_HORIZONTAL;
    l = strlen(p->nickname);
    w = 1+(12-l)/2;
    for (i = 0; i < l; i++) tiles[w+i] = p->nickname[i];
    if (p->level == 100) {
        tiles[12] = 49; 
        tiles[13] = 48; 
        tiles[14] = 48;
    }
    else {
        tiles[12] = LEVEL;
        if (p->level < 10) {
            tiles[13] = 48+p->level;
            tiles[14] = 0;
        }
        else {
            tiles[13] = 48+p->level/10;
            tiles[14] = 48+p->level%10;
        }
    }
    if (b) {
        tiles[1] = NUMBERS + p->batting_order;
        tiles[15] = BATTING_AVG;
    }
    else {
        tiles[1] = p->position;
        tiles[15] = EARNED_RUN_AVG;
    }
    tiles[20] = 0;
    set_bkg_tiles(x,y,12,2,tiles);
    if (b) set_bkg_tiles(x+4,y+1,4,1,batting_avg(p));
    else set_bkg_tiles(x+4,y+1,4,1,earned_run_avg(p));
    set_bkg_tiles(x+9,y+1,3,1,health_pct(p));
}

void draw_bases () {
    for (i = 0; i < 5; i+=2) tiles[i] = 0;
    tiles[5] = (runners_on_base & FIRST_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
    tiles[1] = (runners_on_base & SECOND_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
    tiles[3] = (runners_on_base & THIRD_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
    set_bkg_tiles(9,0,3,2,tiles);
}

void draw_count_outs_inning () {
    tiles[0] = (frame % 2 == 0) ? INNING_TOP : INNING_BOTTOM;
    tiles[1] = 49 + frame/2;
    set_bkg_tiles(1,13,2,1,tiles);
    set_bkg_tiles(1,14,1,3,"BSO");
    for (i = 0; i < 4; i++) tiles[0+i] = (i < balls()  ) ? BASEBALL : DOTTED_CIRCLE;
    for (i = 0; i < 3; i++) tiles[4+i] = (i < strikes()) ? BASEBALL : DOTTED_CIRCLE;
    tiles[7] = 0;
    for (i = 0; i < 3; i++) tiles[8+i] = (i < outs()   ) ? BASEBALL : DOTTED_CIRCLE;
    tiles[11] = 0;
    set_bkg_tiles(2,14,4,3,tiles);
}

void draw_team_names () {
    disable_interrupts();
    ENABLE_RAM_MBC5;
    memcpy(name_buff, user_name, 7);
    if (name_buff[0] == 0) {
        set_bkg_tiles(0,0,4,1,"Home");
        set_bkg_tiles(0,1,4,1,"Away");
    }
    else {
        if (home_team) set_bkg_tiles(0,1,7,1,name_buff);
        else set_bkg_tiles(0,0,7,1,name_buff);
        memcpy(name_buff, rival_name, 8);
        if (home_team) set_bkg_tiles(0,0,7,1,name_buff);
        else set_bkg_tiles(0,1,7,1,name_buff);
    }
    DISABLE_RAM_MBC5;
    enable_interrupts();    
}

void draw_score () {
    sprintf(name_buff, "%d", home_score);
    l = strlen(name_buff);
    set_bkg_tiles(9,0,l,1,name_buff);
    sprintf(name_buff, "%d", away_score);
    l = strlen(name_buff);
    set_bkg_tiles(9,1,l,1,name_buff);
}

void draw_ui () {
    draw_team_names();
    draw_score();
    draw_bases();
    draw_player_ui(0, &test_player);
    draw_player_ui(1, &test_player);
    draw_bkg_ui_box(0,12,20,6);
    draw_count_outs_inning();
    set_bkg_tiles(9,14,10,3,
        "PLAY  TEAM"
        "          "
        "ITEM  RUN "
    );
    DISPLAY_ON;
}

void move_play_menu_arrow () {
    for (i = 0; i < 2; i++) {
        for (j = 0; j < 2; j++) {
            tiles[0] = (x==i && y==j) ? ARROW_RIGHT : 0;
            set_bkg_tiles(i*6+8,j*2+14,1,1,tiles);
        }
    }
}

UBYTE select_play_menu_item () {
    move_play_menu_arrow();
    waitpadup();
    while (1) {
        k = joypad();
        if (k & J_UP && y == 1) { y = 0; move_play_menu_arrow(); }
        else if (k & J_DOWN && y == 0) { y = 1; move_play_menu_arrow(); }
        else if (k & J_LEFT && x == 1) { x = 0; move_play_menu_arrow(); }
        else if (k & J_RIGHT && x == 0) { x = 1; move_play_menu_arrow(); }

        if (k & J_A) return x * 2 + y;
    }
    return 0;
}

void move_move_menu_arrow (int y) {
    for (i = 0; i < 4; i++) {
        tiles[i] = (i == y) ? ARROW_RIGHT : 0;
    }
    set_bkg_tiles(6,13,1,4,tiles);
}

void show_move_info () {//struct move *m) {
    draw_bkg_ui_box(0,8,11,5);
    set_bkg_tiles(1,9,5,1,"TYPE/");
    strcpy(name_buff, types[0]);//m->type]);
    set_bkg_tiles(2,10,strlen(name_buff),1,name_buff);
    set_bkg_tiles(5,11,5,1,"22/35"); //TODO: use real numbers
}

UBYTE select_move_menu_item (struct player *p) { // input should be move struct
    get_bkg_tiles(0,8,20,10,bkg_buff);
    draw_bkg_ui_box(5,12,15,6);

    c = 4;
    for (i = 0; i < 4; ++i) {
        if ((p->moves)[i] == NULL) { c = i; break; }
        memcpy(name_buff, (p->moves)[i]->name, 16);
        set_bkg_tiles(7,13+i,strlen(name_buff),1,name_buff);
    }
    if (c < 4) set_bkg_tiles(7,c+13,2,4-c,"--------");

    move_move_menu_arrow(move_choice);
    show_move_info();//p->moves[move_choice]);

    waitpadup();
    while (1) {
        k = joypad();
        if (k & J_UP && move_choice > 0) {
            wait_vbl_done();
            --move_choice;
            move_move_menu_arrow(move_choice);
            show_move_info();//p->moves[move_choice]);
            waitpadup();
        }
        else if (k & J_DOWN && move_choice < c-1) {
            wait_vbl_done();
            ++move_choice;
            move_move_menu_arrow(move_choice);
            show_move_info();//p->moves[move_choice]);
            waitpadup();
        }
        if (k & (J_START | J_A)) {
            set_bkg_tiles(0,8,20,10,bkg_buff);
            return move_choice+1;
        }
        else if (k & J_B) break;
        wait_vbl_done(); 
    }
    set_bkg_tiles(0,8,20,10,bkg_buff);
    return 0;
}

void show_aim_circle (UBYTE size) {
    SPRITES_8x8;
    i = (size%8)+_BASEBALL_TILE_COUNT;
    set_sprite_tile(1, i);
    set_sprite_prop(1, USE_PAL);
    set_sprite_tile(2, i);
    set_sprite_prop(2, FLIP_X_PAL);
    set_sprite_tile(3, i);
    set_sprite_prop(3, FLIP_Y_PAL);
    set_sprite_tile(4, i);
    set_sprite_prop(4, FLIP_XY_PAL);
}

void move_aim_circle (UBYTE x, UBYTE y) {
    move_sprite(1, x,   y);
    move_sprite(2, x+8, y);
    move_sprite(3, x,   y+8);
    move_sprite(4, x+8, y+8);
}

void pitch (struct player *p, int move) {
    sprintf(str_buff, "%s sets.", p->nickname);
    reveal_text(str_buff);
    show_aim_circle(3);
    move_aim_circle(96,32);
}

void bat (struct player *p, int move) {
    set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,32+_FONT_TILE_COUNT,_righty_batter_user0_map);
    show_aim_circle(7);
    move_aim_circle(49,85); //TODO: handle lefty batters
    sprintf(str_buff, "%s steps\ninto the box.\0", p->nickname);
    display_text(str_buff);
    a = 49<<1;
    b = 85<<1;
    for (i = 0; i < 60; ++i) {
        k = joypad();
        if (k & J_RIGHT) ++a;
        else if (k & J_LEFT) --a;
        if (k & J_DOWN) ++b;
        else if (k & J_UP) --b;
        move_aim_circle(a>>1, b>>1);
        wait_vbl_done();
    }
    sprintf(str_buff, "%s sets.\0", "LAGGARD");
    display_text(str_buff);
    for (i = 0; i < 60; ++i) { // TODO: quick pitch should decrease this time
        k = joypad();
        if (k & J_RIGHT) ++a;
        else if (k & J_LEFT) --a;
        if (k & J_DOWN) ++b;
        else if (k & J_UP) --b;
        move_aim_circle(a>>1, b>>1);
        wait_vbl_done();
    }
    display_text("And the pitch.");
    x = 144<<1;
    y = 16<<1;

    c = 0;
    for (i = 0; i < 150; ++i) {
        // bat
        k = joypad();
        if (c == 0 && i > 0) {
            if (k & J_RIGHT) ++a;
            else if (k & J_LEFT) --a;
            if (k & J_DOWN) ++b;
            else if (k & J_UP) --b;
            move_aim_circle(a>>1, b>>1);

            if (k & J_A) {
                c = i;
                set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,32+_FONT_TILE_COUNT,_righty_batter_user1_map);
            }
        }
        else if (i == c + 2) {
            set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,32+_FONT_TILE_COUNT,_righty_batter_user2_map);
        }
        
        // pitch
        x -= 4;
        y += 3;
        set_sprite_tile(0, 6 + (i/10)%4);
        move_sprite(0, x>>1, y>>1);
        wait_vbl_done();
    }
    set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,32+_FONT_TILE_COUNT,_righty_batter_user0_map);
}

void play_ball (struct player *p, int move) {
    if (home_team == (frame % 2)) bat(p, move);
    else pitch(p, move);
    HIDE_WIN;
}

void start_game () {
    DISPLAY_OFF;
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    move_bkg(0,0);
    clear_screen();
    set_bkg_data(0, _UI_TILE_COUNT, _ui_tiles);
    set_bkg_data(32, _FONT_TILE_COUNT, _font_tiles);
    set_sprite_data(0, _BASEBALL_TILE_COUNT, _baseball_tiles);
    set_sprite_data(_BASEBALL_TILE_COUNT, _CIRCLE_TILE_COUNT, _circle_tiles);

    balls_strikes_outs = (3 << 4) | (2 << 2) | 1;
    runners_on_base = (9 << 8) | 5;
    frame = 0;
    home_team = 0;
    home_score = 1;
    away_score = 3;
    move_choice = 0;

    test_player.position = 1;
    test_player.batting_order = 3;
    test_player.level = 77;
    test_player.hp = 97;
    test_player.at_bats = 100;
    test_player.hits = 32;
    test_player.moves[0] = &move1;
    test_player.moves[1] = &move2;
    strcpy(move1.name, "FASTBALL");
    strcpy(move2.name, "BUNT");
    strcpy(test_player.nickname, "TEST");

    play_intro();
    draw_ui();
    
    x = 0;
    y = 0;
    while (1) {
        a = select_play_menu_item();
        switch (a) {
            case 0:
                b = select_move_menu_item(&test_player);
                if (b > 0) play_ball(&test_player, b-1);
                x = 0;
                y = 0;
                break;
            case 1:
                break;
            case 2:
                break;
            case 3:
                reveal_text("Quitting is\nnot an option!");
                HIDE_WIN;
                break;
        }
    }
}

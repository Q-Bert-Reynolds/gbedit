#include "beisbol.h"
#include "../res/coaches/calvin_back.c"

UBYTE balls   () { return (balls_strikes_outs & BALLS_MASK  ) >> 4; }
UBYTE strikes () { return (balls_strikes_outs & STRIKES_MASK) >> 2; }
UBYTE outs    () { return (balls_strikes_outs & OUTS_MASK   ); }

// void slide_in_players(void) {
//     if (LY_REG == 72){
//         LYC_REG = 135;
//         SCX_REG = x;
//     }
//     else if (LY_REG == 135) {
//         LYC_REG = 72;
//         SCX_REG = 0;
//     }
// }

void play_intro () {
    set_bkg_data(32+_FONT_TILE_COUNT, _CALVIN_BACK_TILE_COUNT, _calvin_back_tiles); 
    draw_bkg_ui_box(0,12,20,6);
    for (j = 0; j < _CALVIN_BACK_ROWS; ++j) {
        for (i = 0; i < _CALVIN_BACK_COLUMNS; ++i) {
            tiles[j*_CALVIN_BACK_COLUMNS+i] = _calvin_back_map[j*_CALVIN_BACK_COLUMNS+i]+32+_FONT_TILE_COUNT;
        }
    }
    set_bkg_tiles(0,12-_CALVIN_BACK_ROWS,_CALVIN_BACK_COLUMNS,_CALVIN_BACK_ROWS,tiles);
    // set_bkg_data_doubled()
    DISPLAY_ON;
    waitpad(J_A);
    waitpadup();
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
    tiles[12] = LEVEL;
    tiles[13] = 48+p->level; // this won't work for lvl > 9
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

void start_game () {
    DISPLAY_OFF;
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    move_bkg(0,0);
    clear_screen();
    set_bkg_data(0, _UI_TILE_COUNT, _ui_tiles);
    set_bkg_data(32, _FONT_TILE_COUNT, _font_tiles);

    balls_strikes_outs = (3 << 4) | (2 << 2) | 1;
    runners_on_base = (9 << 8) | 5;
    frame = 0;
    home_team = 0;
    home_score = 1;
    away_score = 3;

    test_player.position = 1;
    test_player.batting_order = 3;
    test_player.level = 7;
    test_player.hp = 97;
    test_player.at_bats = 100;
    test_player.hits = 32;
    strcpy(test_player.nickname, "TEST");

    play_intro();
    draw_ui();
}

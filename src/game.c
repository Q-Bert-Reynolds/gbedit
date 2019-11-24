#include "beisbol.h"

void draw_player_ui (int x, int y, int position, int lvl, float avg, char *name) {
    tiles[0] = 0;
    tiles[1] = position;
    for (i = 0; i < 10; i++) tiles[i+2] = BOX_HORIZONTAL;
    l = strlen(name);
    w = 1+(12-l)/2;
    for (i = 0; i < l; i++) tiles[w+i] = name[i];
    tiles[12] = LEVEL;
    tiles[13] = 48+lvl; // this won't work for lvl > 9
    tiles[15] = position > 48 ? BATTING_AVG : EARNED_RUN_AVG;
    sprintf(str_buff, "%f", avg);
    for (i = 0; i < 4; i++) tiles[16+i] = str_buff[i];
    set_bkg_tiles(x,y,12,2,tiles);
}

void draw_bases () {
    for (i = 0; i < 3; i++) {
        tiles[i*2] = 0;
        tiles[i*2+1] = 23;
    }
    set_bkg_tiles(9,0,3,2,tiles);
}

UBYTE balls = 3;
UBYTE strikes = 2;
UBYTE outs = 1; 
void draw_count_outs_inning () {
    tiles[0] = INNING_TOP;
    tiles[1] = 48+9;
    set_bkg_tiles(1,13,2,1,tiles);
    set_bkg_tiles(1,14,1,3,"BSO");
    for (i = 0; i < 4; i++) tiles[0+i] = (i < balls) ? BASEBALL : DOTTED_CIRCLE;
    for (i = 0; i < 3; i++) tiles[4+i] = (i < strikes) ? BASEBALL : DOTTED_CIRCLE;
    tiles[7] = 0;
    for (i = 0; i < 3; i++) tiles[8+i] = (i < outs) ? BASEBALL : DOTTED_CIRCLE;
    tiles[11] = 0;
    set_bkg_tiles(2,14,4,3,tiles);
}

void draw_ui () {
    set_bkg_tiles(0,0,9,1,"Home   0 ");
    set_bkg_tiles(0,1,9,1,"Away   0 ");
    draw_bases();
    draw_player_ui(0,2,1,7,0.327f,"BEAR");
    draw_player_ui(8,10,49,9,1.27f,"BUBBIE");
    draw_bkg_ui_box(0,12,20,6);
    draw_count_outs_inning();
    set_bkg_tiles(9,14,10,3,
        "PLAY  TEAM"
        "          "
        "ITEM  RUN "
    );
}

void start_game () {
    DISPLAY_OFF;
    clear_screen();
    set_bkg_data(0, _UI_TILE_COUNT, _ui_tiles);
    set_bkg_data(32, _FONT_TILE_COUNT, _font_tiles);
    draw_ui();
    DISPLAY_ON;
}
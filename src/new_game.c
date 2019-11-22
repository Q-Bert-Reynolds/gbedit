#include "beisbol.h"
#include "../res/coaches/doc_hickory.c"
#include "../res/coaches/calvin.c"
#include "../res/coaches/nolan0.c"
#include "../res/players/033Muchacho.c"

char *home_names = "NEW NAME\nRED\nCALVIN\nHOMER";
char *away_names = "NEW NAME\nBLUE\nNOLAN\nMIKE";

void new_game() {
    // set image to Doc
    DISPLAY_OFF;
    clear_screen();
    move_bkg(48,0);
    set_bkg_data(0, _UI_TILE_COUNT, _ui_tiles);
    set_bkg_data(32, _FONT_TILE_COUNT, _font_tiles);
    set_bkg_data(32+_FONT_TILE_COUNT, _DOC_HICKORY_TILE_COUNT, _doc_hickory_tiles);
    for (i = 0; i < _DOC_HICKORY_ROWS*_DOC_HICKORY_COLUMNS; ++i) {
        tiles[i] = _doc_hickory_map[i]+32+_FONT_TILE_COUNT;
    }
    set_bkg_tiles(13,4,_DOC_HICKORY_COLUMNS,_DOC_HICKORY_ROWS,tiles);
    DISPLAY_ON;

    fade_in();
    display_text("Hello there!\nWelcome to the\nworld of B\x7FiSBOL.");
    display_text("My name is DOC!\nPeople call me\nthe B\x7FiSBOL PROF!");
    fade_out();

    // set image to Muchacho
    DISPLAY_OFF;
    clear_screen();
    set_bkg_data(32+_FONT_TILE_COUNT, _033MUCHACHO_TILE_COUNT, _033Muchacho_tiles);
    for (i = 0; i < _033MUCHACHO_ROWS*_033MUCHACHO_COLUMNS; ++i) {
        tiles[i] = _033Muchacho_map[i]+32+_FONT_TILE_COUNT;
    }
    set_bkg_tiles(13,4,_033MUCHACHO_COLUMNS,_033MUCHACHO_ROWS,tiles);
    DISPLAY_ON;

    fade_in();
    display_text("This world is\ninhabited by\nathletes called\nPLAYERS!");
    display_text("For some people,\nPLAYERS are\nicons. Some sign\nthem to teams");
    display_text("Myself...");
    display_text("I study B\x7FiSBOL\nas a profession.");
    fade_out();

    // set image to Calvin
    DISPLAY_OFF;
    clear_screen();
    set_bkg_data(32+_FONT_TILE_COUNT, _CALVIN_TILE_COUNT, _calvin_tiles);
    for (i = 0; i < _CALVIN_ROWS*_CALVIN_COLUMNS; ++i) {
        tiles[i] = _calvin_map[i]+32+_FONT_TILE_COUNT;
    }
    set_bkg_tiles(13,4,_CALVIN_COLUMNS,_CALVIN_ROWS,tiles);
    move_bkg(-56,0);
    DISPLAY_ON;
    fade_in();

    // slide in Calvin
    for (i = -56; i <= 48; i+=4) {
        move_bkg(i,0);
        wait_vbl_done();
    }
    display_text("First, what is\nyour name?");
    for (i = 48; i >= 0; i-=2) {
        move_bkg(i,0);
        wait_vbl_done();
    }

    // ask for user's name
#ifdef HOME
    str_buff = home_names;
#else
    str_buff = away_names;
#endif
    d = 0;
    while (d == 0) {
        d = show_list_menu(0,0,12,12,"NAME",str_buff);
    }
    
    // show text entry
    user_name = "NOLAN";
    
    clear_bkg_area(0,0,12,12);
    for (i = 0; i <= 48; i+=2) {
        move_bkg(i,0);
        wait_vbl_done();
    }
    display_text("Right! So your\nname is CALVIN!");
    fade_out();

    // set image to Nolan
    DISPLAY_OFF;
    clear_screen();
    set_bkg_data(32+_FONT_TILE_COUNT, _NOLAN0_TILE_COUNT, _nolan0_tiles);
    for (i = 0; i < _NOLAN0_ROWS*_NOLAN0_COLUMNS; ++i) {
        tiles[i] = _nolan0_map[i]+32+_FONT_TILE_COUNT;
    }
    set_bkg_tiles(13,4,_NOLAN0_COLUMNS,_NOLAN0_ROWS,tiles);
    move_bkg(-56,0);
    DISPLAY_ON;
    fade_in();

    // slide in Nolan
    for (i = -56; i <= 48; i+=4) {
        move_bkg(i,0);
        wait_vbl_done();
    }
    display_text("This is my grand-\nson. He's been\nyour rival since\nyou were a rookie");
    display_text("...Erm, what is\nhis name again?");
    for (i = 48; i >= 0; i-=2) {
        move_bkg(i,0);
        wait_vbl_done();
    }
    
    // ask for rival's name
    // ask for user's name
#ifdef HOME
    str_buff = away_names;
#else
    str_buff = home_names;
#endif
    d = 0;
    while (d == 0) {
        d = show_list_menu(0,0,12,12,"NAME",str_buff);
    }

    clear_bkg_area(0,0,12,12);

    // text entry
    rival_name = "CALVIN";
    
    for (i = 0; i <= 48; i+=2) {
        move_bkg(i,0);
        wait_vbl_done();
    }
    display_text("That's right! I\nremember now! His\nname is NOLAN!");
    fade_out();

    // set image to Calvin
    DISPLAY_OFF;
    clear_screen();
    set_bkg_data(32+_FONT_TILE_COUNT, _CALVIN_TILE_COUNT, _calvin_tiles);
    for (i = 0; i < _CALVIN_ROWS*_CALVIN_COLUMNS; ++i) {
        tiles[i] = _calvin_map[i]+32+_FONT_TILE_COUNT;
    }
    set_bkg_tiles(13,4,_CALVIN_COLUMNS,_CALVIN_ROWS,tiles);
    DISPLAY_ON;
    fade_in();

    // transition to game
    display_text("CALVIN!");
    display_text("Your very own\B\x7FiSBOL legend is\nabout to unfold!");
    display_text("A world of dreams\nand adventures\nwith B\x7FiSBOL\nawaits!Let's go!"); //don't wait for input at the end
    //shrink image
    fade_out();
    // load bedroom
    while(1);
}

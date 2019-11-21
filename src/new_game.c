#include "beisbol.h"
#include "../res/coaches/doc_hickory.c"
#include "../res/coaches/calvin.c"
#include "../res/coaches/nolan0.c"
#include "../res/font.c"
#include "../res/ui.c"

void new_game() {
    DISPLAY_OFF;
    clear_screen();
    set_bkg_data(0, _UI_TILE_COUNT, _ui_tiles);
    set_bkg_data(32, _FONT_TILE_COUNT, _font_tiles);
    set_bkg_data(32+_FONT_TILE_COUNT, _DOC_HICKORY_TILE_COUNT, _doc_hickory_tiles);
    for (i = 0; i < _DOC_HICKORY_ROWS*_DOC_HICKORY_COLUMNS; ++i) {
        tiles[i] = _doc_hickory_map[i]+32+_FONT_TILE_COUNT;
    }
    set_bkg_tiles(6,4,_DOC_HICKORY_COLUMNS,_DOC_HICKORY_ROWS,tiles);
    DISPLAY_ON;

    fade_in();
    display_text("Hello there!\nWelcome to the\nworld of BéiSBOL.");
    display_text("My name is DOC!\nPeople call me\nthe BéiSBOL PROF!");
    fade_out();
    clear_screen();
    // set img to Chico
    fade_in();
    display_text("This world is\ninhabited by\nathletes called\nPLAYERS!");
    display_text("For some people,\nPLAYERS are\nicons. Some sign\nthem to teams");
    display_text("Myself...");
    display_text("I study BéiSBOL\nas a profession.");
    fade_out();
    clear_screen();
    // set img to Calvin
    fade_in();
    display_text("First, what is\nyour name?");
    // move to right
    // show name list -> text entry
    user_name = "NOLAN";
    // remove name list
    // re-center
    display_text("Right! So your\nname is CALVIN!"));
    fade_out();
    clear_screen();
    // set img to Nolan
    fade_in();
    display_text("This is my grand-\nson. He's been\nyour rival since\nyou were a rookie");
    display_text("...Erm, what is\nhis name again?");
    // move to right
    // show name list -> text entry
    rival_name = "CALVIN";
    // remove name list
    // re-center
    display_text("That's right! I\nremember now! His\nname is NOLAN!"));
    fade_out();
    clear_screen();
    // set img to Calvin
    fade_in();
    display_text("CALVIN!"));
    display_text("Your very own\nBéiSBOL legend is\nabout to unfold!");
    display_text("A world of dreams\nand adventures\nwith BéiSBOL\nawaits!Let's go!"); //don't wait for input at the end
    //shrink image
    fade_out();
    // load bedroom
    while(1);
}

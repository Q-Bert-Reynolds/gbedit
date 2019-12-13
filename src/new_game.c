#include "beisbol.h"
#include "../img/coaches/doc_hickory.c"
#include "../img/coaches/calvin.c"
#include "../img/coaches/nolan0.c"

char *home_names = "NEW NAME\nRED\nCALVIN\nHOMER";
char *away_names = "NEW NAME\nBLUE\nNOLAN\nMIKE";

void new_game() {
    set_interrupts(VBL_IFLAG);

    // set image to Doc
    DISPLAY_OFF;
    move_bkg(48,0);
    load_font_tiles(NEW_GAME_BANK);
    set_bkg_data(_UI_FONT_TILE_COUNT, _DOC_HICKORY_TILE_COUNT, _doc_hickory_tiles);
    CLEAR_SCREEN(' ');
    set_bkg_tiles_with_offset(13,4,_DOC_HICKORY_COLUMNS,_DOC_HICKORY_ROWS,_UI_FONT_TILE_COUNT,_doc_hickory_map);
    DISPLAY_ON;

    fade_in();
    reveal_text("Hello there!\nWelcome to the\nworld of B\x7FiSBOL.", NEW_GAME_BANK);
    reveal_text("My name is DOC!\nPeople call me\nthe B\x7FiSBOL PROF!", NEW_GAME_BANK);
    fade_out();

    // set image to Muchacho
    DISPLAY_OFF;
    CLEAR_SCREEN(0);
    load_player_bkg_data(33, _UI_FONT_TILE_COUNT, NEW_GAME_BANK);
    set_player_bkg_tiles(13, 4, 33, _UI_FONT_TILE_COUNT, NEW_GAME_BANK);
    DISPLAY_ON;

    fade_in();
    reveal_text("This world is\ninhabited by\nathletes called\nPLAYERS!", NEW_GAME_BANK);
    reveal_text("For some people,\nPLAYERS are\nicons. Some sign\nthem to teams", NEW_GAME_BANK);
    reveal_text("Myself...", NEW_GAME_BANK);
    reveal_text("I study B\x7FiSBOL\nas a profession.", NEW_GAME_BANK);
    fade_out();

    // set image to Calvin
    DISPLAY_OFF;
    CLEAR_SCREEN(0);
    set_bkg_data(_UI_FONT_TILE_COUNT, _CALVIN_TILE_COUNT, _calvin_tiles);
    set_bkg_tiles_with_offset(13,4,_CALVIN_COLUMNS,_CALVIN_ROWS,_UI_FONT_TILE_COUNT,_calvin_map);
    move_bkg(-56,0);
    DISPLAY_ON;
    fade_in();

    // slide in Calvin
    for (i = -56; i <= 48; i+=4) {
        move_bkg(i,0);
        wait_vbl_done();
    }
    reveal_text("First, what is\nyour name?", NEW_GAME_BANK);
    for (i = 48; i >= 0; i-=2) {
        move_bkg(i,0);
        wait_vbl_done();
    }

    // ask for user's name
#ifdef HOME
    strcpy(str_buff, home_names);
#else
    strcpy(str_buff, away_names);
#endif
    d = 0;
    while (d == 0) {
        d = show_list_menu(0,0,12,12, "NAME", str_buff, NEW_GAME_BANK);
    }
    
    // show text entry
    CLEAR_BKG_AREA(0,0,12,12,' ');
    if (d == 1) {
        move_bkg(48,0);
        show_text_entry("YOUR NAME?", name_buff, 7, NEW_GAME_BANK);
    }
    else {
        d -= 1;
        j = 0;
        l = strlen(str_buff);
        for (i = 0; i < l; i++) {
            if (str_buff[i] == '\0' || str_buff[i] == '\n') {
                --d;
            }
            else if (d == 0) {
                name_buff[j] = str_buff[i];
                ++j;
            }
        }
        for (i = 0; i <= 48; i+=2) {
            move_bkg(i,0);
            wait_vbl_done();
        }
    }
    sprintf(str_buff, "Right! So your\nname is %s!", name_buff);
    reveal_text(str_buff, NEW_GAME_BANK);
    fade_out();

    // save user name
    disable_interrupts();
    ENABLE_RAM_MBC5;
    memcpy(user_name, name_buff, 7);
    DISABLE_RAM_MBC5;
    enable_interrupts();

    // set image to Nolan
    DISPLAY_OFF;
    CLEAR_SCREEN(' ');
    set_bkg_data(_UI_FONT_TILE_COUNT, _NOLAN0_TILE_COUNT, _nolan0_tiles);
    set_bkg_tiles_with_offset(13,4,_NOLAN0_COLUMNS,_NOLAN0_ROWS,_UI_FONT_TILE_COUNT,_nolan0_map);
    move_bkg(-56,0);
    DISPLAY_ON;
    fade_in();

    // slide in Nolan
    for (i = -56; i <= 48; i+=4) {
        move_bkg(i,0);
        wait_vbl_done();
    }
    reveal_text("This is my grand-\nson. He's been\nyour rival since\nyou were a rookie", NEW_GAME_BANK);
    reveal_text("...Erm, what is\nhis name again?", NEW_GAME_BANK);
    for (i = 48; i >= 0; i-=2) {
        move_bkg(i,0);
        wait_vbl_done();
    }
    
    // ask for rival's name
#ifdef HOME
    strcpy(str_buff, away_names);
#else
    strcpy(str_buff, home_names);
#endif
    d = 0;
    while (d == 0) {
        d = show_list_menu(0,0,12,12,"NAME",str_buff,NEW_GAME_BANK);
    }

    CLEAR_BKG_AREA(0,0,12,12,' ');

    if (d == 1) {
        move_bkg(48,0);
        show_text_entry("RIVAL's NAME?", name_buff, 7, NEW_GAME_BANK);
    }
    else {
        d -= 1;
        j = 0;
        l = strlen(str_buff);
        for (i = 0; i < l; i++) {
            if (str_buff[i] == '\0' || str_buff[i] == '\n') {
                --d;
            }
            else if (d == 0) {
                name_buff[j] = str_buff[i];
                ++j;
            }
        }
        for (i = 0; i <= 48; i+=2) {
            move_bkg(i,0);
            wait_vbl_done();
        }
    }
    
    sprintf(str_buff, "That's right! I\nremember now! His\nname is %s!", name_buff);
    reveal_text(str_buff, NEW_GAME_BANK);
    fade_out();

    // save rival name
    disable_interrupts();
    ENABLE_RAM_MBC5;
    memcpy(rival_name, name_buff, 8);
    DISABLE_RAM_MBC5;
    enable_interrupts();

    // set image to Calvin
    DISPLAY_OFF;
    CLEAR_SCREEN(' ');
    set_bkg_data(_UI_FONT_TILE_COUNT, _CALVIN_TILE_COUNT, _calvin_tiles);
    set_bkg_tiles_with_offset(13,4,_CALVIN_COLUMNS,_CALVIN_ROWS,_UI_FONT_TILE_COUNT,_calvin_map);
    DISPLAY_ON;
    fade_in();

    // transition to game
    disable_interrupts();
    ENABLE_RAM_MBC5;
    sprintf(str_buff, "%s!", user_name);
    DISABLE_RAM_MBC5;
    enable_interrupts();

    reveal_text(str_buff, NEW_GAME_BANK);
    reveal_text("Your very own\nB\x7FiSBOL legend is\nabout to unfold!", NEW_GAME_BANK);
    reveal_text("A world of dreams\nand adventures\nwith B\x7FiSBOL\nawaits! Let's go!", NEW_GAME_BANK); //don't wait for input at the end
    //TODO: shrink image
    fade_out();
}

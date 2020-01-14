INCLUDE "src/beisbol.inc"

SECTION "New Game", ROMX, BANK[NEW_GAME_BANK]

INCLUDE "img/coaches/doc_hickory.asm"
INCLUDE "img/coaches/calvin.asm"
INCLUDE "img/coaches/nolan0.asm"

HomeNames:
  DB "NEW NAME\nRED\nCALVIN\nHOMER", 0
AwayNames:
  DB "NEW NAME\nBLUE\nNOLAN\nCASEY", 0

NewGame::
  ; DISABLE_LCD_INTERRUPT

; // set image to Doc
  DISPLAY_OFF
  xor a
  ld [rSCY], a
  ld a, 48
  ld [rSCX], a ; move_bkg(48,0);

  call LoadFontTiles

  ld hl, _DocHickoryTiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _DOC_HICKORY_TILE_COUNT*16
  call mem_CopyVRAM;mem_CopyToTileData; set_bkg_data(_UI_FONT_TILE_COUNT, _DOC_HICKORY_TILE_COUNT, _doc_hickory_tiles);
  CLEAR_SCREEN " "

  ld a, 13
  ld d, a
  ld a, 4
  ld e, a
  ld a, _DOC_HICKORY_COLUMNS
  ld h, a
  ld a, _DOC_HICKORY_ROWS
  ld l, a
  ld bc, _DocHickoryTileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset

  DISPLAY_ON

  FADE_IN

  halt
  stop

  ld de, 5000
  call gbdk_Delay
; reveal_text("Hello there!\nWelcome to the\nworld of BéiSBOL.", NEW_GAME_BANK);
; reveal_text("My name is DOC!\nPeople call me\nthe BéiSBOL PROF!", NEW_GAME_BANK);
  FADE_OUT

; // set image to Muchacho
; DISPLAY_OFF;
; CLEAR_SCREEN(0);
    
; (33, _UI_FONT_TILE_COUNT, NEW_GAME_BANK);
; set_player_bkg_tiles(13, 4, 33, _UI_FONT_TILE_COUNT, NEW_GAME_BANK);
; DISPLAY_ON;

; FADE_IN(NEW_GAME_BANK);
; reveal_text("This world is\ninhabited by\nathletes called\nPLAYERS!", NEW_GAME_BANK);
; reveal_text("For some people,\nPLAYERS are\nicons. Some sign\nthem to teams", NEW_GAME_BANK);
; reveal_text("Myself...", NEW_GAME_BANK);
; reveal_text("I study BéiSBOL\nas a profession.", NEW_GAME_BANK);
; FADE_OUT(NEW_GAME_BANK);

; // set image to Calvin
; DISPLAY_OFF;
; CLEAR_SCREEN(0);
; set_bkg_data(_UI_FONT_TILE_COUNT, _CALVIN_TILE_COUNT, _calvin_tiles);
; set_bkg_tiles_with_offset(13,4,_CALVIN_COLUMNS,_CALVIN_ROWS,_UI_FONT_TILE_COUNT,_calvin_map);
; move_bkg(-56,0);
; DISPLAY_ON;
; FADE_IN(NEW_GAME_BANK);

; // slide in Calvin
; for (i = -56; i <= 48; i+=4) {
;     move_bkg(i,0);
;     update_vbl();
; }
; reveal_text("First, what is\nyour name?", NEW_GAME_BANK);
; for (i = 48; i >= 0; i-=2) {
;     move_bkg(i,0);
;     update_vbl();
; }

; // ask for user's name
; #ifdef HOME
; strcpy(str_buff, home_names);
; #else
; strcpy(str_buff, away_names);
; #endif
; d = 0;
; while (d == 0) {
;     d = show_list_menu(0,0,12,12, "NAME", str_buff, NEW_GAME_BANK);
; }
    
; // show text entry
; CLEAR_BKG_AREA(0,0,12,12,' ');
; if (d == 1) {
;     move_bkg(48,0);
;     show_text_entry("YOUR NAME?", name_buff, 7, NEW_GAME_BANK);
; }
; else {
;     d -= 1;
;     j = 0;
;     l = strlen(str_buff);
;     for (i = 0; i < l; i++) {
;         if (str_buff[i] == '\0' || str_buff[i] == '\n') {
;             --d;
;         }
;         else if (d == 0) {
;             name_buff[j] = str_buff[i];
;             ++j;
;         }
;     }
;     for (i = 0; i <= 48; i+=2) {
;         move_bkg(i,0);
;         update_vbl();
;     }
; }
; sprintf(str_buff, "Right! So your\nname is %s!", name_buff);
; reveal_text(str_buff, NEW_GAME_BANK);
; FADE_OUT(NEW_GAME_BANK);

; // save user name
; disable_interrupts();
; ENABLE_RAM_MBC5;
; memcpy(user_name, name_buff, 7);
; DISABLE_RAM_MBC5;
; enable_interrupts();

; // set image to Nolan
; DISPLAY_OFF;
; CLEAR_SCREEN(' ');
; set_bkg_data(_UI_FONT_TILE_COUNT, _NOLAN0_TILE_COUNT, _nolan0_tiles);
; set_bkg_tiles_with_offset(13,4,_NOLAN0_COLUMNS,_NOLAN0_ROWS,_UI_FONT_TILE_COUNT,_nolan0_map);
; move_bkg(-56,0);
; DISPLAY_ON;
; FADE_IN(NEW_GAME_BANK);

; // slide in Nolan
; for (i = -56; i <= 48; i+=4) {
;     move_bkg(i,0);
;     update_vbl();
; }
; reveal_text("This is my grand-\nson. He's been\nyour rival since\nyou were a rookie", NEW_GAME_BANK);
; reveal_text("...Erm, what is\nhis name again?", NEW_GAME_BANK);
; for (i = 48; i >= 0; i-=2) {
;     move_bkg(i,0);
;     update_vbl();
; }
  
; // ask for rival's name
; #ifdef HOME
; strcpy(str_buff, away_names);
; #else
; strcpy(str_buff, home_names);
; #endif
; d = 0;
; while (d == 0) {
;     d = show_list_menu(0,0,12,12,"NAME",str_buff,NEW_GAME_BANK);
; }

; CLEAR_BKG_AREA(0,0,12,12,' ');

; if (d == 1) {
;     move_bkg(48,0);
;     show_text_entry("RIVAL's NAME?", name_buff, 7, NEW_GAME_BANK);
; }
; else {
;     d -= 1;
;     j = 0;
;     l = strlen(str_buff);
;     for (i = 0; i < l; i++) {
;         if (str_buff[i] == '\0' || str_buff[i] == '\n') {
;             --d;
;         }
;         else if (d == 0) {
;             name_buff[j] = str_buff[i];
;             ++j;
;         }
;     }
;     for (i = 0; i <= 48; i+=2) {
;         move_bkg(i,0);
;         update_vbl();
;     }
; }
  
; sprintf(str_buff, "That's right! I\nremember now! His\nname is %s!", name_buff);
; reveal_text(str_buff, NEW_GAME_BANK);
; FADE_OUT(NEW_GAME_BANK);

; // save rival name
; disable_interrupts();
; ENABLE_RAM_MBC5;
; memcpy(rival_name, name_buff, 8);
; DISABLE_RAM_MBC5;
; enable_interrupts();

; // set image to Calvin
; DISPLAY_OFF;
; CLEAR_SCREEN(' ');
; set_bkg_data(_UI_FONT_TILE_COUNT, _CALVIN_TILE_COUNT, _calvin_tiles);
; set_bkg_tiles_with_offset(13,4,_CALVIN_COLUMNS,_CALVIN_ROWS,_UI_FONT_TILE_COUNT,_calvin_map);
; DISPLAY_ON;
; FADE_IN(NEW_GAME_BANK);

; // transition to game
; disable_interrupts();
; ENABLE_RAM_MBC5;
; sprintf(str_buff, "%s!", user_name);
; DISABLE_RAM_MBC5;
; enable_interrupts();

; reveal_text(str_buff, NEW_GAME_BANK);
; reveal_text("Your very own\nBéiSBOL legend is\nabout to unfold!", NEW_GAME_BANK);
; reveal_text("A world of dreams\nand adventures\nwith BéiSBOL\nawaits! Let's go!", NEW_GAME_BANK); //don't wait for input at the end
; //TODO: shrink image
; FADE_OUT(NEW_GAME_BANK);
  ret

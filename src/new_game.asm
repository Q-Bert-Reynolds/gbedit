INCLUDE "src/beisbol.inc"

SECTION "New Game", ROMX, BANK[NEW_GAME_BANK]

INCLUDE "img/coaches/doc_hickory.asm"
INCLUDE "img/coaches/calvin.asm"
INCLUDE "img/coaches/nolan0.asm"

HomeNames:
  DB "NEW NAME\nRED\nCALVIN\nHOMER", 0
AwayNames:
  DB "NEW NAME\nBLUE\nNOLAN\nCASEY", 0
UserNameTitle:
  DB "NAME", 0
RivalNameTitle:
  DB "RIVAL", 0
UserNameTextEntryTitle:
  DB "YOUR NAME?", 0

HelloThereString:
  DB "Hello there!\nWelcome to the\nworld of BéiSBOL.", 0
MyNameIsDocString:
  DB "My name is DOC!\nPeople call me\nthe BéiSBOL PROF!", 0
ThisWorldIsString:
  DB "This world is\ninhabited by\nathletes called\nPLAYERS!", 0
ForSomeString:
  DB "For some people,\nPLAYERS are\nicons. Some sign\nthem to teams", 0
MyselfString:
  DB "Myself...", 0
IStudyBeisbolString:
  DB "I study BéiSBOL\nas a profession.", 0
WhatIsYourNameString:
  DB "First, what is\nyour name?", 0
RightSoYourNameString:
  DB "Right! So your\nname is %s!", 0
MyGrandsonString:
  DB "This is my grand-\nson. He's been\nyour rival since\nyou were a rookie", 0
WhatIsYourRivalString:
  DB "...Erm, what is\nhis name again?", 0
IRememberNowString:
  DB "That's right! I\nremember now! His\nname is %s!", 0
ExclaimNameString:
  DB "%s!", 0
YourBeisbolLegendString:
  DB "Your very own\nBéiSBOL legend is\nabout to unfold!", 0
AWorldOfDreamsString:
  DB "A world of dreams\nand adventures\nwith BéiSBOL\nawaits! Let's go!", 0


NewGame::
  DISABLE_LCD_INTERRUPT

;set image to Doc
  DISPLAY_OFF
  xor a
  ld [rSCY], a
  ld a, 48
  ld [rSCX], a ; move_bkg(48,0);

  call LoadFontTiles

  ; since font takes up $9000 to $9800, no need to wrap around with mem_CopyToTileData
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
  
; reveal_text("Hello there!\nWelcome to the\nworld of BéiSBOL.", NEW_GAME_BANK);
  ld hl, HelloThereString
  call RevealText

; reveal_text("My name is DOC!\nPeople call me\nthe BéiSBOL PROF!", NEW_GAME_BANK);
  ld hl, MyNameIsDocString
  call RevealText
  FADE_OUT

;set image to Muchacho
  DISPLAY_OFF
  CLEAR_SCREEN 0
    
; load_player_bkg_data(33, _UI_FONT_TILE_COUNT, NEW_GAME_BANK);
; set_player_bkg_tiles(13, 4, 33, _UI_FONT_TILE_COUNT, NEW_GAME_BANK);
  DISPLAY_ON

  FADE_IN
; reveal_text("This world is\ninhabited by\nathletes called\nPLAYERS!", NEW_GAME_BANK);
  ld hl, ThisWorldIsString
  call RevealText

; reveal_text("For some people,\nPLAYERS are\nicons. Some sign\nthem to teams", NEW_GAME_BANK);
  ld hl, ForSomeString
  call RevealText

; reveal_text("Myself...", NEW_GAME_BANK);
  ld hl, MyselfString
  call RevealText

; reveal_text("I study BéiSBOL\nas a profession.", NEW_GAME_BANK);
  ld hl, IStudyBeisbolString
  call RevealText
  FADE_OUT

;set image to Calvin
  DISPLAY_OFF
  CLEAR_SCREEN 0

  ld hl, _CalvinTiles
  ld de, $8800
  ld bc, _CALVIN_TILE_COUNT*16
  call mem_CopyVRAM; set_bkg_data(_UI_FONT_TILE_COUNT, _CALVIN_TILE_COUNT, _calvin_tiles);
  CLEAR_SCREEN " "

  ld a, 13
  ld d, a
  ld a, 4
  ld e, a
  ld a, _CALVIN_COLUMNS
  ld h, a
  ld a, _CALVIN_ROWS
  ld l, a
  ld bc, _CalvinTileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset; set_bkg_tiles_with_offset(13,4,_CALVIN_COLUMNS,_CALVIN_ROWS,_UI_FONT_TILE_COUNT,_calvin_map);

  ld a, -56
  ld [rSCX], a
  xor a
  ld [rSCY], a; move_bkg(-56,0);

  DISPLAY_ON
  FADE_IN

  ld a, -56
  ld [_i], a
.slideInCalvinLoop; for (i = -56; i <= 48; i+=4) {
  call gbdk_WaitVBL
  ld a, [_i]
  ld [rSCX], a
  add a, 4
  ld [_i], a
  sub a, 48
  jp nz, .slideInCalvinLoop

; reveal_text("First, what is\nyour name?", NEW_GAME_BANK);
  ld hl, WhatIsYourNameString
  call RevealText

  ld a, 48
  ld [_i], a
.slideOverCalvinLoop; for (i = 48; i >= 0; i-=2) {
  call gbdk_WaitVBL
  ld a, [_i]
  sub a, 2
  ld [rSCX], a
  ld [_i], a
  jp nz, .slideOverCalvinLoop

;ask for user's name
IF DEF(_HOME)
  ld hl, HomeNames; strcpy(str_buff, home_names);
ELSE
  ld hl, AwayNames; strcpy(str_buff, away_names);
ENDC
  ld de, str_buffer
  call str_Copy

  xor a
  ld [_d], a
.ShowUserNameListLoop; while (d == 0) {
  xor a
  ld b, a
  ld c, a
  ld a, 12
  ld d, a
  ld e, a
  ld hl, UserNameTitle
  push hl ;title on stack
  ld hl, str_buffer ;list items
  call ShowListMenu;d = show_list_menu(0,0,12,12, "NAME", str_buff, NEW_GAME_BANK);
  ld [_d], a
  and a
  jp z, .ShowUserNameListLoop
  
;show text entry
  CLEAR_BKG_AREA 0,0,12,12," "
  ld a, [_d]
  dec a
  jp nz, .nameSelected; if (d == 1) {
  ld a, 48
  ld [rSCX], a
  ld bc, UserNameTextEntryTitle
  ld de, name_buffer
  ld a, 7
  ld l, a
  call ShowTextEntry;     show_text_entry("YOUR NAME?", name_buff, 7, NEW_GAME_BANK);
  jp .moveCalvinBack
.nameSelected ; else {
  ld [_d], a;d -= 1;
  xor a
  ld [_i], a
  ld hl, str_buffer
  call str_Length ;de = length
  ld a, e ;assumes length < 256
  ld [_l], a;l = strlen(str_buff);
  ld hl, str_buffer
  ld de, name_buffer
.copyNameFromListLoop ;for (i = 0; i < l; i++) {
    ld a, [hl]
    and a
    jr nz, .checkNameFound
    ld a, [hl]
    sub "\n"
    jr nz, .checkNameFound
    ld a, [_d]
    dec a
    ld [_d], a
    jr .skipNameCopy
.checkNameFound; else if (d == 0) {
    ld a, [hl]
    ld [de], a ;name_buff[j] = str_buff[i];
    inc de ;++j;
.skipNameCopy
    inc hl
    ld a, [_i]
    inc a
    ld [_i], a
    ld b, a
    ld a, [_l]
    sub b
    jp nz, .copyNameFromListLoop

.moveCalvinBack
  xor a
  ld [_i], a
.moveCalvinBackLoop;for (i = 0; i <= 48; i+=2) {
    call gbdk_WaitVBL
    ld a, [_i]
    add a, 2
    ld [rSCX], a
    ld [_i], a
    sub a, 48
    jp nz, .moveCalvinBackLoop

  stop

; sprintf(str_buff, "Right! So your\nname is %s!", name_buff);
; reveal_text(str_buff, NEW_GAME_BANK);
  ld hl, RightSoYourNameString
  call RevealText
  FADE_OUT

;save user name
  di
  ENABLE_RAM_MBC5
; memcpy(user_name, name_buff, 7);
  DISABLE_RAM_MBC5
  ei

;set image to Nolan
  DISPLAY_OFF
  CLEAR_SCREEN " "
; set_bkg_data(_UI_FONT_TILE_COUNT, _NOLAN0_TILE_COUNT, _nolan0_tiles);
; set_bkg_tiles_with_offset(13,4,_NOLAN0_COLUMNS,_NOLAN0_ROWS,_UI_FONT_TILE_COUNT,_nolan0_map);
; move_bkg(-56,0);
  DISPLAY_ON
  FADE_IN

;slide in Nolan
; for (i = -56; i <= 48; i+=4) {
;     move_bkg(i,0);
;     update_vbl();
; }
; reveal_text("This is my grand-\nson. He's been\nyour rival since\nyou were a rookie", NEW_GAME_BANK);
  ld hl, MyGrandsonString
  call RevealText

; reveal_text("...Erm, what is\nhis name again?", NEW_GAME_BANK);
  ld hl, WhatIsYourRivalString
  call RevealText
; for (i = 48; i >= 0; i-=2) {
;     move_bkg(i,0);
;     update_vbl();
; }
  
;ask for rival's name
; #ifdef HOME
; strcpy(str_buff, away_names);
; #else
; strcpy(str_buff, home_names);
; #endif
; d = 0;
; while (d == 0) {
;     d = show_list_menu(0,0,12,12,"NAME",str_buff,NEW_GAME_BANK);
; }

  CLEAR_BKG_AREA 0,0,12,12," "

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
  ld hl, IRememberNowString
  call RevealText
  FADE_OUT

;save rival name
  di
  ENABLE_RAM_MBC5
; memcpy(rival_name, name_buff, 8);
  DISABLE_RAM_MBC5
  ei

;set image to Calvin
  DISPLAY_OFF
  CLEAR_SCREEN " "
; set_bkg_data(_UI_FONT_TILE_COUNT, _CALVIN_TILE_COUNT, _calvin_tiles);
; set_bkg_tiles_with_offset(13,4,_CALVIN_COLUMNS,_CALVIN_ROWS,_UI_FONT_TILE_COUNT,_calvin_map);
  DISPLAY_ON
  FADE_IN

;transition to game
  di
  ENABLE_RAM_MBC5
; sprintf(str_buff, "%s!", user_name);
  DISABLE_RAM_MBC5
  ei

; reveal_text(str_buff, NEW_GAME_BANK);
  ld hl, ExclaimNameString
  call RevealText

; reveal_text("Your very own\nBéiSBOL legend is\nabout to unfold!", NEW_GAME_BANK);
  ld hl, YourBeisbolLegendString
  call RevealText

; reveal_text("A world of dreams\nand adventures\nwith BéiSBOL\nawaits! Let's go!", NEW_GAME_BANK); //don't wait for input at the end
  ld hl, AWorldOfDreamsString
  call RevealText

  ;TODO: shrink image
  FADE_OUT
  ret

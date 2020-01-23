INCLUDE "src/beisbol.inc"

SECTION "New Game", ROMX, BANK[NEW_GAME_BANK]

INCLUDE "img/coaches/doc_hickory.asm"
INCLUDE "img/coaches/calvin.asm"
INCLUDE "img/coaches/nolan0.asm"

ReplaceString:
  DB "%s", 0
HomeNames:
  DB "NEW NAME\nRED\nCALVIN\nHOMER", 0
AwayNames:
  DB "NEW NAME\nBLUE\nNOLAN\nCASEY", 0
UserNameTitle:
  DB "NAME", 0
RivalNameTextEntryTitle:
  DB "RIVAL NAME?", 0
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

SelectNameOrTextEntry: ;assumes d > 0, bc = title
  ld a, [_d]
  dec a
  jp nz, .nameSelected; if (d == 1) {
  ld a, 48
  ld [rSCX], a
  ld de, name_buffer
  ld a, 7
  ld l, a
  call ShowTextEntry ;show_text_entry("YOUR NAME?", name_buff, 7, NEW_GAME_BANK);
  jp .moveImageBack

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
    jr z, .nextName
    cp "\n"
    jr z, .nextName
    ld a, [_d]
    and a
    jr z, .checkNameFound
    jr .checkLoopEnd
.nextName
    ld a, [_d]
    dec a
    ld [_d], a
    jr .checkLoopEnd
.checkNameFound; else if (d == 0) {
    ld a, [hl]
    ld [de], a ;name_buff[j] = str_buff[i];
    inc de ;++j;
.checkLoopEnd
    inc hl
    ld a, [_i]
    inc a
    ld [_i], a
    ld b, a
    ld a, [_l]
    cp b
    jp nz, .copyNameFromListLoop
  xor a
  ld [de], a ;make sure the last character is 0

.moveImageBack
  xor a
  ld [_i], a
.moveImageBackLoop;for (i = 0; i <= 48; i+=2) {
    call gbdk_WaitVBL
    ld a, [_i]
    add a, 2
    ld [rSCX], a
    ld [_i], a
    sub a, 48
    jp nz, .moveImageBackLoop
  ret

NewGame::
  DISABLE_LCD_INTERRUPT
  SWITCH_RAM_MBC5 0

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

; set image to Calvin
  DISPLAY_OFF
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
.showUserNameListLoop; while (d == 0) {
  ld hl, UserNameTitle
  ld de, name_buffer
  call str_Copy
  
  xor a
  ld b, a
  ld c, a
  ld a, 12
  ld d, a
  ld e, a
  call ShowListMenu;d = show_list_menu(0,0,12,12, "NAME", str_buff, NEW_GAME_BANK);
  ld [_d], a
  and a
  jp z, .showUserNameListLoop

;show text entry
  CLEAR_BKG_AREA 0,0,12,12," "
  ld bc, UserNameTextEntryTitle
  call SelectNameOrTextEntry

; sprintf(str_buff, "Right! So your\nname is %s!", name_buff);
  ld bc, ReplaceString
  ld hl, RightSoYourNameString
  ld de, str_buffer
  call str_Replace

; reveal_text(str_buff, NEW_GAME_BANK);
  ld hl, str_buffer
  call RevealText

  FADE_OUT

;save user name
  di
  ENABLE_RAM_MBC5
  ld hl, name_buffer
  ld de, user_name
  ld bc, 7
  call mem_Copy; memcpy(user_name, name_buff, 7);
  DISABLE_RAM_MBC5
  ei

;set image to Nolan
  DISPLAY_OFF
  CLEAR_SCREEN " "
  ld hl, _Nolan0Tiles
  ld de, $8800
  ld bc, _NOLAN0_TILE_COUNT*16
  call mem_CopyVRAM; set_bkg_data(_UI_FONT_TILE_COUNT, _NOLAN0_TILE_COUNT, _nolan0_tiles);

  ld a, 13
  ld d, a
  ld a, 4
  ld e, a
  ld a, _NOLAN0_COLUMNS
  ld h, a
  ld a, _NOLAN0_ROWS
  ld l, a
  ld bc, _Nolan0TileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset; set_bkg_tiles_with_offset(13,4,_NOLAN0_COLUMNS,_NOLAN0_ROWS,_UI_FONT_TILE_COUNT,_nolan0_map);

  ld a, -56
  ld [rSCX], a; move_bkg(-56,0);
  DISPLAY_ON
  FADE_IN

.slideInNolanLoop; for (i = -56; i <= 48; i+=4) {
  call gbdk_WaitVBL
  ld a, [_i]
  add a, 4
  ld [rSCX], a
  ld [_i], a
  sub a, 48
  jp nz, .slideInNolanLoop

; reveal_text("This is my grand-\nson. He's been\nyour rival since\nyou were a rookie", NEW_GAME_BANK);
  ld hl, MyGrandsonString
  call RevealText

; reveal_text("...Erm, what is\nhis name again?", NEW_GAME_BANK);
  ld hl, WhatIsYourRivalString
  call RevealText

  ld a, 48
  ld [_i], a
.slideOverNolanLoop; for (i = 48; i >= 0; i-=2) {
  call gbdk_WaitVBL
  ld a, [_i]
  sub a, 2
  ld [rSCX], a
  ld [_i], a
  jp nz, .slideOverNolanLoop
  
;ask for rival's name
IF DEF(_HOME)
  ld hl, AwayNames; strcpy(str_buff, home_names);
ELSE
  ld hl, HomeNames; strcpy(str_buff, away_names);
ENDC
  ld de, str_buffer
  call str_Copy

  xor a
  ld [_d], a
.showRivalNameListLoop; while (d == 0) {
  ld hl, UserNameTitle
  ld de, name_buffer
  call str_Copy
  
  xor a
  ld b, a
  ld c, a
  ld a, 12
  ld d, a
  ld e, a
  call ShowListMenu;d = show_list_menu(0,0,12,12,"NAME",str_buff,NEW_GAME_BANK);
  ld [_d], a
  and a
  jp z, .showRivalNameListLoop

  CLEAR_BKG_AREA 0,0,12,12," "
  ld bc, RivalNameTextEntryTitle;"RIVAL's NAME?"
  call SelectNameOrTextEntry
  
; sprintf(str_buff, "That's right! I\nremember now! His\nname is %s!", name_buff);
  ld hl, IRememberNowString
  ld de, str_buffer
  ld bc, ReplaceString
  call str_Replace
; reveal_text(str_buff, NEW_GAME_BANK);
  ld hl, str_buffer
  call RevealText
  FADE_OUT

;save rival name
  di
  ENABLE_RAM_MBC5
  ld hl, name_buffer
  ld de, rival_name
  ld bc, 8
  call mem_Copy; memcpy(rival_name, name_buff, 8);
  DISABLE_RAM_MBC5
  ei

;set image to Calvin
  DISPLAY_OFF
  CLEAR_SCREEN " "

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

  DISPLAY_ON
  FADE_IN

;transition to game
  di
  ENABLE_RAM_MBC5
  ld hl, user_name
  ld de, name_buffer
  ld bc, 8
  call mem_Copy; memcpy(user_name, name_buff, 8);
  DISABLE_RAM_MBC5
  ei

; sprintf(str_buff, "%s!", user_name);
  ld hl, ExclaimNameString
  ld de, str_buffer
  ld bc, ReplaceString
  call str_Replace

; reveal_text(str_buff, NEW_GAME_BANK);
  ld hl, str_buffer
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

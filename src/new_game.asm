INCLUDE "src/beisbol.inc"

SECTION "New Game", ROMX, BANK[NEW_GAME_BANK]

INCLUDE "img/new_game/new_game.asm"
INCLUDE "img/new_game/new_game_sprites/new_game_sprites.asm"

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
  jp nz, .nameSelected
  ld a, 48
  ld [rSCX], a
  ld de, name_buffer
  ld a, 7
  ld l, a
  call ShowTextEntry
  jp .moveImageBack

.nameSelected
  ld [_d], a
  xor a
  ld [_i], a
  ld hl, str_buffer
  call str_Length ;de = length
  ld a, e ;assumes length < 256
  ld [_l], a
  ld hl, str_buffer
  ld de, name_buffer
.copyNameFromListLoop
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
.checkNameFound
    ld a, [hl]
    ld [de], a 
    inc de
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
.moveImageBackLoop
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

.showDoc
  DISPLAY_OFF
  xor a
  ld [rSCY], a
  ld a, 48
  ld [rSCX], a

  call LoadFontTiles

.docTiles
  ; since font takes up $9000 to $9800, no need to wrap around with mem_CopyToTileData
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld a, COACH_DOC_HICKORY
  call LoadCoachTiles
  CLEAR_SCREEN " "

  ld d, 13
  ld e, 4
  ld h, _UI_FONT_TILE_COUNT;offset
  ld a, COACH_DOC_HICKORY
  call SetCoachTiles

.docPalettes
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .fadeInDoc

  xor a
  ld hl, PaletteUI
  call GBCSetPalette

  ld h, 1
  ld a, COACH_DOC_HICKORY
  call LoadCoachPalettes

  ld d, 13
  ld e, 4
  ld h, 1;offset
  ld a, COACH_DOC_HICKORY
  call SetCoachPalettes

.fadeInDoc
  DISPLAY_ON
  call FadeIn
  
  ld hl, HelloThereString
  call RevealTextAndWait

  ld hl, MyNameIsDocString
  call RevealTextAndWait
  call FadeOut

.showMuchacho
  DISPLAY_OFF
  CLEAR_SCREEN " "
    
.muchachoTiles
  ld a, NUM_MUCHACHO
  ld de, _UI_FONT_TILE_COUNT
  call LoadPlayerBkgData

  ld a, NUM_MUCHACHO
  ld b, 13
  ld c, 4
  ld de, _UI_FONT_TILE_COUNT
  call SetPlayerBkgTiles

.muchachoColors
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .fadeInMuchacho

  xor a
  ld hl, PaletteUI
  call GBCSetPalette

  ld a, NUM_MUCHACHO
  call LoadPlayerBaseData
  ld hl, player_base.sgb_pal
  ld a, [hli]
  ld c, a
  ld a, [hli]
  ld b, a
  ld a, [sgb_Pal23]
  call SetPalettesDirect

  ld a, 1
  ld [rVBK], a
  CLEAR_SCREEN 0
  ld d, 13
  ld e, 4
  ld a, 2
  ld bc, $0707
  ld hl, _SCRN0
  call gbdk_SetTilesTo
  xor a
  ld [rVBK], a

.fadeInMuchacho
  DISPLAY_ON

  call FadeIn
  ld hl, ThisWorldIsString
  call RevealTextAndWait

  ld hl, ForSomeString
  call RevealTextAndWait

  ld hl, MyselfString
  call RevealTextAndWait

  ld hl, IStudyBeisbolString
  call RevealTextAndWait
  call FadeOut

.showCalvin
  DISPLAY_OFF
  CLEAR_SCREEN " "

.calvinTiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld a, COACH_CALVIN
  call LoadCoachTiles

  ld d, 13
  ld e, 4
  ld a, COACH_CALVIN
  ld h, _UI_FONT_TILE_COUNT
  call SetCoachTiles

.calvinColors
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .slideInCalvin

  xor a
  ld hl, PaletteUI
  call GBCSetPalette

  ld h, 1
  ld a, COACH_CALVIN
  call LoadCoachPalettes

  ld d, 13
  ld e, 4
  ld h, 1;offset
  ld a, COACH_CALVIN
  call SetCoachPalettes

.slideInCalvin
  ld a, -56
  ld [rSCX], a
  xor a
  ld [rSCY], a

  DISPLAY_ON

  ld a, -56
.slideInCalvinLoop
    push af
    call gbdk_WaitVBL
    pop af
    ld [rSCX], a
    add a, 4
    cp 48
    jp nz, .slideInCalvinLoop

  ld hl, WhatIsYourNameString
  call RevealTextAndWait

  ld a, 48
.slideOverCalvinLoop
    push af
    call gbdk_WaitVBL
    pop af
    sub a, 2
    ld [rSCX], a
    jr nz, .slideOverCalvinLoop

;ask for user's name
IF DEF(_HOME)
  ld hl, HomeNames
ELSE
  ld hl, AwayNames
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
    ld [list_selection], a
    ld b, a
    ld c, a
    ld a, 12
    ld d, a
    ld e, a
    ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_PAD_TOP
    call ShowListMenu
    ld [_d], a
    and a
    jp z, .showUserNameListLoop

.showTextEntry
  CLEAR_BKG_AREA 0,0,12,12," "
  ld bc, UserNameTextEntryTitle
  call SelectNameOrTextEntry

  ld bc, name_buffer
  ld hl, RightSoYourNameString
  ld de, str_buffer
  call str_Replace

  ld hl, str_buffer
  call RevealTextAndWait

  call FadeOut

.saveUserName
  ld hl, name_buffer
  ld de, user_name
  ld bc, 7
  call mem_Copy

.showNolan
  DISPLAY_OFF
  CLEAR_SCREEN " "

.nolanTiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld a, COACH_NOLAN0
  call LoadCoachTiles

  ld d, 13
  ld e, 4
  ld a, COACH_NOLAN0
  ld h, _UI_FONT_TILE_COUNT
  call SetCoachTiles

.nolanColors
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .slideInNolan

  xor a
  ld hl, PaletteUI
  call GBCSetPalette

  ld h, 1
  ld a, COACH_NOLAN0
  call LoadCoachPalettes

  ld d, 13
  ld e, 4
  ld a, COACH_NOLAN0
  ld h, 1
  call SetCoachPalettes

.slideInNolan
  ld a, -56
  ld [rSCX], a
  DISPLAY_ON

  ld a, -56
.slideInNolanLoop
    push af
    call gbdk_WaitVBL
    pop af
    add a, 4
    ld [rSCX], a
    cp 48
    jp nz, .slideInNolanLoop

  ld hl, MyGrandsonString
  call RevealTextAndWait

  ld hl, WhatIsYourRivalString
  call RevealTextAndWait

  ld a, 48
.slideOverNolanLoop
    push af
    call gbdk_WaitVBL
    pop af
    sub a, 2
    ld [rSCX], a
    jp nz, .slideOverNolanLoop
  
;ask for rival's name
IF DEF(_HOME)
  ld hl, AwayNames
ELSE
  ld hl, HomeNames
ENDC
  ld de, str_buffer
  call str_Copy

  xor a
  ld [_d], a
.showRivalNameListLoop
    ld hl, UserNameTitle
    ld de, name_buffer
    call str_Copy

    xor a
    ld [list_selection], a
    ld b, a
    ld c, a
    ld a, 12
    ld d, a
    ld e, a
    ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_PAD_TOP
    call ShowListMenu
    ld [_d], a
    and a
    jp z, .showRivalNameListLoop

  CLEAR_BKG_AREA 0,0,12,12," "
  ld bc, RivalNameTextEntryTitle;"RIVAL's NAME?"
  call SelectNameOrTextEntry
  
  ld hl, IRememberNowString
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  call FadeOut

.saveRivalName
  ld hl, name_buffer
  ld de, rival_name
  ld bc, 8
  call mem_Copy; memcpy(rival_name, name_buff, 8);

.showCalvinAgain
  DISPLAY_OFF
  CLEAR_SCREEN " "

.calvinTilesAgain
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld a, COACH_CALVIN
  call LoadCoachTiles

  ld d, 13
  ld e, 4
  ld a, COACH_CALVIN
  ld h, _UI_FONT_TILE_COUNT
  call SetCoachTiles

  ld hl, _NewGameTiles
  ld de, $8800+_CALVIN_TILE_COUNT*16
  ld bc, _NEW_GAME_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, _NewGameSpritesTiles
  ld de, _VRAM
  ld bc, _NEW_GAME_TILE_COUNT*16
  call mem_CopyVRAM
  
.calvinColorsAgain
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .fadeInCalvin

  xor a
  ld hl, PaletteUI
  call GBCSetPalette

  ld h, 1
  ld a, COACH_CALVIN
  call LoadCoachPalettes

  ld d, 13
  ld e, 4
  ld h, 1;offset
  ld a, COACH_CALVIN
  call SetCoachPalettes

.fadeInCalvin
  DISPLAY_ON
  call FadeIn

;transition to game
  ld hl, user_name
  ld de, name_buffer
  ld bc, 8
  call mem_Copy

  ld hl, ExclaimNameString
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace

  ld hl, str_buffer
  call RevealTextAndWait

  ld hl, YourBeisbolLegendString
  call RevealTextAndWait

  ld hl, AWorldOfDreamsString
  call RevealTextAndWait

  ld de, 500
  call gbdk_Delay

  ld d, 13
  ld e, 4
  ld h, _SILHOUETTE0_COLUMNS
  ld l, _SILHOUETTE0_ROWS
  ld bc, _Silhouette0TileMap
  ld a, _UI_FONT_TILE_COUNT+_CALVIN_TILE_COUNT
  call SetBkgTilesWithOffset

  ld de, 500
  call gbdk_Delay

  ld d, 13
  ld e, 4
  ld h, _SILHOUETTE1_COLUMNS
  ld l, _SILHOUETTE1_ROWS
  ld bc, _Silhouette1TileMap
  ld a, _UI_FONT_TILE_COUNT+_CALVIN_TILE_COUNT
  call SetBkgTilesWithOffset

  ld de, 500
  call gbdk_Delay

  CLEAR_BKG_AREA 13, 4, 7, 7, " "

  xor a
  ld [sprite_props], a
  ld [sprite_flags], a
  ld b, 72
  ld c, 76
  ld h, 2
  ld l, 2
  ld de, _NewGameCalvinTileMap
  call SetSpriteTilesXY

  ld de, 500
  call gbdk_Delay

  call FadeOut

  ;NOTE: starting xy determines grid alignment!!! should be even
  ld a, 10
  ld [map_x], a
  ld [map_y], a
  ld a, MAP_CHUNK_BILLETTOWNNE
  ld hl, MapOverworldChunks;TODO: this should be the beginning of the current map bank
  call SetCurrentMapChunk

  xor a
  ld [seconds], a
  ld [minutes], a
  ld [hours], a
  ld [hours+1], a
  ret

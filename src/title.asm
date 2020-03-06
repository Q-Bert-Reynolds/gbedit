INCLUDE "src/beisbol.inc"

SECTION "Title", ROMX, BANK[TITLE_BANK]

INCLUDE "img/title/title/title.asm"
INCLUDE "img/title/title/title_sprites/title_sprites.asm"

IF DEF(_HOME)
INCLUDE "img/home_version/version.asm"
IntroPlayerNums: 
  DB 4, 7, 1, 13, 32, 123, 25, 35, 112, 63, 92, 132, 17, 95, 77, 129
ELSE
INCLUDE "img/away_version/version.asm"
IntroPlayerNums: 
  DB 7, 4, 1, 56, 106, 37, 113, 142, 135, 143, 44, 60, 84, 137, 94, 26
ENDC

PLAYER_INDEX EQU _TITLE_TILE_COUNT+_VERSION_TILE_COUNT

ShowTitleLCDInterrupt::
  ld a, [rLY]
  and a
  jr z, .dropInTitle
  cp 255
  jr nz, .slideVersion
.dropInTitle
  ld a, 63
  ld [rLYC], a
  xor a
  ld [rSCX], a
  ld a, [_y]
  ld [rSCY], a
  jp EndLCDInterrupt
.slideVersion
  ld a, [rLY]
  cp 63
  jr nz, .scrollPlayers
  ld a, 72
  ld [rLYC], a
  ld a, [_x]
  ld [rSCX], a
  xor a
  ld [rSCY], a
  jp EndLCDInterrupt
.scrollPlayers
  ld a, [rLY]
  cp 72
  jr nz, .screenBottom
  ld a, 135
  ld [rLYC], a
  ld a, 128
  ld [rSCX], a
  xor a
  ld [rSCY], a
  jp EndLCDInterrupt
.screenBottom
  ld a, [rLY]
  cp 135
  jp nz, EndLCDInterrupt
  xor a
  ld [rLYC], a
  ld [rSCX], a
  ld [rSCY], a
  jp EndLCDInterrupt

CyclePlayersLCDInterrupt::
  ld a, [rLY]
  and a
  jr z, .noScroll
  cp 72
  jr nz, .noScroll
  ld a,  135
  ld [rLYC], a
  ld a, [_x]
  ld [rSCX], a
  jp EndLCDInterrupt
.noScroll
  ld a, [rLY]
  cp 135
  jp nz, EndLCDInterrupt
  ld a, 72
  ld [rLYC], a
  xor a
  ld [rSCX], a
  jp EndLCDInterrupt

ShowPlayer: ;de = player number
  DISABLE_LCD_INTERRUPT
  ld hl, IntroPlayerNums
  add hl, de
  ld a, [hl]
  push af ;player num
  ld de, PLAYER_INDEX
  call LoadPlayerBkgData; load_player_bkg_data(intro_player_nums[p], PLAYER_INDEX, TITLE_BANK);
  CLEAR_BKG_AREA 20,10,7,7,0

  pop af
  push af
  call GetPlayerImgColumns; a = 7-get_player_img_columns (intro_player_nums[p], TITLE_BANK);

  ld d, a
  ld a, 27
  sub a, d
  ld b, a;x
  ld a, 17
  sub a, d
  ld c, a;y
  pop af ;player num
  ld de, PLAYER_INDEX
  call SetPlayerBkgTiles; set_player_bkg_tiles(20+a, 10+a, intro_player_nums[p], PLAYER_INDEX, TITLE_BANK);

  ld a, 72
  ld [rLYC], a
  SET_LCD_INTERRUPT CyclePlayersLCDInterrupt
  ret

TitleDrop:
  DB 64,61,58,55,52,49,44,41,38,35,30,25,20,15,10,5,0,6,8,10,11,10,8,6,0,3,4,5,4,3,0,-1

VersionSlide:


BallToss:
  DB 16,15,15,14,14,13,13,12,12,11,11,10,10,10,9,9,9,8,8,7,7,7,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,7,7,7,8,8,9,9,9,10,10,10,11,11,12,12,13,13,14,14,15,15

ShowTitle:
  di
  DISPLAY_OFF
  call UpdateAudio
  CLEAR_SCREEN 0
  ld hl, rBGP
  ld [hl], BG_PALETTE
  ld hl, rOBP0
  ld [hl], SPR_PALETTE_0
  ld hl, rOBP1
  ld [hl], $E0

  ld hl, _TitleSpritesTiles
  ld de, _VRAM
  ld bc, _TITLE_SPRITES_TILE_COUNT*16
  call mem_CopyVRAM
  call UpdateAudio

  ld bc, _CALVIN_TITLE_ROWS*_CALVIN_TITLE_COLUMNS
  ld hl, _CalvinTitleTileMap
  ld de, 0
  call SetSpriteTiles

  call UpdateAudio

  ld a, 96
  ld b, a
  ld c, a
  ld a, _CALVIN_TITLE_COLUMNS
  ld h, a
  ld a, _CALVIN_TITLE_ROWS
  ld l, a
  xor a
  call MoveSprites ;bc = xy, hl = wh, a = offset
  call UpdateAudio

  ld c, 5
  ld d, OAMF_PAL1
  call gbdk_SetSpriteProp
  ld c, 10 ;would be 5 if blank sprites were skipped
  ld d, 94
  ld e, 117
  call gbdk_MoveSprite

  ld hl, _TitleTiles
  ld de, _VRAM+$1000
  ld bc, _TITLE_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, _VersionTiles
  ld de, _VRAM+$1000+_TITLE_TILE_COUNT*16
  ld bc, _VERSION_TILE_COUNT*16
  call mem_CopyVRAM
  call UpdateAudio

  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, _BEISBOL_LOGO_COLUMNS ; w
  ld l, _BEISBOL_LOGO_ROWS ; h
  ld bc, _BeisbolLogoTileMap
  call gbdk_SetBkgTiles

  xor a
  ld d, a
  ld e, a
  call ShowPlayer
  call UpdateAudio

  SET_LCD_INTERRUPT ShowTitleLCDInterrupt

  ld a, 64
  ld [_y], a
  ld [_x], a
  DISPLAY_ON
  call gbdk_WaitVBL
  LOAD_SONG LoadTakeMeOutToTheBallGame

  ld hl, TitleDrop
.dropInTitleLoop
    call gbdk_WaitVBL
    ld a, [hli]
    cp -1
    jr z, .finishTitleDrop
    ld [_y], a
    jr .dropInTitleLoop
.finishTitleDrop

  di
  ld d, 20
  ld e, 8
  ld h, _VERSION_COLUMNS
  ld l, _VERSION_ROWS
  ld a, _TITLE_TILE_COUNT
  ld bc, _VersionTileMap
  call SetBKGTilesWithOffset
  ei

  xor a
  ld [_x], a
.slideInVersionTextLoop
  call gbdk_WaitVBL
  ld a, [_x]
  add a, 3
  ld [_x], a
  cp 104
  jr c, .slideInVersionTextLoop

  DISABLE_LCD_INTERRUPT
  CLEAR_BKG_AREA 20, 8, _VERSION_COLUMNS, _VERSION_ROWS, 0
  ld d, 7
  ld e, 8
  ld h, _VERSION_COLUMNS
  ld l, _VERSION_ROWS
  ld a, _TITLE_TILE_COUNT
  ld bc, _VersionTileMap
  call SetBKGTilesWithOffset

  ld a, 72
  ld [rLYC], a
  SET_LCD_INTERRUPT CyclePlayersLCDInterrupt

  ld a, 128
  ld [_x], a
  xor a
  ld [_z], a ;current player index
CyclePlayersLoop:
  ld a, 255
  ld [_i], a
.exitableOneSecPauseLoop1
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exitTitleScreen, (PADF_START | PADF_A)
  call gbdk_WaitVBL
  ld a, [_i]
  dec a
  ld [_i], a
  jr nz, .exitableOneSecPauseLoop1

  xor a
  ld [_j], a
.movePlayerOffScreenLoop ;for (j = 0; j <= 128; j+=4) {
  ld a, [_j]
  add a, 128
  ld [_x], a
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exitTitleScreen, (PADF_START | PADF_A)
  ld a, [_z]
  and a
  jr nz, .skipBallToss
  ld hl, BallToss
  ld a, [_j]
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hl]
  add a, 101 ;y = 101+BallToss+_j
  ld e, a
  ld a, 94 ;x
  ld d, a
  ld a, 10 ;sprite id (would be 5 if blanks were removed)
  ld c, a
  call gbdk_MoveSprite ;if (z == 0) move_sprite(5, 94, 101 + ball_toss[j]);
.skipBallToss
  call gbdk_WaitVBL
  ld a, [_j]
  add a, 4
  ld [_j], a
  sub 128
  jr nz, .movePlayerOffScreenLoop

  ld a, [_z]
  inc a
  ld [_z], a
  cp 16
  jr nz, .skipMod
  xor a
  ld [_z], a
.skipMod
  xor a
  ld d, a
  ld a, [_z]
  ld e, a
  call ShowPlayer

  xor a
  ld [_x], a
.movePlayerOnScreenLoop ;for (j = 0; j <= 128; j+=4) {
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exitTitleScreen, (PADF_START | PADF_A)
  call gbdk_WaitVBL
  ld a, [_x]
  add a, 4
  ld [_x], a
  sub 128
  jr nz, .movePlayerOnScreenLoop

  jp CyclePlayersLoop
.exitTitleScreen
  ret

NewGameOptionMenuText:
  db "NEW GAME\nOPTION", 0
NewGameContinueOptionMenuText:
  db "CONTINUE\nNEW GAME\nOPTION", 0
CoachStatText:
  db "COACH"
PennantsStatText:
  db "PENNANTS"
RoledexStatText:
  db "ROLéDEX"
TimeStatText:
  db "TIME"
ShowStartMenu: ; puts choice in a ... 0 = back, >0 = choice
  DISABLE_LCD_INTERRUPT
  DISPLAY_OFF
  call UpdateAudio
  CLEAR_SCREEN 0
  call LoadFontTiles
  DISPLAY_ON

  di
  SWITCH_RAM_MBC5 0
  ENABLE_RAM_MBC5
  ld hl, user_name
  ld de, name_buffer
  ld bc, 8
  call mem_Copy; memcpy(name_buff, user_name, 7);
  DISABLE_RAM_MBC5
  ei 
  call UpdateAudio

  ld hl, name_buffer
  call str_Length
  ld a, d
  and a
  jp nz, .noSaveFile
  ld a, e
  and a
  jp z, .noSaveFile
  cp 8
  jp nc, .noSaveFile

.newGameContinueLoop; while (name_buff[0] > 0) {
  xor a
  ld hl, name_buffer
  ld [hl], a
  ld hl, NewGameContinueOptionMenuText
  ld de, str_buffer
  call str_Copy
  ld bc, 0
  ld d, 15
  ld e, 8
  call ShowListMenu ;y = show_list_menu(0,0,15,8,"","CONTINUE\nNEW GAME\nOPTION",TITLE_BANK);
  cp 1 ;if (y == 1) {
  ret nz ;else return y;
  ld [_y], a
  call gbdk_WaitVBL

  ld b, 4
  ld c, 7
  ld d, 16
  ld e, 10
  call DrawBKGUIBox ;draw_bkg_ui_box(4,7,16,10);

  ld d, 5
  ld e, 9
  ld h, 5
  ld l, 1
  ld bc, CoachStatText
  call gbdk_SetBkgTiles ;set_bkg_tiles(5,9,5,1,"COACH");

  di
  SWITCH_RAM_MBC5 0
  ENABLE_RAM_MBC5
  ld hl, user_name
  ld de, name_buffer
  ld bc, 8
  call mem_Copy
  DISABLE_RAM_MBC5
  ei
  ld hl, name_buffer
  call str_Length
  ld h, e
  ld d, 11
  ld e, 9
  ld l, 1
  ld bc, name_buffer
  call gbdk_SetBkgTiles ;set_bkg_tiles(11,9,strlen(name_buff),1,name_buff);

  ld d, 5
  ld e, 11
  ld h, 8
  ld l, 1
  ld bc, PennantsStatText
  call gbdk_SetBkgTiles ;set_bkg_tiles(5,11,8,1,"PENNANTS");

  ld d, 18
  ld e, 11
  ld h, 1
  ld l, 1
  ld bc, str_buffer
  ld a, "0"
  ld [bc], a
  call gbdk_SetBkgTiles ;set_bkg_tiles(18,11,1,1,"0");//+penant_count);
  
  ld d, 5
  ld e, 13
  ld h, 7
  ld l, 1
  ld bc, RoledexStatText
  call gbdk_SetBkgTiles ;set_bkg_tiles(5,13,7,1, "ROLéDEX");

  ;sprintf(str_buff, "%d", 151);
  ld d, 16
  ld e, 13
  ld h, 3
  ld l, 1
  ld bc, str_buffer
  ld a, "1"
  ld [bc], a
  inc bc
  inc bc
  ld [bc], a
  dec bc
  ld a, "5"
  ld [bc], a
  dec bc
  call gbdk_SetBkgTiles ;set_bkg_tiles(16,13,3,1,str_buff);

  ld d, 5
  ld e, 15
  ld h, 4
  ld l, 1
  ld bc, TimeStatText
  call gbdk_SetBkgTiles ;set_bkg_tiles(5,15,4,1,"TIME");

  ; sprintf(str_buff, "%d:%d", 999, 59);
  ; l = strlen(str_buff);
  ; call gbdk_SetBkgTiles ;set_bkg_tiles(19-l,15,l,1,str_buff);
  WAITPAD_UP
.showGameStatsLoop ;while (1) {
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .returnY, PADF_A ;if (joypad() & J_A) return y;
    JUMP_TO_IF_BUTTONS .backPressed, PADF_B; else if (joypad() & J_B) {
    call gbdk_WaitVBL
    jr .showGameStatsLoop
.backPressed
  CLEAR_BKG_AREA 4,7,16,10,0
  jp .newGameContinueLoop
.returnY
  ld a, [_y]
  ret

.noSaveFile
  xor a;title
  ld hl, name_buffer
  ld [hl], a

  ld hl, NewGameOptionMenuText ;text
  ld de, str_buffer
  call str_Copy

  xor a
  ld b, a
  ld c, a ;bc=xy
  ld a, 15
  ld d, a ;width
  ld a, 6
  ld e, a ;height
  call ShowListMenu; return show_list_menu(0,0,15,6,"","NEW GAME\nOPTION",TITLE_BANK);
  ret

Title:: ; puts (c-d-1) in a
  xor a
  ld [rSCX], a

  DISABLE_LCD_INTERRUPT
  xor a
  ld [_d], a
.showTitleAndNewGameMenuLoop ; while (d == 0 || d == c)
  ld a, [_d]
  and a
  jr nz, .checkOptions
  call ShowTitle

  jr .showStartMenu
.checkOptions
  ld a, [_d]
  ld d, a
  ld a, [_c]
  and a, d
  jp z, .showStartMenu
  call ShowOptions
  xor a
  ld [_d], a
.showStartMenu
  call ShowStartMenu ;puts choice in a
  ld [_d], a;d = show_start_menu();

  ld a, [_d]
  and a ;d==0
  jr z, .showTitleAndNewGameMenuLoop
  ld b, a
  ld a, [_c]
  sub a, b ;d==c
  jr z, .showTitleAndNewGameMenuLoop

  DISABLE_LCD_INTERRUPT

; return c-d-1
  ld a, [_d]
  ld d, a
  ld a, [_c]
  sub a, d
  dec a

  ret

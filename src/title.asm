INCLUDE "src/beisbol.inc"

SECTION "Title", ROMX, BANK[TITLE_BANK]

INCLUDE "img/title/title/title.asm"
INCLUDE "img/title/title/title_sprites/title_sprites.asm"
INCLUDE "img/players/001Bubbi.asm"

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
  sub 255
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
  sub 63
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
  sub 72
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
  sub 135
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
  sub 72
  jr nz, .noScroll
  ld a,  135
  ld [rLYC], a
  ld a, [_x]
  ld [rSCX], a
  jp EndLCDInterrupt
.noScroll
  ld a, [rLY]
  sub 135
  jp nz, EndLCDInterrupt
  ld a, 72
  ld [rLYC], a
  xor a
  ld [rSCX], a
  jp EndLCDInterrupt

ShowPlayer: ; de = player number
  DISABLE_LCD_INTERRUPT
  ; load_player_bkg_data(intro_player_nums[p], PLAYER_INDEX, TITLE_BANK);
  ld hl, _001BubbiTiles
  ld de, _VRAM+$1000+PLAYER_INDEX*16
  ld bc, _001BUBBI_TILE_COUNT*16
  call mem_CopyToTileData
  CLEAR_BKG_AREA 20,10,7,7,0
  ; a = 7-get_player_img_columns (intro_player_nums[p], TITLE_BANK);
  ; set_player_bkg_tiles(20+a, 10+a, intro_player_nums[p], PLAYER_INDEX, TITLE_BANK);
  SET_BKG_TILES_WITH_OFFSET (27-_001BUBBI_COLUMNS), (17-_001BUBBI_ROWS), _001BUBBI_COLUMNS, _001BUBBI_ROWS, PLAYER_INDEX, _001BubbiTileMap
  SET_LCD_INTERRUPT CyclePlayersLCDInterrupt
  ret

BallToss:
  DB 16,15,15,14,14,13,13,12,12,11,11,10,10,10,9,9,9,8,8,7,7,7,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,7,7,7,8,8,9,9,9,10,10,10,11,11,12,12,13,13,14,14,15,15

ShowTitle:
  di
  DISPLAY_OFF
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

  SET_SPRITE_TILES (_CALVIN_TITLE_ROWS*_CALVIN_TITLE_COLUMNS), _CalvinTitleTileMap, 0, 0

  ld a, 96
  ld b, a
  ld c, a
  ld a, _CALVIN_TITLE_COLUMNS
  ld h, a
  ld a, _CALVIN_TITLE_ROWS
  ld l, a
  xor a
  call MoveSprites ;bc = xy, hl = wh, a = offset

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

  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, _BEISBOL_LOGO_COLUMNS ; w
  ld l, _BEISBOL_LOGO_ROWS ; h
  ld bc, _BeisbolLogoTileMap
  call gbdk_SetBKGTiles

  xor a
  ld d, a
  ld e, a
  call ShowPlayer
  nop

  SET_LCD_INTERRUPT ShowTitleLCDInterrupt

  ld a, 64
  ld [_y], a
  ld [_x], a
  DISPLAY_ON
  call gbdk_WaitVBL
.dropInTitleLoop
  call gbdk_WaitVBL
  ld a, [_y]
  dec a
  ld [_y], a
  jr nz, .dropInTitleLoop

  di
  SET_BKG_TILES_WITH_OFFSET 20, 8, _VERSION_COLUMNS, _VERSION_ROWS, _TITLE_TILE_COUNT, _VersionTileMap
  ei

  xor a
  ld [_x], a
.slideInVersionTextLoop
  call gbdk_WaitVBL
  ld a, [_x]
  inc a
  ld [_x], a
  sub 104
  jr nz, .slideInVersionTextLoop

  DISABLE_LCD_INTERRUPT
  CLEAR_BKG_AREA 20, 8, _VERSION_COLUMNS, _VERSION_ROWS, 0
  SET_BKG_TILES_WITH_OFFSET 7, 8, _VERSION_COLUMNS, _VERSION_ROWS, _TITLE_TILE_COUNT, _VersionTileMap
  
  SET_LCD_INTERRUPT CyclePlayersLCDInterrupt

  ld a, 128
  ld [_x], a
CyclePlayersLoop:
  xor a
  ld [_z], a ;current player index

  ld a, 60
  ld [_i], a
.exitableOneSecPauseLoop1
  JUMP_TO_IF_BUTTONS .exitTitleScreen, (PADF_START | PADF_A)
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
  JUMP_TO_IF_BUTTONS .exitTitleScreen, (PADF_START | PADF_A)
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
  sub 16
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
  JUMP_TO_IF_BUTTONS .exitTitleScreen, (PADF_START | PADF_A)
  call gbdk_WaitVBL
  ld a, [_x]
  add a, 4
  ld [_x], a
  sub 128
  jr nz, .movePlayerOnScreenLoop

  jp CyclePlayersLoop
.exitTitleScreen
  ret

ShowStartMenu:
  DISPLAY_OFF
  DISABLE_LCD_INTERRUPT
  CLEAR_SCREEN 0
  call LoadFontTiles
  DISPLAY_ON

  di
  ENABLE_RAM_MBC5
  ; memcpy(name_buff, user_name, 7);
  DISABLE_RAM_MBC5
  ei 

  ; while (name_buff[0] > 0) {
  ;     c = 3; // even though c is set in show_list_menu, it gets reset to original value when it returns
  ;     y = show_list_menu(0,0,15,8,"","CONTINUE\nNEW GAME\nOPTION",TITLE_BANK);
  ;     if (y == 1) {
  ;         update_vbl();
  ;         draw_bkg_ui_box(4,7,16,10);
  ;         set_bkg_tiles(5,9,5,1,"COACH");
  ;         set_bkg_tiles(11,9,strlen(name_buff),1,name_buff);
  ;         set_bkg_tiles(5,11,8,1,"PENNANTS");
  ;         set_bkg_tiles(18,11,1,1,"0");//+penant_count);
  ;         set_bkg_tiles(5,13,7,1, "ROLeDEX"); // "ROL\x7FDEX" draws trash here for some reason
  ;         set_bkg_tiles(8,13,1,1,"\x7F"); // HACK: wouldn't be necessary if "ROL\x7FDEX" worked above
  ;         sprintf(str_buff, "%d", 151);
  ;         set_bkg_tiles(16,13,3,1,str_buff);
  ;         set_bkg_tiles(5,15,4,1,"TIME");
  ;         sprintf(str_buff, "%d:%d", 999, 59);
  ;         l = strlen(str_buff);
  ;         set_bkg_tiles(19-l,15,l,1,str_buff);
  ;         update_waitpadup();
  ;         while (1) {
  ;             if (joypad() & J_A) return y;
  ;             else if (joypad() & J_B) {
  ;                 CLEAR_BKG_AREA(4,7,16,10,0);
  ;                 break;
  ;             }
  ;             update_vbl();
  ;         }
  ;     }
  ;     else return y;
  ; }
  ; c = 2;
  ; return show_list_menu(0,0,15,6,"","NEW GAME\nOPTION",TITLE_BANK);
  ; }
  ret

Title::
  xor a
  ld [rSCX], a

  xor a
  ld [rIE], a
  ld [_d], a
.showTitleAndNewGameMenuLoop ; while (d == 0 || d == c)
  ld a, [_d]
  and a
  jr nz, .checkOptions
  call ShowTitle

; HACK - early return here
  xor a
  ld [rIE], a
  ret
; END HACK

  jr .showStartMenu
.checkOptions
  ld a, [_d]
  ld d, a
  ld a, [_c]
  and a, d
  jp z, .showStartMenu
  ; call ShowOptions
  xor a
  ld d, a
.showStartMenu
  call ShowStartMenu
  ld a, [_d]
  and a
  jr z, .showTitleAndNewGameMenuLoop
  ld a, [_c]
  and a
  jr z, .showTitleAndNewGameMenuLoop

  xor a
  ld [rIE], a

; return c-d-1
  ld a, [_d]
  ld d, a
  ld a, [_c]
  sub a, d
  dec a
  ret
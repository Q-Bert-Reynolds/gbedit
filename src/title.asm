INCLUDE "src/beisbol.asm"

SECTION "Title", ROMX, BANK[TITLE_BANK]

INCLUDE "img/title/title/title.asm"
INCLUDE "img/title/title/title_sprites/title_sprites.asm"

IF DEF(_HOME)
INCLUDE "img/home_version/version.asm"
IntroPlayerNums: 
  DB 4, 7, 1, 13, 32, 123, 25, 35, 112, 63, 092, 132, 17, 095, 77, 129
ELSE
INCLUDE "img/away_version/version.asm"
IntroPlayerNums: 
  DB 7, 4, 1, 56, 106, 37, 113, 142, 135, 143, 44, 60, 84, 137, 94, 26
ENDC

PLAYER_INDEX EQU _TITLE_TILE_COUNT+_VERSION_TILE_COUNT

; void show_title_lcd_interrupt(void) {
;     switch (LY_REG) {
;         case 0:
;         case 255:
;             LYC_REG = 63;
;             SCX_REG = 0;
;             SCY_REG = y;
;             break;
;         case 63:
;             LYC_REG = 71;
;             SCX_REG = x;
;             SCY_REG = 0;
;             break;
;         case 71:
;             LYC_REG = 135;
;             SCX_REG = 128;
;             SCY_REG = 0;
;             break;
;         case 135:
;             LYC_REG = 0;
;             SCX_REG = 0;
;             SCY_REG = 0;
;             break;
;     }
; }

; void cycle_players_lcd_interrupt(void) {
;     if (LY_REG == 72){
;         LYC_REG = 135;
;         SCX_REG = x;
;     }
;     else if (LY_REG == 135) {
;         LYC_REG = 72;
;         SCX_REG = 0;
;     }
; }

; void show_player (UBYTE p) {
;     load_player_bkg_data(IntroPlayerNums: DBLAYER_INDEX, TITLE_BAN
;     a = 7-get_player_img_columns (IntroPlayerNums: DBITLE_BAN
;     CLEAR_BKG_AREA(20,10,7,7,0);
;     set_player_bkg_tiles(20+a, 10+a, IntroPlayerNums: DBLAYER_INDEX, TITLE_BAN
; }

BallToss:
  DB 16,15,15,14,14,13,13,12,12,11,11,10,10,10,9,9,9,8,8,7,7,7,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,7,7,7,8,8,9,9,9,10,10,10,11,11,12,12,13,13,14,14,15,15

ShowTitle:
  DISPLAY_OFF
  ;CLEAR_SCREEN(0);
  ld hl, rBGP
  ld [hl], BG_PALETTE
  ld hl, rOBP0
  ld [hl], SPR_PALETTE_0
  ld hl, rOBP1
  ld [hl], $E0

  ld hl, TitleSpritesTiles
  ld de, _VRAM
  ld bc, _TITLE_SPRITES_TILE_COUNT*16
  call mem_CopyVRAM
;     a = 0;
;     for (j = 0; j < _CALVIN_TITLE_ROWS; ++j) {
;         for (i = 0; i < _CALVIN_TITLE_COLUMNS; ++i) {
;             b = _calvin_title_map[j*_CALVIN_TITLE_COLUMNS+i];
;             if (b == 0) continue;
;             set_sprite_tile(a, b);
;             set_sprite_prop(a, 0);
;             move_sprite(a, i*8+96, j*8+96);
;             a++;
;         }
;     }

  ; ld hl, _OAMRAM+5*4+2 ;OAM+N*4
  ; ld d, [hld]
  dec hl ;_OAMRAM + 5 * 4
  ld b, 94 ;x
  ld c, 117 ;y
  ld e, OAMF_PAL1 ;flags
  call gbdk_SetOAM

  di
;     add_LCD(show_title_lcd_interrupt);
  ei 
;     set_interrupts(LCD_IFLAG|VBL_IFLAG);

  ld hl, TitleTiles
  ld de, _VRAM+$1000
  ld bc, _TITLE_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, VersionTiles
  ld de, _VRAM+$1000+_TITLE_TILE_COUNT
  ld bc, _VERSION_TILE_COUNT*16
  call mem_CopyVRAM

  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, _BEISBOL_LOGO_COLUMNS ; w
  ld l, _BEISBOL_LOGO_ROWS ; h
  ld bc, BeisbolLogoTileMap
  call gbdk_SetBKGTiles

;     show_player(0);
;     y = 64;
;     x = 64;
  DISPLAY_ON
;     for (i = 0; i <= 64; i+=2) {
;         y = 64-i;
;         update_vbl();
;     }

  call gbdk_WaitVBLDone
;     set_bkg_tiles_with_offset(7,8,_VERSION_COLUMNS,_VERSION_ROWS,_TITLE_TILE_COUNT,_version_map);
  ; ld d, 7 ; x
  ; ld e, 8 ; y
  ; ld h, _VERSION_COLUMNS ; w
  ; ld l, _VERSION_ROWS ; h
  ; ld bc, VersionTileMap
  ; call gbdk_SetBKGTiles

;     for (i = 0; i <= 64; i+=2) {
;         x = -64+i;
;         update_vbl();
;     }
  call gbdk_WaitVBLDone
  di 
;     remove_LCD(show_title_lcd_interrupt);
;     x = 128;
;     add_LCD(cycle_players_lcd_interrupt);
  ei
;     z = 0;
;     while (1) {
;         for (i = 0; i < 60; i++) {
;             if (joypad() & (J_START | J_A)) return;
;             update_vbl();
;         }
;         for (j = 0; j <= 128; j+=6) {
;             x = j+128;
;             if (joypad() & (J_START | J_A)) return;
;             if (z == 0) move_sprite(5, 94, 101 + ball_toss[j]);
;             update_vbl();
;         }
;         z++;
;         if (z == 16) z = 0;
;         disable_interrupts();
;         show_player(z);
;         enable_interrupts();
;         for (j = 0; j <= 128; j+=6) {
;             x = j;
;             if (joypad() & (J_START | J_A)) return;
;             update_vbl();
;         }
;     }
; }
  ret

ShowStartMenu:
  DISPLAY_OFF
  di
;     remove_LCD(cycle_players_lcd_interrupt);
  ei
;     set_interrupts(VBL_IFLAG);
;     CLEAR_SCREEN(0);
;     load_font_tiles(TITLE_BANK);
  DISPLAY_ON

  di
  ENABLE_RAM_MBC5
;     memcpy(name_buff, user_name, 7);
  DISABLE_RAM_MBC5
  ei 

;     while (name_buff[0] > 0) {
;         c = 3; // even though c is set in show_list_menu, it gets reset to original value when it returns
;         y = show_list_menu(0,0,15,8,"","CONTINUE\nNEW GAME\nOPTION",TITLE_BANK);
;         if (y == 1) {
;             update_vbl();
;             draw_bkg_ui_box(4,7,16,10);
;             set_bkg_tiles(5,9,5,1,"COACH");
;             set_bkg_tiles(11,9,strlen(name_buff),1,name_buff);
;             set_bkg_tiles(5,11,8,1,"PENNANTS");
;             set_bkg_tiles(18,11,1,1,"0");//+penant_count);
;             set_bkg_tiles(5,13,7,1, "ROLeDEX"); // "ROL\x7FDEX" draws trash here for some reason
;             set_bkg_tiles(8,13,1,1,"\x7F"); // HACK: wouldn't be necessary if "ROL\x7FDEX" worked above
;             sprintf(str_buff, "%d", 151);
;             set_bkg_tiles(16,13,3,1,str_buff);
;             set_bkg_tiles(5,15,4,1,"TIME");
;             sprintf(str_buff, "%d:%d", 999, 59);
;             l = strlen(str_buff);
;             set_bkg_tiles(19-l,15,l,1,str_buff);
;             update_waitpadup();
;             while (1) {
;                 if (joypad() & J_A) return y;
;                 else if (joypad() & J_B) {
;                     CLEAR_BKG_AREA(4,7,16,10,0);
;                     break;
;                 }
;                 update_vbl();
;             }
;         }
;         else return y;
;     }
;     c = 2;
;     return show_list_menu(0,0,15,6,"","NEW GAME\nOPTION",TITLE_BANK);
; }
  ret

Title::
  xor a
  ld [rVBK], a
  ld a, 72
  ld [rSTAT], a
;     set_interrupts(LCD_IFLAG|VBL_IFLAG);
;     d = 0;
;     while (d == 0 || d == c) {
;         if (d == 0) {
  call ShowTitle
;         }
;         else if (d == c) {
;             show_options(TITLE_BANK);
;             d = 0;
;         }
;         d = show_start_menu();
;     }
;     return (UBYTE)(c-d-1);
; }
  ret

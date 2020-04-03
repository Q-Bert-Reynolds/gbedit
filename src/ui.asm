INCLUDE "src/beisbol.inc"

SECTION "UI", ROMX, BANK[UI_BANK]
INCLUDE "img/ui_font.asm"
INCLUDE "img/town_map.asm"

;UILoadFontTiles
;UIRevealText - a = draw flags, hl = text, de = xy
;UIRevealTextAndWait - a = draw flags, hl = text
;UIShowOptions
;UIShowTextEntry - a = draw flags, de = title, hl = str, c = max_len
;UIShowListMenu - a = draw flags, bc = xy, de = wh, text = [str_buffer], title = [name_buff], returns choice in a

UILoadFontTiles::
  ld hl, _UiFontTiles
  ld de, _VRAM+$1000
  ld bc, _UI_FONT_TILE_COUNT*16
  call mem_CopyVRAM ;doesn't loop so mem_CopyToTileData is unnecessary
  ret

UIDrawStateMap::
  DISPLAY_OFF
  ld hl, _TownMapTiles
  ld de, $8800
  ld bc, _TOWN_MAP_TILE_COUNT*16
  call mem_CopyVRAM

  ld de, 0
  ld h, _TOWN_MAP_COLUMNS
  ld l, _TOWN_MAP_ROWS
  ld bc, _TownMapTileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset
  DISPLAY_ON
  ret

UIRevealText:: ;a = draw flags, hl = text, de = xy, uses _i,,_j_x,_y,_w,_l
  push af;draw flags
  push hl;text
  push de;xy

  ld b, d
  ld c, e
  ld d, 20
  ld e, 6
  call DrawUIBox
  
  pop de;xy
  pop hl;text
  pop af;draw flags
  push af;draw flags
  push hl;text
  push de;xy

  and a, DRAW_FLAGS_WIN
  jr z, .skipWin
  SHOW_WIN
.skipWin

  xor a
  ld [_i], a
  ld [_x], a
  ld [_y], a
  ld [_w], a
  pop de;xy
  pop hl;text
  push hl;text
  push de;xy
  call str_Length ;de = length
  ld a, e ;assumes length < 256
  ld [_l], a; l = strlen(text);
.revealTextLoop; for (i = 0; i < l; ++i) {
    pop de;xy
    pop hl;text
    push hl;text
    push de;xy
.testNewLine;   if (text[i] == '\n') {
    xor a
    ld b, a
    ld a, [_i]
    ld c, a
    add hl, bc;text[i]
    ld a, [hl]
    cp "\n"
    jp nz, .drawCharacter

      ld a, [_y]
      inc a
      ld [_y], a
      sub a, 2
      jp nz, .skipFlash ;if (y == 2) {
        pop de;xy
        pop hl;text
        pop af;draw flags
        push af;draw flags
        push hl;text
        push de;xy
        push af;draw flags
        ld a, d
        add a, 18
        ld d, a
        ld a, e
        add a, 4
        ld e, a
        pop af;draw flags
        call FlashNextArrow ;flash_next_arrow(18,4);

        ld a, 1
        ld [_y], a

        pop de;xy
        pop hl;text
        push hl;text
        push de;xy
        xor a
        ld b, a
        ld a, [_w]
        ld c, a
        add hl, bc;text+w
        ld de, str_buffer
        ld a, [_i]
        sub a, c
        ld c, a;i-w
        call mem_Copy ;memcpy(str_buff,text+w,i-w);

        ld a, [_x]
        and a
        jr z, .skipWhiteSpace
        ld bc, 17
        ld hl, str_buffer
.whiteSpaceLoop
          dec bc
          inc hl
          dec a
          jr nz, .whiteSpaceLoop
        ld a, " "
        call mem_Set
.skipWhiteSpace

        pop de;xy
        pop hl;text
        pop af;draw flags
        push af;draw flags
        push hl;text
        push de;xy
        push af;draw flags
        and a, DRAW_FLAGS_PAD_TOP
        rr a
        add a, e
        add a, 1
        ld e, a;y
        ld a, d
        add a, 1
        ld d, a;x
        ld h, 17 ;w
        ld l, 1 ;h
        ld bc, str_buffer
        pop af
        call SetTiles

        ld bc, 17
        ld hl, str_buffer
        ld a, " "
        call mem_Set
        pop de;xy
        pop hl;text
        pop af;draw flags
        push af;draw flags
        push hl;text
        push de;xy
        push af;draw flags
        and a, DRAW_FLAGS_PAD_TOP
        rr a
        add a, e
        add a, 3
        ld e, a;y
        ld a, d
        add a, 1
        ld d, a;x
        ld h, 17 ;w
        ld l, 1 ;h
        ld bc, str_buffer
        pop af
        call SetTiles

.skipFlash
      xor a
      ld [_x], a
      ld a, [_i]
      inc a
      ld [_w], a
      jr .delay
.drawCharacter ;else {
    pop de;xy
    pop hl;text
    pop af;draw flags
    push af;draw flags
    push hl;text
    push de;xy
    push af;draw flags
    xor a
    ld b, a
    ld a, [_i]
    ld c, a
    add hl, bc
    ld b, h
    ld c, l;bc = text+i
    ld a, [_x]
    inc a
    ld [_x], a
    ld d, a ;_x+1
    ld a, [_y]
    add a, a;_y*2
    add a, 1;_y*2+1
    ld e, a ;y=_y*2+1
    pop af;draw flags
    push af;draw flags
    and a, DRAW_FLAGS_PAD_TOP
    rr a
    add a, e
    ld e, a;if pad top, y=_y*2+2
    pop af;draw flags
    pop hl;xy
    push hl;xy
    push af;draw flags
    ld a, d
    add a, h
    ld d, a
    ld a, e
    add a, l
    ld e, a
    ld h, 1 ;w
    ld l, 1 ;h
    pop af;draw flags
    call SetTiles

.delay
    ld de, 10;TODO: should use text speed
    call gbdk_Delay

    ld a, [_i]
    inc a
    ld [_i], a
    ld b, a
    ld a, [_l]
    sub b
    jp nz, .revealTextLoop

  pop de;xy
  pop hl;text
  pop af;draw flags
  ret

UIRevealTextAndWait::
  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a; move_win(7,96);
  
  ld de, 0
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call UIRevealText

  ld d, 18
  ld e, 4
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call FlashNextArrow ;flash_next_arrow(18,4);
  ret

SET_MOVE_OPTIONS_ARROW_TILE: MACRO ;var, row, column
  xor a
  ld bc, tile_buffer
  ld [bc], a
  ld a, [\1]
  cp \3
  jr nz, .setTile\@
  ld a, ARROW_RIGHT_BLANK
  ld bc, tile_buffer
  ld [bc], a
.subY\@
  ld a, [_y]
  cp \2
  jr nz, .setTile\@
  ld a, ARROW_RIGHT
  ld bc, tile_buffer
  ld [bc], a
.setTile\@
ENDM

MoveOptionsArrow:
  ld d, 1 ;x
  ld e, 3 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE _a, 0, 0
  call gbdk_SetBkgTiles; set_bkg_tiles(1,3,1,1,tile_buffer + (a==0 ? 2 : 0) - (y==0 ? 1 : 0));
  
  ld d, 7 ;x
  ld e, 3 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE _a, 0, 1
  call gbdk_SetBkgTiles; set_bkg_tiles(7,3,1,1,tile_buffer + (a==1 ? 2 : 0) - (y==0 ? 1 : 0));
  
  ld d, 14 ;x
  ld e, 3 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE _a, 0, 2
  call gbdk_SetBkgTiles; set_bkg_tiles(14,3,1,1,tile_buffer + (a==2 ? 2 : 0) - (y==0 ? 1 : 0));
  
  ld d, 1 ;x
  ld e, 8 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE _b, 1, 0
  call gbdk_SetBkgTiles; set_bkg_tiles(1,8,1,1,tile_buffer + (b==0 ? 2 : 0) - (y==1 ? 1 : 0));
  
  ld d, 10 ;x
  ld e, 8 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE _b, 1, 1
  call gbdk_SetBkgTiles; set_bkg_tiles(10,8,1,1,tile_buffer + (b==1 ? 2 : 0) - (y==1 ? 1 : 0));

  ld d, 1 ;x
  ld e, 13 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE _c, 2, 0
  call gbdk_SetBkgTiles; set_bkg_tiles(1,13,1,1,tile_buffer + (c==0 ? 2 : 0) - (y==2 ? 1 : 0));
  
  ld d, 10 ;x
  ld e, 13 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  SET_MOVE_OPTIONS_ARROW_TILE _c, 2, 1
  call gbdk_SetBkgTiles; set_bkg_tiles(10,13,1,1,tile_buffer + (c==1 ? 2 : 0) - (y==2 ? 1 : 0));

  ld a, ARROW_RIGHT
  ld bc, tile_buffer
  ld [bc], a
  ld d, 1 ;x
  ld e, 16 ;y
  ld h, 1 ;w
  ld l, 1 ;h
  ld a, [_y]
  cp 3
  jr z, .setCancelTile
  ld a, ARROW_RIGHT_BLANK
  ld [bc], a
.setCancelTile
  call gbdk_SetBkgTiles; set_bkg_tiles(1,16,1,1,tile_buffer + (y==3 ? 1 : 2));
  ret

TextSpeedOptionString:
  DB "TEXT SPEED        "
  DB "                  "
  DB " FAST  MEDIUM SLOW"

AnimationOptionString:
  DB "AT-BAT ANIMATIONS "
  DB "                  "
  DB " ON       OFF     "

CoachingOptionString:
  DB "COACHING STYLE    "
  DB "                  "
  DB " SHIFT    SET     "

CancelOptionString:
  DB "CANCEL"

UIShowOptions::
  DISPLAY_OFF
  CLEAR_BKG_AREA 0,0,20,18," "

  di
  SWITCH_RAM_MBC5 0
  ENABLE_RAM_MBC5
  ld a, [text_speed]
  ld [_a], a
  ld a, [animation_style]
  ld [_b], a
  ld a, [coaching_style]
  ld [_c], a
  DISABLE_RAM_MBC5
  ei

.testA; if (a > 2) a = 0;
  ld a, [_a]
  cp 3
  jr c, .testB 
  xor a
  ld [_a], a
.testB; if (b > 1) b = 0;
  ld a, [_b]
  cp 2
  jr c, .testC
  xor a
  ld [_b], a
.testC; if (c > 1) c = 0;
  ld a, [_c]
  cp 2
  jr c, .doneTestingStoreOptions
  xor a
  ld [_c], a
.doneTestingStoreOptions

  xor a
  ld b, a
  ld c, a
  ld a, 20
  ld d, a
  ld a, 5
  ld e, a
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox
  ; set_bkg_tiles(1,1,18,3,
  ;   "TEXT SPEED        "
  ;   "                  "
  ;   " FAST  MEDIUM SLOW"
  ld d, 1
  ld e, 1
  ld h, 18
  ld l, 3
  ld bc, TextSpeedOptionString
  call gbdk_SetBkgTiles

  xor a
  ld b, a
  ld a, 5
  ld c, a
  ld e, a
  ld a, 20
  ld d, a
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox
  ; set_bkg_tiles(1,6,18,3,
  ;   "AT-BAT ANIMATIONS "
  ;   "                  "
  ;   " ON       OFF     "
  ld d, 1
  ld e, 6
  ld h, 18
  ld l, 3
  ld bc, AnimationOptionString
  call gbdk_SetBkgTiles

  xor a
  ld b, a
  ld a, 10
  ld c, a
  ld a, 20
  ld d, a
  ld a, 5
  ld e, a
  ld a, DRAW_FLAGS_BKG
  call DrawUIBox
  ; set_bkg_tiles(1,11,18,3,
  ;   "COACHING STYLE    "
  ;   "                  "
  ;   " SHIFT    SET     "
  ld d, 1
  ld e, 11
  ld h, 18
  ld l, 3
  ld bc, CoachingOptionString
  call gbdk_SetBkgTiles

  ; set_bkg_tiles(2,16,6,1,
  ;   "CANCEL"
  ld d, 2
  ld e, 16
  ld h, 6
  ld l, 1
  ld bc, CancelOptionString
  call gbdk_SetBkgTiles

  DISPLAY_ON

  xor a
  ld [_y], a; y = 0;

  call MoveOptionsArrow; move_options_arrow(y);
  WAITPAD_UP

.moveOptionsArrowLoop; while (1) {
  call UpdateInput;   k = joypad();
.checkUpPressed;   if (button_state & PADF_UP && y > 0) {
  ld a, [button_state]
  and a, PADF_UP
  jr z, .checkDownPressed
  ld a, [_y]
  and a
  jp z, .checkDownPressed
  call gbdk_WaitVBL
  ld a, [_y]
  dec a
  ld [_y], a
  call MoveOptionsArrow;     move_options_arrow(--y);
  WAITPAD_UP
  jp .waitVBLAndLoop
.checkDownPressed;   else if (button_state & PADF_DOWN && y < 3) {
  ld a, [button_state]
  and a, PADF_DOWN
  jr z, .checkLeftPressed
  ld a, 3
  ld b, a
  ld a, [_y]
  cp b
  jr nc, .checkLeftPressed
  call gbdk_WaitVBL
  ld a, [_y]
  inc a
  ld [_y], a
  call MoveOptionsArrow;     move_options_arrow(++y);
  WAITPAD_UP
  jp .waitVBLAndLoop
.checkLeftPressed;   else if (button_state & PADF_LEFT && y < 3) {
  ld a, [button_state]
  and a, PADF_LEFT
  jr z, .checkRightPressed
  ld a, [_y]
  cp 3
  jr nc, .checkRightPressed
  call gbdk_WaitVBL
.moveALeft;     if (y == 0 && a > 0) --a;
  ld a, [_y]
  and a
  jr nz, .moveBLeft
  ld a, [_a]
  and a
  jr z, .moveBLeft
  dec a
  ld [_a], a
  jr .moveArrowLeft
.moveBLeft;     else if (y == 1 && b > 0) --b;
  ld a, [_y]
  cp 1
  jr nz, .moveCLeft
  ld a, [_b]
  and a
  jr z, .moveCLeft
  dec a
  ld [_b], a
  jr .moveArrowLeft
.moveCLeft;     else if (y == 2 && c > 0) --c;
  ld a, [_y]
  cp 2
  jr nz, .moveArrowLeft
  ld a, [_c]
  and a
  jr z, .moveArrowLeft
  dec a
  ld [_c], a
.moveArrowLeft
  call MoveOptionsArrow;     move_options_arrow(y);
  WAITPAD_UP
  jr .waitVBLAndLoop
.checkRightPressed;   else if (button_state & PADF_RIGHT && y < 3) {
  ld a, [button_state]
  and a, PADF_RIGHT
  jr z, .checkStartAPressed
  ld a, [_y]
  cp 3
  jr nc, .checkStartAPressed
  call gbdk_WaitVBL
.moveARight;     if (y == 0 && a < 2) ++a;
  ld a, [_y]
  and a
  jr nz, .moveBRight
  ld a, [_a]
  cp 2
  jr nc, .moveBRight
  inc a
  ld [_a], a
  jr .moveArrowRight
.moveBRight;     else if (y == 1 && b < 1) ++b;
  ld a, [_y]
  cp 1
  jr nz, .moveCRight
  ld a, [_b]
  cp 1
  jr nc, .moveCRight
  inc a
  ld [_b], a
  jr .moveArrowRight
.moveCRight;     else if (y == 2 && c < 1) ++c;
  ld a, [_y]
  cp 2
  jr nz, .moveArrowRight
  ld a, [_c]
  cp 1
  jr nc, .moveArrowRight
  inc a
  ld [_c], a
.moveArrowRight
  call MoveOptionsArrow;     move_options_arrow(y);
  WAITPAD_UP
  jr .waitVBLAndLoop
.checkStartAPressed;   if (button_state & (PADF_START | PADF_A) && y == 3) break;
  ld a, [_y]
  cp 3
  jr nz, .checkBPressed
  ld a, [button_state]
  and a, PADF_START | PADF_A
  jr nz, .exitMoveOptionsArrowLoop
.checkBPressed;   else if (button_state & PADF_B) break;
  ld a, [button_state]
  and a, PADF_B
  jr nz, .exitMoveOptionsArrowLoop
.waitVBLAndLoop
  call gbdk_WaitVBL
  jp .moveOptionsArrowLoop
.exitMoveOptionsArrowLoop

  di
  ENABLE_RAM_MBC5
  ld a, [_a]
  ld [text_speed], a
  ld a, [_b]
  ld [animation_style], a
  ld a, [_c]
  ld [coaching_style], a
  DISABLE_RAM_MBC5
  ei

  ret

MoveTextEntryArrow: ; bc = from xy, de = to xy
  push bc ;from xy
  push de ;to xy
  call gbdk_WaitVBL
  ld hl, tile_buffer
  xor a
  ld [hl], a; tiles[0] = 0;
  ld a, c
  cp 5; if (from_y == 5) {
  jr nz, .notFromLineFive
  ld e, 15
  ld a, 1
  ld d, a
  ld h, a
  ld l, a
  ld bc, tile_buffer
  call gbdk_SetWinTiles ;set_win_tiles(1,15,1,1,tile_buffer);
  jr .setArrow
.notFromLineFive; else {
  ld a, b ;from_x
  add a, a ;from_x*2
  inc a ;from_x*2+1
  ld d, a
  ld a, c ;from_y
  add a, a ;from_y*2
  add a, 5 ;from_y*2+5
  ld e, a
  ld a, 1
  ld h, a
  ld l, a
  ld bc, tile_buffer
  call gbdk_SetWinTiles ;set_win_tiles(from_x*2+1,from_y*2+5,1,1,tile_buffer);
.setArrow
  pop de ;to xy
  pop bc ;from xy  
  ld hl, tile_buffer
  ld a, ARROW_RIGHT
  ld [hl], a; tiles[0] = ARROW_RIGHT;
  ld a, e
  cp 5; if (to_y == 5) {
  jr nz, .notToLineFive
  push bc ;from xy
  push de ;to xy
  ld e, 15
  ld a, 1
  ld d, a
  ld h, a
  ld l, a
  ld bc, tile_buffer
  call gbdk_SetWinTiles ;set_win_tiles(1,15,1,1,tile_buffer);
  pop de ;to xy
  pop bc ;from xy
  jr .waitPadUp
.notToLineFive; else {
  ld a, d ;to_x
  add a, a ;to_x*2
  inc a ;to_x*2+1
  ld d, a
  ld a, e ;to_y
  add a, a ;to_y*2
  add a, 5 ;to_y*2+5
  ld e, a
  ld a, 1
  ld h, a
  ld l, a
  ld bc, tile_buffer
  call gbdk_SetWinTiles ;set_win_tiles(to_x*2+1,to_y*2+5,1,1,tile_buffer);
.waitPadUp
  WAITPAD_UP; update_waitpadup();
  ret

UpdateTextEntryDisplay: ; hl = str, d = max_len
  push de; d = max_len
  push hl; str

  ld d, 10;x
  ld e, 2;y
  pop bc ;str
  pop hl; h = max_len = width
  push hl
  push bc ;str
  ld l, 1; l = height
  call gbdk_SetWinTiles; set_win_tiles(10,2,max_len,1,str);

  pop bc ;str
  pop de ;d =max_len
  push de
  push bc ;str
  ld c, d ;c = max_len
  xor a
  ld b, a
  ld a, "-"
  ld hl, tile_buffer
  call mem_Set

  pop hl ;str
  push hl
  call str_Length; w = strlen(str);
  ld hl, tile_buffer
  add hl, de
  ld a, "^"
  ld [hl], a

  ld d, 10;x
  ld e, 3;y
  pop bc ;str
  pop hl; h = max_len = width
  ld bc, tile_buffer
  ld l, 1; l = height
  call gbdk_SetWinTiles; set_win_tiles(10,2,max_len,1,str);

  ret

LowerCase:
  db "abcdefghijklmnopqrstuvwxyz *():;[]#%-?!*+/.,↵", 0
LowerCaseTitle:
  db "lower case", 0
UpperCase:
  db "ABCDEFGHIJKLMNOPQRSTUVWXYZ *():;[]#%-?!*+/.,↵", 0
UpperCaseTitle:
  db "UPPER CASE", 0

UIShowTextEntry:: ; de = title, hl = str, c = max_len
  push bc;c = max_len
  push hl;str
  push de;title
  DISPLAY_OFF

  xor a
  ld b, a;b = 0, c = max_len
  call mem_Set; for (i = 0; i != max_len; ++i) str[i] = 0;
  CLEAR_WIN_AREA 0,0,20,4," "
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a; move_win(7,0);

  
  pop hl;title
  push hl
  call str_Length; l = strlen(title);
  ld a, e ;assumes len < 256
  ld [_l], a
  and a
  jp z, .skipTiles; if (l > 0) 
  pop bc;title
  push bc
  xor a
  ld d, a
  ld a, 1
  ld e, a
  ld l, a
  ld a, [_l]
  ld h, a
  call gbdk_SetWinTiles;set_win_tiles(0,1,l,1,title);
.skipTiles
  pop bc; title
  pop hl; str
  pop de; e = max_len
  push de
  push hl ;str
  ld d, e; d = max_len
  call UpdateTextEntryDisplay; update_text_entry_display(str, max_len);
  xor a
  ld b, a
  ld a, 4
  ld c, a
  ld a, 20
  ld d, a
  ld a, 11
  ld e, a
  ld a, DRAW_FLAGS_WIN
  call DrawUIBox
  DISPLAY_ON
  pop hl ;str
  pop de; e = max_len
  push de; e = max_len
  push hl; str

  xor a
  ld [_x], a
  ld [_y], a
  ld [_c], a
  ld [_l], a
.drawTextBoxLoop; while (1) {
    ld de, str_buffer
    ld bc, 46
    ld a, [_c]
    and a
    jp nz, .shouldUseUpper
.shouldUseLower;   if (c == 0) {
    ld hl, UpperCase
    call mem_Copy;     memcpy(str_buff, upper_case, 46);
    ld bc, LowerCaseTitle;set_win_tiles(2,15,10,1,"lower case");
    jr .setCaseTiles
.shouldUseUpper;   else {
    ld hl, LowerCase
    call mem_Copy;     memcpy(str_buff, lower_case, 46);
    ld bc, UpperCaseTitle;set_win_tiles(2,15,10,1,"UPPER CASE");
.setCaseTiles
    ld d, 2
    ld e, 15
    ld h, 10
    ld l, 1
    call gbdk_SetWinTiles
    xor a
    ld [_j], a
.rowLoop;   for (j = 0; j < 5; ++j) {
      xor a
      ld [_i], a
      ld a, [_j]
      add a, a; j*2
      ld de, 18
      call math_Multiply; hl = 18 * j*2
      ld b, h
      ld c, l ;bc = j*2*18
      ld hl, tile_buffer
      add hl, bc ;tiles[j*2*18]
      push hl
      ld hl, str_buffer
      ld a, [_j]
      add a, a ;_j*2
      add a, a ;_j*4
      add a, a ;_j*8
      ld c, a
      ld a, [_j]
      add a, c ;_j*9
      ld c, a
      add hl, bc ;str_buff[j*9]
      ld d, h
      ld e, l
      pop hl ;tiles[j*2*18]
.collumnLoop1;     for (i = 0; i < 9; ++i) {
        ld a, [_x]
        ld b, a
        ld a, [_i]
        sub a, b
        jr nz, .notArrowTile
        ld a, [_y]
        ld b, a
        ld a, [_j]
        sub a, b
        jr nz, .notArrowTile;(x==i && y==j) ?
        ld a, ARROW_RIGHT
        ld [hli], a;tiles[j*2*18+i*2] = ARROW_RIGHT
        jr .setCharTile
.notArrowTile
        xor a
        ld [hli], a;tiles[j*2*18+i*2] = 0
.setCharTile
        ld a, [de]
        ld [hli], a ;tiles[j*2*18+i*2+1] = str_buff[j*9+i];
        inc de
      ld a, [_i]
      inc a
      ld [_i], a
      sub 9
      jr nz, .collumnLoop1

      xor a
      ld [_i], a
      ld a, [_j]
      add a, a; j*2
      inc a ;j*2+1
      ld de, 18
      call math_Multiply; hl = 18 * (j*2+1)
      ld b, h
      ld c, l ;bc = (j*2+1)*18
      ld hl, tile_buffer
      add hl, bc ;tiles[(j*2+1)*18]
.collumnLoop2 ;for (i = 0; i < 9; ++i) {
        xor a
        ld [hli], a ;tiles[(j*2+1)*18+i*2]   = 0;
        ld [hli], a ;tiles[(j*2+1)*18+i*2+1] = 0;
      ld a, [_i]
      inc a
      ld [_i], a
      sub 9
      jr nz, .collumnLoop2

    ld a, [_j]
    inc a
    ld [_j], a
    sub a, 5
    jr nz, .rowLoop

    ld d, 1
    ld e, 5
    ld h, 18
    ld l, 9
    ld bc, tile_buffer
    call gbdk_SetWinTiles;set_win_tiles(1,5,18,9,tile_buffer);

    WAITPAD_UP
.moveArrowLoop;   while (1) {
      call UpdateInput;k = joypad();
      ld a, [_x]
      ld b, a
      ld d, a
      ld a, [_y]
      ld c, a
      ld e, a
.moveUp;if (button_state & PADF_UP && y > 0) {
      ld a, [button_state]
      and PADF_UP
      jr z, .moveDown
      ld a, [_y]
      and a
      jr z, .moveDown
      dec e
      ld a, e
      ld [_y], a;--y;
      call MoveTextEntryArrow;  move_text_entry_arrow(x,y,x,y-1);
      jp .startOrAPressed
.moveDown;else if (button_state & PADF_DOWN && y < 5) {
      ld a, [button_state]
      and PADF_DOWN
      jr z, .moveLeft
      ld a, [_y]
      sub a, 5
      jr z, .moveLeft
      inc e
      ld a, e
      ld [_y], a;++y;
      call MoveTextEntryArrow;  move_text_entry_arrow(x,y,x,y+1);
      jp .startOrAPressed
.moveLeft;else if (button_state & PADF_LEFT && x > 0 && y < 5) {
      ld a, [button_state]
      and PADF_LEFT
      jr z, .moveRight
      ld a, [_y]
      sub a, 5
      jr z, .moveRight
      ld a, [_x]
      and a
      jr z, .moveRight
      dec d
      ld a, d
      ld [_x], a;  --x;
      call MoveTextEntryArrow;  move_text_entry_arrow(x,y,x-1,y);
      jp .startOrAPressed
.moveRight;else if (button_state & PADF_RIGHT && x < 8 && y < 5) {
      ld a, [button_state]
      and PADF_RIGHT
      jr z, .startOrAPressed
      ld a, [_y]
      sub a, 5
      jr z, .startOrAPressed
      ld a, [_x]
      sub a, 8
      jr z, .startOrAPressed
      inc d
      ld a, d
      ld [_x], a;  ++x;
      call MoveTextEntryArrow;  move_text_entry_arrow(x,y,x+1,y);
.startOrAPressed ;if (button_state & (PADF_START | PADF_A)) {
      ld a, [button_state]
      and PADF_START | PADF_A
      jp z, .bPressed
      ld a, [_y]
      sub a, 5
      jr nz, .testEnd;       if (y == 5) {
      ld a, [_c]
      ld b, a
      ld a, 1
      sub a, b
      ld [_c], a ;c = 1-c;
      jp .exitMoveArrowLoop ;break;
.testEnd ; else if (str_buff[y*9+x] == '\x1E') {
      ld hl, str_buffer
      xor a
      ld b, a
      ld a, [_y]
      add a, a;y*2
      add a, a;y*4
      add a, a;y*8
      ld c, a
      ld a, [_y]
      add a, c;y*9
      ld c, a
      ld a, [_x]
      add a, c;y*9+x
      ld c, a
      add hl, bc ;str_buff[y*9+x]
      ld a, [hl]
      cp "↵" ;0x1E
      jp nz, .testLength
      ld a, [_l]
      and a
      jp nz, .exitTextEntryLoop ; if (l > 0) return;
      jr .waitVBL
.testLength;else if (l < max_len) {
      ld a, [_l]
      pop hl ;str
      pop de ;e = max_len
      push de
      push hl
      cp e
      jr nc, .waitVBL
      pop hl ;str
      push hl
      ld c, a; _l
      inc a
      ld [_l], a;_l++
      xor a
      ld b, a
      add hl, bc;hl = str[_l]
      push hl ;str[_l]
      ld hl, str_buffer
      ld a, [_y]
      add a, a;y*2
      add a, a;y*4
      add a, a;y*8
      ld c, a
      ld a, [_y]
      add a, c;y*9
      ld c, a
      ld a, [_x]
      add a, c;y*9+x
      ld c, a
      add hl, bc ;str_buff[y*9+x]
      pop bc;str[_l]
      ld a, [hl]
      ld [bc], a ;str[l++] = str_buff[y*9+x];

      inc bc ;make sure there is a 0 at the end of the string
      xor a
      ld [bc], a
      dec bc

      pop hl ;str
      pop de ;e = max_len
      push de
      ld d, e ;d = max_len
      xor a
      ld e, a
      push hl ;str
      call UpdateTextEntryDisplay;update_text_entry_display(str, max_len);

      WAITPAD_UP
      jr .waitVBL
.bPressed;     else if (button_state & PADF_B && l > 0) {
      ld a, [button_state]
      and PADF_B
      jr z, .waitVBL
      ld a, [_l]
      and a
      jr z, .waitVBL
      dec a
      ld [_l], a;--l
      ld c, a
      xor a
      ld b, a
      pop hl;str
      push hl
      add hl, bc;str[l]
      ld [hl], a;str[l] = 0;
      pop hl;str
      pop de ;e = max_len
      push de
      ld d, e ;d = max_len
      xor a
      ld e, a
      push hl;str
      call UpdateTextEntryDisplay ;update_text_entry_display(str, max_len);
      WAITPAD_UP
.waitVBL
    call gbdk_WaitVBL
    jp .moveArrowLoop
.exitMoveArrowLoop
    jp .drawTextBoxLoop
.exitTextEntryLoop
  pop af;str
  pop af;a = max_len
  ret

DrawListEntry:; a=draw flags, bc=xy, de=wh, hl=text
  ;store register state
  push bc ;xy
  push de ;wh
  push hl ;text

  ;reorganize registers to use with gbdk_SetBkgTiles
  pop bc ;text
  pop hl ;wh
  pop de ;xy
  push de ;xy
  push hl ;wh
  push bc ;text

  push af ;draw flags

  ld a, d
  add a, 2
  ld d, a;x = x+2
  ld a, [_j]
  ld e, a;y = _j
  pop af ;draw flags
  push af ;draw flags
  and a, DRAW_FLAGS_PAD_TOP
  rr a
  add a, e
  ld e, a;+1 if pad
  ld a, [_l]
  ld h, a;w = _l
  ld a, 1
  ld l, a;h = 1
  ld bc, tile_buffer
  pop af;draw flags
  call SetTiles

  ;restore initial register state
  pop hl ;text
  pop de ;wh
  pop bc ;xy
  ret 

UIShowListMenu::; a = draw flags, bc = xy, de = wh, text = [str_buffer], title = [name_buff], returns choice in a
  push af ;draw flags
  push bc ;xy
  push de ;wh
  call DrawUIBox
  pop de ;wh
  pop bc ;xy
  pop af ;draw flags
  push af

  xor a
  ld [_l], a ; length of current entry
  ld [_c], a ; number of rows (used later)
  ld a, c
  add a, 1
  ld [_j], a ;y position to draw entry
  ld hl, str_buffer ; first letter of current entry (from text)
  pop af ;draw flags
.drawListEntriesLoop
    push bc ;xy
    push de ;wh
    push hl ;text
    push af ;draw flags
.testNewLine; if (text[k] == '\n') {
    ld a, [hl] ;text
    cp "\n"
    jr nz, .testStringEnd
    pop af ;draw flags
    push af
    call DrawListEntry
    xor a
    ld [_l], a
    ld a, [_j]
    add a, 2
    ld [_j], a
    ld a, [_c]
    inc a
    ld [_c], a
    pop af;draw flags
    pop hl;text
    push af
    push hl
    jr .nextCharacter
.testStringEnd; else if (text[k] == '\0') {
    and a
    jr nz, .copyCharacterToTiles
    pop af ;draw flags
    push af
    call DrawListEntry
    ld a, [_c]
    inc a
    ld [_c], a
    pop af ;draw flags
    pop hl ;text
    pop de ;wh
    pop bc ;xy
    jr .exitDrawListEntriesLoop ;break;
.copyCharacterToTiles; else tiles[++l] = text[k];
    ld hl, tile_buffer
    xor a
    ld b, a
    ld a, [_l]
    ld c, a
    inc a
    ld [_l], a
    add hl, bc
    pop af;draw flags
    pop bc ;text
    push af;draw flags
    ld a, [bc]
    ld [hl], a
    push bc ;text
.nextCharacter
    pop hl ;text
    pop af ;draw flags
    inc hl
    pop de ;wh
    pop bc ;xy
    jp .drawListEntriesLoop

.exitDrawListEntriesLoop
  push bc ;xy
  push de ;wh

  push af ;draw flags
  xor a
  ld [_j], a
  ld d, b
  inc d
  ld e, c
  inc e
  pop af ;draw flags
  push af ;draw flags
  call DrawListMenuArrow
  pop af ;draw flags

  pop de ;wh
  pop bc ;xy
  
  push bc ;xy
  push de ;wh
  push af ;draw flags
.drawTitle
  push de ;wh
  ld hl, name_buffer
  call str_Length; puts length in de
  ld a, e ;assumes length is less than 256
  pop de ;wh
  ld e, a ;l = strlen(title);
  and a
  jr z, .skipTitle;if (l > 0) {
  ld a, d ;w
  sub a, e ;w-l
  srl a;i = (w-l)/2;
  add a, b;x+i
  ld b, a
  ld d, e ;w = l
  ld a, 1
  ld e, a ;h = 1
  ;surely there's a better way to do this than rearrange registers
  pop af ;draw flags
  push bc ;xy
  push de ;wh
  ld bc, name_buffer
  pop hl ;wh
  pop de ;xy
  push af
  call SetTiles ;set_bkg_tiles(x+i,y,l,1,title);
  pop af
  pop de
  push de
  push af
.skipTitle
  pop af
  pop de ;wh
  pop bc ;xy

  push bc ;xy
  push af;draw flags
  WAITPAD_UP;update_waitpadup();
  xor a
  ld [_j], a ;j = 0;
.moveMenuArrowLoop ;while (1) {
    call UpdateInput
    pop af;draw flags
    pop de;xy
    push de
    inc d
    inc e
    push af;draw flags
    call MoveListMenuArrow
.selectMenuItem ;if (button_state & (PADF_START | PADF_A)) 
    ld a, [button_state]
    and a, PADF_START | PADF_A
    jr z, .back
    ld a, [_j]
    inc a ;return j+1;
    jr .exitMenu
.back ;else if (button_state & PADF_B) 
    ld a, [button_state]
    and a, PADF_B
    jr z, .waitVBLThenLoop
    xor a ;return 0;
    jr .exitMenu
.waitVBLThenLoop
    call gbdk_WaitVBL ;update_vbl();
    jp .moveMenuArrowLoop
.exitMenu
  pop de ;discard draw flags
  pop bc ;xy
  ret ;return a

CoachStatText:
  db "COACH"
PennantsStatText:
  db "PENNANTS"
RoledexStatText:
  db "ROLéDEX"
TimeStatText:
  db "TIME"
UIDrawSaveStats::;a = draw flags, de = xy
  push de;xy
  push af;draw flags
  HIDE_ALL_SPRITES

  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  ld b, d
  ld c, e
  ld d, 16
  ld e, 10
  pop af;draw flags
  push af
  call DrawUIBox

  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  inc d;x+1
  inc e
  inc e;y+2
  ld h, 5
  ld l, 1
  ld bc, CoachStatText
  pop af;draw flags
  push af
  call SetTiles

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
  ld l, 1
  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  ld a, 10
  add a, d
  ld d, a;x+10
  inc e
  inc e;y+2
  ld bc, name_buffer
  pop af;draw flags
  push af
  call SetTiles

  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  inc d;x+1
  ld a, 4
  add a, e
  ld e, a;y+4
  ld h, 8
  ld l, 1
  ld bc, PennantsStatText
  pop af;draw flags
  push af
  call SetTiles

  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  ld a, 14
  add a, d
  ld d, a;x+14
  ld a, 4
  add a, e
  ld e, a;y+4
  ld h, 1
  ld l, 1
  ld bc, str_buffer
  ld a, "0"
  ld [bc], a
  pop af;draw flags
  push af
  call SetTiles

  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  inc d;x+1
  ld a, 6
  add a, e
  ld e, a;y+6
  ld h, 7
  ld l, 1
  ld bc, RoledexStatText
  pop af;draw flags
  push af
  call SetTiles

  pop af;draw flags
  pop de;xy
  push de;xy
  push af;draw flags
  ld a, 12
  add a, d
  ld d, a;x+12
  ld a, 6
  add a, e
  ld e, a;y+6
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
  pop af;draw flags
  push af
  call SetTiles

  pop af;draw flags
  pop de;xy
  push af;draw flags
  inc d;x+1
  ld a, 8
  add a, e
  ld e, a;y+8
  ld h, 4
  ld l, 1
  ld bc, TimeStatText
  pop af;draw flags
  call SetTiles
  ret
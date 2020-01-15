INCLUDE "src/beisbol.inc"

SECTION "UI", ROMX, BANK[UI_BANK]
INCLUDE "img/ui_font.asm"

;UILoadFontTiles
;UIRevealText - hl = text
;UIShowOptions
;UIShowTextEntry - de = title, hl = str, c = max_len
;UIShowListMenu - returns a, bc = xy, de = wh, text = [str_buffer], title = [name_buff]

UILoadFontTiles::
  ld hl, _UiFontTiles
  ld de, _VRAM+$1000
  ld bc, _UI_FONT_TILE_COUNT*16
  call mem_CopyVRAM ;doesn't loop so mem_CopyToTileData is unnecessary
  ret

FlashNextArrow: ;de = xy
  push de;xy
  ld hl, tile_buffer
  ld a, ARROW_DOWN
  ld [hl], a ;tile_buffer[0] = ARROW_DOWN;
  ld b, h
  ld c, l
  ld a, 1
  ld h, a ;w=1
  ld l, a ;h=1
  call gbdk_SetWinTiles ;set_win_tiles(x, y, 1, 1, tile_buffer);
  WAITPAD_UP
  ld a, 20
  pop de;xy
.loop1 ;for (a = 20; a > 0; --a) {
  ld [_a], a
  JUMP_TO_IF_BUTTONS .exitFlashNextArrow, PADF_A
  push de;xy
  ld de, 10
  call gbdk_Delay
  pop de ;restore xy
  ld a, [_a]
  dec a
  jp nz, .loop1
  ld hl, tile_buffer

  xor a
  ld [hl], a ;tile_buffer[0] = 0;
  ld b, h
  ld c, l
  ld a, 1
  ld h, a ;w=1
  ld l, a ;h=1
  push de ;xy
  call gbdk_SetWinTiles ;set_win_tiles(x, y, 1, 1, tile_buffer);

  pop de ;restore xy
  ld a, 20
.loop2 ;for (a = 20; a > 0; --a) {
  ld [_a], a
  JUMP_TO_IF_BUTTONS .exitFlashNextArrow, PADF_A
  push de;xy
  ld de, 10
  call gbdk_Delay
  pop de ;restore de
  ld a, [_a]
  dec a
  jp nz, .loop2
  jp FlashNextArrow
.exitFlashNextArrow
  ret

UIRevealText::
  push hl;text

  xor a
  ld b, a
  ld c, a
  ld a, 20
  ld d, a
  ld a, 6
  ld e, a
  call DrawWinUIBox; bc = xy, de = wh; draw_win_ui_box(0,0,20,6);

  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a; move_win(7,96);
  SHOW_WIN
  
  xor a
  ld [_i], a
  ld [_x], a
  ld [_y], a
  ld [_w], a
  pop hl ;text
  push hl
  call str_Length ;de = length
  ld a, e ;assumes length < 256
  ld [_l], a; l = strlen(text);
.revealTextLoop; for (i = 0; i < l; ++i) {
    pop hl;text
    push hl
.testNewLine;   if (text[i] == '\n') {
    xor a
    ld b, a
    ld a, [_i]
    ld c, a
    add hl, bc;text[i]
    ld a, [hl]
    cp "\n"
    jr nz, .drawCharacter

      ld a, [_y]
      inc a
      ld [_y], a
      sub a, 2
      jr nz, .skipFlash ;if (y == 2) {
        ld d, 18
        ld e, 4
        call FlashNextArrow ;flash_next_arrow(18,4);

        ld a, 1
        ld [_y], a

        ld bc, 17
        ld hl, str_buffer
        ld a, " "
        call mem_Set ;memcpy(str_buff,"                 ",17);

        pop hl;text
        push hl
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

        ld d, 1 ;x
        ld e, 2 ;y
        ld h, 17 ;w
        ld l, 1 ;h
        ld bc, str_buffer
        call gbdk_SetWinTiles ;set_win_tiles(1, 2, 17, 1, str_buff);

        ld bc, 17
        ld hl, str_buffer
        ld a, " "
        call mem_Set
        ld d, 1 ;x
        ld e, 4 ;y
        ld h, 17 ;w
        ld l, 1 ;h
        ld bc, str_buffer
        call gbdk_SetWinTiles ;set_win_tiles(1, 4, 17, 1, "                 ");

.skipFlash
      xor a
      ld [_x], a
      ld a, [_i]
      inc a
      ld [_w], a
      jr .delay
.drawCharacter ;else {
    pop hl; text
    push hl
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
    add a, 2;_y*2+2
    ld e, a ;y=_y*2+2
    ld h, 1 ;w
    ld l, 1 ;h
    call gbdk_SetWinTiles;set_win_tiles(x+1,y*2+2,1,1,text+i);

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

  ld d, 18
  ld e, 4
  call FlashNextArrow ;flash_next_arrow(18,4);
  pop hl ;text
  ret

MoveOptionsArrow: ; e = y
; tiles[0] = 0;
; tiles[1] = ARROW_RIGHT;
; tiles[2] = ARROW_RIGHT_BLANK;
; set_bkg_tiles(1,3,1,1,tiles + (a==0 ? 2 : 0) - (y==0 ? 1 : 0));
; set_bkg_tiles(7,3,1,1,tiles + (a==1 ? 2 : 0) - (y==0 ? 1 : 0));
; set_bkg_tiles(14,3,1,1,tiles + (a==2 ? 2 : 0) - (y==0 ? 1 : 0));
; set_bkg_tiles(1,8,1,1,tiles + (b==0 ? 2 : 0) - (y==1 ? 1 : 0));
; set_bkg_tiles(10,8,1,1,tiles + (b==1 ? 2 : 0) - (y==1 ? 1 : 0));
; set_bkg_tiles(1,13,1,1,tiles + (c==0 ? 2 : 0) - (y==2 ? 1 : 0));
; set_bkg_tiles(10,13,1,1,tiles + (c==1 ? 2 : 0) - (y==2 ? 1 : 0));
; set_bkg_tiles(1,16,1,1,tiles + (y==3 ? 1 : 2));
  ret

UIShowOptions::
  DISPLAY_OFF
  di
  ENABLE_RAM_MBC5
  ld a, [text_speed]
  ld [_a], a
  ld a, [animation_style]
  ld [_b], a
  ld a, [coaching_style]
  ld [_c], a
  DISABLE_RAM_MBC5
  ei

; if (a > 2) a = 0;
; if (b > 1) b = 0;
; if (c > 1) c = 0;

  xor a
  ld b, a
  ld c, a
  ld a, 20
  ld d, a
  ld a, 5
  ld e, a
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,0,20,5);
; set_bkg_tiles(1,1,18,3,
;   "TEXT SPEED        "
;   "                  "
;   " FAST  MEDIUM SLOW"

  xor a
  ld b, a
  ld a, 5
  ld c, a
  ld e, a
  ld a, 20
  ld d, a
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,5,20,5);
; set_bkg_tiles(1,6,18,3,
;   "AT-BAT ANIMATIONS "
;   "                  "
;   " ON       OFF     "

  xor a
  ld b, a
  ld a, 10
  ld c, a
  ld a, 20
  ld d, a
  ld a, 5
  ld e, a
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,10,20,5);
; set_bkg_tiles(1,11,18,3,
;   "COACHING STYLE    "
;   "                  "
;   " SHIFT    SET     "


; set_bkg_tiles(2,16,6,1,
;   "CANCEL"

  DISPLAY_ON
  WAITPAD_UP

  xor a
  ld [_y], a; y = 0;
  call MoveOptionsArrow; move_options_arrow(y);

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
  jr .waitVBLAndLoop
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
  jr .waitVBLAndLoop
.checkLeftPressed;   else if (button_state & PADF_LEFT && y < 3) {
  call gbdk_WaitVBL
;     if (y == 0 && a > 0) --a;
;     else if (y == 1 && b > 0) --b;
;     else if (y == 2 && c > 0) --c;
  call MoveOptionsArrow;     move_options_arrow(y);
  WAITPAD_UP
  jr .waitVBLAndLoop
.checkRightPressed;   else if (button_state & PADF_RIGHT && y < 3) {
  call gbdk_WaitVBL
;     if (y == 0 && a < 2) ++a;
;     else if (y == 1 && b < 1) ++b;
;     else if (y == 2 && c < 1) ++c;
  call MoveOptionsArrow;     move_options_arrow(y);
  WAITPAD_UP
  jr .waitVBLAndLoop
.checkStartAPressed;   if (button_state & (PADF_START | PADF_A) && y == 3) break;
  ld a, [button_state]
  and a, PADF_START | PADF_A
  jr z, .exitMoveOptionsArrowLoop
  jr .waitVBLAndLoop
.checkBPressed;   else if (button_state & PADF_B) break;
  ld a, [button_state]
  and a, PADF_B
  jr z, .exitMoveOptionsArrowLoop
.waitVBLAndLoop
  call gbdk_WaitVBL
  jp .moveOptionsArrowLoop
.exitMoveOptionsArrowLoop

  di
  ENABLE_RAM_MBC5;
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
; update_vbl();
; tiles[0] = 0;
; if (from_y == 5) {
;   set_win_tiles(1,15,1,1,tiles);
; else {
;   set_win_tiles(from_x*2+1,from_y*2+5,1,1,tiles);
; tiles[0] = ARROW_RIGHT;
; if (to_y == 5) {
;   set_win_tiles(1,15,1,1,tiles);
; else {
;   set_win_tiles(to_x*2+1,to_y*2+5,1,1,tiles);
; update_waitpadup();

UpdateTextEntryDisplay: ; hl = str, d = max_len
; w = strlen(str);
; for (i = 0; i < max_len; ++i) {
;   tiles[i] = ' ';
;   if (i != w) tiles[i+max_len] = '-';
;   else tiles[i+max_len] = '^';
; set_win_tiles(10,2,max_len,2,tiles);
; if (w > 0) set_win_tiles(10,2,w,1,str);

LowerCase:
  db "abcdefghijklmnopqrstuvwxyz *():;[]#%-?!*+/.,é"
UpperCase:
  db "ABCDEFGHIJKLMNOPQRSTUVWXYZ *():;[]#%-?!*+/.,é"
UIShowTextEntry:: ; de = title, hl = str, c = max_len
; DISPLAY_OFF;
; for (i = 0; i != max_len; ++i) str[i] = 0;
; CLEAR_WIN_AREA(0,0,20,4,' ');
; move_win(7,0);
; l = strlen(title);
; if (l > 0) set_win_tiles(0,1,l,1,title);
; update_text_entry_display(str, max_len);
; draw_win_ui_box(0,4,20,11);
; DISPLAY_ON;
; x = 0;
; y = 0;
; c = 0;
; l = 0;
; while (1) {
;   if (c == 0) {
;     memcpy(str_buff, upper_case, 46);
;     set_win_tiles(2,15,10,1,"lower case");
;   else {
;     memcpy(str_buff, lower_case, 46);
;     set_win_tiles(2,15,10,1,"UPPER CASE");

;   for (j = 0; j < 5; ++j) {
;     for (i = 0; i < 9; ++i) {
;       tiles[j*2*18+i*2]   = (x==i && y==j) ? ARROW_RIGHT : 0;
;       tiles[j*2*18+i*2+1] = str_buff[j*9+i];
;     for (i = 0; i < 9; ++i) {
;       tiles[(j*2+1)*18+i*2]   = 0;
;       tiles[(j*2+1)*18+i*2+1] = 0;
;   set_win_tiles(1,5,18,9,tiles);
;   update_waitpadup();
;   while (1) {
;     k = joypad();
;     if (button_state & PADF_UP && y > 0) {
;       move_text_entry_arrow(x,y,x,y-1);
;       --y;
;     else if (button_state & PADF_DOWN && y < 5) {
;       move_text_entry_arrow(x,y,x,y+1);
;       ++y;
;     else if (button_state & PADF_LEFT && x > 0 && y < 5) {
;       move_text_entry_arrow(x,y,x-1,y);
;       --x;
;     else if (button_state & PADF_RIGHT && x < 8 && y < 5) {
;       move_text_entry_arrow(x,y,x+1,y);
;       ++x;

;     if (button_state & (PADF_START | PADF_A)) {
;       if (y == 5) {
;         c = 1-c;
;         break;
;       else if (str_buff[y*9+x] == '\x1E') {
;         if (l > 0) return;
;       else if (l < max_len) {
;         str[l++] = str_buff[y*9+x];
;         set_win_tiles(10,3,max_len,1,str);
;         update_text_entry_display(str, max_len);
;         update_waitpadup();
;     else if (button_state & PADF_B && l > 0) {
;       str[--l] = '\0';
;       update_text_entry_display(str, max_len);
;       update_waitpadup();
;     update_vbl(); 
  ret

MoveMenuArrow: ;xy on stack, must stay there
  xor a
  ld [_i], a
  ld hl, tile_buffer
.tilesLoop; for (i = 0; i < c; ++i) {
  xor a
  ld [hli], a;   tiles[i*2] = 0;
  ld a, [_j]
  ld c, a
  ld a, [_i]
  sub a, c ;_i - _j
  jp nz, .setZero ;if (i == _j)
  ld a, ARROW_RIGHT ;tiles[i*2+1] = ARROW_RIGHT;
  jr .skip
.setZero
  xor a ;else tiles[i*2+1] = 0;
.skip
  ld [hli], a ;tiles[i*2+1]

  ld a, [_i]
  inc a
  ld [_i], a;++_i
  ld b, a
  ld a, [_c]
  sub a, b ;_c-_i
  jp nz, .tilesLoop

  ; pop de ;xy
  ; push de ;xy must stay on stack
  ld a, 1
  ; add a, d
  ld d, a ;x=x+1
  ld a, 1
  ; add a, e
  ld e, a ;y=y+1

  ld a, 1
  ld h, a ;w=1
  ld a, [_c]
  add a, a
  ld l, a ;h=_c*2
  
  ld bc, tile_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(x+1,y+1,1,c*2,tiles);
  ret

DrawListEntry: ;set_bkg_tiles(b+2,_j,_l,1,hl);
;store register state
  push bc ;xy
  push de ;wh
  push hl ;text

;reorganize registers to use with gbdk_SetBKGTiles
  pop bc ;text
  pop hl ;wh
  pop de ;xy
  push de ;xy
  push hl ;wh
  push bc ;text

  ld a, d
  add a, 2
  ld d, a;x = x+2
  ld a, [_j]
  ld e, a;y = _j
  ld a, a
  ld a, [_l]
  ld h, a;w = _l
  ld a, 1
  ld l, a;h = 1
  ld bc, tile_buffer
  call gbdk_SetBKGTiles

;restore initial register state
  pop hl ;text
  pop de ;wh
  pop bc ;xy
  ret 

UIShowListMenu::; returns a, bc = xy, de = wh, text = [str_buffer], title = [name_buff]
  push bc ;xy
  push de ;wh
  call DrawBKGUIBox; draw_bkg_ui_box(x,y,w,h);
  pop de ;wh
  pop bc ;xy

  xor a
  ld [_l], a ; length of current entry
  ld [_c], a ; number of rows (used later)
  ld a, c
  add a, 2
  ld [_j], a ;y position to draw entry
  ld hl, str_buffer ; first letter of current entry (from text)
.drawListEntriesLoop
  push bc ;xy
  push de ;wh
  push hl ;text
.testNewLine; if (text[k] == '\n') {
  ld a, [hl] ;text
  cp "\n"
  jr nz, .testStringEnd
  call DrawListEntry;set_bkg_tiles(x+2,j,l,1,tiles);
  xor a
  ld [_l], a
  ld a, [_j]
  add a, 2
  ld [_j], a
  ld a, [_c]
  inc a
  ld [_c], a
  jr .nextCharacter
.testStringEnd; else if (text[k] == '\0') {
  and a
  jr nz, .copyCharacterToTiles
  call DrawListEntry;set_bkg_tiles(x+2,j,l,1,tiles);
  ld a, [_c]
  inc a
  ld [_c], a
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
  pop bc ;text
  ld a, [bc]
  ld [hl], a
  push bc ;text
.nextCharacter
  pop hl ;text
  inc hl
  pop de ;wh
  pop bc ;xy
  jp .drawListEntriesLoop
.exitDrawListEntriesLoop

  push bc ;xy
  push de ;wh

  push bc
  xor a
  ld [_j], a
  call MoveMenuArrow
  pop bc

  pop de ;wh
  pop bc ;xy
  
  push bc ;xy
  push de ;wh
.drawTitle
  push de ;wh
  ld hl, name_buffer
  call str_Length; puts length in de
  ld a, e ;assumes length is less than 256
  pop de ;wh
  ld e, a ;l = strlen(title); 
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
  push bc ;xy
  push de ;wh
  push hl ;title
  pop bc ;title
  pop hl ;wh
  pop de ;xy
  call gbdk_SetBKGTiles ;set_bkg_tiles(x+i,y,l,1,title);
.skipTitle
  pop de ;wh
  pop bc ;xy

  push bc ;xy
  WAITPAD_UP;update_waitpadup();
  xor a
  ld [_j], a ;j = 0;
.moveMenuArrowLoop ;while (1) {
  call UpdateInput
.checkMoveArrowUp ;if (button_state & PADF_UP && j > 0) {
  ld a, [button_state]
  and a, PADF_UP
  jp z, .checkMoveArrowDown
  ld a, [_j]
  or a
  jp z, .checkMoveArrowDown
  call gbdk_WaitVBL ;update_vbl(); 
  ld a, [_j]
  dec a
  ld [_j], a ;--j
  call MoveMenuArrow;move_menu_arrow(--j);
  WAITPAD_UP ;update_waitpadup();
  jr .waitVBLThenLoop
.checkMoveArrowDown ;else if (button_state & PADF_DOWN && _j < _c-1) {
  ld a, [button_state]
  and a, PADF_DOWN
  jp z, .selectMenuItem
  ld a, [_c]
  dec a
  ld b, a
  ld a, [_j]
  cp b
  jp nc, .selectMenuItem
  call gbdk_WaitVBL ;update_vbl(); 
  ld a, [_j]
  inc a
  ld [_j], a ;++j
  call MoveMenuArrow;move_menu_arrow(++j);
  WAITPAD_UP ;update_waitpadup();
  jr .waitVBLThenLoop
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
  pop bc ;xy
  ret ;return a
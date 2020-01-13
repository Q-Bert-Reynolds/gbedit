INCLUDE "src/beisbol.inc"

SECTION "UI", ROMX, BANK[UI_BANK]
INCLUDE "img/ui_font.asm"

UILoadFontTiles::
  ld hl, _UiFontTiles
  ld de, _VRAM+$1000
  ld bc, _UI_FONT_TILE_COUNT*16
  call mem_CopyVRAM ;doesn't loop so mem_CopyToTileData is unnecessary
  ret

FlashNextArrow: ;de = xy
;     while (1) {
;         tiles[0] = ARROW_DOWN;
;         set_win_tiles(x, y, 1, 1, tiles);
;         update_waitpadup();
;         for (a = 0; a < 20; ++a) {
;             if (joypad() & J_A) return;
;             update_delay(10);
;         tiles[0] = 0;
;         set_win_tiles(x, y, 1, 1, tiles);
;         for (a = 0; a < 20; ++a) {
;             if (joypad() & J_A) return;
;             update_delay(10);
  ret

UIRevealText:: ; hl = text
; draw_win_ui_box(0,0,20,6);
; move_win(7,96);
; SHOW_WIN;
; x = 0;
; y = 0;
; l = strlen(text);
; w = 0;
; for (i = 0; i < l; ++i) {
;   if (text[i] == '\n') {
;     ++y;
;     memcpy(str_buff,"                 ",17);
;     memcpy(str_buff,text+w,i-w);
;     if (y == 2) {
;       y = 1;
;       flash_next_arrow(18,4);
;       set_win_tiles(1, 2, 17, 1, str_buff);
;       set_win_tiles(1, 4, 17, 1, "                 ");
;     x = 0;
;     w = i+1;
;   else {
;     set_win_tiles(x+1,y*2+2,1,1,text+i);
;     x++;
;   update_delay(10);
; flash_next_arrow(18,4);
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
; DISPLAY_OFF;
; disable_interrupts();
; ENABLE_RAM_MBC5;
; a = text_speed;
; b = animation_style;
; c = coaching_style;
; DISABLE_RAM_MBC5;
; enable_interrupts();
; if (a > 2) a = 0;
; if (b > 1) b = 0;
; if (c > 1) c = 0;
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,0,20,5);
; set_bkg_tiles(1,1,18,3,
;   "TEXT SPEED        "
;   "                  "
;   " FAST  MEDIUM SLOW"
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,5,20,5);
; set_bkg_tiles(1,6,18,3,
;   "AT-BAT ANIMATIONS "
;   "                  "
;   " ON       OFF     "
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,10,20,5);
; set_bkg_tiles(1,11,18,3,
;   "COACHING STYLE    "
;   "                  "
;   " SHIFT    SET     "
; set_bkg_tiles(2,16,6,1,
;   "CANCEL"
; DISPLAY_ON;
; update_waitpadup();
; y = 0;
; move_options_arrow(y);
; while (1) {
;   k = joypad();
;   if (k & J_UP && y > 0) {
;     update_vbl(); 
;     move_options_arrow(--y);
;     update_waitpadup();
;   else if (k & J_DOWN && y < 3) {
;     update_vbl(); 
;     move_options_arrow(++y);
;     update_waitpadup();
;   else if (k & J_LEFT && y < 3) {
;     update_vbl(); 
;     if (y == 0 && a > 0) --a;
;     else if (y == 1 && b > 0) --b;
;     else if (y == 2 && c > 0) --c;
;     move_options_arrow(y);
;     update_waitpadup();
;   else if (k & J_RIGHT && y < 3) {
;     update_vbl(); 
;     if (y == 0 && a < 2) ++a;
;     else if (y == 1 && b < 1) ++b;
;     else if (y == 2 && c < 1) ++c;
;     move_options_arrow(y);
;     update_waitpadup();
;   if (k & (J_START | J_A) && y == 3) break;
;   else if (k & J_B) break;
;   update_vbl(); 
; disable_interrupts();
; ENABLE_RAM_MBC5;
; text_speed = a;
; animation_style = b;
; coaching_style = c;
; DISABLE_RAM_MBC5;
; enable_interrupts();

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
;     if (k & J_UP && y > 0) {
;       move_text_entry_arrow(x,y,x,y-1);
;       --y;
;     else if (k & J_DOWN && y < 5) {
;       move_text_entry_arrow(x,y,x,y+1);
;       ++y;
;     else if (k & J_LEFT && x > 0 && y < 5) {
;       move_text_entry_arrow(x,y,x-1,y);
;       --x;
;     else if (k & J_RIGHT && x < 8 && y < 5) {
;       move_text_entry_arrow(x,y,x+1,y);
;       ++x;

;     if (k & (J_START | J_A)) {
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
;     else if (k & J_B && l > 0) {
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
.checkMoveArrowUp ;if (k & J_UP && j > 0) {
  ld a, [button_state];k = joypad();
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
.checkMoveArrowDown ;else if (k & J_DOWN && j < c-1) {
  ld a, [button_state];k = joypad();
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
.selectMenuItem ;if (k & (J_START | J_A)) 
  ld a, [button_state];k = joypad();
  and a, PADF_START | PADF_A
  jr z, .back
  ld a, [_j]
  inc a ;return j+1;
  jr .exitMenu
.back ;else if (k & J_B) 
  ld a, [button_state];k = joypad();
  and a, PADF_B
  jr z, .waitVBLThenLoop
  xor a ;return 0;
  jr .exitMenu
.waitVBLThenLoop
  call gbdk_WaitVBL ;update_vbl();
  jp .moveMenuArrowLoop
.exitMenu
  pop bc ;xy
  ret ;return 0;
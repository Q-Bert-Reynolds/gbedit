#include "beisbol.h"
#include "../res/font.c"
#include "../res/ui.c"

const unsigned char blank_tile[] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
void clear_screen () {
    set_bkg_data(0, 1, blank_tile);
    for (i = 0; i < 1024; ++i) tiles[i] = 0;
    set_bkg_tiles(0,0,32,32,tiles);
    set_win_tiles(0,0,20,18,tiles);
    move_win(160,144);
    for (i = 0; i < 40; i++) move_sprite(i, 0, 0);
}

void clear_bkg_area (UBYTE x, UBYTE y, UBYTE w, UBYTE h) {
    set_bkg_data(0, 1, blank_tile);
    l = w*h;
    for (i = 0; i < l; ++i) tiles[i] = 0;
    set_bkg_tiles(x,y,w,h,tiles);
}

void draw_ui_box (UBYTE w, UBYTE h) {
    for (j = 0; j < h; j++) {
        for (i = 0; i < w; i++) {
            k = 0;
            if (j == 0) {
                if (i == 0) k = BOX_UPPER_LEFT;
                else if (i == w-1) k = BOX_UPPER_RIGHT;
                else k = BOX_HORIZONTAL;
            }
            else if (j == h-1) {
                if (i == 0) k = BOX_LOWER_LEFT;
                else if (i == w-1) k = BOX_LOWER_RIGHT;
                else k = BOX_HORIZONTAL;
            }
            else if (i == 0 || i == w-1) k = BOX_VERTICAL;

            tiles[j*w+i] = k;
        }
    }
}

void draw_bkg_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h) {
    draw_ui_box(w,h);
    set_bkg_tiles(x,y,w,h,tiles);
}

void draw_win_ui_box (UBYTE x, UBYTE y, UBYTE w, UBYTE h) {
    draw_ui_box(w,h);
    set_win_tiles(x,y,w,h,tiles);
}

void flash_next_arrow (UBYTE x, UBYTE y) {
    while (1) {
        tiles[0] = ARROW_DOWN;
        set_win_tiles(x, y, 1, 1, tiles);
        waitpadup();
        for (a = 0; a < 20; a++) {
            if (joypad() & J_A) return;
            wait_vbl_done();
        }
        tiles[0] = 0;
        set_win_tiles(x, y, 1, 1, tiles);
        for (a = 0; a < 20; a++) {
            if (joypad() & J_A) return;
            wait_vbl_done();
        }
    }
}

void display_text (unsigned char *text) {
    SHOW_WIN;
    move_win(0,96);
    draw_win_ui_box(0,0,20,6);
    x = 0;
    y = 0;
    l = strlen(text);
    for (i = 0; i < l; i++) {
        if (text[i] == '\n') {
            x = 0;
            ++y;
            if (y == 2) {
                y = 1;
                flash_next_arrow(18,16);
                get_win_tiles(1, 4, 17, 1, tiles);
                set_win_tiles(1, 2, 17, 1, tiles);
                for (j = 0; j < 17; ++j) tiles[j] = 0;
                set_win_tiles(1, 4, 17, 1, tiles);
            }
        }
        else {
            set_win_tiles(x+1,y*2+2,1,1,text+i);
            x++;
        }        
        delay(10);
    }
    flash_next_arrow(18,4);
}

void move_menu_arrow (int y) {
    for (i = 0; i < c; i++) {
        tiles[i*2] = 0;
        if (i == y) tiles[i*2+1] = ARROW_RIGHT;
        else tiles[i*2+1] = 0;
    }
    set_bkg_tiles(1,1,1,c*2,tiles);
}

UBYTE show_list_menu (UBYTE x, UBYTE y, UBYTE w, UBYTE h, char *title, char *text) {
    draw_bkg_ui_box(x,y,w,h);

    l = 0;
    j = y+2;
    c = 0;
    k = 0;
    while (1) {
        if (text[k] == '\n') {
            set_bkg_tiles(x+2,j,l,1,tiles);
            l = 0;
            j += 2;
            ++c;
        }
        else if (text[k] == '\0') {
            set_bkg_tiles(x+2,j,l,1,tiles);
            ++c;
            break;
        }
        else {
            tiles[l] = text[k];
            ++l;
        }
        ++k;
    }

    tiles[0] = ARROW_RIGHT;
    set_bkg_tiles(x+1,y+2,1,1,tiles);
    
    l = strlen(title);
    if (l > 0) {
        i = (w-l)/2;
        set_bkg_tiles(x+i,y,l,1,title);
    }

    waitpadup();
    j = 0;
    while (1) {
        k = joypad();
        if (k & J_UP && j > 0) {
            wait_vbl_done(); 
            move_menu_arrow(--j);
            waitpadup();
        }
        else if (k & J_DOWN && j < c-1) {
            wait_vbl_done(); 
            move_menu_arrow(++j);
            waitpadup();
        }
        if (k & (J_START | J_A)) return j+1;
        else if (k & J_B) return 0;
        wait_vbl_done(); 
    }
    return -1;
}

void move_text_entry_arrow (UBYTE from_x, UBYTE from_y, UBYTE to_x, UBYTE to_y) {
    wait_vbl_done();
    tiles[0] = 0;
    if (from_y == 5) {
        set_win_tiles(1,15,1,1,tiles);
    }
    else {
        set_win_tiles(from_x*2+1,from_y*2+5,1,1,tiles);
    }
    tiles[0] = ARROW_RIGHT;
    if (to_y == 5) {
        set_win_tiles(1,15,1,1,tiles);
    }
    else {
        set_win_tiles(to_x*2+1,to_y*2+5,1,1,tiles);
    }
    waitpadup();
}

void update_text_entry_display (char *text, UBYTE max_len) {
    w = strlen(text);
    for (i = 0; i < max_len; ++i) {
        if (i < w) tiles[i] = text[i];
        else if (i == w) tiles[i] = '-';
        else tiles[i] = '_';
    }
    set_win_tiles(10,3,max_len,1,tiles);
    waitpadup();
}

char *lower_case = "abcdefghijklmnopqrstuvwxyz *():;[]#%-?!*+/.,\x1E";
char *upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ *():;[]#%-?!*+/.,\x1E";
char *show_text_entry (char *dest, UBYTE max_len) {
    DISPLAY_OFF;
    clear_screen();
    move_win(0,0);
    set_win_tiles(0,1,10,1,"YOUR NAME?");
    draw_win_ui_box(0,4,20,11);
    DISPLAY_ON;
    
    x = 0;
    y = 0;
    c = 0;
    l = 0;
    while (1) {
        if (c == 0) {
            strcpy(str_buff, upper_case);
            set_win_tiles(2,15,10,1,"lower case");
        }
        else {
            strcpy(str_buff, lower_case);
            set_win_tiles(2,15,10,1,"UPPER CASE");
        }
        for (j = 0; j < 5; ++j) {
            for (i = 0; i < 9; ++i) {
                tiles[j*2*18+i*2]   = (x==i && y==j) ? ARROW_RIGHT : 0;
                tiles[j*2*18+i*2+1] = str_buff[j*9+i];
            }
            for (i = 0; i < 9; ++i) {
                tiles[(j*2+1)*18+i*2]   = 0;
                tiles[(j*2+1)*18+i*2+1] = 0;
            }
        }
        set_win_tiles(1,5,18,9,tiles);

        waitpadup();
        while (1) {
            k = joypad();
            if (k & J_UP && y > 0) {
                move_text_entry_arrow(x,y,x,y-1);
                --y;
            }
            else if (k & J_DOWN && y < 5) {
                move_text_entry_arrow(x,y,x,y+1);
                ++y;
            }
            else if (k & J_LEFT && x > 0 && y < 5) {
                move_text_entry_arrow(x,y,x-1,y);
                --x;
            }
            else if (k & J_RIGHT && x < 8 && y < 5) {
                move_text_entry_arrow(x,y,x+1,y);
                ++x;
            }

            if (k & (J_START | J_A)) {
                if (y == 5) {
                    c = 1-c;
                    break;
                }
                else if (str_buff[y*9+x] == '\x1E' && l > 0) {
                    return dest;
                }
                else if (l < max_len) {
                    dest[l++] = str_buff[y*9+x];
                    update_text_entry_display(dest, max_len);
                }
            }
            else if (k & J_B && l > 0) {
                dest[--l] = '\0';
                update_text_entry_display(dest, max_len);
            }
            wait_vbl_done(); 
        }
    }

    return dest;
}

void fade_out () {
    disable_interrupts();
    BGP_REG = 0x90;
    OBP0_REG = 0x90;
    delay(200);
    BGP_REG = 0x40;
    OBP0_REG = 0x40;
    delay(200);
    BGP_REG = 0x00;
    OBP0_REG = 0x00;
    delay(200);
}

void fade_in () {
    disable_interrupts();
    BGP_REG = 0x40;
    OBP0_REG = 0x40;
    delay(200);
    BGP_REG = 0x90;
    OBP0_REG = 0x90;
    delay(200);
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    delay(200);
}

void main () {
    cgb_compatibility();
    DISPLAY_OFF;
    // setup_audio();
    SPRITES_8x8;
    BGP_REG = BG_PALETTE;
    OBP0_REG = SPR_PALETTE_0;
    OBP1_REG = SPR_PALETTE_1;
    SHOW_SPRITES;
    SHOW_BKG;
    // SWITCH_ROM_MBC5(START_BANK);
    // start();
    // SWITCH_ROM_MBC5(TITLE_BANK);
    // if (title()) {
    //     // continue
    // }
    // else {
        SWITCH_ROM_MBC5(NEW_GAME_BANK);
        new_game();
    // }
}

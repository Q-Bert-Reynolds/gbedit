INCLUDE "src/beisbol.inc"

INCLUDE "data/item_data.asm"
INCLUDE "data/item_strings.asm"

SECTION "Item Bank 0", ROM0
ShowInventoryFromWorld::
  ld a, ITEM_BANK
  call SetBank

  call ShowInventory

  ld a, OVERWORLD_BANK
  call SetBank
  ret

ShowInventoryFromPlayBall::
  call CopyBkgToWin
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a
  SHOW_WIN
  
  ld a, ITEM_BANK
  call SetBank

  call ShowInventory

  ld a, PLAY_BALL_BANK
  call SetBank

  HIDE_WIN
  ret

GetInventoryItemID::; a = index of item in list
  ld hl, items
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli];get item id
  ret 

GetItemData::;a = item id, returns item data address in hl
  ld hl, ItemList
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hli]
  ld h, a
  ld l, b
  ret

SECTION "Item Bank X", ROMX, BANK[ITEM_BANK]
ShowInventory::
  ld bc, $0402
  ld de, $100B
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DrawUIBox
  HIDE_SPRITES

  call GetInventoryLength;number of items in b
  ld a, b
  ld [_b], a;number of items
  xor a
  ld [_j], a;index
  ld a, 1
  ld [_s], a;current page
  ld a, 3
  ld [_c], a;number of places the list menu arrow can be
  ld de, $0503
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DrawListMenuArrow
  call DrawItems
  WAITPAD_UP_OR_FRAMES 20
.loop
    call UpdateInput
    ld de, $0503
    ld a, [_j]
    ld c, a
    push bc;old _j in c
    ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
    call MoveListMenuArrow
    pop bc;old _j in c
    ld b, a;store dir
    ld a, [_j]
    sub a, c;change in _j
    cp b;check if change is same as expected
    jr z, .flashDownArrow
.scrollItems
    ld a, [_s]
    add a, b
    ld [_s], a
    call DrawItems
.flashDownArrow
    ld a, [vbl_timer]
    cp a, 30
    ld a, 0
    jr c, .drawDown
.drawDownArrow
    ld a, ARROW_DOWN
.drawDown
    ld d, 18
    ld e, 11
    ld bc, name_buffer
    ld [bc], a
    ld hl, $0101
    ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
    call SetTiles
.checkA
    ld a, [button_state]
    and a, PADF_A
    jr z, .checkB
    call SelectItem
    cp a, -1
    jr z, .exit
.checkB
    ld b, 0
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
    call gbdk_WaitVBL
    jp .loop
.exit
  ret

DrawItems::
  CLEAR_WIN_AREA 6,3,13,9,0
  ld a, [_b]
  ld b, a
  dec b
  ld a, [_s]
  and a
  cp 1
  jr c, .numTooLow
  cp b
  jr nc, .numTooHigh
  jr .draw
.numTooLow
  ld a, 1
  ld [_s], a
  jr .draw
.numTooHigh
  ld a, [_s]
  dec a
  ld [_s], a
.draw
  inc b
  ld de, $0603
  ld c, 4
.loop
    push bc;list len, draw count
    push af;num
    push de;xy
    call DrawInventoryEntry
    pop de;xy
    inc e
    inc e;y+=2
    pop af;num
    inc a;num++
    pop bc;count
    dec c
    jr nz, .loop
  ret

GetInventoryLength::;puts item list len in b
  ld b, 0
  ld hl, items
.loop
    inc b
    ld a, [hli]
    inc hl
    and a
    ret z
    jr .loop

DrawInventoryEntry::;a = num, de = xy, bc = list len, draw count
  inc e;y++
  push de;xy
  cp a, b;is num last?
  jr c, .drawItem
  jr z, .drawCancel
  pop de;xy
  ret
.drawCancel
  ld hl, CancelString
  jp .draw

.drawItem
  dec a
  ld hl, items
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli];get item id
  dec a
  ld c, a
  ld a, [hl];get item count
  and a
  jr z, .getItemName

.drawItemCount
  ld h, 0
  ld l, a;item count
  push bc;item index
  push de;xy
  ld de, name_buffer
  call str_Number

  ld hl, name_buffer
  call str_Length

  ld h, e
  ld l, 1
  pop de;xy
  inc e
  push de;xy
  ld a, 17
  sub a, h
  ld d, a
  ld bc, name_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call SetTiles

  pop de;xy
  ld d, 14
  ld bc, name_buffer
  ld a, "x"
  ld [bc], a
  ld hl, $0101
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call SetTiles

  pop bc;item index

.getItemName
  ld hl, ItemNames 
  call str_FromArray;item index in bc

.draw
  ld de, str_buffer
  call str_Copy

  ld hl, str_buffer
  call str_Length

  ld h, e
  ld l, 1
  pop de;xy
  ld bc, str_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call SetTiles
  ret

UseTossText:
  db "USE\nTOSS",0

TooImportantText:
  db "That's too impor-\ntant to toss!",0

NoCyclingText:
  db "No cycling\nallowed here.",0

IsItOkToTossText:
  db "Is it OK to toss\n%s?",0

SelectItem::
  ld a, [_b]
  ld b, a
  ld a, [_s]
  ld c, a
  ld a, [_j]
  add a, c
  cp a, b
  jr z, .exit
.getItem
  dec a
  call GetInventoryItemID;item id in a
.checkBike
  cp BICYCLE_ITEM
  jr nz, .notBike

  ;TODO: check if cycling allowed
  ld hl, NoCyclingText
  jr .displayText

.notBike
  call GetItemData;item data address in hl
  push hl;item data address

  ld hl, UseTossText
  ld de, str_buffer
  call str_Copy
  xor a
  ld [name_buffer], a
  ld a, DRAW_FLAGS_WIN
  ld b, 13
  ld c, 10
  ld d, 7
  ld e, 5
  call ShowListMenu
  and a
  jp z, .exit

.tossItem
  pop hl;item data address
  inc hl
  ld a, [hld];a = item type, item data address in hl
  cp ITEM_TYPE_SPECIAL
  jr z, .tooImportant
  call TossItem
  ld a, 0
  ret

.tooImportant
  ld hl, TooImportantText
  jr .displayText

.useItem
  pop hl;item data address

  jr .exit
  
.displayText
  ld de, $0012
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText
  
  ld de, $1210
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call FlashNextArrow

.exit
  ld a, -1
  ret

UseItem:;hl = item address
  inc hl
  ld a, [hld];a = item type
  cp ITEM_TYPE_BASEBALL
  cp ITEM_TYPE_GAME
  cp ITEM_TYPE_MOVE
  cp ITEM_TYPE_SPECIAL
  cp ITEM_TYPE_STATS
  cp ITEM_TYPE_SELL
  cp ITEM_TYPE_WORLD

TossItem:;hl = item address
.showTossCount

.askSure
  ret
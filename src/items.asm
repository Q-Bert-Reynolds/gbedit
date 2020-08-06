INCLUDE "src/beisbol.inc"

INCLUDE "data/item_data.asm"
INCLUDE "data/item_strings.asm"

SECTION "Item Bank 0", ROM0
ShowInventory::
  ld a, [game_state]
  and a, GAME_STATE_PLAY_BALL
  jr z, .show
    call CopyBkgToWin
    ld a, 7
    ld [rWX], a
    xor a
    ld [rWY], a
    SHOW_WIN

.show
  ld a, [loaded_bank]
  push af
  ld a, ITEM_BANK
  call SetBank
  call _ShowInventory

  ld a, [game_state]
  and a, GAME_STATE_PLAY_BALL
  jr z, .exit
    HIDE_WIN

.exit
  pop af
  call SetBank
  ret

GetInventoryItemID::; a = index of item in list, returns item id in a, item count in [hl]
  push bc
  ld hl, inventory
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli];get item id
  pop bc
  ret 

GetItemData::;a = item id, returns item data address in hl
  push bc
  dec a
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
  pop bc
  ret

SECTION "Item Bank X", ROMX, BANK[ITEM_BANK]

UseTossText:          db "USE\nTOSS",0
TooImportantText:     db "That's too impor-\ntant to toss!",0
NoCyclingText:        db "No cycling\nallowed here.",0
IsItOkToTossItemText: db "Is it OK to toss\n%s?",0
ThrewAwayItemText:    db "Threw away\n%s.",0
NowIsNotTheTimeText:  db "Doc: %s!\nThis isn't the\ntime to use that!",0
BootedUpTMText:       db "Booted up a TM!",0
ItContainedMoveText:  db "It contained\n%s!",0
TeachMoveText:        db "Teach %s\nto a PLAYER?",0

_ShowInventory:
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
    call gbdk_WaitVBL
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
    ld de, 0
    ld hl, $1412
    ld bc, bkg_buffer
    call gbdk_GetWinTiles

    call SelectItem
    cp a, -1
    jr z, .exit
    
    ld de, 0
    ld hl, $1412
    ld bc, bkg_buffer
    call gbdk_SetWinTiles
    call DrawItems
    WAITPAD_UP
    jp .loop
    
.checkB
    ld b, 0
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
    jp .loop
.exit
  WAITPAD_UP
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
  ld hl, inventory
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
  ld hl, inventory
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

SelectItem::;returns exit code in a (-1 = close inventory, 0 = back to inventory)
  PLAY_SFX SelectSound
  ld a, [_j];index
  ld b, a
  ld a, [_c];number of places the list menu arrow can be
  ld c, a
  push bc;index/places
  ld a, [_b];num items
  ld b, a
  ld a, [_s];page
  ld c, a
  push bc;num items,page
  ld a, [_j]
  add a, c
  cp a, b
  jr z, .closeInventory
.getItem
  dec a;index
  ld b, a;index
  call GetInventoryItemID;item id in a
.checkBike
  cp BICYCLE_ITEM
  jr nz, .notBike

  ;TODO: check if cycling allowed
  ld hl, NoCyclingText
  jr .displayText

.notBike
  push bc;index in b
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
  pop hl;item data address
  pop bc;index in b
  and a
  jp z, .backToItemList
  cp a, 1
  jr z, .useItem
.tossItem
  inc hl
  ld a, [hld];a = item type, item data address in hl
  cp ITEM_TYPE_SPECIAL
  jr z, .tooImportant
  ld a, b;item index
  call TossItem
  jr .exit

.tooImportant
  ld hl, TooImportantText
  jr .displayText

.useItem
  ld a, b;item index
  call UseItem
  jr .exit
  
.displayText
  call RevealItemTextAndWait

.backToItemList
  ld a, 1
  jr .exit

.closeInventory
  ld a, -1

.exit;a = exit code (-1 = exit inventory, 0 = decrement item count)
  ld d, a;exit code
  pop bc;num items,page
  and a
  jr nz, .skip
  dec b
.skip
  ld a, b
  ld [_b], a;num items
  ld a, c
  ld [_s], a;page
  pop bc;index/places
  ld a, b
  ld [_j], a;index
  ld a, c
  ld [_c], a;number of places the list menu arrow can be
  ld a, d;exit code
  ret

UseItem:;hl = item data address, a = index, returns exit code in a (0 = item removed completely)
  push af;index
  ld a, [game_state]
  and a, GAME_STATE_PLAY_BALL
  push af;play ball flag
  inc hl
  ld a, [hld];a = item type
.checkBaseballItem
  cp ITEM_TYPE_BASEBALL
  jr nz, .checkGameItem
  pop af;play ball flag
  jr z, .notTheTime
    
.checkGameItem
  cp ITEM_TYPE_GAME
  jr nz, .checkMoveItem
  pop af;play ball flag
  jr z, .notTheTime

.checkMoveItem
  cp ITEM_TYPE_MOVE
  jr nz, .checkSpecialItem
  pop af;play ball flag
  jr nz, .notTheTime
  call TeachMove
  jr .exit
  
.checkSpecialItem
  cp ITEM_TYPE_SPECIAL
  jr nz, .checkStatsItem
  pop af;play ball flag
  call UseSpecialItem
  jr z, .notTheTime
  jr .exit

.checkStatsItem
  cp ITEM_TYPE_STATS
  jr nz, .checkSellItem
  pop af;play ball flag, not used here
  jr .exit

.checkSellItem
  cp ITEM_TYPE_SELL
  jr nz, .checkWorldItem
  pop af;play ball flag
  jr nz, .notTheTime
  jr .exit

.checkWorldItem
  cp ITEM_TYPE_WORLD
  jr nz, .exit
  pop af;play ball flag
  jr z, .notTheTime
  jr .exit

.notTheTime
  ld hl, NowIsNotTheTimeText
  ld de, str_buffer
  ld bc, user_name
  call str_Replace
  ld hl, str_buffer
  call RevealItemTextAndWait

.exit
  pop af;index
  ld a, 1
  ret

UseSpecialItem:;hl = item data address, f = playball flag, returns z if can't use now
  ld a, [hli]
  jr nz, .playingBaseball
.walkingAround
  DEBUG_LOG_STRING "HERE"
  cp TOWN_MAP_ITEM
  jr z, .useTownMap
  cp HARMONICA_ITEM
  jr z, .playMusic
  cp OLD_ROD_ITEM
  jr z, .goFish
  cp GOOD_ROD_ITEM
  jr z, .goFish
  cp SUPER_ROD_ITEM
  jr z, .goFish
  cp TOKEN_CASE_ITEM
  jr z, .showTokens
  jr .anywhere
.playingBaseball
  cp HARMONICA_ITEM
  jr z, .wakePlayer
  cp TOWN_MAP_ITEM
  ret z
  cp OLD_ROD_ITEM
  ret z
  cp GOOD_ROD_ITEM
  ret z
  cp SUPER_ROD_ITEM
  ret z
  cp TOKEN_CASE_ITEM
  ret z
.anywhere
  cp HELIX_JERSEY_ITEM
  ret z
  cp DOME_HELMET_ITEM
  ret z
  cp OLD_HAT_ITEM
  ret z
  cp GOLD_TEETH_ITEM
  ret z
  cp SS_TICKET_ITEM
  ret z
  cp DREAM_SCOPE_ITEM
  ret z
  cp EXP_ALL_ITEM
  ret z
  xor a
  ret
.goFish
  jr .exit
.showTokens
  jr .exit
.useTownMap
  call ShowTownMap
  jr .exit
.playMusic
  jr .exit
.wakePlayer
.exit
  ld a, 1
  or a
  ret

ShowTownMap:
  HIDE_WIN
  call DrawStateMap
.loop
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, PADF_A | PADF_B | PADF_START
  jr .loop
.exit
  SHOW_WIN
  ret

TeachMove:;hl = item data address
  ld bc, 4
  add hl, bc
  ld a, [hl]
  call GetMoveName

  ld hl, BootedUpTMText
  call RevealItemTextAndWait

  ld hl, ItContainedMoveText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealItemTextAndWait

  ld hl, TeachMoveText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  ld de, $000C
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText

  ld hl, YesNoText
  ld de, str_buffer
  call str_Copy
  xor a
  ld [name_buffer], a
  ld b, 14;x
  ld c, 7;y
  ld d, 6;w
  ld e, 5;h
  ld a, DRAW_FLAGS_WIN
  call ShowListMenu
  ret 

TossItem:;hl = item data address, a = index, returns exit code in a (0 = item removed completely)
  push hl;item data address
.showTossCount
  push af;index
  call GetInventoryItemID
  ld a, [hl];item count

  ld h, a;item count
  ld a, DRAW_FLAGS_WIN
  ld b, 15;x
  ld c, 9;y
  ld d, 5;w
  ld e, 3;h
  call ShowNumberPicker
  and a
  jr nz, .askSure
  pop bc;b = item index
  pop hl;item data address
  ld a, 1
  ret
  
.askSure
  pop bc;item index
  ld c, a;count
  pop hl;item data address
  push bc;index/count
  ld a, [hl]
  sub a, 2;why 2 instead of one?
  ld b, 0
  ld c, a
  ld hl, ItemNames 
  call str_FromArray;item index in bc
  push hl;item name
  ld de, name_buffer
  call str_Copy

  ld hl, IsItOkToTossItemText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace

  ld hl, str_buffer
  ld de, $000C
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText
  
  ld hl, YesNoText
  ld de, str_buffer
  call str_Copy
  xor a
  ld [name_buffer], a
  ld b, 14;x
  ld c, 7;y
  ld d, 6;w
  ld e, 5;h
  ld a, DRAW_FLAGS_WIN
  call ShowListMenu
  pop hl;item name
  pop bc;index/count
  cp a, 1
  jr z, .tossItems
  ld a, 1;return code
  ret

.tossItems
  push hl;item name
  ld d, 0
  ld e, b
  ld hl, inventory
  add hl, de
  add hl, de 
  inc hl
  ld a, [hl]
  sub a, c;item count - toss count
  jr z, .removeItemCompletely
  ld [hl], a
  ld a, 1;exit code
  jr .showText
.removeItemCompletely
  inc hl
  ld d, h
  ld e, l
  dec de
  dec de
  ld a, MAX_ITEMS*BYTES_PER_ITEM
  sub a, b
  sub a, b
  ld b, 0
  ld c, a;items to move down
  call mem_Copy;copies hl to hl-2
  xor a;exit code
.showText
  pop hl;item name
  push af;exit code
  ld de, name_buffer
  call str_Copy

  ld hl, ThrewAwayItemText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace

  ld hl, str_buffer
  call RevealItemTextAndWait

  pop af;exit code (-1 = item removed completely)
  ret

RevealItemTextAndWait:;hl = text
  ld de, $000C
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText
  
  ld de, $1210
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call FlashNextArrow
  ret
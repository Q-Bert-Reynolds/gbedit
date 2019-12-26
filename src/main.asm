include "src/hardware.asm"

section "Gloval Vars", wram0
last_button_state: db
button_state: db
temp: db

section "Header", rom0[$100]
Entry:
    nop
    jp Start
    NINTENDO_LOGO
if def(HOME)
    db "BEISBOL HOME",0,0,0  ;Cart name - 15bytes
else
    db "BEISBOL AWAY",0,0,0  ;Cart name - 15bytes
endc
    db 0                     ;$143
    db 0,0                   ;$144 - Licensee code (not important)
    db 0                     ;$146 - SGB Support indicator
    db CART_ROM_MBC5_RAM_BAT ;$147 - Cart type
    db CART_ROM_2M           ;$148 - ROM Size
    db CART_RAM_256K         ;$149 - RAM Size
    db 1                     ;$14a - Destination code
    db $33                   ;$14b - Old licensee code
    db 0                     ;$14c - Mask ROM version
    db 0                     ;$14d - Complement check (important)
    dw 0                     ;$14e - Checksum (not important)

section "VBlank",rom0[$0040]
    reti
section "LCDC",rom0[$0048]
    reti
section "TimerOverflow",rom0[$0050]
    reti
section "Serial",rom0[$0058]
    reti
section "p1thru4",rom0[$0060]
    reti

section "Game", rom0
Start:
ld sp, $ffff ;init stack ptr
call WaitVBlank

xor a ;"xor a" is equivlent to "ld a, 0", but it's twice as fast
ld [rLCDC], a ;turn off the display

ld hl, _VRAM + $1000 ;location of bg tiles


WaitVBlank::
    ldh a, [rLY] ;since the scanline address (rLY) is in $FFxx, use "ldh" instead of "ld"
    cp 144 ;check to see if we're done drawing all 144 lines
    jr c, WaitVBlank
    ret
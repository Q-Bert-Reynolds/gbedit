INCLUDE "src/beisbol.asm"
INCLUDE "src/start.asm"

SECTION "Gloval Vars", WRAM0
last_button_state: DB
button_state: DB
temp: DB

SECTION "Header", ROM0[$100]
Entry:
  nop
  jp Start
  NINTENDO_LOGO
IF DEF(_HOME)
  DB "BEISBOL HOME",0,0,0  ;Cart name - 15bytes
ELSE
  DB "BEISBOL AWAY",0,0,0  ;Cart name - 15bytes
ENDC
  DB 0                     ;$143
  DB 0,0                   ;$144 - Licensee code (not important)
  DB 0                     ;$146 - SGB Support indicator
  DB CART_ROM_MBC5_RAM_BAT ;$147 - Cart type
  DB CART_ROM_2M           ;$148 - ROM Size
  DB CART_RAM_256K         ;$149 - RAM Size
  DB 1                     ;$14a - Destination code
  DB $33                   ;$14b - Old licensee code
  DB 0                     ;$14c - Mask ROM version
  DB 0                     ;$14d - Complement check (important)
  dw 0                     ;$14e - Checksum (not important)

SECTION "VBlank", ROM0[$0040]
  reti
SECTION "LCDC", ROM0[$0048]
  reti
SECTION "TimerOverflow", ROM0[$0050]
  reti
SECTION "Serial", ROM0[$0058]
  reti
SECTION "p1thru4", ROM0[$0060]
  reti

SECTION "Game", ROM0
Game:
  ld sp, $ffff
  call Start
.gameLoop
  lcd_WaitVRAM
  jr .gameLoop

TurnLCDOff::
  ldh a, [rLCDC]
  add a
  ret nc
  lcd_WaitVRAM  
  ldh a, [rLCDC]
  and %01111111
  ldh [rLCDC],A
  ret

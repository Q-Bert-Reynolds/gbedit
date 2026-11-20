;The editor uses VBlank for cursor sprites and gamepad presses, and serial
;interrupts for the PS/2 keyboard.
SECTION "VBlank", ROM0[$0040]
  jp VBLInterrupt
SECTION "LCDC", ROM0[$0048]
  reti
SECTION "TimerOverflow", ROM0[$0050]
  reti
SECTION "Serial", ROM0[$0058]
  jp SerialInterrupt
SECTION "p1thru4", ROM0[$0060]
  reti

SECTION "Interrupt Code", ROM0
SerialInterrupt::
  PUSH_ALL
  call PS2KeyboardInterrupt
  POP_ALL
  reti

DisableLCDInterrupt::
  di
  ldh a, [rIE]
  and a, ~IEF_STAT
  ldh [rIE], a
  xor a
  ldh [rSTAT], a
  reti

VBLInterrupt::
  PUSH_ALL
  call gbdk_DMATransfer
  call LatchPad
  ld a, 1
  ldh [vbl_done], a
  POP_ALL
  reti

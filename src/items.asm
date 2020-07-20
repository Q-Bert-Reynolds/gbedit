INCLUDE "src/beisbol.inc"

SECTION "Items", ROM0

ShowItemListFromWorld::
  ld bc, $0000
  ld de, $1412
  ld a, DRAW_FLAGS_WIN
  call ShowListMenu ;a = draw flags, bc = xy, de = wh, [str_buffer] = text, [name_buffer] = title, returns choice in a (0 = cancel)
  ret
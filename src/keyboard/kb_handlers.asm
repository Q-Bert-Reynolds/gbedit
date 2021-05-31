; KBHandleCharacter
; KBHandleTab
; KBHandleEnter
; KBHandleBackspace

KBHandleCharacter::;a = character in ASCII
  jp DrawCharacter

KBHandleTab::
  ld c, 4
.loop
    push bc
    ld a, " "
    call DrawCharacter
    pop bc
    dec c
    jr nz, .loop
  ret

KBHandleEnter::
  xor a
  ld [_x], a
  ld a, [_y]
  inc a
  cp a, 18
  jr c, .setY
.wrapY
  xor a
.setY
  ld [_y], a
  ret

KBHandleBackspace::
  ld a, -1
  jp RemoveCharacter

KBHandleDelete::
  ld a, 1
  jp RemoveCharacter

KBHandleFunctionKey::;a = function key
  ret

KBHandleEscape::
  ret
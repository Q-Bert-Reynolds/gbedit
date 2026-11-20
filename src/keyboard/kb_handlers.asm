MACRO EDITOR_KEY ;key event
  ld a, \1
  jp KBHandleEditorKey
ENDM

KBHandleEditorKey::;a = key, queues key presses in editor mode
  ld b, a;key
  ld a, [kb_mode]
  cp a, KB_MODE_EDITOR
  ret nz
  ld a, [kb_flags]
  and a, KB_FLAG_RELEASE
  ret nz
  ld a, [kb_event_write]
  ld c, a;write index
  inc a
  and a, KB_EVENT_COUNT-1
  ld hl, kb_event_read
  cp a, [hl]
  ret z;queue full, drop key
  ld [kb_event_write], a
  ld h, 0
  ld l, c
  add hl, hl
  ld de, kb_event_buffer
  add hl, de
  ld [hl], b;key
  inc hl
  ld a, [kb_modifiers]
  ld [hl], a
  ret

KBHandleCharacter::
  jp KBHandleEditorKey

KBHandleArrowKey::;a = dpad flags
  ld c, KEY_RIGHT
  cp a, PADF_RIGHT
  jr z, .key
  ld c, KEY_LEFT
  cp a, PADF_LEFT
  jr z, .key
  ld c, KEY_UP
  cp a, PADF_UP
  jr z, .key
  ld c, KEY_DOWN
.key
  ld a, c
  jp KBHandleEditorKey

KBHandleTab::
  EDITOR_KEY KEY_TAB
KBHandleEnter::
  EDITOR_KEY KEY_ENTER
KBHandleEscape::
  EDITOR_KEY KEY_ESCAPE
KBHandleBackspace::
  EDITOR_KEY KEY_BACKSPACE
KBHandleDelete::
  EDITOR_KEY KEY_DELETE
KBHandleFunctionKey::;reserved for editor shortcuts
  ret

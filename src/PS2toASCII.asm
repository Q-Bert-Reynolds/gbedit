PS2toASCII:
DB 0 ;null
DB 27 ;escape
DB "1234567890-="
DB 8 ;backspace
DB 9 ;tab
DB "qwertyuiop[]"
DB 13 ;enter
DB -1 ;left control
DB "asdfghjkl;'`"
DB -1 ;left shift
DB "\\zxcvbnm,./"
DB -1 ;right shift
DB "*"
DB -1 ;left alt
DB " "
DB -1 ;Caps Lock
DB -1 ;F1
DB -1 ;F2
DB -1 ;F3
DB -1 ;F4
DB -1 ;F5
DB -1 ;F6
DB -1 ;F7
DB -1 ;F8
DB -1 ;F9
DB -1 ;F10
DB -1 ;NumberLock
DB -1 ;ScrollLock
DB "789-456+1230."

PS2toASCIIShifted:
DB 0 ;null
DB 27 ;escape
DB "!@#$%^&*()_+"
DB 8 ;backspace
DB 9 ;tab
DB "QWERTYUIOP{}"
DB 13 ;enter
DB -1 ;left control
DB "ASDFGHJKL:\"~"
DB -1 ;left shift
DB "|ZXCVBNM<>?"
DB -1 ;right shift
DB "*"
DB -1 ;left alt
DB " "
DB -1 ;CapsLock
DB -1 ;F1
DB -1 ;F2
DB -1 ;F3
DB -1 ;F4
DB -1 ;F5
DB -1 ;F6
DB -1 ;F7
DB -1 ;F8
DB -1 ;F9
DB -1 ;F10
DB -1 ;NumberLock
DB -1 ;ScrollLock
DB "789-456+1230."
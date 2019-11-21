Compiling:
    `python3 png2gbdk.py`
    `make clean`
    `make`

TODO:
    banking (ROM and SRAM)
    Main
        fade in/out func
    Intro
        sfx
        sparks after ball hits light
        pitch/bat anim
        bounce title
        delay version slide
        randomize players
    New Game
        Text
    Battle
    Walking
    Roledex

Controller - MCB5

ROM Banks:
    main.c (bank0) - movement, font, menus, bank switching
    start.c (bank1) - startup stuff (copyrights, intro, title, new game/continue)
    players.c (bank2) - player images
    battle.c (bank3) - battle code
    roledex.c (bank4) - rolédex

RAM Banks
    main.c (bank0) - global vars
    save.c (bank1) - name, money, progress
    party.c (bank2) - party players
    items.c (bank3) - carried items
    farm1.c, farm2.c, etc - equivalent to pkmn boxes
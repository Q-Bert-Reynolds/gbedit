Compiling:
    `python3 png2gbdk.py`
    `make clean`
    `make`

TODO:
    fix
    player images:
        batting/pitching -> front/back -> ready/action (8 each)
    python script
        handle 1bpp and rle
        only update .c file when png changes
        identify animations - same size, numbered names (name0, name1, etc)
    Main
    Intro
        sfx
        sparks after ball hits light
        pitch/bat anim
        bounce title
        delay version slide
        randomize players
    New Game
        shrink Calvin image
    Battle
        doubled back & player front images should be different batting/pitching images
        hit the ball
        opponent pitching
            handle different moves
        user batting
            handle different moves
        opponent batting
            animation
        user pitching
            animation
            move ball
    Team Menu
    Walking
    Roledex

Cart - MCB5, 4M ROM (256 banks), 32K SRAM (4 banks)

ROM Banks:
    main.c (bank0) - movement, font, menus, bank switching
    start.c (bank1) - startup stuff (copyrights, intro, title, new game/continue)
    battle.c (bank2) - battle code
    roledex.c (bank3) - rolédex descriptions
    players_a.c, players_b.c, etc (bank10 - 18) - player images

RAM Banks
    main.c (bank0) - global vars
    save.c (bank1) - name, money, progress
    party.c (bank2) - party players
    items.c (bank3) - carried items
    farm1.c, farm2.c, etc - equivalent to pkmn boxes
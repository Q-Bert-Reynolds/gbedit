# From the back of the box:
You've finally been granted your Béisbol coaching license. Now, it's time to head out to become the world's greatest baseball coach. It's going to take all you've got to recruit 150 Players in this enormous world. Recruit and train Players like the shockingly-cute Chu. Face off against Yogi's torrential cannons. Stand strong when facing OT's stormy Gust. Trade with friends and watch your Players grow. Important - no single Player can win it all. Can you develop the ultimate Béisbol strategy to defeat the eight League Leaders and become the greatest Béisbol Team of all time?

- Recruit up to 139 different Players playing the Home version. Using the Game Link cable (sold separately), trade with a friend who has the Away version to recruit all 150.
- You'll need to use both versions (Home and Away) to recruit all of the Players.
- Test your coaching skills by playing against a friend using the Game Link cable (sold separately).
- Save your Team and game progress on the Game Pak memory.
- Requires basic reading skills to fully enjoy the entertaining story.


# Links:
- [Rolédex](https://docs.google.com/spreadsheets/d/1IIjJsqXnREAFDcOv2hRcLN3WZhSiNk8bw7BR21-FdMg/edit#gid=2070431085)
- [Move List](https://docs.google.com/spreadsheets/d/1OaO0aDuWQQxm-jt5bHvgmJ0le7WQDbh3Wp3kto6G5YQ/edit#gid=0)
- [Trainer's Guide](https://drive.google.com/file/d/11NbPeM3DPUOJs8hVLy9bznyHUQPVsvav/view)
- [Home Version Box](https://drive.google.com/file/d/1-uF70yOGvBDvrCaU4W-j3mZX3pLW1fXw/view)
- [Away Version Box](https://drive.google.com/file/d/1_kXh6oG8o5cgbJV2eutplZcjUX0jlLqc/view)
- [Cartridge Labels](https://drive.google.com/file/d/1n6UwmMSDLmREgHvivLpuPbX-q09tqQ74/view)
- [Old rom hack attempt](https://bitbucket.org/q_bert_reynolds/beisbolromhack/src/master/)

# Compiling:
    python3 png2gbdk.py
    python3 roledex.py
    make clean
    make

# TODO:
Player images:

- batting/pitching -> front/back -> ready/action (8 each)

Python script

- handle 1bpp and rle
- only update .c file when png changes
- identify animations - same size, numbered names (name0, name1, etc)

Intro

- sfx
- sparks after ball hits light
- pitch/bat anim
- bounce title
- delay version slide
- randomize players

New Game

- shrink Calvin image, transition to bedroom

Battle

- doubled back & player front images should be different batting/pitching images
- hit the ball
- handle different moves
- batting 
- opponent batting / user pitching
    - animation
    - move ball

Team Menu

Walking

Rolédex

# Cart
MCB5, 2M ROM (128 banks), 32K SRAM (4 banks)

ROM Banks:

    main.c         ( bank0 ) - movement/collisions, bank switching
    ui.c           ( bank2 ) - font, non-realtime UI functions, options
    start.c        ( bank3 ) - copyrights & intro
    title.c        ( bank4 ) - title, new game/continue menu
    new_game.c     ( bank5 ) - prologue, name entry
    play_ball.c    ( bank6 ) - baseball
    roledex.c      ( bank7 ) - rolédex descriptions
    lineup.c       ( bank8 ) - change batting order & positions
    players_imgX.c ( bank1X) - player images

RAM Banks

    save0.c (bank0) - main save file
# From the back of the box:
You've finally been granted your Béisbol coach's license. Now, it's time to head out to become the world's greatest baseball coach. It's going to take all you've got to recruit 150 Players in this enormous world. Recruit and train Players like the shockingly-cute Chu. Face off against Yogi's torrential cannons. Stand strong when facing OT's stormy Gust. Trade with friends and watch your Players grow. Important - no single Player can win it all. Can you develop the ultimate Béisbol strategy to defeat the eight League Leaders and become the greatest Béisbol Team of all time?

- Recruit up to 139 different Players playing the Home version. Using the Game Link cable (sold separately), trade with a friend who has the Away version to recruit all 150.
- You'll need to use both versions (Home and Away) to recruit all of the Players.
- Test your coaching skills by playing against a friend using the Game Link cable (sold separately).
- Save your Team and game progress on the Game Pak memory.
- Requires basic reading skills to fully enjoy the entertaining story.

# Links:
- [Rolédex](https://docs.google.com/spreadsheets/d/1IIjJsqXnREAFDcOv2hRcLN3WZhSiNk8bw7BR21-FdMg)
- [Move List](https://docs.google.com/spreadsheets/d/1OaO0aDuWQQxm-jt5bHvgmJ0le7WQDbh3Wp3kto6G5YQ)
- [Trainer's Guide](https://drive.google.com/file/d/11NbPeM3DPUOJs8hVLy9bznyHUQPVsvav/view)
- [Home Version Box](https://drive.google.com/file/d/1-uF70yOGvBDvrCaU4W-j3mZX3pLW1fXw/view)
- [Away Version Box](https://drive.google.com/file/d/1_kXh6oG8o5cgbJV2eutplZcjUX0jlLqc/view)
- [Cartridge Labels](https://drive.google.com/file/d/1n6UwmMSDLmREgHvivLpuPbX-q09tqQ74/view)
- [Old rom hack attempt](https://bitbucket.org/q_bert_reynolds/beisbolromhack)

# Compiling:
    python3 png2rgbds.py
    python3 roledex.py
    make clean
    make

# Cart:
MCB5, 2M ROM (128 banks), 32K SRAM (4 banks)

# TODO:
General

- link cable support!
- give math subroutines more appropriate names
- math_Divide24 and str_Number24 are both really similar to their 16 bit counterparts, perhaps they can be reduced in to a smaller number of instructions, or we could only use the 24 bit versions
- SetSpriteTiles and SetSpriteTilesProps can likely be merged
- big list of "real names" to use in place of ID and OT

Python scripts

- duplicate functionality (like the PascalCase function) should be moved to library file
- avatar directional maps should be organized into arrays
- only update .asm file when PNG or TMX files change
- handle 1bpp and rle images
- identify animations - same size, numbered names (name0, name1, etc)

Intro

- sfx
- sparks after ball hits light
- pitch/bat anim
- delay version slide
- randomize players

New Game

- shrink Calvin image, transition to bedroom

Battle

- doubled back & player front images should be different batting/pitching images
- hit the ball
- handle different moves
- show X next to pitches when batting / swings when pitching 
- opponent batting / user pitching
    - animation
    - move ball

Team Menu

- stat page
  - missing moves in move list should show "-"
  - should be accessible from PC as well
- swap batting order
- restore tiles from previous screen

Overworld

- make legs go behind things
- collisions
- animated tiles
- load black tiles outside of map bounds
- fix move left/up bug where boundary tiles don't load sometimes

Rolédex

- layout
- scrolling
- details

Music:

- Charge (intro anim)
- Billet Town
- play ball

SFX:

- pitch
- hit
- wiff
- catch
- select
- confirm
- cancel

Player images:

- batting/pitching -> front/back -> ready/action (8 each)

# Thanks

- Jeff Frohwein, http://devrs.com/gb/
- John Metcalf, http://www.retroprogramming.com
- http://z80-heaven.wikidot.com/
- https://gbdev.github.io/pandocs/
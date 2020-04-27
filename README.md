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
    python3 mod2gbt.py
    python3 img2rgbds.py
    python3 tmx2rgbds.py
    python3 roledex.py
    python3 moves.py
    make clean
    make

# Cart:
MCB5, 2M ROM (128 banks), 32K SRAM (4 banks)

# Credits

- Art, Code, Audio - Nolan Baker
- hardware.inc - Jones, Carsten Sorenson, Jeff Frohwein, Antonio Niño Díaz
- memory1.asm - Jeff Frohwein, Carsten Sorensen
- gbdk.asm - Pascal Felber, Lars Malmborg, Michael Hope
- gbt_player.asm - Antonio Niño Díaz
- sgb.asm - Imanol Barriuso, Martin Ahrnbom

# Thanks

- [Nintendo](https://www.nintendo.com/), [Creatures inc.](https://www.creatures.co.jp/), and [GAME FREAK inc.](https://www.gamefreak.co.jp/) for creating [Pokémon](https://www.pokemon.com/us/pokemon-video-games/pokemon-red-version-and-pokemon-blue-version/).
- Pascal Felber, Lars Malmborg, and Michael Hope for [GBDK](https://gbdk.sourceforge.net)
- [Jeff Frohwein](https://devrs.com/gb/)
- [John Metcalf](https://www.retroprogramming.com)
- Anyon who has contributed to [Z80 Heaven](https://z80-heaven.wikidot.com/)
- Anyone who worked on the [GameBoy Pandocs](https://gbdev.github.io/pandocs/):
  - Pan of Anthrox
  - Marat Fayzullin
  - Pascal Felber
  - Paul Robson
  - Martin Korth
  - Antonio Niño Díaz
  - Antonio Vivace
  - Beannaich
  - Elizafox
  - endrift
  - exezin
  - Furrtek
  - Gekkio
  - ISSOtm
  - Jeff Frohwein
  - John Harrison
  - kOOPa
  - LIJI32
  - jrra
  - Mantidactyle
  - mattcurrie
  - nitro2k01
  - pinobatch
  - T4g1
  - TechFalcon
- Anyone who worked on the [GameBoy CPU Manual](http://marc.rawer.de/Gameboy/Docs/GBCPUman.pdf)
  - Pan of Anthrox
  - GABY
  - Marat Fayzullin
  - Pascal Felber
  - Paul Robson
  - Martin Korth
  - kOOPa
  - Bowser
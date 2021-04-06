Priority

- load/interact characters and items from map data
  - map sprites should be cleared from buffer after going through a door
  - after moving, iterate through array and oam_ram removing sprites that are far enough off screen
  - handle sprite collisions
- using the computer
  - Bill's PC (will allow roster changes!!!)
  - Doc's PC
  - League PC
- unsigned player should be pitcher in leadoff spot for random appearances
  - ghosts should be the rest of the spots
  - unsigned player always bats, ghosts always run
- make batting results semi-random so we can move on to FX

Bugs

- on GBC/SGB, player colors aren't reset after viewing the move list during a ballgame
- on SGB, viewing a player on your team during a ballgame crashes the game
- unclipped map text drawn incorrectly most of the time
- can't deposit special items
- if holding more than one directional button, can't hop ledge
- palettes broken when exiting lineup or roledex
- color of version name incorrect after returning from new game/continue/options screen
- SGB sound test doesn't seem to work, test on hardware

 General

- link cable support!
- copy string labels and English text to spreadsheet, translate to other languages, parse CSV
- give math subroutines more appropriate names
- big list of "real names" to use in place of ID and OT
- cut off sprites with the text box using an LCD interrupt (see https://gbdev.io/pandocs/#faux-layer-textbox-status-bar)
- print stats, records, rolédex

Optimization

- COPY_TILE_BLOCK macro in GBDK.asm should be a subroutine, add HRAM vars to allow for this
- utilize remaining HRAM (after DMA routine)
- replace long chains of compares and jumps with jump tables
- remove use of temp_bank in rolédex to free up RAM
- move_data.id could be stored in upper 7 bits (since there are < 128 moves), move_data.use in LSB
- player image data need to be compressed to fit more
- math_Divide24 and str_Number24 are both really similar to their 16 bit counterparts, perhaps they can be reduced in to a smaller number of instructions, or we could only use the 24 bit versions
- SetSpriteTiles, SetSpriteTilesProps, and SetSpriteTilesXY can likely be merged
- Load/Set User/Opposing PlayerBkgTiles subroutines share a ton of code
- palette ids are at most 7, so two palettes could fit in a byte, cutting palette data in half
- several routines that simply call their banked counterpart can likely be replaced with Trampoline

Python scripts

- add colors and palette maps to player data
- roledex description parser should print warning when more than 6 lines
- avatar directional maps should be organized into arrays
- SGB borders should (optionally?) use PNG palettes directly
- duplicate functionality (like the PascalCase function) should be moved to library file
- only update .asm file when PNG, GIF, TMX, or MOD files change
- handle 1bpp and rle images

Start

- intro home version batter has too many tiles, is also ugly
- make intro ball movement smooth
- randomize(ish) scrolling players on title screen

Play Ball

- transition animation should also set tile palettes
- offers accepted by unsigned players should end game
- set contact power from move, player, and barrel
- if opposing pitcher is ahead - throw more balls, behind - throw more strikes
- pitches in the dirt should bounce
- hide strikezone after pitcher sets
- reduce pitching frames to 3, batting to 2, make trail fx a sprite
- ball should go behind lefty user batter, righty opposing batter
- ball should fly off screen after contact
- slide batter across screen right after contact, walk, etc.
- more pitching/batting animations
- change color of move info based on type
- bunting
- update user player stats

Game Results

- Show box score
- Learn moves at certain ages. (sepatrate learn move logic from UseItemOnPlayer subroutine)

Announcer

- finish (deterministic) announcer mode baseball logic
- fix range calculation in AnnounceFieldingText subroutine
- Announce "Squirt looks done for out there." when out of HP. 
- Announce things like "Ghost runners on first and third." when playing against an unsigned player

Simulation

- ball should bounce off fences
- running
- catching throwing
- implement basic rules
- iterative landing spot calc slightly off, direct method often way off
- field should probably be bigger than 32x32

Team Menu

- add hair/skin palette data
- pressing left and right cycles between stats
- missing moves in stat page move list should show "-"
- stat page should be accessible from PC
- show pitch or bat icon next to move PP
- show appropriate stat (ie. BA, ERA) below age

Map System

- handle different sprite types (ie. tile, stamp, animation, avatar)
- sprites should be pooled
  - make an array of map object instances (current position, map chunk, map sprites index)
- map text should be clipped (or converted to stamps or turned off completely)
- map scripts should also have collision check
- use Unity's collision trigger property for finer control over GB collisions
- separate palettes and stamps from object data
- palette 0 is used for UI, should not be exported
- chunks should be exported as tile arrays when more efficient than objects
- print errors for more than 255 chunks, text, doors, etc. when exporting a scene
- map stamps should be referenced from an index to a jump table instead of directly addressed
- default collision type for chunk
- regions should have their own music, palettes, tiles, etc
- an chunk index of 0 should fill the chunk with some default tile
- make legs go behind things
- animated tiles
- add diagonal lines to map system, (already implemented in editor)
- draw map to bkg_buffer then copy to _SCRN0... unsure if it's faster, but it should be tested
- make the editor a standalone application

Items

- change select arrow to empty after selecting item
- hide play/item/team/run when item menu selected
- max offer should depend on ball (baseball = $100, game ball = $1000, etc.)
- use protein, carbos, etc.
- add music/text when playing harmonica in overworld
- wake player when playing harmonica in game
- use select to swap items in list
- add town names and cursor to town map
- status clearing items should have more specific messages (ie. "Chu is no longer paralyzed.")
 
Rolédex

- update seen/signed after games, transformations, and signings
- finish player descriptions (some show placeholder pokemon text)
- fix player descriptions that are longer than 6 lines
- if player descriptions only span 1 page, garbage text is drawn on the next
- create tileset specific to dex
- show player home towns / recruitment locations

Audio

- pitch, hit, wiff, catch SFX
- on/off PC SFX

Super GameBoy

- set tiles to palette 0 when drawing UI boxes (currently only works on GBC)
- GBCSetPalette (used to match SGB and GBC palettes) can cause problems with GBC specific palettes
- use color palette data
- use additional sprites (bottom row of tiles will be trashed)
- borders for each city when walking
- borders for different fields
- extra music voices
- fix LCD interrupt flickering when sending packets
- use second controller?

Design Notes

- Ghost runners appear when an unrecruited player gets on base
- you can only see/sign Ghost runners after you've bought a ticket to the Field of Dreams
- player stats should peak at their prime age (~25)
- after prime age, speed and throw stats begin to decline (bat and field don't)
- when a player dies (~75), their second type becomes Ghost
- rather than selecting a player, you're selecting one of Doc Hicory's three teams - you get to name it
- play against Doc Hicory (the Billet Town team that neither you nor your rival picked) anytime you want to
- pitch speed should be a relative speed so that pitches appear faster when the pitcher's Throw stat is higher than the batter's Bat stat
- each town should have an age limits for their league, you should be able to replay home teams as many times as you want
- Bill (of Bill's PC fame) is Bill James.
- teammates in their 20s and 30s have a small chance of producing a child
- A storm has cut off the path to the weather tower. It's cleared after you beat the game. That's where you meet the weather man, Mike.
- after becoming the world champions, the northern pass opens... encounter Mike at top of weather research tower
- You can use items as often as you want, but using an item on your pitcher while they're pitching requires a mound visit. Umps won't let you make more than one mound visit per inning per pitcher.
- Pitchers must complete a plate appearance before they can be swapped out.
- Low HP means more errors and bad pitches, slower movement.
- You get the frozen head of Ted Williams in the equivalent of Pewter City's Museum of Science.
- replace "PC" with "server"
- When a player reaches 0 HP, they're hurt and must come out of the game. The minimum number of players on the field is 7. Below that, and the team must forefeit. Whenever there is no player for a lineup spot, an out is recorded for that batter.
- Batting/Pitching sprites should be shown on appropriate stat screens.
- Main player image should be flipped to show correct handedness.
- make some players only available on certain hardware (DMG, GBC, SGB 1/2, GBP, GBA, emulators)
- age should be independent of experience and based instead on game time
  - if 30 minutes of playing is 1 month, you would need to play for 6 hours for your initial team of 5-year-olds to turn 6
  - experience would be tied to Grade (instead of Level)
  - steroid use would then affect Grade instead of Age
  - steroids use should be tracked separately
  - steroids stop working after they've been taken 20 times
  - some transformations (Gio to OT, for example) require steroid use
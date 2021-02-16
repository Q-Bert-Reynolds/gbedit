Priority

- map system
  - enter/exit buildings
  - handle multiple maps/banks
  - load/interact characters and items
- make batting results semi-random so we can move on to FX

 General

- link cable support!
- copy string labels and English text to spreadsheet, translate to other languages, parse CSV
- give math subroutines more appropriate names
- big list of "real names" to use in place of ID and OT
- cut off sprites with the text box using an LCD interrupt (see https://gbdev.io/pandocs/#faux-layer-textbox-status-bar)

Optimization

- COPY_TILE_BLOCK macro in GBDK.asm should be a subroutine, add HRAM vars to allow for this
- move most used subroutines to HRAM
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

- color of version name incorrect after returning from new game/continue/options screen
- intro home version batter has too many tiles
- make intro ball movement smooth
- randomize(ish) scrolling players on title screen
- load bedroom map after new game scene ends

Play Ball

- fix UI palette on GBC
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

- print errors for more than 255 chunks, text, doors, etc. when exporting a scene
- map stamps should be referenced from an index to a jump table instead of directly addressed
- default collision type for chunk
- regions should have their own music, palettes, tiles, etc
- an chunk index of 0 should fill the chunk with some default tile
- font tiles should be usable in the editor
- random encounters should only happen on fields, batting cages, bullpens, etc
- make legs go behind things
- animated tiles
- add diagonal lines to map system, (already implemented in editor)
- draw map to bkg_buffer then copy to _SCRN0... unsure if it's faster, but it should be tested
- door script should have dropdowns for scene and chunk instead of typing in names
- make the editor a standalone application
- BUG: if holding more than one directional button, collisions can break

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

- update seen/signed after games, evolutions, and signings
- finish player descriptions (some show placeholder pokemon text)
- fix player descriptions that are longer than 6 lines
- if player descriptions only span 1 page, garbage text is drawn on the next
- create tileset specific to dex
- show player home towns / recruitment locations

Audio

- fix title screen SFX and music switching
- pitch, hit, wiff, catch SFX

Super GameBoy

- use color palette data
- use additional sprites
- borders for each city when walking
- borders for different fields
- crowd SFX
- extra music voices
- fix LCD interrupt flickering when sending packets
- use second controller?

Design Notes

- Ghost runners appear when an unrecruited player gets on base
- you can only see/sign Ghost runners after you've bought a ticket to the Field of Dreams
- player stats should peak at their prime age (~25)
- after prime age, speed and throw stats begin to decline (bat and field don't)
- when a player dies (~75), their second type becomes Ghost
- steroids move a player's age toward their prime age
- steroids stop working half way between prime and death (~50)
- rather than selecting a player, you're selecting one of Doc Hicory's three teams - you get to name it
- play against Doc Hicory (the Billet Town team that neither you nor your rival picked) anytime you want to
- pitch speed should be a relative speed so that pitches appear faster when the pitcher's Throw stat is higher than the batter's Bat stat
- trash cans at your rival's house "look like they've taken a beating"
- each town should have an age limits for their league, you should be able to replay home teams as many times as you want
- Bill (of Bill's PC fame) is Bill James.
- teammates in their 20s and 30s have a small chance of producing a child
- A storm has cut off the path to the weather tower. It's cleared after you beat the game. That's where you meet the weather man, Mike.
- after becoming the world champions, the northern pass opens... encounter Mike at top of weather research tower
- You can use items as often as you want, but using an item on your pitcher while they're pitching requires a mound visit. Umps won't let you make two mound visits in a row.
- No HP means more errors and bad pitches, slower movement.
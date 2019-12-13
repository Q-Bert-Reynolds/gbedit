VERSION = AWAY
ROM_NAME = BEISBOL_$(VERSION).gbc
CART = 0x1B #ROM+MBC5+RAM+BATT
ROM_BANKS = 0x80
RAM_BANKS = 0x04
ROM_FLAGS = -Wl-yt$(CART) -Wl-yo$(ROM_BANKS) -Wl-ya$(RAM_BANKS)

# Directories
SRC_DIR =   ./src
DATA_DIR =  ./data
MUSIC_DIR = ./music
DIST_DIR =  ./bin
OBJ_DIR =   ./build

# Binaries
CC = lcc -D$(VERSION)=def

# Files
ROM_FILE = $(DIST_DIR)/$(ROM_NAME)
OBJ_FILES = $(OBJ_DIR)/main.o

all: 
	# gcc mod2gbt.c -o $(DIST_DIR)/mod2gbt

	@mkdir -p $(OBJ_DIR)
	
	$(CC) -Wa-l -Wf-ba1 -c -o $(OBJ_DIR)/save0.o $(SRC_DIR)/save0.c
	
	# $(CC) -Wa-l -Wf-bo1 -c -o $(OBJ_DIR)/gbt_player_bank1.o $(SRC_DIR)/gbt_player_bank1.s
	$(CC) -Wa-l -Wf-bo2 -c -o $(OBJ_DIR)/ui.o               $(SRC_DIR)/ui.c	
	$(CC) -Wa-l -Wf-bo3 -c -o $(OBJ_DIR)/start.o            $(SRC_DIR)/start.c
	$(CC) -Wa-l -Wf-bo4 -c -o $(OBJ_DIR)/title.o            $(SRC_DIR)/title.c
	$(CC) -Wa-l -Wf-bo5 -c -o $(OBJ_DIR)/new_game.o         $(SRC_DIR)/new_game.c
	$(CC) -Wa-l -Wf-bo6 -c -o $(OBJ_DIR)/play_ball.o        $(SRC_DIR)/play_ball.c

	for i in {0..5}; do\
		$(CC) -Wa-l -Wf-bo1$$i -c -o $(OBJ_DIR)/roledex$$i.o $(DATA_DIR)/roledex$$i.c;\
	done

	# $(CC) -Wa-l -c -o $(OBJ_DIR)/gbt_player.o $(SRC_DIR)/gbt_player.s
	$(CC) -Wa-l -c -o $(OBJ_DIR)/main.o 	  $(SRC_DIR)/main.c
	
	@mkdir -p $(DIST_DIR)
	$(CC) -Wl-m -Wl-yp0x143=0x80 $(ROM_FLAGS) -o $(ROM_FILE) $(OBJ_DIR)/*.o
	
	open $(ROM_FILE)

clean:
	# @rm -rf $(DIST_DIR)
	@rm -rf $(OBJ_DIR)

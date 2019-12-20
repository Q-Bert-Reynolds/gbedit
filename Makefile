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
	@mkdir -p $(OBJ_DIR)
	
	# Save RAM
	$(CC) -Wa-l -Wf-ba1 -c -o $(OBJ_DIR)/save0.o     $(SRC_DIR)/save0.c

	# ROM Banks
	$(CC) -Wa-l -Wf-bo2 -c -o $(OBJ_DIR)/ui.o        $(SRC_DIR)/ui.c	
	$(CC) -Wa-l -Wf-bo3 -c -o $(OBJ_DIR)/start.o     $(SRC_DIR)/start.c
	$(CC) -Wa-l -Wf-bo4 -c -o $(OBJ_DIR)/title.o     $(SRC_DIR)/title.c
	$(CC) -Wa-l -Wf-bo5 -c -o $(OBJ_DIR)/new_game.o  $(SRC_DIR)/new_game.c
	$(CC) -Wa-l -Wf-bo6 -c -o $(OBJ_DIR)/play_ball.o $(SRC_DIR)/play_ball.c

	# Generated Files
	$(CC) -Wa-l -Wf-bo8 -c -o $(OBJ_DIR)/player_strings.o $(DATA_DIR)/player_strings.c 
	$(CC) -Wa-l -Wf-bo9 -c -o $(OBJ_DIR)/player_data.o $(DATA_DIR)/player_data.c 
	for i in {0..5}; do\
		$(CC) -Wa-l -Wf-bo1$$i -c -o $(OBJ_DIR)/player_img$$i.o $(DATA_DIR)/player_img$$i.c;\
	done

	# Bank 0
	$(CC) -Wa-l -c -o $(OBJ_DIR)/audio.o     $(SRC_DIR)/audio.c	
	$(CC) -Wa-l -c -o $(OBJ_DIR)/main.o 	  $(SRC_DIR)/main.c
	
	# GB File
	@mkdir -p $(DIST_DIR)
	$(CC) -Wl-m -Wl-yp0x143=0x80 $(ROM_FLAGS) -o $(ROM_FILE) $(OBJ_DIR)/*.o
	
	open $(ROM_FILE)

clean:
	# @rm -rf $(DIST_DIR)
	@rm -rf $(OBJ_DIR)

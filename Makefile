VERSION = AWAY
ROM_NAME = BEISBOL_$(VERSION).gbc
CART = 0x1B #ROM+MBC5+RAM+BATT
ROM_BANKS = 0x80
RAM_BANKS = 0x04
ROM_FLAGS = -Wl-yt$(CART) -Wl-yo$(ROM_BANKS) -Wl-ya$(RAM_BANKS)

# Directories
SRC_DIR = ./src
DIST_DIR = ./bin
OBJ_DIR = ./build

# Binaries
CC = lcc -D$(VERSION)=def

# Files
ROM_FILE = $(DIST_DIR)/$(ROM_NAME)
OBJ_FILES = $(OBJ_DIR)/main.o

all: 
	@mkdir -p $(OBJ_DIR)
	
	$(CC) -Wa-l -Wf-ba1 -c -o $(OBJ_DIR)/save0.o        $(SRC_DIR)/save0.c
	$(CC) -Wa-l -Wf-bo2 -c -o $(OBJ_DIR)/ui.o           $(SRC_DIR)/ui.c	
	$(CC) -Wa-l -Wf-bo3 -c -o $(OBJ_DIR)/start.o        $(SRC_DIR)/start.c
	$(CC) -Wa-l -Wf-bo4 -c -o $(OBJ_DIR)/title.o        $(SRC_DIR)/title.c
	$(CC) -Wa-l -Wf-bo5 -c -o $(OBJ_DIR)/new_game.o     $(SRC_DIR)/new_game.c
	$(CC) -Wa-l -Wf-bo6 -c -o $(OBJ_DIR)/play_ball.o    $(SRC_DIR)/play_ball.c

	$(CC) -Wa-l -Wf-bo10 -c -o $(OBJ_DIR)/player_img0.o $(SRC_DIR)/player_img0.c
	$(CC) -Wa-l -Wf-bo11 -c -o $(OBJ_DIR)/player_img1.o $(SRC_DIR)/player_img1.c
	$(CC) -Wa-l -Wf-bo12 -c -o $(OBJ_DIR)/player_img2.o $(SRC_DIR)/player_img2.c
	$(CC) -Wa-l -Wf-bo13 -c -o $(OBJ_DIR)/player_img3.o $(SRC_DIR)/player_img3.c
	$(CC) -Wa-l -Wf-bo14 -c -o $(OBJ_DIR)/player_img4.o $(SRC_DIR)/player_img4.c
	$(CC) -Wa-l -Wf-bo15 -c -o $(OBJ_DIR)/player_img5.o $(SRC_DIR)/player_img5.c
	
	$(CC) -Wa-l -c -o $(OBJ_DIR)/main.o $(SRC_DIR)/main.c
	
	@mkdir -p $(DIST_DIR)
	$(CC) -Wl-m -Wl-yp0x143=0x80 $(ROM_FLAGS) -o $(ROM_FILE) $(OBJ_DIR)/*.o
	
	open $(ROM_FILE)

clean:
	# @rm -rf $(DIST_DIR)
	@rm -rf $(OBJ_DIR)

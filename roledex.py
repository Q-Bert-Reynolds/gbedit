import csv

def main():
  roledex = []
  with open("./data/roledex.csv") as file:
    dict_reader = csv.DictReader(file)
    for player in dict_reader:
      roledex.append(player)
  
  file_count = 6
  players_per_file = int(151 / file_count)

  generate_header()
  generate_main(file_count, players_per_file)
  for i in range(file_count):
    generate_banks(roledex, i, players_per_file)

def generate_header ():
  with open("./data/roledex.h", "w+") as h_file:
    h_file.write("#ifndef ROLEDEX\n")
    h_file.write("#define ROLEDEX\n\n")
    h_file.write("#include <gb/gb.h>\n\n")
    h_file.write("#define PLAYER_IMG_BANK 10\n\n")
    h_file.write("void load_player_bkg_data (UBYTE number, UBYTE vram_offset, WORD return_bank);\n")
    h_file.write("UBYTE get_player_img_columns (UBYTE number, WORD return_bank);\n")
    h_file.write("void set_player_bkg_tiles(UBYTE x, UBYTE y, UBYTE number, UBYTE vram_offset, WORD return_bank);\n\n")
    h_file.write("#endif\n")

def generate_main (file_count, players_per_file):
  with open("./data/roledex.c", "w+") as c_file:
    c_file.write("#include \"../src/beisbol.h\"\n\n")

    for i in range(file_count):
      c_file.write("extern const char* player_tiles" + str(i) + "[];\n")
    for i in range(file_count):
      c_file.write("extern const unsigned char player_tile_counts" + str(i) + "[];\n")
    for i in range(file_count):
      c_file.write("extern const unsigned char player_columns" + str(i) + "[];\n")
    for i in range(file_count):
      c_file.write("extern const char* player_maps" + str(i) + "[];\n")

    c_file.write("\nvoid load_player_bkg_data (UBYTE number, UBYTE vram_offset, WORD return_bank) {\n    ")
    for i in range(file_count):
      n = players_per_file*(i+1)
      if i < file_count-1:
        c_file.write("if (number <= "+str(n)+")")
      c_file.write(" {\n")
      c_file.write("        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+"+str(i)+");\n")
      c_file.write("        set_bkg_data(vram_offset, ")
      c_file.write("player_tile_counts"+str(i)+"[number-"+str(n-players_per_file+1)+"], ")
      c_file.write("player_tiles"+str(i)+"[number-"+str(n-players_per_file+1)+"]);\n")
      c_file.write("    }\n")
      if i < file_count-1:
        c_file.write("    else ")
    c_file.write("    SWITCH_ROM_MBC5(return_bank);\n}\n")

    c_file.write("\nUBYTE get_player_img_columns (UBYTE number, WORD return_bank) {\n    i = 0;\n    ")
    for i in range(file_count):
      n = players_per_file*(i+1)
      if i < file_count-1:
        c_file.write("if (number <= "+str(n)+")")
      c_file.write(" {\n")
      c_file.write("        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+"+str(i)+");\n")
      c_file.write("        i = player_columns"+str(i)+"[number-"+str(n-players_per_file+1)+"];\n")
      c_file.write("    }\n")
      if i < file_count-1:
        c_file.write("    else ")
    c_file.write("    SWITCH_ROM_MBC5(return_bank);\n    return i;\n}\n")

    c_file.write("\nvoid set_player_bkg_tiles(UBYTE x, UBYTE y, UBYTE number, UBYTE vram_offset, WORD return_bank) {\n    ")
    for i in range(file_count):
      n = players_per_file*(i+1)
      if i < file_count-1:
        c_file.write("if (number <= "+str(n)+")")
      c_file.write(" {\n")
      c_file.write("        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+"+str(i)+");\n")
      c_file.write("        set_bkg_tiles_with_offset(x, y, ")
      c_file.write("player_columns"+str(i)+"[number-"+str(n-players_per_file+1)+"], ")
      c_file.write("player_columns"+str(i)+"[number-"+str(n-players_per_file+1)+"], vram_offset, ")
      c_file.write("player_maps"+str(i)+"[number-"+str(n-players_per_file+1)+"]);\n")
      c_file.write("    }\n")
      if i < file_count-1:
        c_file.write("    else ")
    c_file.write("    SWITCH_ROM_MBC5(return_bank);\n}\n")

def generate_banks(roledex, i, players_per_file):
  with open("./data/roledex"+str(i)+".c", "w+") as c_file:
    for n in range(players_per_file):
      player = roledex[i*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("#include \"../img/players/"+name+".c\"\n")

    c_file.write("\nconst char* player_tiles"+str(i)+"[] = {\n")
    for n in range(players_per_file):
      player = roledex[i*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("    &_"+name+"_tiles,\n")

    c_file.write("};\n\nconst unsigned char player_tile_counts"+str(i)+"[] = {\n")
    for n in range(players_per_file):
      player = roledex[i*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("    _"+name.upper()+"_TILE_COUNT,\n")

    c_file.write("};\n\nconst unsigned char player_columns"+str(i)+"[] = {\n")
    for n in range(players_per_file):
      player = roledex[i*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("    _"+name.upper()+"_COLUMNS,\n")

    c_file.write("};\n\nconst char* player_maps"+str(i)+"[] = {\n")
    for n in range(players_per_file):
      player = roledex[i*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("    &_"+name+"_map,\n")
    c_file.write("};\n")

if __name__ == "__main__":
  main()
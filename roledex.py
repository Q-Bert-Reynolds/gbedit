import csv

file_count = 6
players_per_file = int(151 / file_count)

def main():
  roledex = []
  with open("./data/roledex.csv") as file:
    dict_reader = csv.DictReader(file)
    for player in dict_reader:
      roledex.append(player)
  
  generate_header()
  generate_main()
  generate_player_strings(roledex)
  generate_player_data(roledex)
  for bank in range(file_count):
    generate_img_bank(roledex, bank)

def generate_header ():
  with open("./data/roledex.h", "w+") as h_file:
    h_file.write("#ifndef ROLEDEX\n")
    h_file.write("#define ROLEDEX\n\n")
    h_file.write("#include <gb/gb.h>\n")
    h_file.write("#include \"../src/types.h\"\n\n")
    h_file.write("#define PLAYER_STRINGS 8\n")
    h_file.write("#define PLAYER_DATA 9\n")
    h_file.write("#define PLAYER_IMG_BANK 10\n\n")
    h_file.write("char* get_player_name (UBYTE number, WORD return_bank);\n")
    h_file.write("char* get_player_description (UBYTE number, WORD return_bank);\n")
    h_file.write("void load_player_base_data (UBYTE number, WORD return_bank);\n")
    h_file.write("void load_player_bkg_data (UBYTE number, UBYTE vram_offset, WORD return_bank);\n")
    h_file.write("UBYTE get_player_img_columns (UBYTE number, WORD return_bank);\n")
    h_file.write("void set_player_bkg_tiles(UBYTE x, UBYTE y, UBYTE number, UBYTE vram_offset, WORD return_bank);\n\n")
    h_file.write("#endif\n")

def generate_main ():
  with open("./data/roledex.c", "w+") as c_file:
    c_file.write("#include \"roledex.h\"\n")
    c_file.write("#include \"../src/beisbol.h\"\n\n")

    c_file.write("extern const char* player_strings[151];\n")
    c_file.write("extern void load_base_data(unsigned char number);\n")
    for i in range(file_count):
      c_file.write("extern const char* player_tiles" + str(i) + "[];\n")
    for i in range(file_count):
      c_file.write("extern const UBYTE player_tile_counts" + str(i) + "[];\n")
    for i in range(file_count):
      c_file.write("extern const UBYTE player_columns" + str(i) + "[];\n")
    for i in range(file_count):
      c_file.write("extern const char* player_maps" + str(i) + "[];\n")

    c_file.write("\nchar* get_player_name (UBYTE number, WORD return_bank) {\n")
    c_file.write("    SWITCH_ROM_MBC5(PLAYER_STRINGS);\n")
    c_file.write("    strcpy(name_buff, player_strings[number]);\n")
    c_file.write("    SWITCH_ROM_MBC5(return_bank);\n")
    c_file.write("    return name_buff;\n}\n")

    c_file.write("\nchar* get_player_description (UBYTE number, WORD return_bank) {\n")
    c_file.write("    SWITCH_ROM_MBC5(PLAYER_STRINGS);\n")
    c_file.write("    strcpy(str_buff, (player_strings[number]+11));\n")
    c_file.write("    SWITCH_ROM_MBC5(return_bank);\n")
    c_file.write("    return str_buff;\n}\n")

    c_file.write("\nPlayerBase player_base;\n")
    c_file.write("void load_player_base_data (UBYTE number, WORD return_bank) {\n")
    c_file.write("    SWITCH_ROM_MBC5(PLAYER_DATA);\n")
    c_file.write("    load_base_data(number);\n")
    c_file.write("    SWITCH_ROM_MBC5(return_bank);\n}\n")

    c_file.write("\nvoid load_player_bkg_data (UBYTE number, UBYTE vram_offset, WORD return_bank) {\n    ")
    for i in range(file_count):
      n = players_per_file*(i+1)
      if i < file_count-1:
        c_file.write("if (number <= "+str(n)+") ")
      c_file.write("{\n")
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
        c_file.write("if (number <= "+str(n)+") ")
      c_file.write("{\n")
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
        c_file.write("if (number <= "+str(n)+") ")
      c_file.write("{\n")
      c_file.write("        SWITCH_ROM_MBC5(PLAYER_IMG_BANK+"+str(i)+");\n")
      c_file.write("        set_bkg_tiles_with_offset(x, y, ")
      c_file.write("player_columns"+str(i)+"[number-"+str(n-players_per_file+1)+"], ")
      c_file.write("player_columns"+str(i)+"[number-"+str(n-players_per_file+1)+"], vram_offset, ")
      c_file.write("player_maps"+str(i)+"[number-"+str(n-players_per_file+1)+"]);\n")
      c_file.write("    }\n")
      if i < file_count-1:
        c_file.write("    else ")
    c_file.write("    SWITCH_ROM_MBC5(return_bank);\n}\n")

def generate_img_bank(roledex, bank):
  player_count = players_per_file
  if bank == file_count-1:
    remainder = 151 - players_per_file * file_count
    player_count += remainder

  with open("./data/player_img"+str(bank)+".c", "w+") as c_file:
    for n in range(player_count):
      player = roledex[bank*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("#include \"../img/players/"+name+".c\"\n")

    c_file.write("\nconst char* player_tiles"+str(bank)+"[] = {\n")
    for n in range(player_count):
      player = roledex[bank*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("    &_"+name+"_tiles,\n")

    c_file.write("};\n\nconst unsigned char player_tile_counts"+str(bank)+"[] = {\n")
    for n in range(player_count):
      player = roledex[bank*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("    _"+name.upper()+"_TILE_COUNT,\n")

    c_file.write("};\n\nconst unsigned char player_columns"+str(bank)+"[] = {\n")
    for n in range(player_count):
      player = roledex[bank*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("    _"+name.upper()+"_COLUMNS,\n")

    c_file.write("};\n\nconst char* player_maps"+str(bank)+"[] = {\n")
    for n in range(player_count):
      player = roledex[bank*players_per_file+n]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      c_file.write("    &_"+name+"_map,\n")
    c_file.write("};\n")

def generate_player_strings(roledex):
  with open("./data/player_strings.c", "w+") as c_file:
    c_file.write("\nconst char* player_strings[151] = {\n")
    for player in roledex:
      c_file.write("    \"{0: <10}\\0{1}\",\n".format(player["Nickname"], player["Description"]))
    c_file.write("};\n")


type_names = [
  "NORMAL", "FIRE", "WATER", "ELECTRIC", "GRASS", 
  "ICE", "FIGHTING", "POISON", "GROUND", "FLYING", 
  "PSYCHIC", "BUG", "ROCK", "GHOST", "DRAGON"
]
def player_type_string(player):
  t1 = type_names.index(player["Type1"].upper())
  s =  "    " + str(t1) + ", // " + player["Type1"] + ",\n"
  if player["Type2"]:
    t2 = type_names.index(player["Type2"].upper())
    s += "    " + str(t2) + ", // " + player["Type2"] + ",\n"
  else:
    s += "    " + str(t1) + ",\n"
  return s

def evolves_to_string(roledex, player):
  s = ""
  num = 0
  try:
    int(player["EVTo"])
  except:
    pass

  if num > 0:
    num = int(player["EVTo"])
    s += player["EVTo"]
    s += ", // " + roledex[num]["Nickname"]
  else:
    s += "0,"
  return "    " + s + "\n"

evolution_types = ["None", "Level", "Trade", "Fire", "Water", "Thunder", "Leaf", "Moon"]
def evolution_type_string(player):
  evType = ""
  evLevel = ""
  lv = 0
  try:
    lv = int(player["EVType"])
  except:
    pass
  
  if lv > 0:
    evType += "1, // evolves at Level:"
    evLevel += player["EVType"] + ","
  elif player["EVType"] in evolution_types:
    evType += str(evolution_types.index(player["EVType"])) +  ", //"
    if player["EVType"] == "Trade":
      evType += "evolves when Traded"
    else:
      evType += "evolves when given " + player["EVType"] + " Ball"
    evLevel += "0,"
  else:
    evType += "0,"
    evLevel += "0,"
  return "    " + evType + "\n    " + evLevel + "\n"

def generate_player_data(roledex):
  with open("./data/player_data.c", "w+") as c_file:
    c_file.write("#include \"../src/types.h\"\n")

    var_names = ""
    for player in roledex:
      var_name = "_" + player["#"] + player["Nickname"].replace(" ","").replace("-","") + "_roledex"
      var_names += "    &" + var_name + ",\n"
      c_file.write("\nPlayerBase " + var_name + " = {\n")
      c_file.write("    " + str(int(player["#"])) + ",\n")
      c_file.write(player_type_string(player))
      c_file.write(evolves_to_string(roledex, player))
      c_file.write(evolution_type_string(player))
      c_file.write("    " + str(player["HP"]) + ", // HP\n")
      c_file.write("    " + str(player["Bat"]) + ", // Bat\n")
      c_file.write("    " + str(player["Field"]) + ", // Field\n")
      c_file.write("    " + str(player["Speed"]) + ", // Speed\n")
      c_file.write("    " + str(player["Throw"]) + ", // Throw\n")
      c_file.write("    " + str(player["BodyID"]) + ", // Lineup Body\n")
      c_file.write("    " + str(player["HeadID"]) + ", // Lineup Head\n")
      c_file.write("    " + str(player["HatID"]) + ", // Lineup Hat\n")
      c_file.write("};\n")
    c_file.write("\nconst PlayerBase* roledex[151] = {\n"+var_names+"};\n")

    c_file.write("\nvoid load_base_data(unsigned char number) {\n")
    r = "roledex[number]"
    c_file.write("    player_base.num = "+r+"->num;\n")
    c_file.write("    player_base.type1 = "+r+"->type1;\n")
    c_file.write("    player_base.type2 = "+r+"->type2;\n")
    c_file.write("    player_base.evolves_to = "+r+"->evolves_to;\n")
    c_file.write("    player_base.evolve_type = "+r+"->evolve_type;\n")
    c_file.write("    player_base.evolve_level = "+r+"->evolve_level;\n")
    c_file.write("    player_base.hp = "+r+"->hp;\n")
    c_file.write("    player_base.bat = "+r+"->bat;\n")
    c_file.write("    player_base.field = "+r+"->field;\n")
    c_file.write("    player_base.speed = "+r+"->speed;\n")
    c_file.write("    player_base.throw = "+r+"->throw;\n")
    c_file.write("    player_base.lineup_body = "+r+"->lineup_body;\n")
    c_file.write("    player_base.lineup_head = "+r+"->lineup_head;\n")
    c_file.write("    player_base.lineup_hat = "+r+"->lineup_hat;\n")
    c_file.write("}\n")


if __name__ == "__main__":
  main()
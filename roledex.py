import csv
import textwrap

file_count = 6
players_per_file = int(151 / file_count)

def main():
  roledex = []
  with open("./data/roledex.csv") as file:
    dict_reader = csv.DictReader(file)
    for player in dict_reader:
      roledex.append(player)
  
  generate_player_strings(roledex)
  generate_player_data(roledex)
  generate_img_bank(roledex)

def generate_img_bank(roledex):
  with open("./data/player_img.asm", "w+") as c_file:
    for bank in range(file_count):
      player_count = players_per_file
      if bank == file_count-1:
        remainder = 151 - players_per_file * file_count
        player_count += remainder

      c_file.write("SECTION \"Player Images "+str(bank)+"\", ROMX, BANK[PLAYER_IMG_BANK+"+str(bank)+"]\n")
      c_file.write("DW PlayerTiles"+str(bank)+"\n")
      c_file.write("DW PlayerTileCounts"+str(bank)+"\n")
      c_file.write("DW PlayerColumns"+str(bank)+"\n")
      c_file.write("DW PlayerTileMaps"+str(bank)+"\n\n")

      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        c_file.write("INCLUDE \"img/players/"+name+".asm\"\n")

      c_file.write("\nPlayerTiles"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        c_file.write("DW _"+name+"Tiles\n")

      c_file.write("\nPlayerTileCounts"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        c_file.write("DB _"+name.upper()+"_TILE_COUNT\n")

      c_file.write("\nPlayerColumns"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        c_file.write("DB _"+name.upper()+"_COLUMNS\n")

      c_file.write("\nPlayerTileMaps"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        c_file.write("DW _"+name+"TileMap\n")
      c_file.write("\n")

def generate_player_strings(roledex):
  with open("./data/player_strings.asm", "w+") as c_file:
    c_file.write("SECTION \"Player Strings\", ROMX, BANK[PLAYER_STRINGS_BANK]\n")
    c_file.write("\nPlayerNames::\n")
    for player in roledex:
      c_file.write("DB \"{0}\", 0\n".format(player["Nickname"].upper()))
    c_file.write("\n\nPlayerDescriptions::\n")
    for player in roledex:
      lines = textwrap.wrap(player["Description"], 18)
      description = "\\n".join(lines)
      c_file.write("DB \"{0}\", 0\n".format(description))
    c_file.write("\n")

def player_type_string(player):
  t1 = player["Type1"].upper()
  s =  "DB " + t1 + "\n"
  if player["Type2"]:
    t2 = player["Type2"].upper()
    s += "DB " + t2 + "\n"
  else:
    s += "DB NONE\n"
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
    s += " ;" + roledex[num]["Nickname"]
  else:
    s += "0"
  return "DB " + s + "\n"

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
    evType += "1 ;evolves at Level:"
    evLevel += player["EVType"]
  elif player["EVType"] in evolution_types:
    evType += str(evolution_types.index(player["EVType"])) +  " ;"
    if player["EVType"] == "Trade":
      evType += "evolves when Traded"
    else:
      evType += "evolves when given " + player["EVType"] + " Ball"
    evLevel += "0"
  else:
    evType += "0"
    evLevel += "0"
  return "DB " + evType + "\nDB " + evLevel + "\n"

def generate_player_data(roledex):
  with open("./data/player_data.asm", "w+") as c_file:
    c_file.write("SECTION \"Player Data\", ROMX, BANK[PLAYER_DATA_BANK]\n")

    var_names = ""
    for player in roledex:
      var_name = "_" + player["#"] + player["Nickname"].replace(" ","").replace("-","") + "Roledex"
      var_names += "DW " + var_name + "\n"
      c_file.write("\n" + var_name + ":\n")
      c_file.write("DB " + str(int(player["#"])) + "\n")
      c_file.write(player_type_string(player))
      c_file.write(evolves_to_string(roledex, player))
      c_file.write(evolution_type_string(player))
      c_file.write("DB " + str(player["HP"]) + " ;HP\n")
      c_file.write("DB " + str(player["Bat"]) + " ;Bat\n")
      c_file.write("DB " + str(player["Field"]) + " ;Field\n")
      c_file.write("DB " + str(player["Speed"]) + " ;Speed\n")
      c_file.write("DB " + str(player["Throw"]) + " ;Throw\n")
      c_file.write("DB " + str(player["BodyID"]) + " ;Lineup Body\n")
      c_file.write("DB " + str(player["HeadID"]) + " ;Lineup Head\n")
      c_file.write("DB " + str(player["HatID"]) + " ;Lineup Hat\n")
      c_file.write("DB " + str(player["GBPal"]) + " ;Palette\n")
    c_file.write("\nRoledex:\n"+var_names+"\n")

    c_file.write("LoadBaseData:: ;bc = number\n")
    c_file.write("  ld hl, Roledex\n")
    c_file.write("  add hl, bc\n")
    c_file.write("  ld a, [hli]\n")
    c_file.write("  ld b, a\n")
    c_file.write("  ld a, [hl]\n")
    c_file.write("  ld l, a\n")
    c_file.write("  ld h, b\n")
    c_file.write("  ld de, player_base\n")
    c_file.write("  ld bc, 14\n")
    c_file.write("  call mem_Copy\n")
    c_file.write("  ret\n")

if __name__ == "__main__":
  main()
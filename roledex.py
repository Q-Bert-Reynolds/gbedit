import os
import glob
import csv
import textwrap
import math

players_per_file = 4
file_count = math.ceil(151 / players_per_file)
print ("Generating " + str(file_count) + " player image banks.")

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
  with open("./data/player_img.asm", "w+") as asm_file:
    asm_file.write("IMG_BANK_COUNT EQU " + str(file_count) + "\n")
    asm_file.write("PLAYERS_PER_BANK = 151 / IMG_BANK_COUNT\n\n")
    for bank in range(file_count):
      player_count = players_per_file
      if bank == file_count-1:
        player_count = 151 - players_per_file * (file_count-1)

      asm_file.write("SECTION \"Player Images "+str(bank)+"\", ROMX, BANK[PLAYER_IMG_BANK+"+str(bank)+"]\n\n")
      
      asm_file.write("DW PlayerTiles"+str(bank)+"\n")
      asm_file.write("DW PlayerTileCounts"+str(bank)+"\n")
      asm_file.write("DW PlayerColumns"+str(bank)+"\n")
      asm_file.write("DW PlayerTileMaps"+str(bank)+"\n")
      asm_file.write("DW PlayerAnimTiles"+str(bank)+"\n")
      asm_file.write("DW PlayerAnimTileCounts"+str(bank)+"\n")
      asm_file.write("DW PlayerAnimTileMaps"+str(bank)+"\n\n")

      anims = [
        "lefty_batter_user",
        "righty_batter_user",
        "lefty_pitcher_user_2x",
        "righty_pitcher_user_2x",
        "lefty_batter_opponent",
        "righty_batter_opponent",
        "lefty_pitcher_opponent",
        "righty_pitcher_opponent",
      ]

      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        asm_file.write("INCLUDE \"img/players/"+name+".asm\"\n")

      asm_file.write("\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        for path in glob.glob("./img/players/"+name+"/"+name+"_*.asm"):
          asm_file.write("INCLUDE \"" + path + "\"\n")


      asm_file.write("\nPlayerTiles"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        asm_file.write("DW _"+name+"Tiles\n")

      asm_file.write("\nPlayerTileCounts"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        asm_file.write("DB _"+name.upper()+"_TILE_COUNT\n")

      asm_file.write("\nPlayerColumns"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        asm_file.write("DB _"+name.upper()+"_COLUMNS\n")

      asm_file.write("\nPlayerTileMaps"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        asm_file.write("DW _"+name+"TileMap\n")

      asm_file.write("\nPlayerAnimTiles"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        for anim in anims:
          path = "./img/players/"+name+"/"+name+"_"+anim+".asm"
          if os.path.exists(path):
            label = "_" + name + PascalCase(anim) + "Tiles"
            asm_file.write("DW "+label+"\n")
          else:
            asm_file.write("DW 0\n")

      asm_file.write("\nPlayerAnimTileCounts"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        for anim in anims:
          path = "./img/players/"+name+"/"+name+"_"+anim+".asm"
          if os.path.exists(path):
            count = "_" + name.upper() + "_" + anim.upper() + "_TILE_COUNT"
            asm_file.write("DB "+count+"\n")
          else:
            asm_file.write("DB 0\n")

      asm_file.write("\nPlayerAnimTileMaps"+str(bank)+"::\n")
      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        for anim in anims:
          path = "./img/players/"+name+"/"+name+"_"+anim+".asm"
          if os.path.exists(path):
            label = "_" + name + PascalCase(anim) + "0TileMap"
            asm_file.write("DW "+label+"\n")
          else:
            asm_file.write("DW 0\n")

      asm_file.write("\n")

def generate_player_strings(roledex):
  with open("./data/player_strings.asm", "w+") as asm_file:
    asm_file.write("SECTION \"Player Strings\", ROMX, BANK[PLAYER_STRINGS_BANK]\n")
    asm_file.write("\nPlayerNames::\n")
    for player in roledex:
      asm_file.write("DB \"{0}\", 0\n".format(player["Nickname"].upper()))
    asm_file.write("\n\nPlayerDescriptions::\n")
    for player in roledex:
      lines = textwrap.wrap(player["Description"], 18)
      description = "\\n".join(lines)
      asm_file.write("DB \"{0}\", 0\n".format(description))
    asm_file.write("\n")

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

def height_string(player):
  h = float(player["Height"])
  feet = "{0:01X}".format(int(h))
  inches = "{0:01X}".format(int((h*100)%100))
  return "DB $" + feet + inches + " ;height\n"

def weight_string(player):
  w = float(player["Weight"])
  lbs = "{0:03X}".format(int(w))
  frac = "{0:01X}".format(int((w*10)%10))
  return "DW $" + frac + lbs + " ;weight\n"

def generate_player_data(roledex):
  with open("./data/player_data.asm", "w+") as asm_file:
    asm_file.write("SECTION \"Player Data\", ROMX, BANK[PLAYER_DATA_BANK]\n")
    asm_file.write(";weight format: DDDDLLLL LLLLLLLL where D is decimal and L is lbs\n")
    asm_file.write(";height format: FFFFIIII where F is feet and I is inches\n")

    var_names = ""
    for player in roledex:
      var_name = "_" + player["#"] + player["Nickname"].replace(" ","").replace("-","") + "Roledex"
      var_names += "DW " + var_name + "\n"
      asm_file.write("\n" + var_name + ":\n")
      asm_file.write("DB " + str(int(player["#"])) + "\n")
      asm_file.write(player_type_string(player))
      asm_file.write(evolves_to_string(roledex, player))
      asm_file.write(evolution_type_string(player))
      asm_file.write(height_string(player))
      asm_file.write(weight_string(player))
      asm_file.write("DB " + str(player["HP"]) + " ;HP\n")
      asm_file.write("DB " + str(player["Bat"]) + " ;Bat\n")
      asm_file.write("DB " + str(player["Field"]) + " ;Field\n")
      asm_file.write("DB " + str(player["Speed"]) + " ;Speed\n")
      asm_file.write("DB " + str(player["Throw"]) + " ;Throw\n")
      asm_file.write("DB " + str(player["BodyID"]) + " ;Lineup Body\n")
      asm_file.write("DB " + str(player["HeadID"]) + " ;Lineup Head\n")
      asm_file.write("DB " + str(player["HatID"]) + " ;Lineup Hat\n")
      asm_file.write("DB " + str(player["GBPal"]) + " ;Palette\n")
    asm_file.write("\nRoledex:\n"+var_names)

def PascalCase(name):
  s = name.split("_")
  for i in range(len(s)):
    s[i] = s[i][0].upper() + s[i][1:]
  s = "".join(s)
  s.replace("-", "")
  return s

if __name__ == "__main__":
  main()
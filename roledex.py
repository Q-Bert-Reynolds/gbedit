import os
import glob
import csv
import textwrap
import math
import pathlib 

players_per_file = 27
file_count = math.ceil(151 / players_per_file)
print ("Generating " + str(file_count) + " player image banks.")

anims = [
  "lefty_batter_user",
  "righty_batter_user",
  "lefty_pitcher_user",
  "righty_pitcher_user",
  "lefty_batter_opponent",
  "righty_batter_opponent",
  "lefty_pitcher_opponent",
  "righty_pitcher_opponent",
]

def main():
  roledex = []
  with open("./data/roledex.csv") as file:
    dict_reader = csv.DictReader(file)
    for player in dict_reader:
      roledex.append(player)

  learned_moves = {}
  with open("./data/learned_moves.csv") as file:
    rows = csv.reader(file)
    moves = next(rows)
    max_learnset = 0
    player_with_largest = ""
    for row in rows:
      player = row[0]
      player_moves = []
      for i in range(1, len(row)):
        if (row[i]):
          player_moves.append((row[i], moves[i]))
      if len(player_moves) > max_learnset:
        max_learnset = len(player_moves)
        player_with_largest = player
      learned_moves[player] = sorted(player_moves)
  print(player_with_largest + " has largest learnset at " + str(max_learnset) + " moves.")

  taught_moves = {}
  with open("./data/taught_moves.csv") as file:
    rows = csv.reader(file)
    moves = next(rows)
    count = math.ceil(55/8)*8 #number of HMs + TMs rounded to the next multiple of 8
    for row in rows:
      player = row[0]
      player_moves = ["0"]*count
      for i in range(1, len(row)):
        if (row[i]):
          player_moves[i-1] = "1"
      bin_str = "".join(player_moves)
      byte_array = []
      for i in range(0,count,8):
        byte_array.append("${:02X}".format(int(bin_str[i:i+8], 2)))
      taught_moves[player] = byte_array

  generate_player_strings(roledex)
  generate_player_data(roledex, learned_moves, taught_moves)
  generate_img_bank(roledex)

def generate_img_bank(roledex):
  with open("./data/player_img.asm", "w+") as asm_file:
    asm_file.write("IMG_BANK_COUNT EQU " + str(file_count) + "\n")
    asm_file.write("PLAYERS_PER_BANK = (151 + (IMG_BANK_COUNT- 1)) / IMG_BANK_COUNT\n\n")
    for bank in range(file_count):
      player_count = players_per_file
      if bank == file_count-1:
        player_count = 151 - players_per_file * (file_count-1)

      asm_file.write("SECTION \"Player Images "+str(bank)+"\", ROMX, BANK[PLAYER_IMG_BANK+"+str(bank)+"]\n\n")
      
      asm_file.write("DW PlayerTiles"+str(bank)+"\n")
      asm_file.write("DW PlayerTileCounts"+str(bank)+"\n")
      asm_file.write("DW PlayerColumns"+str(bank)+"\n")
      asm_file.write("DW PlayerTileMaps"+str(bank)+"\n")

      for n in range(player_count):
        player = roledex[bank*players_per_file+n]
        name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
        asm_file.write("INCLUDE \"img/players/"+name+".asm\"\n")

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

      asm_file.write("\n")

    bank = 0
    bytes_per_anim = 65*16 + 56*4 #max 16 tiles, max 4 8x7 frames, TODO: this should be calculated instead 
    bytes_so_far = 0
    index = 0
    while index < 151:
      if bytes_so_far == 0:
        asm_file.write("SECTION \"Player Animations "+str(bank)+"\", ROMX, BANK[PLAYER_IMG_BANK+IMG_BANK_COUNT+"+str(bank)+"]\n\n")
        asm_file.write("\n")
      player = roledex[index]
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      for path in glob.glob("./img/players/"+name+"/"+name+"_*.asm"):
        path = pathlib.PurePath(path).as_posix()
        asm_file.write("INCLUDE \"" + path + "\"\n")
        bytes_so_far += bytes_per_anim
        if (bytes_so_far >= 16384):
          bank += 1
          bytes_so_far = 0
      index += 1
    print("Generated " + str(bank+1) + " banks for player animations.")

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

ev_items = {
  "Fire":    "FIRE_GLOVE_ITEM",
  "Thunder": "SPARK_GLOVE_ITEM",
  "Water":   "WATER_GLOVE_ITEM",
  "Leaf":    "LEAF_GLOVE_ITEM",
  "Moon":    "MOON_GLOVE_ITEM"
}
def evolves_to_string(roledex, player):
  s = ";evolution\n"
  if not player["EVTo"]:
    s += "DB EV_TYPE_NONE\n"
    return s

  ages = []
  player_nums = []
  types = []
  try:
    player_nums = [player["EVTo"]]
    ages = [int(player["EVType"])]
    types = ["EV_TYPE_AGE"]
  except:
    player_nums = player["EVTo"].split(" ")
    types = player["EVType"].split(" ")
    ages = [0] * len(types)
  
  for i in range(len(player_nums)):
    num = str(int(player_nums[i]))
    t = types[i]
    extra = "0"
    if (ages[i] > 0):
      t = "EV_TYPE_AGE"
      extra = str(ages[i])
    elif types[i] == "Trade":
      t = "EV_TYPE_TRADE"
    else:
      extra = ev_items[t]
      t = "EV_TYPE_ITEM"
    s += "DB " + t + ", " + num + ", " + extra + "\n"

  s += "DB 0\n"
  return s

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

def generate_player_data(roledex, learned_moves, taught_moves):
  with open("./data/player_data.asm", "w+") as asm_file:
    for player in roledex:
      asm_file.write("NUM_"+player["Nickname"].upper().replace(" ","_").replace("-","_")+" EQU "+str(int(player["#"]))+"\n")

    asm_file.write("SECTION \"Player Data\", ROMX, BANK[PLAYER_DATA_BANK]\n")
    asm_file.write(";weight format: DDDDLLLL LLLLLLLL where D is decimal and L is lbs\n")
    asm_file.write(";height format: FFFFIIII where F is feet and I is inches\n")

    var_names = ""
    for player in roledex:
      name = player["#"] + player["Nickname"].replace(" ","").replace("-","")
      var_name = "_" + name + "Roledex"
      var_names += "DW " + var_name + "\n"
      asm_file.write("\n" + var_name + ":\n")
      asm_file.write("DB " + str(int(player["#"])) + "\n")
      asm_file.write(player_type_string(player))
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
      asm_file.write("DB " + str(player["GBPal"]) + " ;Lineup Palette\n")
      asm_file.write("DW " + str(player["SGBPal"]) + " ;Color Palette\n")

      asm_file.write(";animations\n")
      for anim in anims:
        count = anim.upper() + "_TILE_COUNT"
        label = PascalCase(anim) + "Tiles"

        path = "./img/players/"+name+"/"+name+"_"+anim+".asm"
        if os.path.exists(path):
          label = name + label
          count = name.upper() + "_" + count

        asm_file.write("DB BANK(_"+label+")\n")
        asm_file.write("DW _"+label+"\n")
        asm_file.write("DB _"+count+"\n")

      asm_file.write("DB " + ", ".join(taught_moves[player["Nickname"]]) + " ;HM/TM bit field\n")

      asm_file.write(";learnset\n")
      for move in learned_moves[player["Nickname"]]:
        move_const = move[1].upper().replace(" ","_").replace(".","").replace("-","_") + "_MOVE"
        asm_file.write("DB " + move_const + ", " + move[0] + "\n")
      asm_file.write("DB 0\n")

      asm_file.write(evolves_to_string(roledex, player))
      
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
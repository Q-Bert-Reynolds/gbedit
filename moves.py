import csv

def main():
  moves = []
  with open("./data/moves.csv") as file:
    dict_reader = csv.DictReader(file)
    for move in dict_reader:
      moves.append(move)

  generate_move_data(moves)
  generate_move_strings(moves)

def generate_move_strings(moves):
  with open("./data/move_strings.asm", "w+") as c_file:
    c_file.write("SECTION \"Move Strings\", ROMX, BANK[PLAYER_STRINGS_BANK]\n")
    
    c_file.write("\nMoveNames::\n")
    for move in moves:
      if (len(move["Move"]) > 12):
        print("Warning: \"" + move["Move"] + "\" is more than 12 characters long.")
      c_file.write("DB \"" + move["Move"] + "\", 0\n")

def generate_move_data(moves):
  with open("./data/move_data.asm", "w+") as c_file:
    c_file.write("SECTION \"Move Data\", ROMX, BANK[PLAYER_DATA_BANK]\n")

    constants = ""
    var_names = ""
    move_data = ""
    for i in range(len(moves)):
      move = moves[i]
      var_name = move["Move"].replace(" ","").replace(".","").replace("-","") + "Move"
      var_names += "DW " + var_name + "\n"
      constant = move["Move"].upper().replace(" ","_").replace(".","").replace("-","_") + "_MOVE"
      constants += constant + " EQU " + str(i+1) + "\n"
      move_data += "\n" + var_name + ":;" + move["Description"] + "\n"
      move_data += "DB " + constant + "\n"
      if move["Category"] == "Pitching":
        move_data += "DB 0;Pitch\n"
      else:
        move_data += "DB 1;Swing\n"
      move_data += "DB " + move["Type"].upper() + "\n"
      move_data += "DB " + str(move["PP"]) + " ;Play Points\n"
      move_data += "DB " + str(move["Power"]) + " ;Power\n"
      move_data += "DB " + str(move["Acc"]) + " ;Accuracy\n"
      if move["Launch"]:
        move_data += "DB " + str(move["Launch"]) + " ;Launch Angle\n"
      if move["Spray"]:
        move_data += "DB " + str(move["Spray"]) + " ;Spray\n"
      if move["Pull"]:
        move_data += "DB " + str(int(float(move["Pull"])*45)) + " ;Pull\n"
      if move["Path"]:
        move_data += "DB PITCH_PATH_" + move["Path"].upper() + " ;Path\n"

    c_file.write("\n" + constants + move_data + "\nMoveList:\n" + var_names + "\n")

if __name__ == "__main__":
  main()
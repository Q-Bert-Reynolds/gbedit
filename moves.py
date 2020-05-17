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
    for i in range(len(moves)):
      move = moves[i]
      var_name = move["Move"].replace(" ","").replace(".","").replace("-","") + "Move"
      var_names += "DW " + var_name + "\n"
      constants += move["Move"].upper().replace(" ","_").replace(".","").replace("-","_") + "_MOVE EQU " + str(i+1) + "\n"
      c_file.write("\n" + var_name + ":;" + move["Description"] + "\n")
      if move["Category"] == "Pitching":
        c_file.write("DB 0;Pitch\n")
      else:
        c_file.write("DB 1;Swing\n")
      c_file.write("DB " + move["Type"].upper() + "\n")
      c_file.write("DB " + str(move["PP"]) + " ;Play Points\n")
      c_file.write("DB " + str(move["Power"]) + " ;Power\n")
      c_file.write("DB " + str(move["Acc"]) + " ;Accuracy\n")
      if move["Launch"]:
        c_file.write("DB " + str(move["Launch"]) + " ;Launch Angle\n")
      if move["Spray"]:
        c_file.write("DB " + str(move["Spray"]) + " ;Spray\n")
      if move["Pull"]:
        c_file.write("DB " + str(int(float(move["Pull"])*45)) + " ;Pull\n")

    c_file.write("\n" + constants + "\n")
    c_file.write("MoveList:\n" + var_names + "\n")

if __name__ == "__main__":
  main()
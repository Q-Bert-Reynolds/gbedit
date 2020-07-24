import os
import csv
import xml.etree.ElementTree as tree
import pathlib 

bank = 0

def main():
  for root, folders, files in os.walk("./maps"):
    name = os.path.basename(root)
    for name in files:
      path = os.path.join(root, name)
      base, ext = os.path.splitext(path)
      tmx_to_asm(path)

def tmx_to_asm(path):
  global bank
  data_written = 0

  base, ext = os.path.splitext(path)
  if ext != ".tmx":
    return
  name = os.path.basename(base)
  
  tmx = tree.parse(path).getroot()
  tiles = tmx.find("layer").find("data").text.replace("\n","").split(',')

  width = int(int(tmx.attrib["width"]) / 32)
  height = int(int(tmx.attrib["height"]) / 32)
  
  hex_strings = []
  for y in range(height):
    for x in range(width):
      hex_string = ""
      for j in range(32):
        for i in range(32):
          tile = tiles[(y*32+j)*32*width+x*32+i]
          tile_hex = "{:02X}".format(int(tile)+127)
          hex_string += tile_hex
      hex_strings.append(hex_string)    
    
  with open(base + ".asm", "w+") as asm_file:
    asm_file.write("_" + name.upper() + "_WIDTH EQU " + str(width) + "\n")
    asm_file.write("_" + name.upper() + "_HEIGHT EQU " + str(height) + "\n")
    for i in range(width*height):
      if data_written == 0:
        asm_file.write("SECTION \""+name+str(bank)+"\", ROMX, BANK[MAPS_BANK+"+str(bank)+"]\n")
      hex_string = hex_strings[i]
      asm_file.write("_" + PascalCase(name) + str(i) + "Tiles: INCBIN \"")
      path = pathlib.PurePath(base + str(i) + ".tilemap").as_posix()
      asm_file.write(path+ "\"\n")
      
      with open(base + str(i) + ".tilemap", "wb") as bin_file:
        bin_file.write(bytes.fromhex(hex_string))

      data_written += 1024
      if data_written >= 16384:
        bank += 1
        data_written = 0

def PascalCase(name):
  s = name.split("_")
  for i in range(len(s)):
    s[i] = s[i][0].upper() + s[i][1:]
  s = "".join(s)
  s.replace("-", "")
  return s

if __name__ == "__main__":
  main()
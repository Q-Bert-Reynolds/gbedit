import os
import csv
import xml.etree.ElementTree as tree
bank = 0

def main():
  asm = ""
  for root, folders, files in os.walk("./maps"):
    name = os.path.basename(root)
    for name in files:
      path = os.path.join(root, name)
      base, ext = os.path.splitext(path)
      asm += tmx_to_asm(path)

  with open("./maps/map_data.asm", "w+") as asm_file:
    asm_file.write(asm)

def tmx_to_asm(path):
  global bank
  base, ext = os.path.splitext(path)
  if ext != ".tmx":
    return ""
  name = os.path.basename(base)
  
  tmx = tree.parse(path).getroot()
  tiles = tmx.find("layer").find("data").text.replace("\n","").split(',')
  tile_count = len(tiles)

  width = int(tmx.attrib["width"])
  height = int(tmx.attrib["height"])
  x_chunks = int(width / 32)
  y_chunks = int(height / 32)
  
  hex_strings = []
  asm = ""
  for y in range(y_chunks):
    for x in range(x_chunks):
      hex_string = ""
      for j in range(32):
        for i in range(32):
          tile = tiles[(y*32+j)*32*x_chunks+x*32+i]
          tile_hex = "{:02X}".format(int(tile)+127)
          hex_string += tile_hex
      hex_strings.append(hex_string)    
    
  asm += "SECTION \""+name+"\", ROMX, BANK[MAPS_BANK+"+str(bank)+"]\n"
  asm +=  "_" + name.upper() + "_TILE_COUNT EQU " + str(tile_count) + "\n"
  asm += "_" + name.upper() + "_WIDTH EQU " + str(width) + "\n"
  asm += "_" + name.upper() + "_HEIGHT EQU " + str(height) + "\n"
  for i in range(x_chunks*y_chunks):
    asm += "_" + PascalCase(name) + str(i) + "Tiles: INCBIN \""
    asm += base + str(i) + ".tilemap\"\n"
    with open(base + str(i) + ".tilemap", "wb") as bin_file:
      bin_file.write(bytes.fromhex(hex_strings[i]))

  bank += 1
  return asm

def PascalCase(name):
  s = name.split("_")
  for i in range(len(s)):
    s[i] = s[i][0].upper() + s[i][1:]
  s = "".join(s)
  s.replace("-", "")
  return s

if __name__ == "__main__":
  main()
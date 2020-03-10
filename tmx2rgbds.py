import os
import csv
import xml.etree.ElementTree as tree

def main():
  for root, folders, files in os.walk("./maps"):
    name = os.path.basename(root)
    for name in files:
      path = os.path.join(root, name)
      base, ext = os.path.splitext(path)
      tmx_to_asm(path)

def tmx_to_asm(path):
  base, ext = os.path.splitext(path)
  if ext != ".tmx":
    return
  name = os.path.basename(base)
  
  tmx = tree.parse(path).getroot()
  tiles = tmx.find("layer").find("data").text.replace("\n","").split(',')
  tile_count = len(tiles)

  width = int(tmx.attrib["width"])
  height = int(tmx.attrib["height"])
  x_chunks = int(width / 32)
  y_chunks = int(height / 32)
  
  hex_strings = []
  for y in range(y_chunks):
    for x in range(x_chunks):
      hex_string = ""
      for j in range(32):
        for i in range(32):
          tile = tiles[(y*32+j)*32*x_chunks+x*32+i]
          tile_hex = "{:02X}".format(int(tile)+127)
          hex_string += tile_hex
      hex_strings.append(hex_string)    
    
  with open(base + ".asm", "w+") as asm_file:
    asm_file.write("IF !DEF(_" + name.upper() + "_TILE_COUNT)\n")
    asm_file.write("_" + name.upper() + "_TILE_COUNT EQU " + str(tile_count) + "\n")
    asm_file.write("_" + name.upper() + "_WIDTH EQU " + str(width) + "\n")
    asm_file.write("_" + name.upper() + "_HEIGHT EQU " + str(height) + "\n")
    for i in range(x_chunks*y_chunks):
      hex_string = hex_strings[i]
      asm_file.write("_" + PascalCase(name) + str(i) + "Tiles: INCBIN \"")
      asm_file.write(base + str(i) + ".tilemap\"\n")
      with open(base + str(i) + ".tilemap", "wb") as bin_file:
        bin_file.write(bytes.fromhex(hex_string))

    asm_file.write("ENDC\n")

def PascalCase(name):
  s = name.split("_")
  for i in range(len(s)):
    s[i] = s[i][0].upper() + s[i][1:]
  s = "".join(s)
  s.replace("-", "")
  return s

if __name__ == "__main__":
    main()
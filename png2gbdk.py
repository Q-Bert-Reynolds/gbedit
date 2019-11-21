#TODO: commandline options (1bpp, 2bpp, rle)
#      only update .c file when png changes

import os
import math
from PIL import Image

def main():
  for root, folders, files in os.walk("./res"):
    name = os.path.basename(root)
    if name in ["res", "players", "coaches"]:
      for name in files:
        path = os.path.join(root, name)
        png_to_c(path)
    else:
      folder_to_c(root, files)

def gb_encode (img):
  rows = int(img.height / 8)
  cols = int(img.width / 8)
  hex_vals = []
  pixels = list(img.getdata())
  for row in range(rows):
    for col in range(cols):
      for j in range(8):
        upper_binary = ""
        lower_binary = ""
        for i in range(8):
          x = col*8+i
          y = row*8+j
          px = pixels[y*img.width+x]
          px = px if isinstance(px, int) else px[0]
          px = int(math.floor(float(px) / 64.0))
          pixels[y*img.width+x] = px
          upper_binary += str(1-int(px%2))
          lower_binary += str(1-int(px/2))
        hex_vals.append("0x{:02X}".format(int(upper_binary, 2)))
        hex_vals.append("0x{:02X}".format(int(lower_binary, 2)))
  return (rows, cols, hex_vals)

def folder_to_c (root, files):
  tileset = []
  tilemaps = {}
  dimensions = {}
  name = os.path.basename(root)
  for file in files:
    path = os.path.join(root, file)
    base, ext = os.path.splitext(path)
    if ext != ".png":
      continue
    img = Image.open(path)
    img_name = os.path.basename(base)
    rows, cols, hex_vals = gb_encode(img)

    tilemaps[img_name] = []
    dimensions[img_name] = (rows, cols)
    for i in range(0, len(hex_vals), 16):
      tile = "    " + ",".join(hex_vals[i:i+16]) + ",\n"
      if tile not in tileset:
        tileset.append(tile)
      tilemaps[img_name].append("0x{:02X}".format(tileset.index(tile)))
        
  name = name.replace("home_", "").replace("away_", "")
  with open(os.path.join(root, name + ".c"), "w+") as c_file:
    c_file.write("#ifndef _" + name.upper() + "_TILE_COUNT\n")
    c_file.write("#define _" + name.upper() + "_TILE_COUNT " + str(len(tileset)) + "\n")

    c_file.write("const unsigned char _" + name + "_tiles[] = {\n")
    for tile in tileset:
      c_file.write(tile)
    c_file.write("};\n")

    for img_name in tilemaps.keys():
      rows, cols = dimensions[img_name]
      c_file.write("#define _" + img_name.upper() + "_ROWS " + str(rows) + "\n")
      c_file.write("#define _" + img_name.upper() + "_COLUMNS " + str(cols) + "\n")
      c_file.write("const unsigned char _" + img_name + "_map[] = {\n")
      for i in range(0, len(tilemaps[img_name]), cols):
        c_file.write("    " + ",".join(tilemaps[img_name][i:i+cols]) + ",\n")
      c_file.write("};\n")

    c_file.write("#endif\n")

def png_to_c (path):
  base, ext = os.path.splitext(path)
  if ext != ".png":
    return
  img = Image.open(path)
  name = os.path.basename(base)
  rows, cols, hex_vals = gb_encode(img)

  if name in ["font", "ui"]:
    tileset = []
    for i in range(0, len(hex_vals), 16):
      tile = "    " + ",".join(hex_vals[i:i+16]) + ",\n"
      tileset.append(tile)

    with open(base + ".h", "w+") as c_file:
      c_file.write("#ifndef _" + name.upper() + "_TILE_COUNT\n")
      c_file.write("#define _" + name.upper() + "_TILE_COUNT " + str(rows*cols) + "\n")

      c_file.write("extern const unsigned char _" + name + "_tiles[];\n")
      c_file.write("#endif\n")

    with open(base + ".c", "w+") as c_file:
      c_file.write("#ifndef _" + name.upper() + "_TILES\n")
      c_file.write("#define _" + name.upper() + "_TILES\n")

      c_file.write("const unsigned char _" + name + "_tiles[] = {\n")
      for tile in tileset:
        c_file.write(tile)
      c_file.write("};\n")

      c_file.write("#endif\n")
  else:
    tileset = []
    tilemap = []
    for i in range(0, len(hex_vals), 16):
      tile = "    " + ",".join(hex_vals[i:i+16]) + ",\n"
      if tile in tileset:
        tilemap.append("0x{:02X}".format(tileset.index(tile)))
      else:
        tilemap.append("0x{:02X}".format(len(tileset)))
        tileset.append(tile)

    with open(base + ".c", "w+") as c_file:
      c_file.write("#ifndef _" + name.upper() + "_TILE_COUNT\n")
      c_file.write("#define _" + name.upper() + "_ROWS " + str(rows) + "\n")
      c_file.write("#define _" + name.upper() + "_COLUMNS " + str(cols) + "\n")
      c_file.write("#define _" + name.upper() + "_TILE_COUNT " + str(rows*cols) + "\n")

      c_file.write("const unsigned char _" + name + "_tiles[] = {\n")
      for tile in tileset:
        c_file.write(tile)
      c_file.write("};\n")

      c_file.write("const unsigned char _" + name + "_map[] = {\n")
      for i in range(0, len(tilemap), cols):
        c_file.write("    " + ",".join(tilemap[i:i+cols]) + ",\n")
      c_file.write("};\n")

      c_file.write("#endif\n")

if __name__ == "__main__":
    main()
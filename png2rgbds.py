import os
import math
from PIL import Image

def main():
  for root, folders, files in os.walk("./img"):
    name = os.path.basename(root)
    if name in ["img", "players", "coaches"]:
      for name in files:
        path = os.path.join(root, name)
        png_to_asm(path)
    else:
      folder_to_asm(root, files)

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
        hex_vals.append("{:02X}".format(int(upper_binary, 2)))
        hex_vals.append("{:02X}".format(int(lower_binary, 2)))
  return (rows, cols, hex_vals)

def folder_to_asm (root, files):
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
      tile = "".join(hex_vals[i:i+16])
      if tile not in tileset:
        tileset.append(tile)
      tilemaps[img_name].append("{:02X}".format(tileset.index(tile)))
        
  name = name.replace("home_", "").replace("away_", "")
  with open(os.path.join(root, name + ".asm"), "w+") as asm_file:
    asm_file.write("IF !DEF(_" + name.upper() + "_TILE_COUNT)\n")
    asm_file.write("_" + name.upper() + "_TILE_COUNT EQU " + str(len(tileset)) + "\n")

    asm_file.write(PascalCase(name)+"Tiles: INCBIN \"")
    asm_file.write(os.path.join(root, name) + ".tiles\"\n")
    
    with open(os.path.join(root, name) + ".tiles", "wb") as bin_file:
      hex_string = ""
      for tile in tileset:
        hex_string += tile
      bin_file.write(bytes.fromhex(hex_string))

    for img_name in tilemaps.keys():
      rows, cols = dimensions[img_name]
      asm_file.write("_" + img_name.upper() + "_ROWS EQU " + str(rows) + "\n")
      asm_file.write("_" + img_name.upper() + "_COLUMNS EQU " + str(cols) + "\n")
      asm_file.write(PascalCase(img_name)+"TileMap: INCBIN \"")
      asm_file.write(os.path.join(root, img_name) + ".tilemap\"\n")

      with open(os.path.join(root, img_name) + ".tilemap", "wb") as bin_file:
        hex_string = ""
        for i in range(0, len(tilemaps[img_name]), cols):
          hex_string += "".join(tilemaps[img_name][i:i+cols])
        bin_file.write(bytes.fromhex(hex_string))
    asm_file.write("ENDC\n")

def png_to_asm (path):
  base, ext = os.path.splitext(path)
  if ext != ".png":
    return
  img = Image.open(path)
  name = os.path.basename(base)
  rows, cols, hex_vals = gb_encode(img)
  tile_count = rows*cols

  if name in ["ui_font"]:
    tileset = []
    for i in range(0, len(hex_vals), 16):
      tile = "".join(hex_vals[i:i+16])
      tileset.append(tile)

    with open(base + ".asm", "w+") as asm_file:
      asm_file.write("IF !DEF(_" + name.upper() + "_TILE_COUNT)\n")
      asm_file.write("_" + name.upper() + "_TILE_COUNT EQU " + str(tile_count) + "\n")

      asm_file.write(PascalCase(name)+"Tiles: INCBIN \"")
      asm_file.write(base + ".tiles\"\n")
      with open(base + ".tiles", "wb") as bin_file:
        hex_string = ""
        for tile in tileset:
          hex_string += tile
        bin_file.write(bytes.fromhex(hex_string))
      asm_file.write("ENDC\n")

  else:
    tileset = []
    tilemap = []
    for i in range(0, len(hex_vals), 16):
      tile = "".join(hex_vals[i:i+16])
      if tile in tileset:
        tilemap.append("{:02X}".format(tileset.index(tile)))
      else:
        tilemap.append("{:02X}".format(len(tileset)))
        tileset.append(tile)

    is_2x = "_back" in name
    if is_2x:
      tilemap_2x = []
      for i in range(len(tilemap)):
        tile = int(tilemap[i], 16)
        tilemap_2x.append(tile*4)
        tilemap_2x.append(tile*4+1)
      tilemap = tilemap_2x
      tilemap_2x = []
      for i in range(rows):
        row = tilemap[i*cols*2:(i+1)*cols*2]
        tilemap_2x.extend(map(lambda n : "{:02X}".format(n), row))
        tilemap_2x.extend(map(lambda n : "{:02X}".format(n+2), row))
      tilemap = tilemap_2x
      rows*=2
      cols*=2
    else:
      tile_count = len(tileset)

    with open(base + ".asm", "w+") as asm_file:
      asm_file.write("IF !DEF(_" + name.upper() + "_TILE_COUNT)\n")
      asm_file.write("_" + name.upper() + "_TILE_COUNT EQU " + str(tile_count) + "\n")

      has_map = (name not in ["health_bar"]) and ("sprites" not in name)
      if has_map:
        asm_file.write("_" + name.upper() + "_ROWS EQU " + str(rows) + "\n")
        asm_file.write("_" + name.upper() + "_COLUMNS EQU " + str(cols) + "\n")
      
      asm_file.write(PascalCase(name)+"Tiles: INCBIN \"")
      asm_file.write(base + ".tiles\"\n")
      with open(base + ".tiles", "wb") as bin_file:
        hex_string = ""
        for tile in tileset:
          hex_string += tile
        bin_file.write(bytes.fromhex(hex_string))

      if has_map:
        asm_file.write(PascalCase(name)+"TileMap: INCBIN \"")
        asm_file.write(base + ".tilemap\"\n")
        with open(base + ".tilemap", "wb") as bin_file:
          hex_string = ""
          for i in range(0, len(tilemap), cols):
            hex_string += "".join(tilemap[i:i+cols])
            bin_file.write(bytes.fromhex(hex_string))
      asm_file.write("ENDC\n")

def PascalCase(name):
  return "".join(x for x in name.title() if not x.isspace())

if __name__ == "__main__":
    main()
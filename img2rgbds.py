import os
import sys
import math
import colorsys
import pathlib 
from PIL import Image
from PIL import GifImagePlugin
from sgb_border import convert as sgb_convert

def parse_all():
  for root, folders, files in os.walk("./img"):
    parse_files(root, files)

def parse_files(root, files):
  name = os.path.basename(root)
  if name in ["img", "players", "coaches", "maps"]:
    for name in files:
      path = os.path.join(root, name)
      img_to_asm(path)
  else:
    folder_to_asm(root, files)

def rgb_to_grey (px):
  if not isinstance(px, int):
    px = px[0]
  px = int(math.floor(float(px) / 64.0))
  return px

def gb_encode (img):
  rows = int(img.height / 8)
  cols = int(img.width / 8)
  hex_vals = []
  pixels = list(img.getdata())
  palettemap = ""
  palette = img.getpalette()
  color_count = 0
  colors = []
  for row in range(rows):
    palettemap += "  DB "
    for col in range(cols):
      palette_id = 0
      for j in range(8):
        upper_binary = ""
        lower_binary = ""
        for i in range(8):
          x = col*8+i
          y = row*8+j
          px = pixels[y*img.width+x]
          if palette != None:
            if px > color_count:
              color_count = px
            palette_id += px/4
            px = px % 4
          else:
            px = px if isinstance(px, int) else px[0]
            px = int(math.floor(float(px) / 64.0))
          upper_binary += str(1-int(px%2))
          lower_binary += str(1-int(px/2))
        hex_vals.append("{:02X}".format(int(upper_binary, 2)))
        hex_vals.append("{:02X}".format(int(lower_binary, 2)))
      palette_id /= 64 #average palette_id
      palettemap += str(int(palette_id))
      if col == cols-1: palettemap += "\n"
      else: palettemap += ","

  if palette != None:
    c = ""
    count = 0
    color_count += 1
    for i in range(0, color_count*3, 3):
      r = round(palette[i]   / 8)
      g = round(palette[i+1] / 8)
      b = round(palette[i+2] / 8)
      c = "  RGB {0:>2}, {1:>2}, {2:>2}\n".format(r,g,b) + c
      count += 1
      if count % 4 == 0:
        colors.append(c)
        c = ""
  return (rows, cols, hex_vals, colors, palettemap)

def flipTileX (tile):
  flipped = ""
  for i in range(16):
    h = tile[i*2:(i+1)*2]
    b = "{0:08b}".format(int(h, 16))[::-1]
    flipped += "{:02X}".format(int(b, 2))
  return flipped

def flipTileY (tile):
  flipped = ""
  for i in range(8):
    flipped = tile[i*4:(i+1)*4] + flipped
  return flipped

def addTileGetFlipsIndex (tile, tileset):
  if tile in tileset:
    return ("00", tileset.index(tile))

  xFlip = flipTileX(tile)
  if xFlip in tileset:
    return ("20", tileset.index(xFlip))

  yFlip = flipTileY(tile)
  if yFlip in tileset:
    return ("40", tileset.index(yFlip))

  xyFlip = flipTileY(xFlip)
  if xyFlip in tileset:
    return ("60", tileset.index(xyFlip))

  tileset.append(tile)
  return ("00", tileset.index(tile))

def folder_to_asm (root, files):
  tileset = []
  tilemaps = {}
  dimensions = {}
  properties = {}
  palettemaps = {}
  colorset = {}

  name = os.path.basename(root)
  for file in files:
    path = os.path.join(root, file)
    base, ext = os.path.splitext(path)
    if ext == ".gif":
      gif_to_asm(path, base)
      continue
    elif ext != ".png":
      continue
    elif "sgb_border" in base:
      png_to_sgb(path, base, name)
      continue
    img = Image.open(path)
    img_name = os.path.basename(base)
    rows, cols, hex_vals, colors, palettemap = gb_encode(img)

    if "avatar" in img_name:
      parts = [
        "_idle_down","_idle_up","_idle_right",
        "_walk_down","_walk_up","_walk_right"
      ] 
      for p in range(len(parts)):
        part_name = parts[p]
        tilemaps[img_name + part_name] = []
        properties[img_name + part_name] = []
        dimensions[img_name + part_name] = (2, 2)#this seems unnecessary
        for i in range(p*64, (p+1)*64, 16):
          tile = "".join(hex_vals[i:i+16])
          flips, index = addTileGetFlipsIndex(tile, tileset)
          properties[img_name + part_name].append(flips)
          tilemaps[img_name + part_name].append("{:02X}".format(index))
      
    else:
      tilemaps[img_name] = []
      palettemaps[img_name] = palettemap
      colorset[img_name] = colors
      dimensions[img_name] = (rows, cols)
      for i in range(0, len(hex_vals), 16):
        tile = "".join(hex_vals[i:i+16])
        if tile not in tileset:
          tileset.append(tile)
        tilemaps[img_name].append("{:02X}".format(tileset.index(tile)))
  
  image_set_to_asm(root, name, tileset, tilemaps, dimensions, properties, palettemaps, colorset)

def image_set_to_asm (root, name, tileset, tilemaps, dimensions, properties, palettemaps, colorset):
  if len(tileset) == 0:
    return
  
  name = name.replace("demo_", "").replace("home_", "").replace("away_", "")
  tilesPath = pathlib.PurePath(root, name + ".tiles").as_posix()
  if len(tileset) > 256:
    print("Error: " + tilesPath + " has " + str(len(tileset)) + " tiles.")
  elif "_2x" in name and len(tileset) > 16:
    print("Warning: " + tilesPath + " has " + str(len(tileset)) + " tiles.")
  elif len(tileset) > 64:
    print("Warning: " + tilesPath + " has " + str(len(tileset)) + " tiles.")
    
  with open(os.path.join(root, name + ".asm"), "w+") as asm_file:
    asm_file.write("IF !DEF(_" + name.upper() + "_TILE_COUNT)\n")
    asm_file.write("_" + name.upper() + "_TILE_COUNT EQU " + str(len(tileset)) + "\n")

    asm_file.write("_"+PascalCase(name)+"Tiles: INCBIN \"")
    asm_file.write(tilesPath + "\"\n")
    
    with open(os.path.join(root, name) + ".tiles", "wb") as bin_file:
      hex_string = ""
      for tile in tileset:
        hex_string += tile
      bin_file.write(bytes.fromhex(hex_string))

    for img_name in tilemaps.keys():
      rows, cols = dimensions[img_name]
      if "avatar" not in img_name:
        asm_file.write("_" + img_name.upper() + "_ROWS EQU " + str(rows) + "\n")
        asm_file.write("_" + img_name.upper() + "_COLUMNS EQU " + str(cols) + "\n")
      tilemapPath = pathlib.PurePath(root, img_name + ".tilemap").as_posix()
      asm_file.write("_" + PascalCase(img_name)+"TileMap: INCBIN \"")
      asm_file.write(tilemapPath+"\"\n")

      with open(os.path.join(root, img_name) + ".tilemap", "wb") as bin_file:
        hex_string = ""
        for i in range(0, len(tilemaps[img_name]), cols):
          hex_string += "".join(tilemaps[img_name][i:i+cols])
        bin_file.write(bytes.fromhex(hex_string))

      if "avatar" in img_name:
        propmapPath = pathlib.PurePath(root, img_name + ".propmap").as_posix()
        asm_file.write("_" + PascalCase(img_name)+"PropMap: INCBIN \"")
        asm_file.write(propmapPath+"\"\n")
        with open(os.path.join(root, img_name) + ".propmap", "wb") as bin_file:
          hex_string = ""
          for i in range(0, len(properties[img_name])):
            hex_string += "".join(properties[img_name][i])
          bin_file.write(bytes.fromhex(hex_string))

    asm_file.write("ENDC\n")

def img_to_asm (path):
  base, ext = os.path.splitext(path)
  if ext == ".png":
    png_to_asm(path,base)
  elif ext == ".gif":
    gif_to_asm(path,base)

def gif_to_asm (path, base):
  img = Image.open(path)
  name = os.path.basename(base)
  if not img.is_animated:
    return

  is_2x = "_2x" in name
  tileset = []
  tilemaps = {}
  dimensions = {}
  properties = {}
  palettemaps = {}
  colorset = {}

  for frame in range(img.n_frames):
    img_name = os.path.basename(base)+str(frame)
    img.seek(frame)
    rows, cols, hex_vals, colors, palettemap = gb_encode(img.convert('RGB'))

    colorset[img_name] = colors
    palettemaps[img_name] = palettemap
    tilemaps[img_name] = []
    for i in range(0, len(hex_vals), 16):
      tile = "".join(hex_vals[i:i+16])
      if tile not in tileset:
        tileset.append(tile)
      tilemaps[img_name].append("{:02X}".format(tileset.index(tile)))
    
    tilemaps[img_name] = []
    for i in range(0, len(hex_vals), 16):
      tile = "".join(hex_vals[i:i+16])
      if tile not in tileset:
        tileset.append(tile)
      tilemaps[img_name].append("{:02X}".format(tileset.index(tile)))
  
    if is_2x:
      tilemap_2x = []
      for i in range(len(tilemaps[img_name])):
        tile = int(tilemaps[img_name][i], 16)
        tilemap_2x.append(tile*4)
        tilemap_2x.append(tile*4+1)
      tilemaps[img_name] = tilemap_2x
      tilemap_2x = []
      for i in range(rows):
        row = tilemaps[img_name][i*cols*2:(i+1)*cols*2]
        tilemap_2x.extend(map(lambda n : "{:02X}".format(n), row))
        tilemap_2x.extend(map(lambda n : "{:02X}".format(n+2), row))
      tilemaps[img_name] = tilemap_2x
      rows*=2
      cols*=2

    dimensions[img_name] = (rows, cols)

  root = os.path.split(path)[0]
  image_set_to_asm(root, name, tileset, tilemaps, dimensions, properties, palettemaps, colors)

def png_to_asm (path, base):
  name = os.path.basename(base)
  if "sgb_border" in name:
    png_to_sgb(path, base, name)
  else:
    png_to_gb(path, base, name)
  return

def png_to_sgb (path, base, name):
  print(path)
  sgb_convert(path, base + ".asm")
  return
  
def png_to_gb (path, base, name):
  img = Image.open(path)
  rows, cols, hex_vals, colors, palettemap = gb_encode(img)
  tile_count = rows*cols

  if name in ["ui_font", "simulation"] or "maps" in path:
    tileset = []
    for i in range(0, len(hex_vals), 16):
      tile = "".join(hex_vals[i:i+16])
      tileset.append(tile)

    with open(base + ".asm", "w+") as asm_file:
      asm_file.write("IF !DEF(_" + name.upper() + "_TILE_COUNT)\n")
      asm_file.write("_" + name.upper() + "_TILE_COUNT EQU " + str(tile_count) + "\n")

      tilesPath = pathlib.PurePath(base + ".tiles").as_posix()
      asm_file.write("_"+PascalCase(name)+"Tiles: INCBIN \"")
      asm_file.write(tilesPath+"\"\n")
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

    is_2x = "_2x" in name
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

      if colors:
        asm_file.write("_" + name.upper() + "_PALETTE_COUNT EQU " + str(len(colors)) + "\n")
        asm_file.write("_"+PascalCase(name)+"Colors:\n"+"".join(colors))
        asm_file.write("_"+PascalCase(name)+"PaletteMap:\n"+palettemap)

      tilesPath = pathlib.PurePath(base + ".tiles").as_posix()
      asm_file.write("_"+PascalCase(name)+"Tiles: INCBIN \"")
      asm_file.write(tilesPath+"\"\n")
      with open(base + ".tiles", "wb") as bin_file:
        hex_string = ""
        for tile in tileset:
          hex_string += tile
        bin_file.write(bytes.fromhex(hex_string))

      if has_map:
        tilemapPath = pathlib.PurePath(base + ".tilemap").as_posix()
        asm_file.write("_"+PascalCase(name)+"TileMap: INCBIN \"")
        asm_file.write(tilemapPath+"\"\n")
        with open(base + ".tilemap", "wb") as bin_file:
          hex_string = ""
          for i in range(0, len(tilemap), cols):
            hex_string += "".join(tilemap[i:i+cols])
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
    if len(sys.argv) == 1: parse_all()
    else:
      for root, folders, files in os.walk(sys.argv[1]):
        parse_files(root, files)
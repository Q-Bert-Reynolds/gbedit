#TODO: commandline options (1bpp, 2bpp, rle)
#TODO: only update .c file when png changes

import os
import math
from PIL import Image

def main():
  for root, folders, files in os.walk("./res"):
    for name in files:
      path = os.path.join(root, name)
      base, ext = os.path.splitext(path)
      if ext == ".png":
        generate_c_file(base)


def generate_c_file (base):
  img = Image.open(base + ".png")
  name = os.path.basename(base)

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
          upper_binary += str(1-int(px/2))
          lower_binary += str(1-int(px%2))
        hex_vals.append("0x{:02x}".format(int(upper_binary, 2)))
        hex_vals.append("0x{:02x}".format(int(lower_binary, 2)))

  blocks = ["  ","░░","▒▒","██"]
  px2block = lambda px : blocks[px]
  with open(base + ".c", "w+") as c_file:
    c_file.write("/*\n")
    for y in range(img.height):
      line = pixels[y*img.width : (y+1)*img.width]
      c_file.write("    " + "".join(map(px2block, line)) + "\n");
    c_file.write("*/\n")

    c_file.write("#define _" + name.upper() + "_ROWS " + str(rows) + "\n")
    c_file.write("#define _" + name.upper() + "_COLUMNS " + str(cols) + "\n")
    c_file.write("#define _" + name.upper() + "_SIZE " + str(rows*cols) + "\n")

    c_file.write("const unsigned char _" + name + "[] = {\n")
    for i in range(0, len(hex_vals), 16):
      c_file.write("    " + ",".join(hex_vals[i:i+16]) + ",\n")
    c_file.write("};\n")

if __name__ == "__main__":
    main()
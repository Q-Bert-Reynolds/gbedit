#TODO: commandline options (1bpp, 2bpp, rle), header files for each folder

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
    
    for folder in folders:
      print(folder) #create header files


def generate_c_file (base):
  img = Image.open(base + ".png")
  
  rows = int(img.height / 8)
  cols = int(img.width / 8)
  hex_vals = []
  pixels = list(img.getdata())
  for row in range(rows):
    for col in range(cols):
      for j in range(8):
        upper_bin = ""
        lower_bin = ""
        for i in range(8):
          x = col*8+i
          y = row*8+j
          px = pixels[y*img.width+x]
          px = px if isinstance(px, int) else px[0]
          px = int(math.floor(float(px) / 64.0))
          upper_bin += str(1-int(px/2))
          lower_bin += str(1-int(px%2))
        hex_vals.append("0x{:02x}".format(int(upper_bin, 2)))
        hex_vals.append("0x{:02x}".format(int(lower_bin, 2)))

  with open(base + ".c", "w+") as c_file:
    c_file.write("const unsigned char _" + os.path.basename(base) + "[] = {\n")
    for i in range(0, len(hex_vals), 16):
      c_file.write("    " + ",".join(hex_vals[i:i+16]) + ",\n")
    c_file.write("}\n")

if __name__ == "__main__":
    main()
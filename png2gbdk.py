import os
import math
from PIL import Image

def main():
  for root, dirs, files in os.walk("./res"):
    for name in files:
      path = os.path.join(root, name)
      base, ext = os.path.splitext(path)
      if ext == ".png":
        generate_c_file(base)


def generate_c_file (base):
  img = Image.open(base + ".png")
  
  rows = int(img.height / 8)
  cols = int(img.width / 8)
  hex_vals = []
  pixels = list(img.getdata())
  for col in range(cols):
    for row in range(rows):
      for j in range(8):
        upper_bin = ""
        lower_bin = ""
        for i in range(8):
          x = col*8+i
          y = row*8+j
          px = int(math.floor(float(pixels[y*img.width+x][0]) / 64.0))
          upper_bin += str(1-int(px/2))
          lower_bin += str(1-int(px%2))
        hex_vals.append(hex(int(upper_bin, 2)))
        hex_vals.append(hex(int(lower_bin, 2)))
  print(base)
  print(hex_vals)
  quit()
  c_file = open(base + ".c", "w+")
  # write bytes here
  c_file.close()


if __name__ == "__main__":
    main()
import os
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
  c_file = open(base + ".c", "w+")

if __name__ == "__main__":
    main()
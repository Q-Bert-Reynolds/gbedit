import os
import shutil

def main():
  for root, folders, files in os.walk("./music"):
    for file in files:
        path = os.path.join(root, file)
        base, ext = os.path.splitext(path)
        if ext != ".mod":
            continue
        name = os.path.basename(base)
        os.system("bin/mod2gbt {0} {1}".format(path, name))
        shutil.move("./" + name + ".asm", "./music/" + name + ".asm")

if __name__ == "__main__":
    main()
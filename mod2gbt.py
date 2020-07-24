import os
import subprocess
import shutil

def main():
  for root, folders, files in os.walk("./music"):
    for file in files:
        path = os.path.join(root, file)
        base, ext = os.path.splitext(path)
        if ext != ".mod":
            continue
        name = os.path.basename(base)
        mod2gbt = os.path.join(os.getcwd(), "bin", "mod2gbt") 
        subprocess.Popen("{0} {1} {2}".format(mod2gbt, path, name), shell=True).wait()
        shutil.move("./" + name + ".asm", "./music/" + name + ".asm")

if __name__ == "__main__":
    main()
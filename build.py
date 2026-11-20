"""Generate the C constants shared with the assembly editor code."""
from pathlib import Path


def main():
    lines = ["#ifndef CONSTANTS\n#define CONSTANTS\n\n"]
    for line in Path("src/constants.asm").read_text(encoding="utf8").splitlines(True):
        line = line.replace("DEF ", "#define ").replace(" EQU ", " ")
        line = line.replace(";", "//").replace(" %", " 0b").replace(" $", " 0x")
        lines.append(line)
    lines.append("\n#endif // CONSTANTS\n")
    Path("src/constants.h").write_text("".join(lines), encoding="utf8")


if __name__ == "__main__":
    main()

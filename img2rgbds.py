"""Convert the editor's indexed font to Game Boy 2bpp tiles.

Keep every tile in sheet order: its index is the character code. The source
palette runs from black to white, opposite the Game Boy's color indices.
"""
from pathlib import Path
from PIL import Image


def main():
    with Image.open("img/ui_font.png") as image:
        if image.mode != "P" or image.size != (128, 128):
            raise ValueError("ui_font.png must be a 128x128 indexed image")
        if image.getextrema()[1] > 3:
            raise ValueError("ui_font.png must use palette indices 0-3")
        tiles = bytearray()
        for tile_y in range(0, image.height, 8):
            for tile_x in range(0, image.width, 8):
                for y in range(8):
                    low = high = 0
                    for x in range(8):
                        color = 3 - image.getpixel((tile_x + x, tile_y + y))
                        low = (low << 1) | (color & 1)
                        high = (high << 1) | (color >> 1)
                    tiles.extend((low, high))
    Path("img/ui_font.tiles").write_bytes(tiles)


if __name__ == "__main__":
    main()

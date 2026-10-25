#!/usr/bin/env python3
"""Android draws a ~3px green focus border around the window after adb input events (emulator artifact).
Paints it over with the adjacent inner pixels. Usage: clean_border.py file.png ..."""
import sys
from PIL import Image

for p in sys.argv[1:]:
    im = Image.open(p).convert("RGB")
    w, h = im.size
    px = im.load()
    if not all(abs(a - b) < 12 for a, b in zip(px[1, h // 2], (129, 171, 3))):
        continue
    n = 4
    for y in range(h):
        for x in range(n):
            px[x, y] = px[n, y]
            px[w - 1 - x, y] = px[w - 1 - n, y]
    for x in range(w):
        for y in range(n):
            px[x, y] = px[x, n]
            px[x, h - 1 - y] = px[x, h - 1 - n]
    im.save(p)

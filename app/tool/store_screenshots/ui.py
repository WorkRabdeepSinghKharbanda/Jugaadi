#!/usr/bin/env python3
"""adb UI helper: ui.py tap <regex> | edit <index> <text> | has <regex>   (matches text or content-desc)."""
import os, re, time, subprocess, sys, xml.etree.ElementTree as ET

ADB = os.path.expanduser("~/Library/Android/sdk/platform-tools/adb")
sh = lambda *a: subprocess.run([ADB, *a], capture_output=True, text=True).stdout


def nodes():
    sh("shell", "uiautomator", "dump", "/sdcard/ui.xml")
    return list(ET.fromstring(sh("exec-out", "cat", "/sdcard/ui.xml")).iter("node"))


def center(n):
    x1, y1, x2, y2 = map(int, re.findall(r"\d+", n.get("bounds")))
    return (x1 + x2) // 2, (y1 + y2) // 2


def find(rx):
    for _ in range(5):  # first dumps can be empty while Flutter publishes its semantics tree
        m = [n for n in nodes() if re.search(rx, n.get("text", "")) or re.search(rx, n.get("content-desc", ""))]
        if m:
            return m
        time.sleep(1)
    return []


cmd = sys.argv[1]
if cmd == "tap":
    m = find(sys.argv[2])
    if not m:
        sys.exit(f"not found: {sys.argv[2]}")
    sh("shell", "input", "tap", *map(str, center(m[0])))
elif cmd == "edit":
    for _ in range(5):
        e = [n for n in nodes() if n.get("class", "").endswith("EditText")]
        if len(e) > int(sys.argv[2]):
            break
        time.sleep(1)
    sh("shell", "input", "tap", *map(str, center(e[int(sys.argv[2])])))
    sh("shell", "input", "keyevent", "KEYCODE_MOVE_END", *["KEYCODE_DEL"] * 8)  # clear any prefilled text
    sh("shell", "input", "text", sys.argv[3].replace(" ", "%s"))
    time.sleep(3)  # let the IME flush before the next action
    if "mInputShown=true" in sh("shell", "dumpsys", "input_method"):
        sh("shell", "input", "keyevent", "KEYCODE_BACK")  # hide keyboard (only when shown, else BACK would pop the route)
        time.sleep(1)
elif cmd == "has":
    sys.exit(0 if find(sys.argv[2]) else 1)

#!/bin/bash
# Usage: capture.sh <phone|tablet-7|tablet-10>
# Needs: mock server on :8787, `flutter run -t tool/store_screenshots/main.dart ...` already running
# with its stdin FIFO at $FIFO (so we can hot-restart with "R"). See main.dart header.
set -u
ADB=~/Library/Android/sdk/platform-tools/adb
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/../../../.claude/docs/play-store/screenshots/$1"
FIFO="${FIFO:?set FIFO to the flutter run stdin fifo}"
case "$1" in
  phone)     SIZE=1080x1920; DENS=380 ;;
  tablet-7)  SIZE=1200x1920; DENS=320 ;;
  tablet-10) SIZE=1600x2560; DENS=320 ;;
  *) echo "bad class"; exit 1 ;;
esac
mkdir -p "$OUT"; W=${SIZE%x*}; H=${SIZE#*x}
UI="python3 $HERE/ui.py"
show() { curl -s -X POST "localhost:8787/__screen?n=$1" >/dev/null; sleep "${2:-3}"; }
# -d: this AVD has two displays; 0 is the main one (see: dumpsys SurfaceFlinger --display-id)
# HOME + relaunch first: after adb input events Android draws a focus border around the window; this clears it.
shot() { $ADB shell input keyevent KEYCODE_HOME; sleep 1; $ADB shell am start -n com.jugaadi.jugaadi/.MainActivity >/dev/null; sleep 2.5; $ADB exec-out screencap -p -d 4619827259835644672 > "$OUT/$1.png"; python3 "$HERE/clean_border.py" "$OUT/$1.png"; echo "captured $1"; }
tap() { $UI tap "$1" || echo "WARN tap failed: $1"; sleep "${2:-1}"; }
ime_hide() { $ADB shell dumpsys input_method | grep -q "mInputShown=true" && $ADB shell input keyevent 4; sleep 0.5; }

$ADB shell settings put global sysui_demo_allowed 1
D="$ADB shell am broadcast -a com.android.systemui.demo -e command"
$D exit >/dev/null; sleep 1; $D enter >/dev/null; sleep 1; $D clock -e hhmm 1200 >/dev/null; $D battery -e level 100 -e plugged false >/dev/null
# order matters here, otherwise the emulator draws doubled wifi/mobile icons
$D network -e mobile show -e datatype none -e level 4 -e fully true >/dev/null; $D network -e sims 1 >/dev/null; $D network -e nosim hide >/dev/null
$D network -e wifi show -e level 4 -e fully true >/dev/null; $D network -e mobile hide >/dev/null
$D notifications -e visible false >/dev/null
$ADB shell wm size "$SIZE"; $ADB shell wm density "$DENS"; sleep 2
echo R > "$FIFO"; sleep 8

show 1; shot 01-nearby-tasks
show 2; shot 02-task-details

show 3 3
SWIPE_TOP='for _ in 1 2; do $ADB shell input swipe $((W/2)) $((H*3/10)) $((W/2)) $((H*17/20)) 300; done'
curl -s -X POST localhost:8787/__fill -d '["Unload tempo truck","Sri Lakshmi Traders, 100 Feet Road","700","3"]' >/dev/null; sleep 2
$ADB shell input swipe $((W/2)) $((H*3/4)) $((W/2)) $((H/5)) 300; sleep 1
tap "Pick dates" 2; tap "October 16, 2026" ; tap "October 18, 2026"; tap "^Save$" 2
eval "$SWIPE_TOP"; sleep 1
shot 03-post-job

show 4; shot 04-my-tasks
show 5; shot 05-applicants
show 6; shot 06-booked-contact
show 7 3; $ADB shell input swipe $((W/2)) $((H*3/4)) $((W/2)) $((H/4)) 300; sleep 1; tap "Edit profile" 2; eval "$SWIPE_TOP"; shot 07-profile-language
show 8; shot 08-plans

show 9 3; tap "My jobs" 2
tap "Filter by date" 2; tap "October 15, 2026"; tap "October 20, 2026"; tap "^Save$" 3
shot 09-my-applications

show 10 3; tap "^Share" 2; shot 10-share-sheet

$ADB shell wm size reset; $ADB shell wm density reset
$D exit >/dev/null

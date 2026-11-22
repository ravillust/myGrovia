"""Capture only the myGrovia demo UI for manual Android verification."""
import argparse
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

ADB = str(Path.home() / 'AppData/Local/Android/sdk/platform-tools/adb.exe')
SERIAL = 'AUXGFMJZBUOJJRZ9'
PACKAGE = 'com.rafifairuz.my_grovia.presentation'
parser = argparse.ArgumentParser()
parser.add_argument('name')
parser.add_argument('--tap', nargs=2, type=int, action='append')
parser.add_argument('--text')
parser.add_argument('--clear', action='store_true')
parser.add_argument('--back', action='store_true')
parser.add_argument('--swipe', nargs=4, type=int)
args = parser.parse_args()
if not args.name.replace('-', '').replace('_', '').isalnum():
    raise ValueError('Use a simple snapshot name')

def adb(*arguments):
    return subprocess.check_output([ADB, '-s', SERIAL, *arguments], timeout=30)

def check_focus():
    focus = adb('shell', 'dumpsys', 'window').decode('utf-8', errors='replace')
    focus_line = next((line for line in focus.splitlines() if 'mCurrentFocus=' in line), '')
    if PACKAGE not in focus_line:
        raise RuntimeError('Demo is not focused; no input/screenshot: ' + focus_line)

check_focus()
if args.tap:
    for position in args.tap:
        check_focus()
        adb('shell', 'input', 'tap', *map(str, position))
if args.clear:
    check_focus()
    adb('shell', 'input', 'keyevent', 'KEYCODE_MOVE_END')
    adb('shell', 'input', 'keyevent', *(['KEYCODE_DEL'] * 100))
if args.text is not None:
    check_focus()
    adb('shell', 'input', 'text', args.text.replace(' ', '%s'))
if args.back:
    check_focus()
    adb('shell', 'input', 'keyevent', 'KEYCODE_BACK')
if args.swipe:
    check_focus()
    adb('shell', 'input', 'swipe', *map(str, args.swipe), '400')
check_focus()
folder = Path('build/device-demo')
folder.mkdir(parents=True, exist_ok=True)
adb('shell', 'uiautomator', 'dump', '/sdcard/mygrovia-demo-ui.xml')
xml = adb('exec-out', 'cat', '/sdcard/mygrovia-demo-ui.xml')
(folder / (args.name + '.xml')).write_bytes(xml)
(folder / (args.name + '.png')).write_bytes(adb('exec-out', 'screencap', '-p'))
for node in ET.fromstring(xml).iter('node'):
    label = node.attrib.get('text') or node.attrib.get('content-desc')
    if label and node.attrib.get('package') == PACKAGE:
        print(label.encode('ascii', errors='backslashreplace').decode(), node.attrib.get('bounds'))

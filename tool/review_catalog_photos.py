"""Generate contact sheets for visual review of downloaded photos."""
import json
import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'build/photo-python'))
from PIL import Image, ImageDraw, ImageFont

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--new', action='store_true')
    args = parser.parse_args()
    entries = json.loads((ROOT / 'third_party/catalog_photos/manifest.json').read_text(encoding='utf-8'))
    available = {}
    for entry in entries:
        if entry.get('asset') and (ROOT / entry['asset']).is_file():
            available.setdefault(entry['asset'], entry)
    folder = ROOT / 'build/photo-review'
    if args.new and (folder / 'index.json').exists():
        previous = {e['asset'] for e in json.loads((folder / 'index.json').read_text(encoding='utf-8'))}
        available = {asset: entry for asset, entry in available.items() if asset not in previous}
        folder = folder / 'new'
    items = list(available.values())
    folder.mkdir(parents=True, exist_ok=True)
    font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 13)
    report = []
    for start in range(0, len(items), 48):
        sheet = Image.new('RGB', (1200, 1440), '#f4f4f4')
        draw = ImageDraw.Draw(sheet)
        page_items = items[start:start+48]
        for offset, entry in enumerate(page_items):
            image = Image.open(ROOT / entry['asset'])
            image.thumbnail((190, 190))
            x, y = (offset % 6) * 200, (offset // 6) * 180
            image.thumbnail((190, 140))
            sheet.paste(image, (x + (200-image.width)//2, y))
            label = f'{start+offset+1}. {entry["id"]}'
            draw.text((x+3,y+141), label[:28], fill='black', font=font)
            draw.text((x+3,y+158), entry['taxon'][:28], fill='#444444', font=font)
            report.append({'index':start+offset+1,'id':entry['id'],'asset':entry['asset'],
                'file_title':entry['file_title'],'subject':entry['taxon']})
        sheet.save(folder / f'page-{start//48+1:02}.jpg', quality=88)
    (folder / 'index.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'{len(items)} photos in {(len(items)+47)//48} contact sheets')

if __name__ == '__main__':
    main()

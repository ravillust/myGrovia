"""Apply reviewed photo metadata without changing plant facts or catalog IDs."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'third_party/catalog_photos/manifest.json'

def apply_photos(catalog):
    if not MANIFEST.exists():
        return catalog
    records = {entry['id']: entry for entry in json.loads(MANIFEST.read_text(encoding='utf-8'))}
    for row in catalog:
        photo = records.get(row['id'])
        if not photo or photo['status'] != 'downloaded':
            if 'catalog_' in (row.get('image') or ''):
                row['image'] = None
                row['photo_reference'] = ''
            continue
        if not (ROOT / photo['asset']).is_file():
            raise FileNotFoundError(photo['asset'])
        row['image'] = photo['asset']
        row['photo_reference'] = '\n'.join(filter(None, [
            photo['file_title'], photo.get('attribution') or photo['author'],
            photo.get('credit'), photo['license'], photo.get('license_url'),
            photo['source_page'], photo['modification'],
        ]))
    return catalog

def write_gaps(catalog):
    (ROOT / 'docs').mkdir(parents=True, exist_ok=True)
    lines = ['id,missing_photo,missing_botanical_name']
    for row in catalog:
        lines.append(f'{row["id"]},{not bool(row.get("image"))},{not bool(row.get("botanical_name"))}')
    (ROOT / 'docs/catalog_gaps.csv').write_text('\n'.join(lines) + '\n', encoding='utf-8')

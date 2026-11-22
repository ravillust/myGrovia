"""Download the pinned source and bundle offline JSON. No backend credentials needed."""
import argparse
import json
from pathlib import Path
from urllib.request import urlopen
from photo_manifest import apply_photos, write_gaps

URL = ('https://raw.githubusercontent.com/Luminoid/plantfolio-common-plants/'
       'bbb364534cfbca28168085897ac9f2ff00a151a5/dist/common_plants.json')
ROOT = Path(__file__).resolve().parents[1]
DISPLAY_LABELS = {
    'swiss-cheese-plant': ('Monstera Deliciosa', 'Monstera deliciosa'),
    'calathea-orbifolia': ('Calathea Orbifolia', 'Goeppertia orbifolia'),
    'snake-plants': ('Snake Plant', 'Dracaena trifasciata'),
    'golden-pothos': ('Golden Pothos', 'Epipremnum aureum'),
}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, help='Pinned source JSON saved locally')
    args = parser.parse_args()
    if args.source:
        source = json.loads(args.source.read_text(encoding='utf-8'))
    else:
        with urlopen(URL, timeout=30) as response:
            source = json.load(response)
    scope = json.loads((ROOT / 'third_party/plantfolio/catalog_scope.json').read_text(encoding='utf-8'))
    catalog = []
    for row in source:
        if 'id' not in row:
            continue
        if not row.get('category', '').startswith(scope['category_prefix']):
            continue
        if row['id'] in scope['excluded_ids']:
            continue
        name, botanical = DISPLAY_LABELS.get(row['id'], (row['typeName'], ''))
        summary = row.get('description', '')
        sections = [summary]
        for field, label in [('commonExamples', 'Examples'), ('origin', 'Origin'), ('careTips', 'Care guidance')]:
            if row.get(field):
                sections.append(label + ': ' + row[field])
        data = dict(id=row['id'], name=name, botanical_name=botanical,
                    source_category=row['category'],
                    image=None,
                    summary=summary, description='\n\n'.join(sections),
                    reference=URL + '\nCC BY-NC-SA 4.0; Luminoid. Text compiled from description, commonExamples, origin and careTips.',
                    photo_reference='',
                    watering_days=row['summerInterval'],
                    light={'brightIndirect': 'Bright indirect', 'mediumIndirect': 'Medium indirect', 'lowIndirect': 'Low indirect'}.get(row.get('lightPreference'), row.get('lightPreference', '')),
                    temperature=' - '.join(map(str, row.get('temperaturePreference', []))) + ' C',
                    tip=row.get('careTips', ''),
                    difficulty='Moderate' if row['id'] == 'calathea-orbifolia' else ('Easy' if row['id'] in DISPLAY_LABELS else 'Unknown'),
                    low_light=row.get('lightPreference') == 'lowIndirect')
        if data['watering_days'] is not None:
            assert 1 <= data['watering_days'] <= 365
        catalog.append(data)
    folder = ROOT / 'assets/data'
    folder.mkdir(exist_ok=True)
    catalog = apply_photos(catalog)
    (folder / 'catalog.json').write_text(json.dumps(catalog, ensure_ascii=False, indent=2), encoding='utf-8')
    write_gaps(catalog)
    print(f'Bundled {len(catalog)} entries from pinned GitHub source.')

if __name__ == '__main__':
    main()

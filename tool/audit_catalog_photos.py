"""Reject drawings, broad substitutes, and manually identified unsuitable assets."""
import json
import re
import time
from catalog_photos import norm
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'third_party/catalog_photos/manifest.json'

def main():
    metadata = {}
    for path in (ROOT / 'build/photo-cache').glob('*.json'):
        data = json.loads(path.read_text(encoding='utf-8'))
        if not isinstance(data, dict):
            continue
        for page in data.get('query', {}).get('pages', []):
            if page.get('imageinfo'):
                metadata[page['title'][5:].replace('_', ' ')] = page['imageinfo'][0].get('extmetadata', {})
    entries = json.loads(MANIFEST.read_text(encoding='utf-8'))
    review_path = ROOT / 'third_party/catalog_photos/review_rejections.json'
    review = {norm(name): reason for name, reason in json.loads(review_path.read_text(encoding='utf-8')).items()} if review_path.exists() else {}
    rejected = []
    for entry in entries:
        if entry['status'] not in ('matched', 'downloaded', 'download_failed'):
            continue
        meta = metadata.get(entry['file_title'].replace('_', ' '), {})
        categories = str(meta.get('Categories', {}).get('value', '')).lower()
        reason = None
        if entry['id'] in ('bonsai', 'bromeliads', 'conifers', 'climbers',
                'root-vegetables', 'onions-garlic', 'cacti', 'forest-cacti',
                'prayer-plants', 'bamboo', 'grasses', 'groundcovers',
                'pitcher-plant', 'epiphytes'):
            entry['broad'] = True
            reason = 'Broad horticultural group; first example is not an exact identity for the group.'
        if entry['id'] == 'calathea-freddie' and 'freddie' not in norm(entry.get('image_description','') + ' ' + entry['file_title']):
            reason = 'Freddie cultivar identity not established; parent species photo withheld.'
        if any(word in categories for word in (
            'botanical illustrations', 'botanical illustration', 'lithographs',
            'engravings', 'drawings of', 'paintings of', 'herbarium specimens', 'pd-art', 'botanical magazine',
        )):
            reason = 'Artwork/herbarium specimen, not a photograph of a living plant.'
        if not entry.get('name_only') and re.match(r'^[A-Z][a-z]+ [a-z][a-z-]+', entry.get('taxon','')):
            primary = entry['examples'].split(',')[0]
            aliases = [entry['taxon']] + re.findall(r'[A-Z][a-z]+ [a-z][a-z-]+', primary)
            identity_text = norm(entry['file_title'] + ' ' + entry.get('image_description',''))
            if not any(norm(alias) in identity_text for alias in aliases):
                reason = 'Species identity not explicit in file title/description; common-name-only match withheld.'
        if entry.get('stage'):
            filename = entry['file_title'].lower()
            if not any(word in filename for word in ('microgreen', 'sprout', 'seedling')):
                reason = 'Requested growth stage not established by image title.'
        if norm(entry['file_title']) in review:
            reason = review[norm(entry['file_title'])]
        if re.search(r' (var\.|subsp\.) ', entry.get('taxon', '')):
            evidence = norm(entry['file_title'] + ' ' + entry.get('image_description', ''))
            if norm(entry['taxon'].split()[-1]) not in evidence.split() and norm(entry['name']) not in evidence:
                reason = 'Botanical variety/subspecies identity not established; parent species withheld.'
        if reason:
            entry['status'] = 'rejected'
            entry['reason'] = reason
            rejected.append((entry['id'], reason))
    MANIFEST.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding='utf-8')
    # Only generated catalog_* files are moved; original repository photos are untouched.
    used = {e['asset'] for e in entries if e['status'] in ('matched', 'downloaded', 'download_failed')}
    quarantine = ROOT / 'build/photo-rejected'
    quarantine.mkdir(parents=True, exist_ok=True)
    for path in (ROOT / 'assets/plants/catalog').glob('catalog_*.jpg'):
        if str(path.relative_to(ROOT)).replace('\\', '/') not in used:
            target = quarantine / path.name
            if target.exists():
                target = quarantine / f'{path.stem}_{time.time_ns()}{path.suffix}'
            assert path.resolve().is_relative_to((ROOT / 'assets/plants').resolve())
            assert target.resolve().is_relative_to((ROOT / 'build/photo-rejected').resolve())
            path.rename(target)
    print('Rejected:', len(rejected))
    for plant, reason in rejected:
        print(plant + ': ' + reason)

if __name__ == '__main__':
    main()

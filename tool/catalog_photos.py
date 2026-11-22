"""Find exact-match freely licensed photographs and prepare offline JPEG assets.
Run with --discover, --download, --apply; cached responses make each stage resumable.
No source text or HTTP access is used by the APK at runtime.
"""
import argparse
import concurrent.futures
import hashlib
import html
import io
import json
import re
import sys
import time
import unicodedata
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
CACHE = ROOT / 'build/photo-cache'
MANIFEST = ROOT / 'third_party/catalog_photos/manifest.json'
REVIEW = ROOT / 'third_party/catalog_photos/review_rejections.json'
HEADERS = {'User-Agent': 'myGroviaCatalogPhotos/1.0 (educational offline plant catalog; attribution retained)'}
WIKI = 'https://en.wikipedia.org/w/api.php'
COMMONS = 'https://commons.wikimedia.org/w/api.php'

def clean(value):
    return html.unescape(re.sub(r'<[^>]*>', '', str(value or ''))).strip()

def norm(value):
    value = unicodedata.normalize('NFKD', value).encode('ascii', 'ignore').decode()
    return re.sub(r'[^a-z0-9]+', ' ', value.lower()).strip()

def fetch(url):
    for attempt in range(4):
        try:
            with urlopen(Request(url, headers=HEADERS), timeout=35) as response:
                return response.read()
        except HTTPError as error:
            if error.code == 429 and ('robot policy' in str(error) or not error.headers.get('Retry-After')):
                raise
            if error.code not in (429, 500, 502, 503, 504) or attempt == 3:
                raise
            time.sleep(int(error.headers.get('Retry-After', 5 * (attempt + 1))))
        except (TimeoutError, OSError):
            if attempt == 3:
                raise
            time.sleep(2 * (attempt + 1))

def api(endpoint, params):
    params = {'format': 'json', 'formatversion': 2, **params}
    key = hashlib.sha256((endpoint + json.dumps(params, sort_keys=True)).encode()).hexdigest()
    path = CACHE / (key + '.json')
    if path.exists():
        return json.loads(path.read_text(encoding='utf-8'))
    result = json.loads(fetch(endpoint + '?' + urlencode(params)))
    if 'error' in result:
        raise ValueError(result['error'])
    path.write_text(json.dumps(result, ensure_ascii=False), encoding='utf-8')
    time.sleep(0.25)
    return result

def plan(row):
    examples = row['description'].split('Examples: ')[-1].split('\n')[0]
    first = examples.split(',')[0].split('(')[0].strip().lstrip('\ufffd\u00d7 ')
    # Keep botanical varieties and named cultivars. Never fall back to their parent species.
    match = re.match(r"([A-Z][a-z]+)(?: (?:[x\u00d7] )?([a-z][a-z-]+))?(?: (?:var\.|subsp\.) [a-z-]+)?", first)
    taxon = row.get('botanical_name') or (match.group(0) if match else '')
    taxon = re.sub(r' (spp|sp|hybrids|species|cultivars)$', '', taxon)
    cultivar = re.search(r"['\u2018]([^'\u2019]+)['\u2019]", first)
    specific_cultivar = bool(cultivar)
    if specific_cultivar:
        taxon = first
    special_stage = bool(re.search(r'microgreens|sprouts|bulbs', row['id'])) and row['id'] != 'brussels-sprouts'
    broad = row['id'] in {
        'deciduous-trees', 'desert-trees', 'evergreen-trees', 'fruit-trees',
        'evergreen-shrubs', 'flowering-shrubs', 'herbaceous-perennials', 'shade-perennials',
        'cool-season-annuals', 'warm-season-annuals', 'aquatic-plants', 'bog-plants', 'alpine-plants',
        'sprouts-microgreens', 'ferns', 'aroids', 'trailing-aroids', 'vines-trailing',
        'palms', 'succulents', 'orchids', 'indoor-aquatics', 'leafy-greens', 'fruiting-vegetables',
        'indoor-herbs', 'carnivorous-plant', 'daisies', 'cycads', 'bonsai', 'bromeliads',
        'conifers', 'climbers', 'root-vegetables', 'onions-garlic', 'cacti',
        'forest-cacti', 'prayer-plants', 'bamboo', 'grasses', 'groundcovers',
        'pitcher-plant', 'epiphytes',
    }
    if special_stage or broad:
        taxon = ''
    if match and norm(row['name']) == norm(match.group(1)):
        taxon = match.group(1)
    genus_subjects = {'alocasias':'Alocasia','anthuriums':'Anthurium','aloes':'Aloe',
        'crassulas':'Crassula','euphorbias':'Euphorbia','hoyas':'Hoya','citrus-trees':'Citrus',
        'senecio':'Senecio','oxalis':'Oxalis','pothos':'Epipremnum aureum'}
    if row['id'] in genus_subjects:
        taxon = genus_subjects[row['id']]
    name_subjects = {'ficus-audrey':'Ficus Audrey', 'climbing-rose':'Climbing rose',
        'petunia-grandiflora':'Grandiflora petunia', 'bell-peppers':'Bell pepper', 'jalapeno':'Jalape?o',
        'cantaloupe':'Cantaloupe', 'honeydew':'Honeydew melon', 'lemon-cucumber':'Lemon cucumber',
        'delicata-squash':'Delicata squash', 'pattypan-squash':'Pattypan squash', 'spaghetti-squash':'Spaghetti squash',
        'japanese-eggplant':'Japanese eggplant', 'thai-eggplant':'Thai eggplant', 'roma-tomato':'Roma tomato',
        'watermelon-yellow':'Yellow watermelon', 'sugar-beet':'Sugar beet', 'wheatgrass':'Wheatgrass',
        'pea-shoots':'Pea shoots', 'lily-asiatic':'Asiatic lily', 'lily-oriental':'Oriental lily',
        'edamame':'Edamame', 'sweet-potato-vine':'Sweet potato vine', 'zucchini':'Zucchini'}
    name_only = row['id'] in name_subjects
    if name_only:
        taxon = name_subjects[row['id']]
        specific_cultivar = False
    queries = list(dict.fromkeys(q for q in [taxon, row['name'], row['name'].capitalize()] if q))
    return {'id': row['id'], 'name': row['name'], 'taxon': taxon,
            'queries': queries, 'cultivar': cultivar.group(1) if specific_cultivar else None,
            'stage': special_stage, 'broad': broad, 'name_only': name_only, 'examples': examples,
            'status': 'pending'}

def cached_pages():
    result = {}
    for path in CACHE.glob('*.json'):
        data = json.loads(path.read_text(encoding='utf-8'))
        if not isinstance(data, dict): continue
        query = data.get('query', {})
        pages = query.get('pages', [])
        if any('imageinfo' in p for p in pages): continue
        by_title = {p['title']: p for p in pages if not p['title'].startswith('File:')}
        aliases = {x['from']: x['to'] for x in query.get('normalized', []) + query.get('redirects', [])}
        result.update(by_title)
        for alias in aliases:
            target = alias
            seen = set()
            while target in aliases and target not in seen:
                seen.add(target)
                target = aliases[target]
            if target in by_title: result[alias] = by_title[target]
    return result

def pages_for(queries):
    cached = cached_pages()
    found = {q:cached[q] for q in queries if q in cached and 'pageimage' in cached[q]
             and 'disambiguation' not in cached[q].get('pageprops', {})}
    queries = [q for q in queries if q not in cached]
    for offset in range(0, len(queries), 40):
        chunk = queries[offset:offset+40]
        response = api(WIKI, dict(action='query', titles='|'.join(chunk), redirects=1,
            prop='pageimages|pageprops', piprop='name|thumbnail', pithumbsize=640, pilicense='free'))
        query = response.get('query', {})
        aliases = {x['from']: x['to'] for x in query.get('normalized', []) + query.get('redirects', [])}
        pages = {x['title']: x for x in query.get('pages', [])}
        for title in chunk:
            resolved = title
            seen = set()
            while resolved in aliases and resolved not in seen:
                seen.add(resolved)
                resolved = aliases[resolved]
            page = pages.get(resolved)
            if page and 'pageimage' in page and 'disambiguation' not in page.get('pageprops', {}):
                found[title] = page
        print(f'Article lookup {min(offset+40,len(queries))}/{len(queries)}; images for {len(found)} titles', flush=True)
    return found

def metadata_for(files):
    found = {}
    for path in CACHE.glob('*.json'):
        data = json.loads(path.read_text(encoding='utf-8'))
        if not isinstance(data,dict): continue
        for page in data.get('query',{}).get('pages',[]):
            if page.get('imageinfo'):
                found[page['title'][5:].replace('_', ' ')] = page['imageinfo'][0]
    files = [f for f in files if f.replace('_',' ') not in found]
    for offset in range(0, len(files), 20):
        chunk = files[offset:offset+20]
        response = api(COMMONS, dict(action='query', titles='|'.join('File:' + f for f in chunk),
            prop='imageinfo', iiprop='url|extmetadata|mime|size', iiurlwidth=640))
        for page in response.get('query', {}).get('pages', []):
            if page.get('imageinfo'):
                found[page['title'][5:].replace('_', ' ')] = page['imageinfo'][0]
        print(f'License metadata {min(offset+20,len(files))}/{len(files)}', flush=True)
    return found

def choose(entry, pages, metadata):
    rejected = {norm(name) for name in json.loads(REVIEW.read_text(encoding='utf-8'))} if REVIEW.exists() else set()
    for query in entry['queries']:
        page = pages.get(query)
        if not page:
            continue
        if norm(page['pageimage']) in rejected:
            continue
        info = metadata.get(page['pageimage'].replace('_', ' '))
        if not info or info.get('mime') not in ('image/jpeg', 'image/png', 'image/webp'):
            continue
        meta = {k: clean(v.get('value', '')) for k,v in info.get('extmetadata', {}).items()}
        categories = meta.get('Categories', '').lower()
        if any(word in categories for word in ('botanical illustration', 'lithographs',
                'engravings', 'drawings of', 'paintings of', 'herbarium specimens', 'pd-art', 'botanical magazine')):
            continue
        license_name = meta.get('LicenseShortName', '')
        if not re.match(r'^(CC BY(?:-SA)? (?:1\.0|2\.0|2\.5|3\.0|4\.0)|CC0(?: 1\.0)?|Public domain)$', license_name):
            continue
        if (license_name.startswith('CC BY') and not meta.get('LicenseUrl')) or meta.get('Restrictions'):
            continue
        if not meta.get('Artist') or min(info.get('width',0), info.get('height',0)) < 200:
            continue
        evidence = norm(' '.join([page['pageimage'], meta.get('ObjectName',''), meta.get('ImageDescription','')]))
        identities = [entry['taxon'], entry['name']]
        identities = [norm(x) for x in identities if x]
        if not any(identity in evidence for identity in identities):
            continue
        if not entry.get('name_only') and re.match(r'^[A-Z][a-z]+ [a-z][a-z-]+', entry['taxon']):
            aliases = [entry['taxon']] + re.findall(r'[A-Z][a-z]+ [a-z][a-z-]+', entry['examples'].split(',')[0])
            identity_text = norm(page['pageimage'] + ' ' + meta.get('ImageDescription', ''))
            if not any(norm(alias) in identity_text for alias in aliases):
                continue
        if entry['cultivar'] and norm(entry['cultivar']) not in evidence:
            continue
        if re.search(r' (var\.|subsp\.) ', entry['taxon']):
            epithet = norm(entry['taxon'].split()[-1])
            if epithet not in evidence.split() and norm(entry['name']) not in evidence:
                continue
        if entry['stage'] and not any(word in norm(page['pageimage']) for word in ('microgreen','sprout','seedling')):
            continue
        if entry['broad']:
            # An individual species photograph cannot establish a broad mixed category.
            continue
        if any(word in norm(page['pageimage']).split() for word in ('distribution','map','diagram','icon','logo','herbarium','fossil','illustration','illustrations','sturm','koehler','lindman')):
            continue
        identity = hashlib.sha256(page['pageimage'].encode()).hexdigest()[:20]
        return {**entry, 'status': 'matched', 'article_title': page['title'],
            'matched_query': query, 'file_title': page['pageimage'],
            'source_page': info['descriptionurl'], 'source_url': info['url'],
            'download_url': info.get('thumburl') or info['url'],
            'author': meta['Artist'], 'credit': meta.get('Credit',''),
            'attribution': meta.get('Attribution',''), 'license': license_name,
            'license_url': meta.get('LicenseUrl',''), 'image_description': meta.get('ImageDescription',''),
            'asset': f'assets/plants/catalog/catalog_{identity}.jpg',
            'modification': 'Resized to fit 640 x 640 pixels; JPEG quality 78; no AI alteration.'}
    return {**entry, 'status': 'unmatched', 'reason': 'No exact-subject image with verified supported license and identity metadata.'}

def save_manifest(entries):
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding='utf-8')

def discover():
    rows = json.loads((ROOT / 'assets/data/catalog.json').read_text(encoding='utf-8'))
    entries = [plan(row) for row in rows]
    queries = list(dict.fromkeys(q for entry in entries for q in entry['queries']))
    (CACHE / 'plan.json').write_text(json.dumps(entries,ensure_ascii=False,indent=2), encoding='utf-8')
    pages = pages_for(queries)
    files = list(dict.fromkeys(page['pageimage'] for page in pages.values()))
    metadata = metadata_for(files)
    entries = [choose(entry, pages, metadata) for entry in entries]
    save_manifest(entries)
    print('Exact matches:', sum(e['status']=='matched' for e in entries), '/', len(entries), flush=True)

def download():
    sys.path.insert(0, str(ROOT / 'build/photo-python'))
    from PIL import Image, ImageOps
    entries = json.loads(MANIFEST.read_text(encoding='utf-8'))
    jobs = {e['asset']: e for e in entries if e['status'] in ('matched','downloaded','download_failed')}
    status_path = CACHE / 'download_status.json'
    previous = json.loads(status_path.read_text()) if status_path.exists() else {}
    def work(pair):
        asset, entry = pair
        path = ROOT / asset
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            return asset, None
        if '429' in str(previous.get(asset, '')):
            return asset, previous[asset]
        try:
            url = entry['download_url'].split('?', 1)[0]
            # Commons accepts only its standard thumbnail widths (not arbitrary 640px).
            if '/thumb/' in url:
                url = re.sub(r'/\d+px-', '/500px-', url)
            elif 'upload.wikimedia.org/wikipedia/commons/' in url:
                base, filename = url.rsplit('/', 1)
                url = base.replace('/commons/', '/commons/thumb/') + '/' + filename + '/250px-' + filename
            raw = fetch(url)
            image = ImageOps.exif_transpose(Image.open(io.BytesIO(raw))).convert('RGB')
            image.thumbnail((640,640), Image.Resampling.LANCZOS)
            image.save(path, 'JPEG', quality=78, optimize=True, progressive=True)
            time.sleep(0.6)
            return asset, None
        except Exception as error:
            return asset, str(error)
    outcomes = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        for i, (asset, error) in enumerate(pool.map(work, jobs.items()),1):
            outcomes[asset] = error
            if i % 10 == 0 or error: print(f'Download {i}/{len(jobs)}: {error or "ok"}',flush=True)
            for entry in entries:
                if entry.get('asset') == asset:
                    entry['status'] = 'download_failed' if error else 'downloaded'
                    if error: entry['download_error'] = error
                    else:
                        entry.pop('download_error', None)
                        entry['sha256'] = hashlib.sha256((ROOT/asset).read_bytes()).hexdigest()
                        entry['bytes'] = (ROOT/asset).stat().st_size
            if i % 10 == 0:
                (CACHE / 'download_status.json').write_text(json.dumps(outcomes), encoding='utf-8')
    (CACHE / 'download_status.json').write_text(json.dumps(outcomes), encoding='utf-8')
    print('Downloaded entries:', sum(e['status']=='downloaded' for e in entries), flush=True)

def search_missing():
    entries = json.loads(MANIFEST.read_text(encoding='utf-8'))
    pending = [e for e in entries if e['status'] in ('unmatched', 'rejected') and not e.get('broad')]
    def work(entry):
        subject = entry['taxon'] or entry['name']
        if entry.get('cultivar'):
            genus = subject.split()[0]
            search = f'"{genus}" "{entry["cultivar"]}"'
        else:
            search = '"' + subject.replace('"','') + '"'
        try:
            response = api(COMMONS, dict(action='query', generator='search',
                gsrsearch=search + ' filetype:bitmap', gsrnamespace=6, gsrlimit=5,
                prop='imageinfo', iiprop='url|extmetadata|mime|size', iiurlwidth=640))
            for page in response.get('query',{}).get('pages',[]):
                if not page.get('imageinfo'): continue
                filename = page['title'][5:]
                found = choose(entry, {entry['queries'][0]: {'title':subject, 'pageimage':filename}},
                    {filename.replace('_',' '):page['imageinfo'][0]})
                if found['status']=='matched':
                    found['search_query'] = search
                    return found
            return {**entry, 'search_query':search}
        except Exception as error:
            return {**entry, 'search_error':str(error)}
    by_id = {e['id']:e for e in entries}
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        for index, entry in enumerate(pool.map(work,pending),1):
            by_id[entry['id']] = entry
            if index % 10 == 0:
                save_manifest(list(by_id.values()))
                print(f'Commons exact search {index}/{len(pending)}; total matches {sum(e["status"]=="matched" for e in by_id.values())}',flush=True)
    save_manifest(list(by_id.values()))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--discover', action='store_true')
    parser.add_argument('--download', action='store_true')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--search-missing', action='store_true')
    parser.add_argument('--optimize', action='store_true')
    parser.add_argument('--report', action='store_true')
    args = parser.parse_args()
    CACHE.mkdir(parents=True, exist_ok=True)
    if args.discover: discover()
    if args.search_missing: search_missing()
    if args.download: download()
    if args.optimize:
        sys.path.insert(0, str(ROOT / 'build/photo-python'))
        from PIL import Image
        entries = json.loads(MANIFEST.read_text(encoding='utf-8'))
        done = set()
        for entry in entries:
            asset = entry.get('asset')
            if entry['status'] not in ('matched', 'downloaded', 'download_failed') or not asset or not (ROOT / asset).is_file():
                continue
            if asset not in done and entry.get('optimized_sha256') != hashlib.sha256((ROOT / asset).read_bytes()).hexdigest():
                with Image.open(ROOT / asset) as source:
                    photo = source.convert('RGB')
                photo.thumbnail((480, 480), Image.Resampling.LANCZOS)
                photo.save(ROOT / asset, 'JPEG', quality=72, optimize=True, progressive=True)
            done.add(asset)
            entry['optimized_sha256'] = hashlib.sha256((ROOT / asset).read_bytes()).hexdigest()
            entry['modification'] = 'Resized to fit 480 x 480 pixels; JPEG quality 72; no AI alteration.'
        save_manifest(entries)
        print('Optimized unique photos:', len(done))
    if args.apply:
        from photo_manifest import apply_photos, write_gaps
        entries = json.loads(MANIFEST.read_text(encoding='utf-8'))
        status_path = CACHE / 'download_status.json'
        outcomes = json.loads(status_path.read_text()) if status_path.exists() else {}
        for entry in entries:
            if entry['status'] in ('matched','downloaded','download_failed') and (ROOT / entry['asset']).is_file():
                entry['status'] = 'downloaded'
                entry['sha256'] = hashlib.sha256((ROOT / entry['asset']).read_bytes()).hexdigest()
                entry['bytes'] = (ROOT / entry['asset']).stat().st_size
                entry.pop('download_error', None)
            elif entry['status'] in ('matched', 'download_failed'):
                entry['status'] = 'download_failed'
                entry['download_error'] = outcomes.get(entry['asset']) or 'Photo not downloaded; placeholder retained.'
        save_manifest(entries)
        path = ROOT / 'assets/data/catalog.json'
        rows = apply_photos(json.loads(path.read_text(encoding='utf-8')))
        path.write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding='utf-8')
        write_gaps(rows)
        print('Catalog entries with photos:', sum(bool(r['image']) for r in rows))
    if args.report:
        from photo_report import report
        report()

if __name__ == '__main__':
    main()

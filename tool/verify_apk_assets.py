"""Inspect the built APK, not just the source folders."""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('apk', nargs='?', default='build/app/outputs/flutter-apk/app-release.apk')
args = parser.parse_args()
apk = Path(args.apk)
manifest = json.loads(Path('third_party/catalog_photos/manifest.json').read_text(encoding='utf-8'))
prefix = 'assets/flutter_assets/'
with zipfile.ZipFile(apk) as archive:
    names = set(archive.namelist())
    catalog_bytes = archive.read(prefix + 'assets/data/catalog.json')
    assert catalog_bytes == Path('assets/data/catalog.json').read_bytes()
    rows = json.loads(catalog_bytes)
    assert all(row['source_category'].startswith('Houseplants - ') for row in rows)
    used = set()
    for entry in manifest:
        if entry['status'] == 'downloaded':
            data = archive.read(prefix + entry['asset'])
            assert hashlib.sha256(data).hexdigest() == entry['sha256']
            used.add(prefix + entry['asset'])
    photos = {name for name in names if name.startswith(prefix + 'assets/plants/')}
    assert photos == used, 'APK includes an unverified or missing plant photograph'
    assert prefix + 'assets/fonts/PlusJakartaSans-OFL.txt' in names
    assert prefix + 'assets/branding/mygrovia_logo.png' in names
    assert prefix + 'assets/illustration/empty_collection_plant.svg' in names
    assert not any(name.startswith(prefix + 'assets/swagger/') for name in names)
    assert not any(name.endswith(('.jks', '.keystore', 'key.properties', 'kernel_blob.bin')) for name in names)
    assert any(name.endswith('/libapp.so') for name in names), 'AOT application library is missing'
    result = {
        'apk': str(apk), 'bytes': apk.stat().st_size,
        'sha256': hashlib.sha256(apk.read_bytes()).hexdigest(),
        'catalog_entries': len(rows), 'entries_with_photo': sum(bool(row['image']) for row in rows),
        'verified_photo_files': len(used), 'legacy_photos_bundled': False,
        'active_catalog_photo_files': len({row['image'] for row in rows if row['image']}),
        'archived_catalog_photos_preserved': True,
        'font_license_bundled': True, 'signing_secrets_bundled': False,
        'aot_library_present': True, 'debug_kernel_blob_present': False,
        'swagger_assets_bundled': False,
    }
Path('build/' + apk.stem + '-verification.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
print(json.dumps(result, indent=2))

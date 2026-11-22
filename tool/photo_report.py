"""Validate final offline assets and write an auditable coverage report."""
import csv
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def report():
    sys.path.insert(0, str(ROOT / 'build/photo-python'))
    from PIL import Image
    entries = json.loads((ROOT / 'third_party/catalog_photos/manifest.json').read_text(encoding='utf-8'))
    rows = json.loads((ROOT / 'assets/data/catalog.json').read_text(encoding='utf-8'))
    by_id = {e['id']: e for e in entries}
    used = set()
    for row in rows:
        entry = by_id[row['id']]
        if entry['status'] != 'downloaded':
            assert 'catalog_' not in (row.get('image') or '')
            continue
        assert row['image'] == entry['asset']
        path = ROOT / entry['asset']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == entry['sha256']
        assert path.stat().st_size == entry['bytes']
        with Image.open(path) as photo:
            assert photo.format == 'JPEG' and max(photo.size) <= 480
            photo.verify()
        used.add(entry['asset'])
    actual = {str(p.relative_to(ROOT)).replace('\\', '/') for p in (ROOT / 'assets/plants/catalog').glob('catalog_*.jpg')}
    verified = {e['asset']: e for e in entries if e['status'] == 'downloaded'}
    assert actual == set(verified), 'Unverified or missing photo assets'
    for asset, entry in verified.items():
        path = ROOT / asset
        assert hashlib.sha256(path.read_bytes()).hexdigest() == entry['sha256']
    active_ids = {row['id'] for row in rows}
    active_entries = [entry for entry in entries if entry['id'] in active_ids]
    count = sum(e['status'] == 'downloaded' for e in active_entries)
    photo_count = sum(bool(r['image']) for r in rows)
    size = sum((ROOT / p).stat().st_size for p in used)
    failed = sum(e['status'] == 'download_failed' for e in active_entries)
    (ROOT / 'docs').mkdir(parents=True, exist_ok=True)
    with (ROOT / 'docs/photo_coverage.csv').open('w', encoding='utf-8', newline='') as stream:
        writer = csv.writer(stream)
        writer.writerow(['id', 'name', 'status', 'asset', 'source_page', 'license', 'reason'])
        for entry in active_entries:
            writer.writerow([entry['id'], entry['name'], entry['status'],
                entry.get('asset', '') if entry['status'] == 'downloaded' else '',
                entry.get('source_page', ''), entry.get('license', ''),
                entry.get('download_error') if entry['status'] == 'download_failed'
                else entry.get('reason', '') if entry['status'] != 'downloaded' else ''])
    text = f'''# Cakupan foto katalog

- Total katalog: {len(rows)} entri.
- Foto pada Dictionary aktif: {count} entri, memakai {len(used)} berkas unik.
- Entri dengan foto: {photo_count}.
- Entri dengan gambar bawaan: {len(rows) - photo_count}.
- Ukuran JPEG Dictionary aktif: {size:,} byte ({size / 1048576:.2f} MiB).
- Foto katalog lama tetap dibundel untuk koleksi yang tersimpan sebelum penyaringan:
  {len(actual - used)} berkas tambahan; total {len(actual)} berkas terverifikasi.
- Kandidat yang belum berhasil diunduh: {failed}; tidak dimasukkan ke APK.

Semua berkas aktif diperiksa dapat didekode, maksimum 480 × 480 piksel,
checksum sesuai manifest, dan dirujuk oleh katalog aktif. Foto arsip juga diperiksa
checksumnya untuk kompatibilitas koleksi lama. Tidak ada foto hasil generasi
AI. Foto yang sama tidak diduplikasi. Foto, atribusi, dan teks tersedia offline.

Seluruh entri diperiksa melalui nama katalog dan nama botani dari sumber.
Kandidat tanpa identitas/lisensi yang cukup, varietas yang tidak cocok, kelompok
terlalu umum, ilustrasi, serta foto yang belum berhasil diunduh tetap menggunakan
gambar bawaan. "Belum ditemukan" bukan berarti foto tersebut tidak ada di internet.
Beberapa unduhan menerima HTTP 429 dari sumber dan tidak dipaksa diulang.

Daftar per tanaman dan alasan: [photo_coverage.csv](photo_coverage.csv).
Detail fotografer/lisensi/sumber/checksum:
[manifest.json](../third_party/catalog_photos/manifest.json).
Metode dan cara memperbarui: [README foto](../third_party/catalog_photos/README.md).

Foto katalog berada di `assets/plants/catalog/`; DatabaseHelper membaca referensi aset dari
katalog SQLite. Flutter membaca berkas foto dari APK. Foto pribadi berbeda: salinannya disimpan
di folder privat aplikasi, bukan dimasukkan ke assets. Pembaruan katalog menjaga
foto pribadi, nama, interval, dan riwayat tanaman yang sudah disimpan.
'''
    (ROOT / 'docs/PHOTO_COVERAGE.md').write_text(text, encoding='utf-8')
    print(text)

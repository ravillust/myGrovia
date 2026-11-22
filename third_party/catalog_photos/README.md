# Foto katalog myGrovia

Foto berasal dari Wikimedia Commons. `manifest.json` mencatat kandidat untuk
seluruh 980 entri: identitas tanaman yang dicari, berkas sumber, fotografer,
halaman sumber, lisensi, perubahan ukuran, dan hasil pemeriksaan. Hanya status
`downloaded` yang dipakai dalam katalog aplikasi. Lisensi foto terpisah dari
lisensi data Plantfolio.

Nama ilmiah/varietas diperiksa terhadap judul dan deskripsi berkas. Foto varietas
lain, ilustrasi botani, spesimen herbarium, dan gambar tanpa lisensi yang didukung
tidak digunakan. Entri tanpa kecocokan tetap memakai ilustrasi bawaan aplikasi.
Pemeriksaan metadata ini bukan identifikasi botani independen.

Foto JPEG dibatasi maksimum 480 × 480 piksel, kualitas 72, tanpa perubahan isi
menggunakan AI. Sebagian sumber lebih kecil. Foto yang sama digunakan bersama
oleh entri dengan identitas yang sama sehingga tidak digandakan dalam APK.
Aturan ukuran thumbnail sumber: https://www.mediawiki.org/wiki/Common_thumbnail_sizes

Setiap foto tetap mengikuti lisensi yang tercatat pada entri masing-masing,
termasuk ketentuan ShareAlike bila berlaku. Atribusi juga disertakan offline dalam
`assets/data/catalog.json`, terlihat di Read more dan menu Sumber foto Koleksi.
URL atribusi adalah informasi sumber; aplikasi tidak perlu mengakses URL itu
untuk menampilkan foto.

Alat persiapan (Python hanya di laptop, bukan di APK):

```powershell
python -m pip install --target build/photo-python Pillow
python tool/catalog_photos.py --discover
python tool/catalog_photos.py --search-missing
python tool/catalog_photos.py --download
python tool/audit_catalog_photos.py
python tool/catalog_photos.py --optimize
python tool/catalog_photos.py --apply
python tool/review_catalog_photos.py
```

Periksa lembar foto di `build/photo-review` sebelum membundel perubahan baru.
Cache API dan foto yang ditolak ada di `build`, tidak dimasukkan dalam APK.
`--discover` membuat ulang daftar kandidat; jangan jalankan untuk sekadar build APK.
Tidak ada pengunduhan foto saat aplikasi dipakai pengguna.

APK hanya membundel folder `assets/plants/catalog/`. Empat foto lama tanpa sumber lisensi sudah dihapus dari direktori induk saat
perapihan. Tes membaca salah satu foto katalog terverifikasi sebagai fixture.

Katalog aktif kini berisi 297 tanaman hias rumah (216 foto, 81 placeholder).
Manifest seluruh sumber dan 710 foto tetap dipertahankan untuk provenansi serta
kompatibilitas koleksi lama. Kebijakan pemilihan katalog tersedia di
`../plantfolio/catalog_scope.json`.

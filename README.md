# myGrovia

Aplikasi Flutter pencatatan penyiraman tanaman. Fitur lokal berjalan sejak pertama
kali dibuka, tanpa login, server laptop, atau konfigurasi akun.

Package Android produksi: `com.rafi.mygrovia`. Nama aplikasi tetap `myGrovia`.

Koleksi dan penyiraman: Flutter -> DatabaseHelper -> SQLite di HP.
Read more: Flutter -> ApiService -> GitHub REST API melalui internet. Jika gagal,
deskripsi bawaan tetap tersedia. Foto Dictionary tetap memakai assets.
Dictionary berisi 297 entri tanaman hias rumah dari kategori Houseplants pada
sumber Plantfolio yang dikunci. 216 entri memiliki foto lokal; 81 memakai
ilustrasi bawaan. Foto yang tidak cocok persis tidak dipaksakan. Foto katalog
lama tetap dibundel agar koleksi yang disimpan sebelum pembaruan tetap tampil.
Koleksi, foto pribadi, dan riwayat disimpan di direktori privat aplikasi.

```powershell
flutter pub get
flutter analyze
flutter test
dart run tool/check_api.dart
flutter build apk --release
```

APK universal: `build/app/outputs/flutter-apk/app-release.apk` setelah perintah
build di atas. Untuk HP ARM64, gunakan `flutter build apk --release --split-per-abi
--target-platform android-arm64 --no-pub`, hasilnya `app-arm64-v8a-release.apk`
di folder yang sama.

Untuk Play Console, jalankan `flutter build appbundle --release`.
Hasilnya berada di `build/app/outputs/bundle/release/app-release.aab`.

Privacy policy tersedia offline melalui menu Dictionary. Teksnya berada di
`assets/data/privacy_policy.json`. Jalankan `python tool/generate_privacy_page.py`
untuk memperbarui `privacy/index.html` dari teks yang sama. Workflow GitHub Pages
memublikasikan hanya folder `privacy/`; aktifkan sumber GitHub Actions di pengaturan Pages.

Build release memerlukan keystore milik pengembang dan `android/key.properties`.
Contoh format tersedia di `android/key.properties.example`. Kedua file privat
tersebut tidak disertakan di repo; gunakan key yang sama untuk pembaruan APK.

`dart run tool/check_api.dart` memanggil GitHub REST API dan menampilkan URL,
status HTTP serta contoh respons. Laporan di `build/` dan `docs/` disimpan lokal.

- [Sumber dan lisensi katalog/foto](third_party/plantfolio/ATTRIBUTION.md)
- [Atribusi foto Wikimedia dan cara memperbaruinya](third_party/catalog_photos/README.md)

Python hanya dipakai bila ingin memperbarui bahan katalog dari GitHub dengan
`python tool/seed_catalog.py`. APK tidak menjalankan Python. Read more menghubungi GitHub REST API;
Wikipedia tidak dipakai. Kode runtime berada di `lib/`, pengujian di `test/`, dan alat
persiapan katalog/build di `tool/`. Catatan pribadi dan folder `docs/` tidak
disertakan di repo.

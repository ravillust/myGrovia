# myGrovia

Proyek Flutter PAPB: katalog tanaman, koleksi demo, dan pencatatan penyiraman.
Katalog mengambil dataset Plantfolio melalui HTTPS. Foto tersedia dalam assets.
Tidak membutuhkan backend lokal atau API key. Perangkat membutuhkan internet.

```powershell
flutter pub get
flutter run
```

Untuk APK: `flutter build apk --release`.

- [Konteks untuk laptop teman dan GPT](CATATAN_UNTUK_GPT.md)
- [Penjelasan HTTP GET dan cara tes](docs/API_MINGGU_INI.md)
- [Atribusi data Plantfolio — CC BY-NC-SA 4.0](third_party/plantfolio/ATTRIBUTION.md)

Koleksi, bookmark, dan riwayat masih di RAM; belum tersimpan setelah aplikasi dimulai ulang.

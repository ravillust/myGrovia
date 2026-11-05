# Konteks terbaru myGrovia untuk GPT di laptop teman

Diperbarui 5 November 2026. Prioritas: membantu mahasiswa menjalankan aplikasi
untuk presentasi PAPB, bukan mengubah desain atau mengganti sumber data lagi.

## Keputusan yang berlaku sekarang

- Flutter/Dart mengambil dataset Plantfolio dari GitHub melalui satu HTTP GET HTTPS.
- Tidak memakai backend sendiri atau SQLite server.
- Read more kembali memakai REST API Wikipedia untuk ringkasan tambahan. Ini
  integrasi REST API yang didemokan; Plantfolio tetap dataset JSON statis.
- Backend Python/SQLite sudah dihapus atas permintaan pengguna karena tidak dipakai.
- Tidak perlu Python, adb reverse, API_BASE_URL, API key, atau hosting sendiri.
- Aplikasi membutuhkan internet saat memuat katalog. Belum ada cache permanen.
- Foto tetap di assets/plants. Katalog menampilkan empat tanaman yang sudah dikenal.
- Koleksi awal masih demo melalui createSampleCollection(catalog); koleksi,
  bookmark, dan riwayat penyiraman masih di RAM, hilang/reset saat aplikasi dimulai ulang.
- Belum ada login/register atau penyimpanan pengguna permanen.

## Menjalankan di laptop teman

Clone/pull repository, buka folder yang berisi pubspec.yaml, kemudian:

```powershell
flutter pub get
flutter devices
flutter run
```

Jika beberapa perangkat tersedia, pilih dengan flutter run -d ID_PERANGKAT.
HP perlu USB debugging untuk instalasi/debug saja. Setelah APK terpasang, akses
katalog memakai internet HP dan tidak memerlukan kabel USB atau server laptop.
Hentikan aplikasi lama dan jalankan ulang, bukan hanya hot reload, ketika berpindah
dari versi backend sebelumnya. Pastikan perangkat dapat membuka raw.githubusercontent.com.

pubspec.yaml meminta Dart ^3.13.2. Periksa flutter --version / flutter doctor
jika SDK laptop teman belum cocok. Jangan menyalin path SDK laptop asal.
Konfigurasi .vscode/launch.json sudah kembali sederhana, tanpa dart-define.

Build APK:

```powershell
flutter build apk --release
```

Output: build/app/outputs/flutter-apk/app-release.apk. Gunakan hasil build terbaru;
APK yang dibuat sebelum migrasi mungkin masih mengarah ke server laptop.

## Sumber data dan batasnya

Repository: https://github.com/Luminoid/plantfolio-common-plants
URL GET yang dipakai (dikunci ke satu commit untuk konsistensi presentasi):

```text
https://raw.githubusercontent.com/Luminoid/plantfolio-common-plants/bbb364534cfbca28168085897ac9f2ff00a151a5/dist/common_plants.json
```

Ini adalah dataset JSON statis yang diambil melalui HTTP GET, bukan REST API
dinamis dengan endpoint pencarian/tambah/hapus. Jelaskan dengan jujur saat presentasi.
Responsnya array besar dengan baris metadata di awal. Flutter memilih empat ID:

| ID sumber | Nama di aplikasi | summerInterval |
|---|---|---|
| swiss-cheese-plant | Monstera Deliciosa | 7 |
| calathea-orbifolia | Calathea Orbifolia | 4 |
| snake-plants | Snake Plant | 14 |
| golden-pothos | Golden Pothos | 7 |

Deskripsi, careTips, lightPreference, temperaturePreference, dan summerInterval
berasal dari sumber online. Nama tampilan/nama ilmiah, lokasi aset foto, dan label
filter Easy care/Low light ditentukan di aplikasi untuk empat tanaman tersebut.
Beberapa entri sumber mencakup kelompok tanaman, bukan hanya satu spesies.

summerInterval dipakai sebagai perkiraan awal demo, bukan ramalan musim Indonesia
atau jadwal pasti. UI mengatakan About every ... days; pengguna tetap memeriksa
tanah. Dokumentasikan perubahan/penyesuaian data, jangan mengaku semuanya berasal
persis dari field API. Lisensi CC BY-NC-SA 4.0; atribusi tersedia di My space →
Plant data source dan third_party/plantfolio/. Jangan menghapus atribusi itu.

## Alur kode yang perlu dipahami

1. HomePage.initState() → loadPlants().
2. loadPlants() → apiService.getPlants().
3. lib/services/api_service.dart: client.get() adalah kode hit HTTP.
4. jsonDecode() membaca respons; loop memilih empat ID, melewati metadata/tanaman lain.
5. lib/model/plant.dart: Plant.fromJson() memetakan field sumber ke objek Plant.
6. setState() di HomePage menyimpan katalog dan memperbarui tampilan.
7. DictionaryPage menerima katalog; pencarian/filter lokal atas hasil yang sudah diterima.
8. Detail menerima objek Plant yang dipilih, tanpa request tambahan.

Jika Read more ditekan: showPlantInformation() membuka PlantInformationDialog.
initState dialog menjalankan loadDescription() → ApiService.getPlantDescription().
Fungsi ini GET https://en.wikipedia.org/api/rest_v1/page/summary/{nama_ilmiah},
memeriksa status dan type standard, lalu mengembalikan extract. Ringkasan Wikipedia
ditampilkan terpisah, bukan mengganti deskripsi katalog. Ada loading, Try again,
pengecekan mounted, dan tombol Source: Wikipedia untuk atribusi.

Loading berupa tulisan. Error/timeout menampilkan pesan dan Try again, bukan
katalog fallback palsu. Pindah tab tidak mengirim request ulang selama HomePage hidup.
Tidak ada singleton, provider, BLoC, atau sistem cache tambahan.

## Thunder Client

New Request → GET → paste URL HTTPS di atas → Send. Body kosong, tanpa Auth/API key.
Header Accept: application/json opsional. Respons sukses 200 berisi array; cari
calathea-orbifolia untuk memperlihatkan salah satu tanaman. Tidak perlu impor
collection Postman; versi JSON collection yang tersedia hanya artefak opsional.

Untuk demo REST API, gunakan GET berikut di Thunder Client:
https://en.wikipedia.org/api/rest_v1/page/summary/Monstera_deliciosa
Body kosong dan No Auth. Headers: Accept: application/json dan
Api-User-Agent: myGroviaStudentProject/0.1 (educational plant app).
Respons 200 berupa objek JSON; field extract ditampilkan oleh Read more.
Uji langsung lewat Dart: dart run tool/check_wikipedia_api.dart.

## Pemeriksaan dan troubleshooting

```powershell
flutter test --no-pub
dart analyze lib test tool
dart run tool/check_plant_api.dart
```

Tes Flutter memakai fixture yang dipotong dari data asli, bukan koneksi internet.
Perintah Dart terakhir benar-benar menghubungi dataset online. Jika aplikasi gagal:
cek koneksi HP, akses domain raw.githubusercontent.com, dan Try again. Jangan
menghidupkan backend Python atau mengatur 10.0.2.2 lagi: itu versi yang sudah dibuang.

Verifikasi katalog sebelumnya di laptop asal: 15 tes Flutter berhasil, analyzer bersih,
skrip Dart menerima empat tanaman dari Plantfolio, dan APK release berhasil
dibangun serta dipasang di HP. Keempat tanaman terlihat pada APK release tanpa
penerusan port tcp:8000. Tetap periksa akses internet di perangkat presentasi.

Setelah Read more ditambahkan kembali: 18 tes Flutter berhasil dan ringkasan
Wikipedia keempat tanaman berhasil diambil melalui kode Dart. APK release telah
dibangun ulang; instal ulang APK terbaru untuk melihat tombol tersebut.

## Preferensi pengguna

Kode harus sederhana dan mudah dipahami pemula, walaupun lebih panjang. Gunakan
Row, Column, Container, SizedBox, if, for, setState, dan Navigator. Jelaskan dalam
bahasa Indonesia sederhana dengan contoh aplikasi. Materi awal dosen: Scaffold,
AppBar, Stateless/Stateful, layout, controller, scroll/overflow. async/await,
JSON, exception, dan factory adalah tambahan yang perlu dijelaskan, bukan diklaim
semua sudah diajarkan. Latihan live coding dilakukan nanti saat diminta.

Pertahankan desain yang sudah disetujui: Plus Jakarta Sans, latar #FAF9F6,
hijau #2F7255, menu bawah ikon saja, tanpa dekorasi atau teks tambahan yang tidak perlu.

## Catatan Git dan panduan lama

Pengguna sebelumnya meminta push, lalu menghentikannya untuk membahas perubahan.
Jangan menganggap sudah di-commit atau di-push; periksa git status dan remote.
Pastikan lib/, assets/, test/, third_party/, docs/, konfigurasi Android,
pubspec.yaml/lock, dan catatan ini ikut terbawa saat push disetujui/dilanjutkan.
Jangan ikut mengubah penghapusan mailmap.txt atau pengaturan workspace Postman
yang tidak terkait tanpa memeriksa maksudnya.

docs/API_MINGGU_INI.md menjelaskan implementasi aktif. Panduan belajar panjang
memiliki bab historis; contoh lokasi file Wikipedia, plantDictionary, dan backend dari versi
lama tidak berlaku sebagai alur aktif. Selalu periksa kode terkini.

## Kalimat presentasi

“Saya mengambil data tanaman dari dataset Plantfolio di GitHub melalui HTTP GET.
Respons JSON saya ubah menjadi List<Plant> dan pilih empat tanaman untuk katalog.
Deskripsi dan informasi perawatan berasal dari sumber online, sedangkan foto
dan label katalog masih dari aplikasi. Data yang sama digunakan di detail.
Ada loading dan tombol coba lagi jika koneksi gagal.”

“Untuk integrasi REST API, tombol Read more mengambil ringkasan dari API Wikipedia
berdasarkan nama ilmiah tanaman. Field extract ditampilkan dalam dialog.”

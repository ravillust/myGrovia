# Pengambilan katalog Plantfolio — implementasi aktif

## REST API untuk presentasi: Read more Wikipedia

Selain katalog JSON statis di bawah, aplikasi kini juga memanggil REST API:

```text
GET https://en.wikipedia.org/api/rest_v1/page/summary/Monstera_deliciosa
```

Di Thunder Client pilih GET, Body kosong, No Auth, header Accept: application/json
dan Api-User-Agent: myGroviaStudentProject/0.1 (educational plant app). Status 200
berarti sukses. Field extract adalah ringkasan yang ditampilkan.

Alur: Read more di PlantDetailPage → showPlantInformation → PlantInformationDialog
→ initState → loadDescription → ApiService.getPlantDescription → client.get().
Nama ilmiah menentukan artikel. Request hanya dibuat saat dialog dibuka/retry,
bukan saat build atau membuka detail. Kesalahan ditampilkan dengan Try again;
respons terlambat tidak memperbarui dialog yang sudah ditutup. Sumber dan lisensi
Wikipedia bisa dibuka melalui Source: Wikipedia, tanpa tombol salin.

Perintah uji nyata: dart run tool/check_wikipedia_api.dart.

Penjelasan dosen: “Katalog mengambil dataset JSON statis Plantfolio. Integrasi
REST API berada di Read more yang mengambil extract dari API Wikipedia.”

Flutter mengambil satu dataset JSON melalui HTTPS, bukan server laptop:

```text
GET https://raw.githubusercontent.com/Luminoid/plantfolio-common-plants/bbb364534cfbca28168085897ac9f2ff00a151a5/dist/common_plants.json
```

Tidak perlu API key, Python, database server, adb reverse, atau dart-define.
Cukup flutter pub get dan flutter run, dengan internet pada perangkat.
Ini JSON statis online, bukan REST API dinamis. GitHub menyediakan hosting file.

## Fungsi tiap file

- lib/services/api_service.dart: URL, HTTP GET, pemeriksaan respons, pemilihan empat ID.
- lib/model/plant.dart: Plant.fromJson membaca field sumber dan memberi label/foto lokal.
- lib/pages/home_page.dart: initState → loadPlants → getPlants → setState.
- lib/pages/dictionary_page.dart: pencarian/filter pada katalog hasil GET.
- lib/pages/plant_detail_page.dart: menampilkan data yang diterima, tanpa request baru.
- lib/pages/profile_page.dart: dialog atribusi Plantfolio dan penjelasan adaptasi data.

## Dari mana datanya?

| Data aplikasi | Asal |
|---|---|
| Deskripsi | description dari Plantfolio |
| Tips perawatan | careTips dari Plantfolio; disimpan dalam model |
| Cahaya | lightPreference, diubah menjadi label yang mudah dibaca |
| Suhu | temperaturePreference [min, max] |
| Perkiraan penyiraman | summerInterval |
| Nama tampilan/nama ilmiah | Label lokal untuk empat pilihan |
| Foto | assets/plants di Flutter |
| Easy care / Low light | Label filter lokal, bukan field kesulitan Plantfolio |
| Koleksi/riwayat | Demo di RAM, belum penyimpanan permanen |

ID pilihan: swiss-cheese-plant, calathea-orbifolia, snake-plants, golden-pothos.
Dua entri sumber, yaitu swiss-cheese-plant dan snake-plants,
dapat mencakup beberapa spesies/varietas dalam sumber. myGrovia memberi label
spesies yang digunakan oleh katalog dan foto lokal.

summerInterval adalah pilihan perkiraan awal demo dari interval musiman sumber.
Bukan jadwal pasti untuk iklim/lokasi pengguna. Tampilan memakai About every ...
days dan tetap mengingatkan memeriksa tanah pada halaman koleksi.

## Uji dan demo

Di Thunder Client: New Request → GET → URL di atas → Send. Body kosong dan No Auth.
Jika sukses: 200 OK dan array JSON. Entri pertama metadata, bukan tanaman.
Cari calathea-orbifolia untuk melihat description, summerInterval: 4, dan suhu.

```powershell
dart run tool/check_plant_api.dart
flutter test --no-pub
dart analyze lib test tool
```

Skrip Dart menghubungi internet, sedangkan tes Flutter memakai respons tiruan dari
cuplikan dataset asli. Tes mencakup metadata, urutan empat tanaman, field invalid,
tanaman hilang, timeout, retry, navigasi, dan layout layar kecil/landscape.

## Sumber dan lisensi

Plantfolio Common Plants © 2026 Luminoid:
https://github.com/Luminoid/plantfolio-common-plants

CC BY-NC-SA 4.0: https://creativecommons.org/licenses/by-nc-sa/4.0/
Atribusi dan perubahan dijelaskan di third_party/plantfolio/ATTRIBUTION.md serta
My space → Plant data source. Cuplikan dataset dan data adaptasinya mengikuti
lisensi yang sama. Foto aplikasi terpisah dari dataset ini.

URL menggunakan commit tertentu agar struktur/nilai tidak berubah saat presentasi.
Backend Python/SQLite sudah dihapus. Wikipedia dipakai kembali hanya untuk Read more.

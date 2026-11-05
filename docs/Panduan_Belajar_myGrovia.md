# Belajar kode myGrovia, pelan-pelan

CATATAN 21 OKTOBER 2026: Dokumen ini menjelaskan versi lama. Untuk kode yang sudah disederhanakan, gunakan Panduan_Kode_Sederhana_myGrovia.html. Versi terbaru tidak memakai Sliver, IndexedStack, ValueKey, dan validasi Form seperti yang dijelaskan di bawah.

Panduan untuk proyek PAPB • Berdasarkan kode yang dibaca pada 19 Oktober 2026.

Dokumen ini bisa dibaca tanpa internet. Gunakan daftar isi untuk berpindah bab dan Ctrl+F untuk mencari istilah. Jika ingin versi PDF, buka dokumen HTML di browser, tekan Ctrl+P, lalu pilih Save as PDF. Latihan live coding belum dimasukkan: kita lakukan bersama setelah kamu selesai mempelajari kode.

Tujuannya bukan menghafal semua tanda. Pahami dulu: data apa yang disimpan, apa yang terjadi ketika tombol ditekan, dan bagian mana yang menampilkan hasilnya. Baca satu subbagian, cocokkan dengan aplikasi, lalu lanjut. Tidak perlu menamatkan satu bab sekali duduk.

Potongan kode yang bertuliskan “bentuk sederhana” atau mengandung komentar pengganti isi hanya untuk menjelaskan. Jangan menimpa file proyek dengan potongan itu. Kode lengkap proyek saat dokumen dibuat tersedia pada lampiran HTML di akhir dokumen.

## 1. Bekal membaca kode

### Variabel adalah tempat menyimpan nilai

```dart
int selectedTab = 0;
```

Bacanya: siapkan tempat bernama selectedTab untuk menyimpan bilangan bulat. Isi awalnya 0. Ketika nilainya diganti menjadi 1, isi lamanya diganti, bukan ditambah menjadi daftar.

String menyimpan teks seperti 'Bedroom'. int menyimpan bilangan bulat seperti 3. double bisa menyimpan pecahan seperti 1.5. bool hanya menyimpan true atau false, yaitu benar atau salah.

```dart
selectedTab = 1;
selectedTab == 1;
```

Satu tanda = mengisi nilai. Dua tanda == memeriksa apakah nilainya sama. Baris kedua menghasilkan benar atau salah; tidak mengganti nilai selectedTab.

### Fungsi adalah perintah yang diberi nama

Misalnya fungsi addPlant bertugas menambahkan tanaman. Agar bisa bekerja, fungsi itu membutuhkan informasi tanaman dan lokasi. Informasi yang diterima fungsi disebut parameter.

```dart
void addPlant(Plant plant, String room) {
  // Perintah menambahkan tanaman.
}
```

void berarti fungsi ini tidak mengembalikan hasil untuk dipakai pemanggilnya. Ini tidak berarti fungsi tidak melakukan apa-apa. Ia bisa mengubah daftar tanaman.

```dart
onPressed: addToCollection,
```

Baris ini memberikan fungsi untuk dijalankan nanti saat tombol ditekan. Berbeda dengan addToCollection() yang langsung memanggil fungsi. Tanda kurung penting.

### Kurung dan tanda yang sering muncul

Kurung biasa () dipakai pada pemanggilan fungsi dan daftar parameter. Kurung kurawal {} bisa membungkus kumpulan perintah. Kurung siku [] dipakai untuk daftar, misalnya daftar tanaman atau children. Titik koma ; menutup pernyataan. Koma memisahkan parameter atau anggota daftar.

```dart
onPressed: () {
  setState(() {
    selectedTab = 1;
  });
},
```

() { ... } di sini adalah fungsi tanpa nama. Kita menuliskan langsung perintahnya di tempat yang membutuhkan fungsi. Bacanya: ketika ditekan, ganti tab menjadi 1 dan minta tampilan diperbarui.

```dart
onPressed: () => setState(() => selectedTab = 1),
```

Ini versi singkat dengan perilaku yang sama. => dipakai untuk fungsi yang hanya memiliki satu ekspresi. Kalau versi singkat membingungkan, bayangkan bentuk panjangnya dulu.

### if, else, dan pilihan dua nilai

```dart
if (selectedTab == 1) {
  // Lakukan jika tab yang aktif nomor 1.
} else {
  // Lakukan jika bukan nomor 1.
}
```

if berarti jika. else berarti kalau tidak. Bentuk pilihan singkatnya dapat terlihat seperti ini:

```dart
selectedTab == index ? plantGreen : mutedText
```

Bacanya: jika nomornya sama, pilih hijau; kalau tidak, pilih abu-abu. Tanda && berarti dan, || berarti atau, dan ! di depan boolean berarti membalik benar menjadi salah atau sebaliknya.

### null, final, dan const

null berarti tidak ada nilai. String? boleh berisi teks atau null. Tanda ? pada tipe tidak berarti kalimat tanya.

final berarti variabel hanya diisi sekali. Jika isinya daftar, anggota daftar masih bisa ditambah atau dihapus. Yang tidak boleh adalah mengarahkan variabel final itu ke daftar lain.

const dipakai untuk nilai konstan. Daftar const tidak bisa diubah isinya. Widget const memiliki konfigurasi konstan, tetapi jangan mengartikannya sebagai “seluruh layar tidak pernah bisa berubah”.

### Widget dan state

Widget adalah bagian penyusun tampilan: tulisan, gambar, tombol, atau satu halaman penuh. State adalah nilai yang sedang diingat oleh tampilan, misalnya tab aktif atau ruangan yang dipilih.

StatelessWidget tidak mengelola objek State sendiri. Ia tetap bisa menampilkan data terbaru ketika induknya membangun ulang dengan data baru. StatefulWidget memiliki State untuk menyimpan kondisi yang berubah.

setState memberi tahu Flutter bahwa tampilan perlu dibangun ulang. Bukan setState yang otomatis memilih halaman atau menyimpan data ke database; perintah di dalamnya dan widget yang membaca datalah yang menentukan hasilnya.

## 2. Peta file dan alur aplikasi

```text
main.dart → HomePage
              ├─ DictionaryPage → PlantDetailPage → RoomSelectionSheet
              ├─ CollectionPage → CollectionDetailPage → WateringDialog
              └─ ProfilePage (judul di layar: My space)
```

model/plant.dart berisi bentuk data dan data demo. widgets/plant_widgets.dart berisi komponen bersama. pubspec.yaml mendaftarkan font, gambar, serta paket yang digunakan. Folder test memeriksa aplikasi secara otomatis; bukan halaman aplikasi.

Saat ini data koleksi, bookmark, dan penyiraman disimpan di memori aplikasi. Belum ada login, database, atau backend. Setelah aplikasi benar-benar dijalankan ulang, data demo dibuat kembali. Hot reload umumnya mempertahankan state, sehingga perilakunya berbeda dengan restart.

## 3. main.dart — pintu masuk aplikasi

### Aplikasi dimulai di sini

```dart
void main() {
  runApp(const MyGroviaApp());
}
```

main adalah fungsi pertama yang dijalankan. runApp meminta Flutter menampilkan widget utama, yaitu MyGroviaApp. Import material.dart di atasnya menyediakan komponen Flutter. Import home_page.dart menyediakan halaman utama. Import plant_widgets.dart menyediakan warna bersama yang dipakai tema.

MyGroviaApp memakai StatelessWidget karena tugasnya mengatur aplikasi, bukan menyimpan pilihan menu. Constructor const MyGroviaApp({super.key}) adalah cara membuat objeknya. super.key meneruskan tanda pengenal widget ke kelas induk Flutter.

### build menjelaskan tampilan

```dart
Widget build(BuildContext context) {
  return MaterialApp(
    // Pengaturan aplikasi.
    home: const HomePage(),
  );
}
```

Bacanya: fungsi build menghasilkan widget MaterialApp. return mengembalikan hasil itu. context adalah informasi posisi widget dalam susunan aplikasi; nanti digunakan untuk mengambil tema atau membuka halaman. @override menandai bahwa kita mengisi metode yang disediakan kelas induk.

MaterialApp mengatur aplikasi secara keseluruhan. home menentukan halaman pertama. title memberikan judul untuk keperluan sistem, bukan otomatis menulis judul di layar. debugShowCheckedModeBanner: false menyembunyikan pita DEBUG; tidak mengubah aplikasi menjadi mode release.

### Tema adalah pengaturan tampilan bersama

```dart
fontFamily: 'PlusJakartaSans',
scaffoldBackgroundColor: const Color(0xfffaf9f6),
```

Font dasar sekarang Plus Jakarta Sans. Latar halaman berwarna putih hangat. Nama font harus cocok dengan yang terdaftar di pubspec.yaml.

colorScheme membuat kumpulan warna dasar. fromSeed mengambil warna awal, sedangkan copyWith menyalin pengaturan sambil mengganti beberapa nilai. primary diatur ke plantGreen. surface menjadi putih. surfaceTint transparan supaya permukaan tertentu tidak mendapat lapisan warna tambahan.

textTheme menyediakan gaya judul dan tulisan. headlineMedium, headlineSmall, dan titleLarge diatur tebal. labelLarge diatur semibold. Halaman mengambilnya melalui Theme.of(context).textTheme. FontWeight.w700 berarti bold; w600 semibold; w400 regular.

dialogTheme mengatur dialog putih dengan sudut membulat. appBarTheme mengatur warna bagian atas halaman. inputDecorationTheme mengatur kolom input: filled mengaktifkan latar, fillColor menentukan warnanya, contentPadding memberi jarak di dalam input.

focusedBorder adalah garis ketika input sedang aktif. enabledBorder adalah garis ketika input bisa dipakai tetapi tidak aktif. OutlineInputBorder membuat garis mengelilingi input. BorderRadius.circular mengatur kelengkungan sudut. BorderSide mengatur warna dan ketebalan garis.

chipTheme mengatur bentuk dasar tombol filter. Pengaturan langsung pada sebuah ChoiceChip bisa menggantikan pengaturan tema. useMaterial3 mengaktifkan komponen Material 3.

Yang perlu kamu pahami: main menjalankan aplikasi, MyGroviaApp mengatur tampilannya secara umum, HomePage mengatur menu dan data bersama.

## 4. home_page.dart — menu dan data bersama

### Menyimpan menu yang dipilih

```dart
int selectedTab = 0;
```

0 berarti Plant dictionary, 1 My collection, dan 2 My space. Nomor daftar di Dart dimulai dari 0. Variabel ini berada di dalam kelas State, di luar build, sehingga tidak kembali menjadi 0 setiap build dijalankan.

```dart
setState(() {
  selectedTab = 1;
});
```

Bacanya: pilih nomor 1 lalu minta Flutter memperbarui tampilan. IndexedStack membaca nomor tersebut melalui index: selectedTab. Anak nomor 1 adalah CollectionPage, maka itulah yang terlihat.

IndexedStack mempertahankan halaman lainnya dalam susunan widget meskipun hanya satu ditampilkan. Ini membantu pencarian tetap ada ketika berganti tab. Scaffold menyediakan tempat isi halaman dan navigasi bawah. SafeArea menjaga isi dari area sistem seperti notch.

### Membuat tiga tombol dari satu fungsi

```dart
navigationButton(1, Icons.local_florist_outlined, 'My collection')
```

Bacanya: buat tombol tujuan nomor 1, dengan gambar bunga dan keterangan My collection. Fungsi navigationButton menerima ketiganya sebagai index, icon, dan label. Fungsi mengembalikan Widget, yaitu tampilan tombol.

```dart
onPressed: () => setState(() => selectedTab = index),
color: selectedTab == index ? plantGreen : mutedText,
```

index adalah nomor milik tombol itu. selectedTab adalah nomor yang sedang dipilih. Saat ditekan, nomor tombol disalin ke selectedTab. Jika keduanya sama, ikon berwarna hijau; selain itu abu-abu.

Row menyusun ketiga tombol ke samping. Expanded memberi masing-masing bagian lebar yang sama. Center menaruh tombol di tengah bagian tersebut. Tinggi area menu adalah 80, ukuran tombol 52 × 52, dan ukuran gambar ikon 30. Bagian lebar menu, area tekan tombol, dan ukuran gambar ikon adalah tiga hal berbeda.

tooltip menampilkan keterangan, misalnya ketika tombol ditekan lama. Semantics(selected: ...) memberi tahu pembaca layar tombol mana yang aktif. Material transparan dengan CircleBorder dan clipBehavior membatasi efek tekan pada lingkaran tombol. Tidak ada bulatan berwarna permanen ketika tombol diam.

### Daftar koleksi dan bookmark

```dart
final plants = createSampleCollection();
final Set<String> bookmarks = {};
bool savedPlantsOnly = false;
int dictionaryVisit = 0;
```

plants menerima tiga tanaman demo. bookmarks menyimpan kumpulan nama tanaman tanpa duplikat. savedPlantsOnly menentukan apakah kamus hanya menampilkan bookmark. dictionaryVisit membantu mereset pencarian saat membuka Saved plants dari My space.

Data disimpan di HomePage karena diperlukan beberapa halaman. Koleksi menampilkan daftar, kamus memeriksa tanaman yang sudah ditambah, dan My space menghitung jumlah. Semuanya menggunakan sumber yang sama.

### Memberikan data dan perintah ke halaman lain

```dart
CollectionPage(
  plants: plants,
  onBrowse: () => setState(() => selectedTab = 0),
  onChanged: () => setState(() {}),
)
```

plants di sebelah kiri adalah nama parameter penerima. plants di sebelah kanan adalah daftar dari HomePage. Nama sama tidak berarti ada dua daftar baru.

onBrowse adalah perintah titipan: ketika tombol + ditekan, buka tab 0. Perintah yang diberikan untuk dijalankan nanti disebut callback. onChanged meminta tampilan induk diperbarui setelah data sudah berubah di bagian lain. Itulah alasan setState-nya kosong: perubahan data telah dilakukan lebih dahulu.

### Menambahkan tanaman

```dart
void addPlant(Plant plant, String room) {
  setState(() {
    plants.add(
      CollectionPlant(
        plant: plant,
        room: room,
        added: DateTime.now(),
        history: [],
      ),
    );
    selectedTab = 1;
  });
}
```

Contohnya pengguna memilih Golden Pothos dan Bedroom. CollectionPlant membuat data yang menggabungkan tanaman, lokasi, waktu sekarang, dan riwayat kosong. plants.add memasukkan data itu ke daftar. selectedTab = 1 membuka My collection. Membuat satu objek berbeda dengan memasukkannya ke daftar.

DictionaryPage menerima onAdd: addPlant. Ini memberikan fungsi, bukan langsung menjalankannya. Fungsi baru dipanggil setelah pengguna mengonfirmasi lokasi.

### Menyimpan dan membatalkan bookmark

Kode proyek memakai bentuk singkat:

```dart
if (!bookmarks.add(plant.name)) bookmarks.remove(plant.name);
```

Set.add menghasilkan true jika nama baru ditambahkan, atau false jika nama sudah ada. Tanda ! membalik hasilnya. Jadi nama yang sudah ada akan dihapus. Bentuk yang lebih mudah dibaca dengan perilaku sama:

```dart
if (bookmarks.contains(plant.name)) {
  bookmarks.remove(plant.name);
} else {
  bookmarks.add(plant.name);
}
```

contains memeriksa keberadaan nama; remove menghapus; add menambahkan. Menghapus bookmark tidak menghapus tanaman dari koleksi karena keduanya disimpan terpisah.

### Membuka Saved plants dari My space

```dart
void openSavedPlants() {
  setState(() {
    savedPlantsOnly = true;
    dictionaryVisit++;
    selectedTab = 0;
  });
}
```

Aktifkan mode bookmark, tambah nomor kunjungan satu, lalu buka tab kamus. Nomor kunjungan dipakai pada key: ValueKey(dictionaryVisit). Ketika key berubah, Flutter mengganti state halaman kamus sehingga pencarian dan filter lokal kembali ke awal. Bookmark tetap ada di HomePage, jadi tidak ikut hilang.

onSavedOnlyChanged menerima true atau false dari kamus dan menyimpannya ke savedPlantsOnly melalui setState. Ini mengganti cara daftar ditampilkan, bukan menghapus bookmark.

ProfilePage menerima plants, savedCount: bookmarks.length, perintah membuka tab 1, dan openSavedPlants. .length menghitung jumlah anggota. HomePage tidak memakai async/await; perubahan datanya berlangsung langsung.

## 5. profile_page.dart — My space

### Menerima data

ProfilePage memakai StatelessWidget. Walaupun angka bisa berubah, halaman ini tidak mengelola daftar sendiri. HomePage memberikan data terbaru ketika membangun ulang tampilan.

```dart
final List<CollectionPlant> plants;
final int savedCount;
final VoidCallback onOpenCollection;
final VoidCallback onOpenSavedPlants;
```

plants adalah daftar koleksi. savedCount adalah jumlah bookmark. VoidCallback berarti fungsi yang tidak menerima parameter dan tidak mengembalikan nilai. Kedua callback membuka halaman lain. required pada constructor berarti informasi itu wajib diberikan. this.plants memasukkan nilai yang diterima ke properti plants milik objek ini.

### Susunan halaman

ListView menyusun konten ke bawah dan bisa digulir. PageHeading menampilkan My space. Padding dengan EdgeInsets.all(24) memberi jarak 24 di empat sisi. Di dalamnya, Column menyusun tiga baris. child menerima satu widget, sedangkan children menerima daftar widget.

### Baris Plants in collection

```dart
ListTile(
  onTap: onOpenCollection,
  contentPadding: EdgeInsets.zero,
  leading: const Icon(Icons.local_florist_outlined, color: plantGreen),
  title: const Text('Plants in collection'),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('${plants.length}'),
      const SizedBox(width: 12),
      const Icon(Icons.chevron_right, size: 20, color: mutedText),
    ],
  ),
)
```

ListTile menyediakan tempat ikon kiri (leading), tulisan utama (title), dan bagian kanan (trailing). onTap membuat seluruh baris bisa ditekan. Panah hanya petunjuk; bukan panah saja yang menerima tekanan.

plants.length menghitung tanaman. ${...} memasukkan hasil perhitungan ke teks. Row mengatur angka dan panah ke samping. SizedBox memberi jarak 12. mainAxisSize.min meminta lebar secukupnya, supaya bagian kanan tidak mengambil seluruh lebar. contentPadding.zero menghapus jarak bawaan karena bagian luar sudah diberi Padding.

### Baris Due for watering

```dart
plants.where((item) => item.daysUntilWatering <= 0).length
```

Bacanya bertahap: ambil daftar tanaman → pilih yang sisa harinya 0 atau negatif → hitung jumlahnya. where menyaring daftar, bukan menghapus tanaman dari daftar asli.

Contoh: Monstera tersisa 6 hari, Calathea 0 hari, Snake Plant 8 hari. Yang lolos hanya Calathea, sehingga angka yang ditampilkan 1. Tanaman tanpa riwayat juga dihitung perlu disiram sesuai aturan demo pada model.

Baris ini tidak memiliki onTap atau panah. Fungsinya hanya menampilkan angka.

### Baris Saved plants

Susunannya sama dengan baris koleksi, tetapi ikon bookmark, tulisan Saved plants, angka Text('$savedCount'), dan onTap: onOpenSavedPlants. $savedCount memasukkan angka ke teks. Divider di antara baris menggambar garis pemisah.

## 6. model/plant.dart — bentuk data

### Plant: informasi umum tanaman

Plant menyimpan name, botanicalName, image, difficulty, light, wateringDays, temperature, description, tip, dan lowLight. Bayangkan satu kartu informasi: nama tanaman, alamat foto, dan kebutuhan perawatannya.

image bertipe String? karena boleh belum mempunyai alamat gambar. wateringDays bertipe int untuk interval hari. lowLight bertipe bool untuk filter Low light. Properti lain berupa teks. Semua properti final sehingga tidak bisa diisi ulang setelah objek dibuat.

Constructor Plant memakai parameter bernama. required this.name berarti nama wajib diberikan. this.difficulty = 'Easy' memberikan nilai awal jika pemanggil tidak menentukannya. this.lowLight = false melakukan hal yang sama untuk lowLight. image tidak wajib; jika tidak diberikan, nilainya null.

Constructor const memungkinkan objek konstan ketika nilainya konstan. Properti tip masih tersimpan meskipun bagian Good to know sudah dihapus dari tampilan.

### WateringEntry: satu kejadian penyiraman

```dart
WateringEntry(DateTime.now(), 'Soil checked before watering', 250)
```

Bacanya: satu catatan penyiraman pada waktu sekarang, dengan catatan tersebut, sebanyak 250 ml. Kelasnya menyimpan date, note, dan milliliters. Constructor menggunakan parameter berdasarkan urutan, sehingga urutannya wajib tanggal, catatan, jumlah air.

### CollectionPlant: tanaman yang dirawat pengguna

CollectionPlant menyimpan plant, room, added, dan history. plant adalah objek Plant yang sudah memiliki nama dan informasi umum. room adalah lokasi milik pengguna. added adalah tanggal penambahan. history adalah List<WateringEntry>, yaitu daftar catatan penyiraman.

item.plant.name berarti buka data tanaman milik item, lalu ambil namanya. item.room langsung mengambil lokasinya. history final tidak melarang penambahan catatan ke daftar; hanya melarang mengganti referensi daftar itu.

### Menghitung kapan perlu disiram

```dart
int get daysUntilWatering {
  if (history.isEmpty) return 0;
  return plant.wateringDays -
      DateTime.now().difference(history.first.date).inDays;
}
```

get membuat nilai yang dihitung ketika dibaca. Pemakaiannya item.daysUntilWatering, tanpa (). Jika daftar riwayat kosong, hasilnya 0. Ini juga mencegah mengambil anggota pertama dari daftar kosong.

history.first mengambil catatan pertama. Kode mengandalkan catatan terbaru berada paling atas. difference menghitung selisih waktu; inDays mengambil jumlah hari penuh. Misalnya interval 7 hari dan terakhir disiram 3 hari lalu: 7 − 3 = 4 hari tersisa.

Nilai negatif berarti interval sudah terlewati. Nilai 0 juga digunakan untuk tanaman tanpa riwayat. Ini aturan aplikasi demo, bukan pemeriksaan kondisi tanah sebenarnya. inDays menghitung durasi hari penuh, bukan sekadar tanggal berganti. Getter tidak membuat timer; hasil dihitung ulang saat dibaca.

### Menghasilkan tulisan status

```dart
if (history.isEmpty || daysUntilWatering <= 0) return 'Due today';
```

Jika riwayat kosong atau sisa hari 0/negatif, tampilkan Due today. Jika belum jatuh tempo, kode menghitung hari sejak disiram. 0 menghasilkan Watered today; 1 menghasilkan Watered yesterday; lainnya Watered $days days ago. $days diganti dengan angkanya. Kode saat ini tidak membedakan label terlambat dari jatuh tempo hari ini.

### Data contoh

plantDictionary adalah daftar const berisi Monstera, Calathea, Snake Plant, dan Golden Pothos. Daftar ini tidak bisa diubah isinya saat aplikasi berjalan. Calathea menentukan difficulty: 'Moderate'; yang lain memakai nilai default Easy. Snake Plant dan Pothos mempunyai lowLight: true.

createSampleCollection membuat daftar koleksi yang bisa berubah. List.generate(3, ...) menjalankan pembuat data tiga kali dengan index 0, 1, dan 2. plantDictionary[index] mengambil tanaman sesuai urutan. ['Living room', 'Bedroom', 'Home office'][index] mengambil lokasi dengan nomor yang sama.

now.subtract(Duration(days: ...)) membuat tanggal beberapa hari sebelum sekarang. Angka [1, 5, 6][index] menghasilkan penyiraman terakhir 1 hari lalu untuk Monstera, 5 untuk Calathea, dan 6 untuk Snake Plant. Masing-masing punya catatan tambahan 15 dan 24 hari lalu. added memakai 90 hari lalu.

Ini khusus demo. Jika nanti memakai backend, kelas model tetap berguna; daftar contoh diganti data yang diambil dari penyimpanan. Saat ini model/post.dart dan model/api_service.dart tidak berisi implementasi; nama file itu bukan berarti backend sudah aktif.

## 7. widgets/plant_widgets.dart — komponen bersama

### Warna yang dipakai berulang

plantGreen adalah hijau utama, mutedText abu-abu teks sekunder, neutralSurface latar netral, dan warmBrown aksen cokelat. Color(0xff2f7255) menentukan warna: ff berarti tidak transparan, sisanya nilai merah, hijau, biru. Ditaruh bersama agar warna tidak ditulis ulang berbeda-beda.

### PlantPhoto

PlantPhoto menerima plant yang wajib dan height yang opsional. Ini StatelessWidget: ia menampilkan data dari induk, bukan mengubah foto sendiri.

```dart
if (plant.image != null) {
  return Image.asset(
    plant.image!,
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    alignment: const Alignment(0, 0.35),
    semanticLabel: plant.name,
  );
}
```

Jika alamat foto ada, Image.asset membaca gambar lokal. ! setelah image memastikan nilai bukan null, setelah sebelumnya diperiksa. width.infinity meminta lebar penuh yang tersedia dari induk, bukan ukuran layar tanpa batas. BoxFit.cover memenuhi area sambil menjaga proporsi; sebagian gambar dapat terpotong.

Alignment(0, 0.35) menempatkan foto di tengah horizontal dan agak ke bawah secara vertikal. semanticLabel memberi keterangan gambar untuk pembaca layar.

Jika alamat foto null, tampilkan Container netral dengan ikon tanaman dan tulisan Photo coming soon. Center menengahkan isi, Column menumpuk ikon dan tulisan, mainAxisSize.min meminta tinggi secukupnya. Ini belum menangani alamat terisi yang ternyata berkasnya tidak ditemukan.

### PageHeading

PageHeading menerima title dan action opsional. title adalah tulisan; action adalah widget lengkap seperti IconButton. Padding.fromLTRB(24,24,24,20) memberi jarak kiri, atas, kanan, bawah. Row menyusun judul dan action ke samping. Expanded memberi judul ruang tersisa sehingga tombol tetap punya tempat.

```dart
Theme.of(context).textTheme.headlineMedium
    ?.copyWith(fontWeight: FontWeight.w700)
```

Bacanya: ambil gaya judul dari tema, salin dengan ketebalan bold. ?. berarti lakukan hanya jika gaya yang didapat bukan null. Ini berbeda dari ! yang memaksakan bahwa nilai bukan null.

```dart
?action,
```

Di dalam daftar children, bentuk ini hanya memasukkan action jika nilainya tidak null. Maknanya seperti if (action != null) action!. Tidak ada tombol kosong yang wajib dibuat jika halaman hanya butuh judul.

### PrimaryButton

PrimaryButton menerima label, onPressed, dan icon opsional. label adalah teks, onPressed perintah ketika ditekan, icon gambar tambahan. onPressed wajib disebut tetapi nilainya boleh null. Pada FilledButton, null berarti tombol nonaktif.

SizedBox meminta lebar penuh. FilledButton.styleFrom mengatur tinggi minimum 52, padding vertikal 14 dan horizontal 20, serta sudut 10. Tinggi minimum bukan tinggi mutlak; tombol bisa bertambah tinggi jika kontennya membutuhkan.

Row menengahkan ikon dan tulisan. if (icon != null) hanya memasukkan ikon ketika ada. ...[Icon(...), SizedBox(...)] memasukkan dua widget sekaligus ke daftar. Jika ikon tidak ada, jaraknya juga tidak ditambahkan.

Flexible membatasi ruang teks agar bisa membungkus ketika sempit. Expanded memaksa anak mengisi bagian ruang yang diberikan; Flexible mengizinkan anak memakai lebih sedikit dari jatahnya. TextAlign.center menengahkan tulisan. Tombol ini StatelessWidget walaupun bisa ditekan: tindakannya diteruskan ke fungsi yang diberikan halaman pemakai.

## 8. dictionary_page.dart — mencari dan membuka tanaman

### Informasi yang diterima

DictionaryPage menerima collection, bookmarks, savedOnly, serta perintah onAdd, onBookmark, dan onSavedOnlyChanged. ValueChanged<Plant> berarti fungsi menerima satu Plant dan tidak mengembalikan nilai. void Function(Plant, String) menerima tanaman dan lokasi. Semua ini berasal dari HomePage.

Halaman Stateful karena pencarian dan filter berubah. searchController membaca atau mengubah isi kolom pencarian. filter mula-mula All plants. Getter savedOnly hanya meneruskan widget.savedOnly, bukan membuat salinan kondisi baru. Dalam kelas State, widget adalah cara mengakses informasi yang diberikan ke halaman.

### Ketika mode bookmark berubah

didUpdateWidget berjalan ketika induk memberi konfigurasi baru sementara state halaman masih dipertahankan. oldWidget adalah konfigurasi sebelumnya. Jika sebelumnya savedOnly false lalu menjadi true, controller dibersihkan dan filter kembali All plants. Flutter akan membangun ulang setelah metode ini, sehingga tidak perlu setState tambahan di sini.

covariant pada parameter oldWidget berkaitan dengan aturan tipe saat mengganti metode induk. Cukup pahami tujuannya dahulu: menerima konfigurasi DictionaryPage lama untuk dibandingkan. Jangan tertukar dengan ValueKey: key berubah membuat state baru, sedangkan didUpdateWidget memperbarui konfigurasi pada state yang masih sama.

dispose membersihkan searchController saat state benar-benar dibuang, lalu memanggil super.dispose. Berganti tab dalam IndexedStack tidak otomatis membuang halaman.

clearSearch menghapus teks, mengatur filter All plants, dan mematikan savedOnly melalui callback. Jadi tindakan ini mereset seluruh penyaringan, bukan sekadar huruf di input.

### Bookmark kosong

Jika savedOnly benar dan bookmarks kosong, build langsung mengembalikan tampilan No saved plants yet. return menghentikan kelanjutan build pada jalur itu. Tombol Browse all plants menjalankan clearSearch. SliverFillRemaining mengisi sisa area agar isi kosong dapat ditempatkan dengan baik; hasScrollBody:false berarti anaknya bukan area scroll tersendiri.

### Membaca teks pencarian

```dart
final query = searchController.text.trim().toLowerCase();
```

Bacanya: ambil teks, buang spasi awal/akhir, lalu ubah ke huruf kecil. '  MONSTERA  ' menjadi 'monstera'. Spasi di tengah kata tidak semuanya dihapus oleh trim.

```dart
final matchesQuery = '${plant.name} ${plant.botanicalName}'
    .toLowerCase()
    .contains(query);
```

Gabungkan nama dan nama ilmiah lalu periksa apakah mengandung kata pencarian. Jika query kosong, contains('') bernilai true sehingga semua tanaman lolos syarat pencarian.

### Memilih hasil yang sesuai

```dart
final results = plantDictionary.where((plant) {
  // Periksa nama, kategori, dan bookmark.
  return matchesQuery && matchesFilter &&
      (!savedOnly || widget.bookmarks.contains(plant.name));
}).toList();
```

Potongan ini disingkat untuk memperlihatkan alurnya. where memeriksa setiap tanaman. Hanya tanaman dengan hasil true yang ikut results. toList menjadikan hasil penyaringan sebagai daftar yang dapat diakses memakai nomor.

matchesFilter benar jika All plants dipilih, atau Easy care dipilih dan difficulty Easy, atau Low light dipilih dan lowLight true. Semua kelompok syarat digabung dengan &&: nama harus cocok, kategori harus cocok, dan aturan bookmark harus cocok.

!savedOnly || bookmarks.contains(...) berarti: saat bukan mode bookmark, syarat ini otomatis lolos; saat mode bookmark, nama harus tersimpan. Data asli plantDictionary tidak dihapus oleh pencarian.

### Bagian scroll dan input

CustomScrollView menggabungkan judul, pencarian, pesan kosong, dan grid dalam satu scroll vertikal. Sliver adalah bagian yang mengikuti sistem scroll ini. SliverToBoxAdapter memasukkan widget biasa seperti Column ke dalamnya. SliverPadding memberi jarak. Ini tambahan di luar widget dasar kelas, digunakan agar grid dan bagian atas bergulir bersama.

Judul berubah antara Plant dictionary dan Saved plants. Ikon bookmark penuh menunjukkan mode bookmark. Tombol memanggil onSavedOnlyChanged(!savedOnly), yaitu meminta kebalikan nilai sekarang.

TextField memakai searchController. onChanged: (_) => setState(() {}) meminta build ulang setiap pengguna mengubah teks. _ berarti nilai parameter tidak dipakai; teks dibaca dari controller. PrefixIcon adalah ikon awal input. SuffixIcon adalah ikon di ujung; penghapus hanya muncul jika query tidak kosong.

### Filter dan hasil kosong

Daftar All plants, Easy care, Low light diubah menjadi ChoiceChip melalui map. map mengubah anggota menjadi bentuk lain, sedangkan where menyaring anggota. selected: filter == name menentukan chip aktif. onSelected menyimpan nama chip melalui setState. Chip aktif hijau dengan teks putih; showCheckmark:false menyembunyikan centang. Menekan chip aktif tetap mempertahankan kategorinya.

SingleChildScrollView horizontal membolehkan filter digeser jika sempit. Jika results kosong, tampilkan No plants found. Ini berbeda dengan belum punya bookmark: di sini kombinasi penyaring tidak menemukan hasil.

Wrap menyusun saran Pothos, Calathea, Snake Plant dan memindahkannya ke baris baru jika sempit. Menekan saran mengisi input, mengatur All plants, dan mematikan mode bookmark.

### Menampilkan kartu

SliverLayoutBuilder membaca lebar yang tersedia. Lebar kurang dari 340 menghasilkan satu kolom, selain itu dua. Ini lebar area grid setelah pengaruh padding, bukan langsung seluruh lebar layar. Jarak antarbaris dan kolom 16.

mainAxisExtent menentukan tinggi kartu: 286 ditambah penyesuaian ukuran teks melalui MediaQuery.textScalerOf(context).scale(60) - 60. Angka 60 adalah patokan ruang teks untuk penyesuaian, bukan pengukuran pasti semua tulisan. Layout tetap perlu diuji pada layar berbeda.

SliverChildBuilderDelegate membuat kartu sesuai kebutuhan area scroll. childCount menentukan jumlahnya. results[index] mengambil tanaman untuk kartu itu. InkWell menerima tekanan. Column menumpuk foto, nama, dan nama ilmiah. ClipRRect memotong foto dengan sudut membulat. maxLines membatasi baris; TextOverflow.ellipsis menampilkan … jika tulisan terlalu panjang.

### Menekan kartu membuka detail

```dart
await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PlantDetailPage(/* data dan callback */),
  ),
);
if (mounted) setState(() {});
```

Bentuk di atas disingkat. Navigator.push menaruh halaman detail di atas halaman sekarang. MaterialPageRoute membungkus halaman tujuan. await menunggu sampai halaman detail ditutup, tanpa membekukan aplikasi. Fungsi yang memakai await diberi async.

Setelah kembali, mounted memeriksa apakah state masih terpasang sebelum setState dipanggil. Ini mencegah memperbarui state yang sudah dibuang.

Detail menerima plant, isSaved dari bookmark, dan isAdded dari collection.any(...). any berarti setidaknya satu anggota memenuhi syarat nama yang sama. onBookmark meneruskan tanaman terpilih ke induk. onAdd menerima room dari detail, lalu meneruskan plant dan room ke HomePage.

## 9. plant_detail_page.dart — informasi satu tanaman

### Data dan bookmark

Halaman menerima plant, isSaved, isAdded, onBookmark, dan onAdd. plant menentukan informasi yang ditampilkan. isAdded menentukan apakah tombol tambah masih aktif. onAdd di sini menerima lokasi saja karena tanaman sudah diketahui oleh halaman kamus yang membukanya.

```dart
late bool saved = widget.isSaved;
```

saved mengingat kondisi ikon bookmark pada detail. late membuat pengisian dari widget ini dilakukan ketika nilainya pertama diperlukan. Nilai awal berasal dari isSaved.

Ketika bookmark ditekan, widget.onBookmark() memperbarui data induk. setState(() => saved = !saved) memperbarui ikon lokal. Keduanya punya tugas: satu mengubah daftar sebenarnya, satu memperbarui tampilan tombol detail.

### Membuka pilihan lokasi

```dart
final room = await showModalBottomSheet<String>(
  context: context,
  // Tampilan panel lokasi.
  builder: (_) => RoomSelectionSheet(plantName: widget.plant.name),
);
if (room == null || !mounted) return;
widget.onAdd(room);
Navigator.pop(context);
```

showModalBottomSheet membuka panel dari bawah. <String> menunjukkan hasil yang diharapkan berupa teks lokasi; hasilnya tetap bisa null jika dibatalkan. await menunggu pilihan pengguna. Setelah panel ditutup, hasil masuk ke room.

Jika room null, pengguna batal. Jika state sudah tidak terpasang, jangan lanjut. return menghentikan fungsi. Kalau pilihan valid, onAdd(room) meminta tanaman ditambah dan Navigator.pop menutup halaman detail.

Fungsi ini bertipe Future<void>: pekerjaan bisa selesai nanti, tetapi tidak mengembalikan nilai berguna kepada pemanggilnya. async/await diperlukan karena menunggu interaksi, bukan karena memakai internet.

isScrollControlled mengizinkan panel menyesuaikan tinggi untuk konten lebih besar. useSafeArea menghindari area sistem tertentu. Bentuk panel putih dengan sudut atas membulat, dipotong mengikuti bentuknya.

### Susunan tampilan

Scaffold menjadi kerangka. CustomScrollView menggabungkan foto atas dan isi. SliverAppBar memiliki tinggi mengembang 290. pinned:true menjaga bar atas tetap tersedia ketika digulir. FlexibleSpaceBar menampilkan PlantPhoto sebagai latar. Tombol Back memakai Navigator.pop. Tombol bookmark memakai IconButton.filledTonal pada halaman detail; ini berbeda dari ikon tanpa latar pada judul kamus.

SliverToBoxAdapter berisi Padding 24 dan Column. Urutannya nama, nama ilmiah miring, tingkat perawatan, deskripsi, kebutuhan cahaya/air/suhu, lalu tombol tambah. TextStyle.height:1.6 adalah jarak tinggi baris relatif terhadap ukuran font, bukan tinggi kotak 1.6.

careInfo(icon, label, value) membuat satu kolom informasi. Dipanggil tiga kali di dalam Row untuk LIGHT, WATER, TEMP. Expanded membagi ruang, lalu Column menumpuk ikon, label, dan nilai. WATER menampilkan interval dari wateringDays, bukan sisa waktu tanaman koleksi pengguna.

Jika isAdded true, tombol bertuliskan Already in Collection, berikon centang, dan onPressed:null. Jika false, tombol menjalankan addToCollection. Pembatasan ini mencegah penambahan ulang melalui tombol yang sama pada alur UI saat ini; belum memakai ID unik dari backend.

## 10. widgets/room_selection_sheet.dart — memilih lokasi

### Mengingat pilihan dan input

```dart
String? selectedRoom;
final roomController = TextEditingController();
final formKey = GlobalKey<FormState>();
```

selectedRoom awalnya null: belum memilih lokasi. roomController membaca nama lokasi yang diketik. formKey adalah pegangan untuk meminta form memeriksa isinya. GlobalKey<FormState> di sini bukan alat reset pencarian seperti ValueKey pada kamus; dipakai untuk mengakses keadaan form.

Halaman menerima plantName untuk ditampilkan di bawah judul. StatefulWidget digunakan karena pilihan lokasi dan tampilan input bisa berubah. dispose membersihkan roomController.

### Baris pilihan lokasi

roomOption(name, icon) membuat ListTile. Dipanggil untuk Living room, Bedroom, Home office, dan Other room. selectedRoom == name menentukan apakah baris aktif. Yang aktif memakai warna hijau, tulisan semibold, dan tanda centang. selectedTileColor transparan agar tidak ada blok warna latar tambahan.

```dart
onTap: () {
  FocusScope.of(context).unfocus();
  setState(() => selectedRoom = name);
},
```

Bacanya: saat memilih baris, lepaskan fokus input, lalu simpan nama lokasi dan perbarui tampilan. Melepas fokus biasanya menutup keyboard yang sedang terbuka.

### Other room dan pemeriksaan input

Jika Other room dipilih, Form dan TextFormField ditampilkan. if di dalam children menentukan apakah bagian itu ikut muncul. ... memasukkan beberapa widget sekaligus, termasuk jarak dan form.

TextFormField berbeda dari TextField biasa karena terhubung dengan pemeriksaan Form. Controller membaca tulisan, maxLength:40 membatasi panjang, labelText memberi nama input, hintText memberi contoh. textCapitalization meminta keyboard mendukung huruf awal kalimat; bukan aturan validasi nama. onFieldSubmitted menjalankan konfirmasi saat tombol selesai di keyboard dipakai.

```dart
validator: (value) => value == null || value.trim().isEmpty
    ? 'Enter a room name'
    : null,
```

Jika tidak ada nilai atau hanya spasi, hasilnya pesan error. Jika valid, hasilnya null. Dalam validator, null berarti tidak ada kesalahan.

### Mengonfirmasi lokasi

```dart
if (selectedRoom == null) return;
if (selectedRoom == 'Other room' && !formKey.currentState!.validate()) {
  return;
}
final room = selectedRoom == 'Other room'
    ? roomController.text.trim()
    : selectedRoom!;
Navigator.pop(context, room);
```

Belum memilih? Berhenti. Memilih Other room tetapi input tidak valid? Berhenti juga. validate menjalankan validator di dalam Form dan menghasilkan true jika semua valid. ! membaliknya, jadi kondisi if berarti pemeriksaan gagal.

Jika Other room, ambil nama yang diketik setelah membuang spasi tepi. Kalau pilihan biasa, gunakan selectedRoom. Navigator.pop(context, room) menutup panel sekaligus mengirim nama lokasi kembali ke await pada halaman detail.

Tombol Add to collection nonaktif selama selectedRoom null. Tombol Close menggunakan Navigator.pop(context) tanpa hasil, sehingga halaman detail menerima null dan tidak menambah tanaman.

### Menghindari tertutup keyboard

Padding bagian bawah mengikuti MediaQuery.viewInsetsOf(context).bottom, yaitu ruang yang tertutup keyboard. SingleChildScrollView memungkinkan isi digulir. SafeArea menjaga area sistem. Column.mainAxisSize.min membuat panel menggunakan tinggi sesuai kebutuhan isinya.

## 11. collection_page.dart — daftar tanaman milik pengguna

### Data dan pilihan tampilan

CollectionPage menerima plants, onBrowse, onChanged. Ini StatelessWidget karena koleksi dikelola HomePage. Kolom utama berisi judul dengan tombol +, lalu Expanded untuk daftar atau tampilan kosong.

```dart
plants.isEmpty ? emptyCollection(context) : ListView(...)
```

Bacanya: kalau belum ada tanaman, tampilkan keadaan kosong; kalau ada, tampilkan daftar. Expanded memberi daftar tinggi yang tersisa setelah judul, sehingga ListView punya area scroll yang jelas.

### Membentuk kartu tanaman

...plants.map(...) membuat kartu untuk setiap tanaman dan memasukkannya ke daftar children. Padding memberi jarak bawah 16. Material memberi latar putih. InkWell membuat kartu bisa ditekan. Di dalam kartu, Row menyusun foto, informasi, dan panah.

Foto diberi lebar 90, tinggi 108, dan sudut membulat melalui ClipRRect. Expanded menyediakan sisa lebar untuk tulisan. Column menumpuk nama, lokasi, dan status. Nama berasal dari item.plant.name, lokasi dari item.room, status dari item.status pada model.

```dart
item.daysUntilWatering <= 0 ? warmBrown : plantGreen
```

Jika sudah waktunya atau belum ada riwayat, status berwarna cokelat. Kalau masih ada sisa hari, hijau. Teks status dibungkus Expanded agar dapat menyesuaikan ruang di samping ikon air.

### Membuka dan menghapus tanaman

Menekan kartu menjalankan Navigator.push ke CollectionDetailPage dengan item terpilih. onChanged diteruskan dari induk. onDelete diberikan sebagai fungsi yang menghapus item dari plants, lalu memanggil onChanged agar HomePage diperbarui.

```dart
onDelete: () {
  plants.remove(item);
  onChanged();
},
```

Perintah ini belum berjalan ketika halaman detail dibuat; detail memanggilnya hanya setelah pengguna menyetujui penghapusan. Setelah route detail ditutup, kode setelah await juga memanggil onChanged untuk menyegarkan tampilan induk. Di sini daftar yang diterima merujuk objek daftar yang sama dengan HomePage, bukan salinan baru.

### Tampilan koleksi kosong

LayoutBuilder membaca tinggi area yang tersedia. SingleChildScrollView membolehkan scroll pada layar kecil. ConstrainedBox menetapkan tinggi minimum sebesar area tersebut, tetapi isi masih boleh lebih tinggi.

Column memakai spaceBetween untuk membagi ruang antarbagian. Spacer atas dibuat sebagai SizedBox dengan tinggi 12% dari ruang yang tersedia. Di tengah ada ilustrasi, judul, dan tombol Browse plant dictionary. Tombol menjalankan onBrowse yang membuka tab 0.

SvgPicture.asset membaca ilustrasi SVG. Itulah alasan file ini mengimpor flutter_svg. Image.asset biasa digunakan untuk foto JPEG, sedangkan SVG dibaca oleh paket tambahan ini.

## 12. collection_detail_page.dart — merawat satu tanaman

File ini berisi dua komponen: CollectionDetailPage dan WateringDialog. Kita bahas halaman dahulu, lalu form yang muncul ketika tombol ditekan.

### Data dan riwayat yang ditampilkan

Halaman menerima item, onChanged, dan onDelete. item adalah satu CollectionPlant dengan lokasi dan riwayatnya. showAll awalnya false.

```dart
final item = widget.item;
final days = item.daysUntilWatering;
final entries = showAll ? item.history : item.history.take(3).toList();
```

item adalah nama singkat agar tidak berulang menulis widget.item; bukan membuat salinan tanaman. days mengambil sisa hari dari model. entries berisi semua riwayat jika showAll true; kalau false, hanya maksimal tiga catatan pertama. take(3) tidak menghapus catatan lain dari history.

### Menunggu hasil form penyiraman

```dart
final entry = await showDialog<WateringEntry>(
  context: context,
  builder: (_) => const WateringDialog(),
);
if (entry == null || !mounted) return;
setState(() => widget.item.history.insert(0, entry));
widget.onChanged();
```

showDialog membuka kotak form. Halaman menunggu hasilnya. Jika pengguna membatalkan, entry null dan fungsi berhenti. Jika valid, insert(0, entry) memasukkan catatan baru di paling atas. setState memperbarui detail; onChanged memperbarui induk dan ringkasan My space.

Setelah itu ScaffoldMessenger menampilkan SnackBar bertuliskan Watering recorded. Ini pesan singkat sebagai tanda penyimpanan ke state berhasil, bukan bukti data sudah disimpan permanen ke database.

### Konfirmasi hapus

removePlant membuka AlertDialog dengan hasil bool. Cancel menutupnya sambil mengirim false. Remove menutupnya sambil mengirim true. Menutup dialog tanpa memilih bisa menghasilkan null.

```dart
if (confirmed != true || !mounted) return;
widget.onDelete();
Navigator.pop(context);
```

Hanya true yang melanjutkan penghapusan. false dan null sama-sama batal. onDelete menjalankan perintah penghapusan dari halaman koleksi, lalu pop menutup detail yang sudah tidak diperlukan. Menghapus item juga menghilangkan akses riwayatnya dari koleksi.

### Isi halaman

SliverAppBar menampilkan foto dengan tinggi mengembang 230, tombol kembali, dan PopupMenuButton. Menu ini berisi Remove plant. Memilihnya menjalankan removePlant. pinned menjaga bar atas ketika scroll.

Isi di bawahnya adalah nama, lokasi, tingkat perawatan, NEXT WATERING, sisa hari, pengingat memeriksa tanah, tombol Record watering, dan riwayat. days <= 0 menghasilkan Due today; selain itu In $days days.

View all hanya muncul jika history.length > 3. Menekannya membalik showAll melalui setState. Teks tombol berubah menjadi Show less. Riwayat kosong menampilkan No watering recorded yet.

...entries.map(...) membuat baris riwayat. Row berisi ikon air, Expanded untuk tanggal dan catatan, lalu jumlah ml. Catatan dan tanggal disusun dengan Column. TimeOfDay.fromDateTime(...).format(context) mengubah waktu catatan menjadi tulisan jam sesuai pengaturan yang berlaku.

### formatDate: tanggal menjadi tulisan

Fungsi ini mengembalikan String. Ia membentuk tanggal hari ini dan tanggal catatan tanpa jam, lalu membandingkannya. Selisih 0 menghasilkan Today, selisih 1 Yesterday. Selain itu, tanggal ditampilkan seperti 19 Oct.

months berisi Jan sampai Dec. date.month bernilai 1–12, sedangkan indeks daftar dimulai 0. Karena itu digunakan months[date.month - 1]. Format ini tidak menampilkan tahun.

Perhitungan ini berbeda dari daysUntilWatering: formatDate mengabaikan jam untuk memberi label tanggal, sedangkan jadwal model menghitung durasi hari penuh sejak penyiraman.

### WateringDialog: menyiapkan input

```dart
final formKey = GlobalKey<FormState>();
final amountController = TextEditingController(text: '300');
final noteController = TextEditingController();
```

formKey meminta form memeriksa input. amountController memulai input jumlah air dengan teks 300. noteController memulai catatan kosong. dispose membersihkan keduanya ketika dialog dibuang.

AlertDialog memakai scrollable:true supaya konten panjang dapat digulir. insetPadding memberi jarak dialog dari tepi layar. titlePadding, contentPadding, dan actionsPadding memberi jarak pada judul, isi, serta tombol. SizedBox meminta lebar isi 340, tetapi tetap dibatasi ruang induk pada layar kecil.

Form membungkus input yang perlu diperiksa. TextFormField jumlah air memakai keyboard angka dan suffixText ml. Keyboard angka hanya membantu pengguna; tetap diperlukan validator karena jenis keyboard bukan jaminan input valid.

### Membaca validator jumlah air

```dart
validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
    ? 'Enter a positive whole number'
    : null,
```

Baca dari dalam: value ?? '' berarti jika value null, gunakan teks kosong. int.tryParse mencoba mengubah teks menjadi bilangan bulat. '250' menjadi 250; 'abc' atau '1.5' gagal dan menghasilkan null. ?? 0 mengganti kegagalan itu menjadi 0. Jika hasilnya 0 atau negatif, kembalikan pesan kesalahan. Jika valid, kembalikan null.

Jadi yang diterima adalah bilangan bulat positif. Input 0, -10, kosong, huruf, atau pecahan ditolak. Kode sekarang belum memberi batas maksimum jumlah ml.

Catatan memakai TextField biasa karena opsional dan tidak memerlukan validator. minLines:3 dan maxLines:4 mengatur ruang teks beberapa baris, bukan jumlah kata. maxLength:100 membatasi karakter. Hint hanya contoh, bukan isi yang otomatis disimpan.

### Cancel dan Save

Kedua tombol dibungkus Expanded di dalam Row, sehingga lebarnya sama. Cancel menjalankan Navigator.pop(context) tanpa hasil. Halaman pemanggil menerima null dan tidak menambah catatan.

```dart
if (!formKey.currentState!.validate()) return;
```

Save meminta semua validator form dijalankan. Jika tidak valid, berhenti dan biarkan pengguna memperbaiki input. ! setelah currentState memastikan FormState tersedia; ! sebelum pemanggilan membalik hasil boolean validate.

Jika valid, kode membuat WateringEntry dengan waktu sekarang, catatan pengguna, dan jumlah air yang sudah diubah menjadi int. Jika catatan setelah trim kosong, dipakai teks Regular watering. int.parse dipakai setelah pemeriksaan berhasil, berbeda dengan tryParse yang dipakai ketika input masih belum dipercaya.

```dart
Navigator.pop(context, WateringEntry(/* waktu, catatan, jumlah */));
```

Potongan di atas disingkat. Artinya: tutup dialog sekaligus kirim catatan baru ke halaman detail. Dialog tidak langsung menambahkan data ke history. Halaman detail yang menerima hasil lalu menjalankan insert(0, entry).

## 13. pubspec.yaml, aset, dan berkas pendukung

pubspec.yaml bukan kode halaman. Ini daftar identitas proyek, kebutuhan paket, font, dan aset. Indentasi memakai spasi menentukan susunannya, jadi perubahan posisi spasi bisa mengubah arti atau membuat error.

name adalah nama paket my_grovia. version menunjukkan versi aplikasi. environment.sdk menentukan rentang Dart yang didukung. dependencies adalah paket yang dipakai aplikasi; flutter_svg membaca SVG. dev_dependencies berisi alat pengembangan seperti flutter_test, flutter_lints, pembuat ikon, dan pembuat splash.

fonts mendaftarkan keluarga PlusJakartaSans dengan Regular, Semibold bobot 600, dan Bold bobot 700. assets mendaftarkan logo, ilustrasi SVG, dan folder foto tanaman. uses-material-design:true menyertakan ikon Material.

flutter_launcher_icons mengatur pembangkitan ikon peluncur. flutter_native_splash mengatur layar awal native sebelum tampilan Flutter siap. Mengedit konfigurasi alat tersebut bukan berarti hasil native langsung dibangkitkan ulang; alatnya perlu dijalankan ketika memang mengubah ikon/splash. Perhatikan huruf besar-kecil nama berkas: konfigurasi logo splash saat dokumen dibaca memakai .PNG, sedangkan aset lain .png. Sistem tertentu membedakan keduanya.

Folder assets/fonts juga berisi lisensi font. Foto dan sumbernya dijelaskan dalam PHOTO_CREDITS.md. PANDUAN_KODE.md adalah catatan proyek sebelumnya. Dokumen yang sedang dibaca ini khusus penjelasan belajar yang lebih pelan.

## 14. Folder test — penjelasan tambahan, bukan syarat memahami UI

Tes adalah kode yang mencoba aplikasi dan memeriksa hasil. Tidak menjadi halaman dalam APK. Kamu bisa fokus ke lib dahulu. Bagian ini menjelaskan fungsi tes yang sudah ada, bukan tugas latihan live coding.

### test/widget_test.dart

openApp menyiapkan ukuran layar 390 × 844 dan menampilkan MyGroviaApp dengan pumpWidget. pumpAndSettle memberi kesempatan pembaruan tampilan serta animasi selesai. addTearDown mendaftarkan pembersihan pengaturan setelah tes selesai agar tes berikutnya tidak ikut terkena.

tapVisible menggulir sampai widget terlihat, menunggu, menekan, lalu menunggu lagi. Ini fungsi pembantu agar langkah yang sama tidak ditulis berulang.

testWidgets membuat satu skenario pengujian. tester adalah alat yang menirukan pengguna: tap menekan, enterText mengetik, scrollUntilVisible menggulir. find.text mencari tulisan, find.byType mencari jenis widget, find.byTooltip mencari keterangan tombol. expect memeriksa apakah hasil sesuai. findsOneWidget berarti ditemukan satu, findsNothing berarti tidak ditemukan. takeException memeriksa apakah ada exception yang tertangkap pada pengujian.

Lima skenario saat ini: memilih lokasi termasuk lokasi custom dan pembatalan; membuka bookmark lewat My space dan reset pencarian; mencari/filter/bookmark; menambah–menyiram–menghapus tanaman; serta tampilan koleksi kosong di layar kecil. Input 0 sengaja dicoba untuk memastikan validasi jumlah air menolak nilai yang salah.

### test/layout_test.dart

Tes ini memakai layar normal lalu layar kecil, teks diperbesar, dan simulasi area keyboard. FontLoader memuat font lokal untuk hasil gambar. Bentuk ..addFont disebut cascade: menjalankan beberapa perintah pada objek yang sama tanpa menuliskan ulang namanya.

RepaintBoundary memberi batas area tampilan yang dapat diambil sebagai gambar. previewKey membantu menemukan area tersebut. precacheImage menyiapkan foto sebelum pengambilan gambar. capture mengubah hasil tampilan menjadi PNG dan menyimpannya di build/ui-previews. dart:io dipakai untuk folder/file, dart:ui untuk data gambar. as RenderRepaintBoundary menyatakan jenis objek yang digunakan setelah diambil dari tampilan.

Tes ini menghasilkan pratinjau dan memeriksa error pada skenario yang dijalankan. Ia tidak membuktikan semua ukuran layar atau semua kemungkinan penggunaan pasti bebas masalah, dan tidak melakukan penilaian selera desain otomatis.

## 15. Menghubungkan semua bagian melalui contoh

### Contoh A: menambahkan Golden Pothos

Pengguna mengetik Pothos di kamus. Controller membaca teks. setState membangun ulang, where memilih tanaman yang sesuai, dan kartu ditampilkan. Kartu ditekan lalu Navigator.push membuka detail. Tombol Add to Collection membuka panel lokasi. Pengguna memilih Bedroom dan mengonfirmasi. Panel ditutup sambil mengirim 'Bedroom'. Detail menerima hasil lalu memanggil onAdd. Kamus meneruskan tanaman dan lokasi ke HomePage. HomePage membuat CollectionPlant, menambahkannya ke plants, dan mengubah selectedTab ke 1. Detail ditutup; koleksi baru terlihat.

### Contoh B: mencatat penyiraman

Pengguna membuka tanaman koleksi. Record watering membuka dialog. Pengguna mengisi 250 ml dan menekan Save. Form memeriksa input. Jika benar, dialog membuat WateringEntry dan mengirimnya saat ditutup. Detail memasukkan catatan ke awal history. Getter sisa hari membaca tanggal terbaru. Detail dan HomePage diperbarui. Riwayat, status kartu, dan jumlah Due for watering di My space mengikuti data terbaru.

### Contoh C: bookmark bukan koleksi

Pengguna menekan bookmark di detail. Daftar bookmarks berubah dan ikon detail berubah. Tanaman belum otomatis masuk plants. Ikon bookmark di judul kamus mengubah mode penyaringan; tidak mengubah keanggotaan bookmark. Saved plants di My space membuka mode tersebut sambil mereset pencarian lama.

## 16. Async, lifecycle, dan materi kelas

### Mengapa ada async walaupun belum memakai backend?

Karena aplikasi menunggu tindakan pengguna. await Navigator.push menunggu halaman ditutup. await showModalBottomSheet menunggu panel ditutup. await showDialog menunggu dialog ditutup. Selama menunggu, pengguna tetap bisa berinteraksi. Ini bukan jeda yang membekukan seluruh layar.

Future adalah hasil pekerjaan yang bisa tersedia nanti. Future<void> berarti selesai nanti tanpa nilai hasil yang perlu dipakai. showDialog<WateringEntry> menjelaskan jenis hasil yang diharapkan, tetapi pembatalan tetap dapat menghasilkan null.

### Lifecycle yang benar-benar dipakai

createState membuat tempat state. build menyusun tampilan dan bisa dipanggil berkali-kali. didUpdateWidget menangani konfigurasi baru dari induk saat state dipertahankan. dispose membersihkan controller ketika state dibuang. mounted memeriksa apakah state masih terpasang sebelum tindakan setelah await.

Kode ini tidak mempunyai metode bernama onStart, onPause, atau onDestroy. Istilah itu membantu memahami siklus hidup secara umum, tetapi tidak boleh diklaim sebagai nama metode Flutter yang digunakan proyek ini. Aplikasi juga tidak memakai while untuk mengulang build; Flutter yang menjadwalkan pembaruannya.

### Mana yang sesuai materi dasar, mana yang tambahan?

Scaffold, AppBar, StatelessWidget, StatefulWidget, setState, Row, Column, Container, TextField, tombol, ukuran, dan area scroll langsung berhubungan dengan materi yang kamu berikan. Expanded/Flexible membantu membagi ruang dan mengurangi overflow.

Callback, model class, Form/validator, Navigator, async/await, IndexedStack, Sliver, dan key adalah tambahan yang dipakai proyek. Tidak semuanya bisa disebut hanya widget dasar kelas. Kita pelajari berdasarkan kebutuhan nyata masing-masing, bukan menghafal istilah sekaligus.

TextEditingController digunakan, tetapi kode pencarian memakai onChanged, bukan addListener yang ditulis sendiri. Controller juga wajib dibersihkan lewat dispose ketika dimiliki state tersebut.

## 17. Cara melanjutkan belajar setelah membaca

Buka aplikasi sambil membaca. Untuk setiap tindakan, cari empat hal: tombol apa yang ditekan, fungsi apa yang dijalankan, data apa yang berubah, dan tampilan mana yang membaca data tersebut. Contohnya Save → validasi dan WateringEntry → history bertambah → status dan riwayat berubah.

Jangan langsung mengubah struktur besar jika satu istilah belum jelas. Tandai judul bagian atau salin potongan kecil yang membingungkan. Saat kembali ke percakapan, sebutkan bab dan bagian tersebut agar kita membahas dari titik yang tepat.

Hot reload cocok untuk banyak perubahan tampilan sambil mempertahankan state. Hot restart mengulang state Dart dari awal. Menambah aset/font atau mengubah bagian native bisa memerlukan penghentian dan menjalankan ulang aplikasi. Data saat ini tidak disimpan permanen, jadi restart dapat mengembalikan demo.

Latihan live coding dilakukan nanti setelah pembahasan dipahami. Kita akan berlatih perubahan fitur secara bertahap, termasuk membaca kode, menentukan file yang perlu diubah, menangani input, dan mengecek hasil; bukan hanya mengganti warna. Dokumen ini tidak mengklaim mengetahui soal yang akan diberikan dosen.

## 18. Kamus singkat untuk dibuka saat lupa

- Parameter: informasi yang diberikan saat memanggil fungsi atau membuat widget.
- Callback: fungsi titipan yang dijalankan nanti ketika suatu tindakan terjadi.
- Constructor: bagian yang dipakai saat membuat objek dari suatu kelas.
- Model: bentuk data, misalnya Plant dan WateringEntry.
- State: kondisi yang sedang diingat tampilan.
- Widget: komponen penyusun tampilan.
- Controller: alat membaca atau mengubah isi input.
- Validator: pemeriksa apakah input memenuhi aturan.
- Route: halaman/lapisan yang dikelola navigasi.
- push: membuka route di atas yang sekarang.
- pop: menutup route teratas; bisa sekaligus mengirim hasil.
- where: memilih anggota yang memenuhi syarat.
- map: mengubah setiap anggota menjadi bentuk lain.
- any: memeriksa apakah ada setidaknya satu anggota yang cocok.
- contains: memeriksa isi kumpulan atau potongan teks, tergantung objeknya.
- length: menghitung jumlah anggota atau karakter, tergantung objeknya.
- isEmpty: memeriksa apakah kosong.
- trim: membuang spasi di awal dan akhir teks.
- ?? : gunakan nilai kanan jika nilai kiri null.
- ?. : lakukan akses hanya jika nilai di kiri tidak null.
- ! setelah nilai: menyatakan nilai pasti tidak null; bisa error jika ternyata null.
- ! sebelum boolean: membalik true/false.
- ... : memasukkan anggota kumpulan ke dalam kumpulan lain.
- ?action dalam daftar: masukkan action hanya jika bukan null.
- Padding: jarak di sekeliling isi widget.
- SizedBox: kotak ukuran tertentu; sering dipakai untuk jarak.
- Expanded: mengisi bagian ruang yang dibagikan Row/Column.
- Flexible: menyesuaikan anak dengan jatah ruang tanpa selalu memaksanya mengisi penuh.
- Overflow: isi tidak muat dalam batas layout yang diberikan.
- mounted: apakah state masih terpasang dalam susunan widget.

Lampiran HTML berikut berisi salinan kode lengkap saat dokumen dibuat. Nomor baris membantu mencocokkan penjelasan. Salinan ini tidak otomatis mengikuti perubahan proyek di masa depan.

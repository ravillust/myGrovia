# Belajar myGrovia — kode yang disederhanakan

Pembaruan 5 November 2026: katalog sekarang mengambil dataset Plantfolio langsung dari GitHub melalui HTTPS. Backend Python/SQLite serta Wikipedia sudah dihapus. Tidak perlu server laptop atau adb reverse; cukup flutter run dengan internet. Deskripsi/perawatan dari Plantfolio, foto dan label katalog dari aplikasi; koleksi masih demo di RAM. Lihat API_MINGGU_INI.md dan ../CATATAN_UNTUK_GPT.md untuk alur terbaru. Bab berikut adalah materi historis versi 21 Oktober; contoh plantDictionary dan createSampleCollection tanpa parameter tidak lagi sama dengan kode terbaru.

Versi dasar 21 Oktober 2026. Panduan 19 Oktober menjelaskan versi lama yang masih memakai Sliver, IndexedStack, dan key untuk mereset pencarian.

Kode sekarang lebih panjang karena langkah-langkahnya ditulis terpisah. Tujuannya supaya kamu bisa mengikuti perintahnya dari atas ke bawah. Latihan live coding tetap kita lakukan nanti, setelah kamu memahami alurnya.

Dokumen ini tidak memerlukan internet. Klik daftar isi untuk pindah bab. Gunakan Ctrl+F untuk mencari kata. Tombol A+ memperbesar tulisan. Kode lengkap setiap file tersedia pada lampiran yang bisa dibuka. Potongan dengan komentar pengganti isi adalah contoh penjelasan, bukan file lengkap untuk disalin.

## 1. Apa yang berubah dan kenapa?

Halaman sekarang memakai Scaffold, ListView, Row, dan Column. Header detail memakai Stack untuk menaruh tombol di depan foto. Kamus tidak memakai Sliver atau delegate lagi. Kartu disusun satu kolom pada layar sempit dan dua kolom pada layar lebih lebar menggunakan Row.

HomePage memilih halaman dengan if, bukan IndexedStack. Hanya halaman tab aktif yang dipasang. Ketika berganti tab, pencarian dan posisi scroll kembali ke awal. Koleksi dan bookmark tidak hilang karena disimpan di HomePage. Saat membuka detail dengan Navigator.push, halaman asal tetap ada di bawahnya.

Foto detail menjadi bagian pertama ListView. Stack menumpuk baris tombol di depan daftar tersebut. Foto ikut scroll tanpa efek mengembang atau mengecil; tombol tetap di atas dan bisa digunakan saat halaman digulir. SafeArea menjaga tombol dari area sistem HP. Latar putih kecil membantu tombol terbaca di atas foto.

Form memeriksa input langsung melalui fungsi confirmRoom atau saveWatering. Tidak memakai Form, GlobalKey<FormState>, atau validator yang ditulis satu baris. Jika input salah, setState mengisi pesan error dan InputDecoration menampilkannya.

Kode lib tidak lagi menggunakan fungsi singkat =>, pemanggilan map/where/any, operator pilihan kondisi ?:, dan ValueKey. Sebagai gantinya ada fungsi bernama, if/else, dan perulangan for.

Tetap ada tambahan di luar rangkuman kelas: model data, callback, Navigator, async/await, dan beberapa widget pembantu. Kode yang berfungsi dengan fitur ini tidak bisa secara jujur disebut hanya memakai istilah yang ada di rangkuman. Bagian tambahan itu dijelaskan berdasarkan kegunaannya di aplikasi.

## 2. Dasar membaca kode

### Variabel dan nilai

```dart
int selectedTab = 0;
```

Bacanya: siapkan tempat bernama selectedTab untuk menyimpan angka. Isi awalnya 0. int adalah bilangan bulat; String teks; bool benar/salah; double bisa memiliki pecahan.

Satu = berarti mengisi nilai. Dua == berarti memeriksa kesamaan. selectedTab = 1 mengubah pilihan. selectedTab == 1 menanyakan apakah pilihannya 1.

final berarti variabel tidak diarahkan ulang ke nilai lain. Jika isinya daftar, anggota daftar masih boleh ditambah. const dipakai untuk nilai konstan; daftar const tidak boleh diubah isinya.

### Fungsi adalah perintah yang diberi nama

```dart
void changeTab(int tabNumber) {
  setState(() {
    selectedTab = tabNumber;
  });
}
```

changeTab menerima nomor tujuan, menyimpannya, lalu meminta layar diperbarui. tabNumber disebut parameter, yaitu informasi yang diberikan saat menjalankan fungsi. void berarti fungsi tidak mengembalikan hasil. return pada fungsi pembuat widget justru menyerahkan widget hasilnya.

changeTab(1) menjalankan fungsi dengan nomor 1. onPressed: openCollection memberikan fungsi agar dijalankan nanti, ketika tombol ditekan. onPressed: () { ... } berarti perintah tombol ditulis langsung di tempat tersebut sebagai fungsi tanpa nama.

### Kondisi dan perulangan

```dart
if (selectedTab == 1) {
  // Lakukan jika tab nomor 1 dipilih.
} else {
  // Lakukan jika kondisinya tidak cocok.
}
```

&& berarti dan, || berarti atau. Kedua syarat pada && harus benar. Pada || cukup salah satu benar. ! di depan boolean membalik benar dan salah.

```dart
for (final Plant plant in plantDictionary) {
  // Periksa satu tanaman, lalu lanjut tanaman berikutnya.
}
```

for ini mengunjungi setiap tanaman. Bentuk for (int index = 0; index < 3; index++) berarti mulai nomor 0, ulang selama nomor kurang dari 3, dan tambah nomor satu setelah tiap putaran. Hasilnya nomor 0, 1, 2. break menghentikan perulangan; return menghentikan fungsi.

### Tanda null

null berarti tidak ada nilai. String? boleh berisi teks atau null. Pada form, roomError null berarti tidak ada pesan kesalahan. Setelah salah, nilainya menjadi teks yang akan ditampilkan.

?. menjalankan akses hanya jika nilai sebelumnya bukan null. Contohnya gaya judul dari tema disalin dengan ?.copyWith. ! setelah nilai menyatakan nilainya pasti bukan null; jangan ditambahkan sembarangan karena bisa error jika ternyata null. super.key meneruskan identitas widget ke Flutter; tidak mereset halaman dengan sendirinya.

## 3. main.dart — menjalankan aplikasi dan mengatur tema

```dart
void main() {
  runApp(const MyGroviaApp());
}
```

main dijalankan pertama. runApp meminta Flutter menampilkan MyGroviaApp. Widget adalah komponen tampilan, bisa sekecil tulisan atau sebesar satu halaman. MyGroviaApp memakai StatelessWidget karena mengatur aplikasi tanpa menyimpan pilihan menu sendiri.

Import material.dart menyediakan widget Flutter. Import home_page.dart menyediakan halaman utama. Import plant_widgets.dart menyediakan warna bersama. import bukan mengambil data dari internet.

build menghasilkan MaterialApp. context membantu mengakses tema dan navigasi dari posisi widget. @override menandai bahwa kita mengisi metode dari kelas induk. home: HomePage menentukan halaman pertama.

ThemeData mengatur tampilan bersama. fontFamily sekarang PlusJakartaSans. textTheme mengatur judul tebal dan label semibold. fontWeight.w700 berarti bold, w600 semibold, w400 regular. scaffoldBackgroundColor mengatur latar halaman.

ColorScheme.fromSeed membuat kumpulan warna dari hijau utama. copyWith mengubah beberapa pengaturannya. surface putih, surfaceTint transparan agar tidak ada lapisan warna tambahan. DialogThemeData mengatur kotak dialog; appBarTheme bagian atas halaman; inputDecorationTheme kolom input.

filled dan fillColor memberi latar input. contentPadding memberi jarak isi dari batas. focusedBorder adalah garis ketika input aktif; enabledBorder saat input tersedia tetapi tidak fokus. BorderRadius.circular membuat sudut membulat. chipTheme mengatur gaya dasar tombol filter. useMaterial3 memakai komponen Material 3.

title memberi judul untuk keperluan sistem; tidak otomatis menjadi teks judul layar. debugShowCheckedModeBanner:false menghilangkan pita DEBUG, bukan mengubah aplikasi menjadi release.

## 4. home_page.dart — tab dan data bersama

### Logika menu

```dart
int selectedTab = 0;
```

Nomor 0 kamus, 1 koleksi, 2 My space. changeTab menerima nomor baru lalu mengisinya melalui setState. setState hanya meminta Flutter membangun ulang; fungsi buildSelectedPage yang memilih halaman dengan if.

```dart
if (selectedTab == 0) {
  return DictionaryPage(/* data dan fungsi yang dibutuhkan */);
}
```

Potongan ini disingkat. Jika nomor 0, hasilnya halaman kamus. Jika 1, koleksi. Selain itu My space. SafeArea melindungi isi dari bagian sistem HP. Scaffold menyediakan body dan bottomNavigationBar.

navigationButton menerima nomor tujuan, gambar ikon, dan label. Warna awal abu-abu, lalu if menggantinya menjadi hijau jika nomor tombol sama dengan selectedTab. onPressed memanggil changeTab(index).

Row menyusun tiga tombol ke samping. Expanded membagi lebar rata. Center menaruh tombol di tengah bagiannya. Area menu setinggi 80, area tombol 52 × 52, ikon berukuran 30. Material transparan dengan bentuk lingkaran membatasi efek tekan. Semantics memberi informasi tab aktif ke pembaca layar. tooltip memberi nama tombol meskipun tidak ada tulisan permanen.

### Data dan fungsi induk

plants adalah daftar koleksi dari createSampleCollection. bookmarks adalah Set<String>, kumpulan nama tanpa duplikat. savedPlantsOnly menentukan apakah kamus hanya menampilkan bookmark.

openDictionary membuka tab 0 dengan mode bookmark dimatikan. openCollection membuka tab 1. openSavedPlants mengaktifkan mode bookmark lalu membuka tab 0. Tidak diperlukan dictionaryVisit atau ValueKey karena perpindahan tab sudah membuat ulang state halaman kamus.

changeSavedFilter menerima true/false dari kamus. changeBookmark memeriksa contains: jika nama sudah ada, remove; kalau belum, add. Ini tidak mengubah koleksi karena bookmark dan koleksi berbeda daftar.

addPlant membuat CollectionPlant dari tanaman, lokasi, waktu sekarang, dan history kosong. plants.add memasukkannya ke daftar. selectedTab menjadi 1 agar hasil terlihat. refreshCollection memanggil setState kosong karena data sudah diubah di halaman lain.

### Data turun, perintah dipanggil ketika dibutuhkan

```dart
CollectionPage(
  plants: plants,
  onBrowse: openDictionary,
  onChanged: refreshCollection,
)
```

plants kiri adalah nama parameter penerima, plants kanan daftar yang diberikan. onBrowse memberi perintah untuk dijalankan nanti saat + ditekan. Fungsi titipan seperti ini disebut callback. onChanged meminta induk memperbarui layar setelah data berubah.

DictionaryPage menerima fungsi addPlant dan changeBookmark. ProfilePage menerima daftar koleksi, jumlah bookmark, dan fungsi pembuka halaman. Semua menggunakan data HomePage agar hasilnya sama.

## 5. profile_page.dart — My space

ProfilePage menerima plants, savedCount, onOpenCollection, dan onOpenSavedPlants. VoidCallback berarti fungsi tanpa parameter dan tanpa nilai kembalian. required berarti parameter wajib diberikan. this.plants memasukkan daftar yang diterima ke properti objek.

Ini StatelessWidget karena data dikelola induk. Tulisan tetap dapat berubah ketika HomePage membangun ulang dengan data terbaru. Stateless bukan berarti tulisan selamanya sama.

ListView membuat halaman bisa digulir. PageHeading menampilkan My space. Padding.all(24) memberi jarak empat sisi. Column menyusun tiga baris ke bawah.

### Membaca satu baris

```dart
ListTile(
  onTap: onOpenCollection,
  leading: const Icon(Icons.local_florist_outlined),
  title: const Text('Plants in collection'),
  // Bagian kanan berisi angka dan panah.
)
```

leading adalah kiri, title tulisan utama, trailing kanan. onTap berlaku untuk seluruh baris. trailing memakai Row berisi Text('${plants.length}'), SizedBox jarak 12, dan panah. length menghitung anggota. ${...} memasukkan hasil perhitungan ke teks. mainAxisSize.min meminta lebar secukupnya. contentPadding.zero menghapus jarak bawaan karena sudah ada jarak dari pembungkus.

countPlantsDueForWatering mulai dari total 0. for membaca tiap tanaman. Jika daysUntilWatering <= 0, total ditambah satu. Setelah semua diperiksa, return total memberikan hasil. Angka ini ditampilkan pada Due for watering; baris itu tidak bisa ditekan karena tidak mempunyai onTap.

Saved plants menampilkan savedCount dan menjalankan onOpenSavedPlants saat ditekan. Divider adalah garis pemisah antarbaris.

## 6. model/plant.dart — bentuk data dan demo

Plant adalah cetakan informasi umum tanaman: name, botanicalName, image, difficulty, light, wateringDays, temperature, description, tip, lowLight. image menyimpan alamat foto, bukan gambar itu sendiri. String? berarti boleh null. wateringDays int untuk jumlah hari, lowLight bool untuk filter.

Constructor memakai nama parameter. required this.name wajib diisi. difficulty default Easy dan lowLight default false. Properti final tidak diisi ulang setelah objek dibuat. tip masih tersimpan walaupun Good to know tidak ditampilkan.

WateringEntry menyimpan satu penyiraman: date, note, milliliters. Constructor memakai urutan, jadi WateringEntry(DateTime.now(), 'Regular watering', 250) berarti sekarang, catatan tersebut, 250 ml.

CollectionPlant menyimpan plant, room, added, history. item.plant.name membaca nama dari objek tanaman, item.room membaca lokasi koleksi. history adalah List<WateringEntry>. Walaupun propertinya final, anggota daftar masih bisa ditambah.

### Getter yang menghitung sisa hari

daysUntilWatering dipanggil seperti membaca properti, tanpa (). Jika riwayat kosong, return 0. Jika ada, ambil tanggal catatan pertama sebagai lastWateringDate. Hitung daysSinceWatering dengan difference(...).inDays. Kurangi interval tanaman dengan jumlah hari yang berlalu untuk mendapatkan remainingDays.

Contoh interval 7, terakhir disiram 3 hari lalu, sisa 4. Negatif berarti terlambat. Kode demo menganggap tanpa riwayat perlu diperiksa untuk disiram, bukan bukti tanahnya kering. inDays menghitung durasi hari penuh, bukan hanya pergantian tanggal. Getter tidak menjalankan timer sendiri.

status memeriksa apakah riwayat kosong atau sisa hari <= 0, lalu menghasilkan Due today. Kalau belum jatuh tempo, 0 hari menghasilkan Watered today, 1 hari Watered yesterday, selebihnya Watered $days days ago.

### Data contoh

plantDictionary adalah daftar const empat tanaman. createSampleCollection membuat tiga koleksi untuk demo. Variabel rooms berisi lokasi dan daysSinceWatering berisi angka 1, 5, 6. Perulangan index 0 sampai 2 mengambil tanaman, lokasi, dan angka sesuai posisi yang sama.

now.subtract(Duration(days: ...)) menghasilkan tanggal beberapa hari sebelum sekarang. history dibuat dari catatan terbaru dan catatan 15/24 hari lalu. CollectionPlant baru dimasukkan menggunakan collection.add(item). Setelah selesai, return collection mengirim daftar ke HomePage.

Ini data demo untuk presentasi UI. Tidak ada penyimpanan permanen. Kelas model masih berguna jika nanti ada backend; sumber daftar demo yang akan diganti. model/post.dart dan model/api_service.dart saat ini kosong.

## 7. widgets/plant_widgets.dart — ukuran dan komponen bersama

plantGreen hijau utama, mutedText warna tulisan sekunder, neutralSurface latar netral, warmBrown aksen cokelat. Color(0xff2f7255) adalah kode warna; ff bagian ketidaktransparanan.

### PlantPhoto

Menerima data plant dan tinggi opsional. Jika image tidak null, Image.asset memuat foto lokal. BoxFit.cover memenuhi area tanpa merusak proporsi, tetapi bisa memotong sebagian gambar. Alignment(0,0.35) mengatur posisi foto. semanticLabel memberi nama untuk pembaca layar.

width:double.infinity meminta lebar penuh yang diizinkan pembungkus. Jika image null, Container netral menampilkan ikon dan Photo coming soon. Ini hanya menangani alamat null, belum alamat yang terisi tetapi berkasnya tidak ditemukan.

### PageHeading

Menerima title dan action opsional. build membuat daftar headingItems berisi judul dalam Expanded. Jika actionButton tidak null, tombol ditambahkan ke daftar. Row menampilkan daftar tersebut. Padding.fromLTRB(24,24,24,20) memberi jarak kiri, atas, kanan, bawah.

Gaya judul mengambil Theme.of(context).textTheme.headlineMedium dan menyalinnya dengan copyWith agar tebal. ?. berarti penyalinan dilakukan jika gaya tersedia.

### PrimaryButton

Menerima label, onPressed, dan icon opsional. onPressed:null membuat tombol nonaktif. SizedBox meminta lebar penuh. FilledButton mengatur tinggi minimum 52, padding, dan sudut 10. Row menengahkan isi. Jika ikon ada, tampilkan ikon dan jarak. Flexible membatasi teks supaya bisa membungkus ketika sempit.

### Mengingat widget layout

SizedBox(width:12) tanpa isi menjadi jarak mendatar. SizedBox(height:24) menjadi jarak ke bawah. Jika mempunyai child, SizedBox meminta ukuran tertentu untuk isinya. Padding memberi jarak di sekeliling anak. Container bisa memberi latar, ukuran, jarak, dan bentuk.

Row menyusun ke samping. Column menyusun ke bawah. child menerima satu widget, children menerima daftar. Expanded mengisi jatah ruang dari Row/Column; Flexible mengizinkan anak lebih kecil dari jatahnya. Center menengahkan dalam ruang yang diberikan, bukan otomatis seluruh layar. ClipRRect memotong gambar mengikuti sudut membulat. SafeArea menghindari area sistem. Ukuran Flutter berupa logical pixel, bukan selalu jumlah piksel fisik layar.

## 8. dictionary_page.dart — pencarian tanpa delegate

Halaman menerima koleksi, bookmark, mode savedOnly, dan tiga callback: onAdd, onBookmark, onSavedOnlyChanged. Tipe void Function(Plant, String) berarti fungsi menerima tanaman dan teks lokasi. State menyimpan searchController dan selectedFilter.

dispose membersihkan controller ketika halaman dibuang. clearSearch mengosongkan teks, mengembalikan All plants, lalu meminta induk mematikan savedOnly. changeBookmarkView menentukan kebalikan mode sekarang melalui if, membersihkan pencarian/filter, lalu memberi tahu induk. searchSuggestedPlant mengisi nama saran dan mengembalikan filter umum.

### Membaca pencarian langkah demi langkah

findMatchingPlants mengambil teks, trim menghapus spasi tepi, toLowerCase menyamakan huruf besar/kecil. Buat results kosong. for membaca satu tanaman setiap putaran.

plantNames menggabungkan nama dan nama ilmiah. contains(searchText) memeriksa kecocokan teks. categoryMatches awalnya true. Jika Easy care dipilih, cocokkan difficulty. Jika Low light dipilih, baca lowLight. bookmarkMatches awalnya true; jika mode savedOnly aktif, periksa apakah nama tersimpan.

Jika nameMatches, categoryMatches, dan bookmarkMatches semuanya benar, results.add(plant). Setelah perulangan selesai, return results. Tidak ada tanaman dihapus dari daftar asli.

### Halaman dan pilihan filter

build menentukan title, tooltip bookmark, dan ikon melalui if. Jika bookmark kosong dan mode savedOnly aktif, tampilkan ListView dengan judul, ikon, pesan kosong, dan tombol Browse all plants. Kalau tidak, tampilkan pencarian, filter, dan hasil.

clearButton awalnya null. Jika teks terisi, buat tombol penghapus. TextField memakai controller. onChanged memanggil setState agar hasil dihitung ulang. PrefixIcon di awal input, suffixIcon di ujung.

buildFilterButton membuat ChoiceChip. if menentukan warna tulisan. selected membandingkan nama chip dengan selectedFilter. onSelected menyimpan nama melalui setState. SingleChildScrollView horizontal membuat chip bisa digeser jika sempit.

buildNoResults menampilkan No plants found jika hasil penyaringan kosong. Ini berbeda dengan tidak punya bookmark. Saran nama memakai TextButton yang memanggil searchSuggestedPlant. Wrap membuat tombol saran pindah baris jika tidak muat.

### Menyusun kartu dengan Row

buildPlantRows menghitung lebar isi: lebar layar dikurangi 48 untuk padding kiri/kanan. Buat daftar rows kosong. Jika lebar kurang dari 340, setiap tanaman ditambahkan sebagai kartu satu baris.

Jika cukup lebar, perulangan index += 2 mengambil dua tanaman setiap putaran. Kartu kiri memakai results[index]. Kartu kanan memakai results[index + 1] jika masih ada. Jika jumlah ganjil, kanan memakai SizedBox kosong. Dua Expanded dengan jarak 16 membagi satu baris. Setelah semua dibuat, Column(children: rows) menampilkannya ke bawah.

Kartu tidak punya tinggi tetap dari grid lagi; tinggi mengikuti isi. Foto setinggi 205, nama, lalu nama ilmiah miring. InkWell menjalankan openPlantDetail ketika ditekan.

### Membuka detail

openPlantDetail memeriksa satu per satu koleksi menggunakan for. Jika nama sama, alreadyInCollection true dan break. Navigator.push membuka PlantDetailPage dengan tanaman, status bookmark, status koleksi, serta callback. Halaman detail mengirim room; callback menggabungkannya dengan plant sebelum meneruskan ke HomePage.

await menunggu detail ditutup. if (mounted) memastikan state kamus masih terpasang sebelum setState. Jika pengguna menambah koleksi, HomePage bisa berpindah ke koleksi dan membuang state kamus; pemeriksaan mounted menangani kondisi ini.

## 9. plant_detail_page.dart — membuka pilihan lokasi

Halaman menerima plant, isSaved, isAdded, onBookmark, dan onAdd. saved awalnya false lalu diisi dari widget.isSaved melalui initState. initState berjalan saat state dibuat; super.initState menjalankan inisialisasi kelas induk.

changeBookmark memanggil callback induk dan membalik saved dengan if/else di dalam setState. Induk mengubah daftar, state lokal mengubah ikon yang terlihat di detail.

build menentukan tulisan/ikon bookmark. Tombol tambah awalnya aktif dengan addToCollection. Jika isAdded benar, label menjadi Already in Collection, ikon centang, dan action null supaya nonaktif.

Scaffold mempunyai SafeArea dan Stack. Anak pertama Stack adalah ListView, anak kedua Padding berisi Row tombol kembali dan bookmark. Yang ditulis belakangan berada di lapisan depan. Back menjalankan Navigator.pop. Bookmark menjalankan changeBookmark. ListView berisi foto setinggi 250 lalu Padding/Column untuk nama, nama ilmiah, care level, deskripsi, informasi perawatan, dan tombol. Foto tidak lagi mengecil otomatis ketika scroll.

careInfo menerima ikon, label, nilai. Expanded membagi ruang dalam Row untuk LIGHT, WATER, TEMP. Di dalamnya Column menumpuk ikon, label kecil, dan isi. WATER adalah interval umum dari Plant, bukan sisa jadwal milik koleksi.

addToCollection membuka showModalBottomSheet<String>. Panel menampilkan RoomSelectionSheet dengan nama tanaman. await menunggu hasil. Jika room null atau state tidak mounted, hentikan fungsi. Jika valid, widget.onAdd(room) meminta penambahan, lalu Navigator.pop menutup detail.

isScrollControlled membantu panel menggunakan tinggi yang dibutuhkan. useSafeArea menghindari area sistem tertentu. backgroundColor, shape, dan clipBehavior mengatur tampilan panel putih dengan sudut atas membulat.

## 10. room_selection_sheet.dart — lokasi dan validasi if

selectedRoom sekarang berupa String dengan nilai awal ''. Teks kosong berarti belum memilih. roomController membaca nama lokasi sendiri. roomError bertipe String?; null berarti tidak ada kesalahan yang ditampilkan. dispose membersihkan controller.

roomOption membuat ListTile untuk Living room, Bedroom, Home office, atau Other room. if menentukan warna, ketebalan, dan centang. onTap melepas fokus keyboard dengan unfocus, menyimpan pilihan, dan membersihkan pesan error.

Jika Other room dipilih, TextFormField ditampilkan. Tidak ada Form atau GlobalKey di versi ini. TextFormField masih dipakai sebagai komponen input, tetapi pemeriksaan dilakukan oleh confirmRoom. errorText:roomError menampilkan pesan dari state. maxLength membatasi panjang 40 karakter; onChanged membersihkan pesan lama; onFieldSubmitted memanggil konfirmasi ketika selesai lewat keyboard.

### confirmRoom

Jika selectedRoom kosong, berhenti. Buat room dari pilihan. Jika pilihan Other room, ambil teks controller dan trim. Jika hasil kosong, set roomError menjadi Enter a room name melalui setState lalu berhenti. Jika semua benar, Navigator.pop(context, room) menutup panel sambil mengirim hasil lokasi.

confirmAction awalnya null. Hanya ketika lokasi sudah dipilih, fungsi confirmRoom diberikan kepada tombol. Tombol Close menutup tanpa hasil; tanaman tidak ditambahkan.

Padding bawah membaca MediaQuery.viewInsetsOf(context).bottom agar konten tidak tertutup keyboard. SingleChildScrollView memungkinkan panel digulir, SafeArea menjaga area sistem, mainAxisSize.min membuat Column memakai tinggi secukupnya.

## 11. collection_page.dart — kartu koleksi

StatelessWidget ini menerima plants, onBrowse, onChanged. build memakai if untuk memilih emptyCollection atau buildPlantList. Judul dan tombol + berada di atas. Expanded memberi area sisanya kepada daftar yang bisa digulir.

buildPlantList memakai ListView dan for di dalam children: untuk tiap item, buat satu kartu. Padding memberi jarak bawah, Material memberi latar putih, InkWell menerima tekanan. Row menyusun foto lebar 90 dan tinggi 108, informasi di Expanded, dan panah kanan.

Nama dibaca dari item.plant.name, lokasi dari item.room, status dari item.status. wateringStatusColor memakai if: sisa hari <= 0 cokelat, lainnya hijau. Status dibungkus Expanded supaya teks menyesuaikan ruang.

Menekan kartu membuka CollectionDetailPage dengan Navigator.push. onDelete berisi plants.remove(item) lalu onChanged(). Fungsi itu hanya dijalankan oleh detail setelah konfirmasi. Setelah detail ditutup, context.mounted diperiksa sebelum meminta induk diperbarui lagi.

emptyCollection memakai ListView dengan ilustrasi SVG, judul, dan tombol. Tidak lagi memakai LayoutBuilder atau ConstrainedBox. Bagian kosong boleh scroll pada layar pendek. SvgPicture.asset berasal dari flutter_svg dan membaca ilustrasi vektor. Tombol browse menjalankan onBrowse untuk membuka kamus.

## 12. collection_detail_page.dart — jadwal, riwayat, dan hapus

File ini berisi CollectionDetailPage dan WateringDialog. Detail menerima item, onChanged, dan onDelete. showAll mengingat apakah seluruh riwayat ditampilkan.

build mengambil sisa hari dari model. Perulangan menambahkan catatan ke entries jika showAll benar atau nomor catatan kurang dari 3. Data asli history tidak dipotong. if menentukan tulisan Due today atau In ... days dan label View all/Show less.

Stack menaruh baris tombol Back dan PopupMenuButton di depan ListView. Menu berisi Remove plant; onSelected memeriksa pilihan sebelum menjalankan removePlant. Body ListView berisi foto setinggi 200 dan Column informasi. Row judul riwayat menaruh tombol View all di kanan, hanya jika catatan lebih dari tiga. Tombol membalik showAll dengan if/else.

Jika entries kosong, tampilkan No watering recorded yet. for di dalam children membuat satu baris untuk tiap catatan. Row menaruh ikon, tanggal/catatan dalam Expanded, dan jumlah ml. TimeOfDay.fromDateTime(...).format(context) membuat tulisan jam.

### waterPlant: menunggu catatan baru

await showDialog<WateringEntry> membuka WateringDialog dan menunggu hasilnya. Jika pengguna batal, hasil null dan fungsi berhenti. mounted diperiksa setelah menunggu. Jika ada catatan, history.insert(0, entry) menaruhnya paling awal melalui setState. onChanged menyegarkan induk. SnackBar Watering recorded memberi tahu pencatatan berhasil di memori aplikasi.

### removePlant: menunggu persetujuan hapus

AlertDialog menampilkan Cancel dan Remove. Cancel mengirim false, Remove true. Menutup tanpa memilih bisa menghasilkan null. if (confirmed != true || !mounted) menghentikan proses selain persetujuan true yang masih valid. Setelah disetujui, onDelete menghapus item dari koleksi, lalu pop menutup detail.

### formatDate

Fungsi membandingkan tanggal tanpa jam. Selisih 0 menghasilkan Today, 1 Yesterday. Selain itu, nama bulan diambil dari daftar Jan–Dec. date.month dimulai 1, indeks daftar dimulai 0, sehingga dipakai months[date.month - 1]. Format sekarang tidak menampilkan tahun.

## 13. WateringDialog — membaca jumlah air dengan langkah jelas

amountController diawali teks 300. noteController kosong. amountError null berarti belum ada pesan salah. Keduanya dibersihkan lewat dispose ketika dialog dibuang.

AlertDialog scrollable agar form bisa digulir. insetPadding mengatur jarak dialog dari layar; contentPadding jarak isi di dalam; actionsPadding jarak area tombol. SizedBox meminta lebar isi 340, tetapi tetap mengikuti batas layar.

TextFormField jumlah air menggunakan keyboard angka, suffix ml, dan errorText:amountError. Tidak memakai validator pada Form. Saat input berubah, pesan kesalahan lama dibersihkan. Keyboard angka membantu mengetik tetapi tidak menjamin nilai valid, jadi pemeriksaan tetap perlu.

### saveWatering

```dart
final int? amount = int.tryParse(amountController.text.trim());
if (amount == null || amount <= 0) {
  setState(() {
    amountError = 'Enter a positive whole number';
  });
  return;
}
```

Ambil teks, buang spasi tepi, coba ubah menjadi bilangan bulat. Jika gagal, tryParse menghasilkan null. Jika gagal atau angkanya 0/negatif, isi pesan error dan berhenti. Input 250 lolos; kosong, abc, 0, -5, dan 1.5 ditolak. Tidak ada batas maksimum ml di kode sekarang.

Setelah valid, ambil catatan dan trim. Jika kosong, isi Regular watering. Buat WateringEntry(DateTime.now(), note, amount), lalu Navigator.pop(context, entry). Dialog hanya mengirim hasil; halaman detail yang memasukkannya ke history.

Cancel memakai pop tanpa hasil, sehingga tidak ada catatan baru. Row dengan dua Expanded membuat tombol Cancel dan Save sama lebar. Catatan memakai TextField dengan 3–4 baris dan batas 100 karakter; optional berarti boleh kosong.

## 14. Routing dan async dengan contoh nyata

push menambah route ke atas tumpukan. pop menutup yang paling atas. Menu bawah tidak memakai push; changeTab menentukan isi body melalui if. Detail memakai push, sehingga halaman daftar tetap ada di bawahnya.

```text
Kamus
  → push detail
  → buka panel lokasi
  → pop panel sambil mengirim lokasi
  → detail menerima lokasi dan meminta HomePage menambah koleksi
  → pop detail
  → HomePage sekarang menampilkan koleksi
```

await menunggu route/panel/dialog ditutup, tidak membekukan aplikasi. async memungkinkan fungsi memakai await. Future<void> berarti pekerjaan dapat selesai nanti tetapi tidak mengirim nilai yang perlu dipakai pemanggil. Tidak ada backend pada penggunaan async ini.

mounted memeriksa state masih terpasang setelah menunggu. dispose membersihkan controller ketika state dibuang. initState membaca nilai awal bookmark detail. Kode tidak memakai metode bernama onStart/onPause/onDestroy dan tidak menjalankan while untuk memperbarui layar.

## 15. pubspec.yaml, test, dan batas aplikasi

pubspec.yaml mendaftarkan paket flutter_svg, font Plus Jakarta Sans Regular/Semibold/Bold, logo, foto, dan ilustrasi. Indentasi spasi penting. dependencies digunakan aplikasi; dev_dependencies alat pengembangan. Pengaturan launcher icon dan splash dipakai oleh alat pembangkit aset native, bukan halaman Flutter biasa.

Folder test berisi simulasi interaksi. widget_test mencoba pencarian, bookmark, penambahan tanaman, pembatalan form, penyiraman, riwayat, dan penghapusan. Tes tambahan memeriksa data tetap ada setelah pergantian tab, serta View all/Show less. layout_test memeriksa layar kecil, skala teks, keyboard, dan landscape pada alur yang diuji, lalu menghasilkan gambar di build/ui-previews.

tester.tap menekan, enterText mengetik, ensureVisible menggulir ke widget, pumpAndSettle menunggu pembaruan dan animasi, expect membandingkan hasil dengan harapan. Tes bukan fitur yang ditampilkan dalam aplikasi dan bukan jaminan semua perangkat pasti sama.

createSampleCollection tetap dipakai untuk demo UTS tampilan dan routing. Data tidak disimpan setelah restart. APK yang pernah dibuat adalah hasil build pada waktu tertentu; mengubah source tidak otomatis mengubah file APK lama. Jika ingin mengumpulkan versi source terbaru, APK perlu dibuild ulang.

Dokumen ini juga merupakan salinan pada waktu tertentu. Jika kode berubah lagi, penjelasan dan lampiran perlu diperbarui. Pelajari per file; saat ada bagian yang belum jelas, sebutkan judul bab dan fungsi tersebut ketika kembali bertanya.

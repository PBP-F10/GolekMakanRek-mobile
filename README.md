<!-- Kalau ada yang mau ditambah/diedit boleh yaa, misal mau tambah emoji, bikin bagus tampilannya, dll. -->
# 🍲 GolekMakanRek-Mobile!  🍜

**GolekMakanRek!** adalah aplikasi untuk Anda para penduduk dan juga turis di Surabaya untuk memilih kuliner sesuai selera.

## 📜 Back Story
Surabaya, sebagai salah satu kota besar di Indonesia, memiliki kekayaan kuliner yang sangat beragam, mulai dari jajanan kaki lima hingga restoran mewah. Namun, dengan begitu banyak pilihan, baik penduduk lokal maupun wisatawan sering kali kebingungan menentukan tempat makan yang sesuai dengan selera dan kebutuhan mereka. Dari sinilah ide GolekMakanRek! muncul—sebuah platform yang dirancang untuk membantu masyarakat Surabaya dan para wisatawan menjelajahi serta menemukan kuliner terbaik di kota ini dengan mudah. GolekMakanRek! bertujuan menjadi solusi bagi setiap orang yang ingin menikmati hidangan lezat, tanpa harus repot memilih di tengah keramaian kota.

## 👥 Anggota Kelompok
| Nama | NPM | Akun GitHub | 
| -- | -- | -- |
| Nisrina Annaisha Sarnadi | 2306275960 | [aisss](https://github.com/nsrnannaisha) |
| Kaindra Rizq Sachio | 2306274964 | [kaindraa](https://github.com/kaindraa) |
| Muhammad Afwan Hafizh | 2306208855 | [mir4na](https://github.com/mir4na) |
| Joshua Montolalu | 2306275746 | [HamletJr](https://github.com/HamletJr) |
| Ignasius Bramantya Widiprasetya | 2306245604 | [BramantyaWidiprasetya ](https://github.com/BramantyaWidiprasetya) |
| Muhammad Falah Marzuq | 2306202315 | [falahMarzuq](https://github.com/falahMarzuq)

## 🗒️ Deskripsi Aplikasi
**GolekMakanRek!** adalah sebuah aplikasi yang memberikan kemudahan bagi penduduk lokal maupun wisatawan untuk menjelajahi berbagai pilihan kuliner di Surabaya. Dengan desain yang sederhana tetapi intuitif, platform ini memungkinkan pengguna mencari restoran dan makanan sesuai selera mereka. Melalui fitur pencarian yang dapat difilter berdasarkan jenis makanan, lokasi, atau popularitas, pengguna dapat menemukan rekomendasi kuliner mulai dari makanan kaki lima hingga restoran berbintang dengan cepat dan mudah.

Selain melihat deskripsi restoran dan menu yang tersedia, pengguna juga dapat membaca ulasan dan melihat rating dari pengguna lain. Fitur ini sangat berguna untuk membantu dalam memilih tempat makan terbaik berdasarkan pengalaman orang lain. Uniknya, pengguna juga dapat berkontribusi dengan memberikan rating dan ulasan sendiri setelah mencicipi makanan dari restoran yang mereka kunjungi. Rating ini kemudian akan terakumulasi, memberikan gambaran yang lebih akurat tentang kualitas makanan dan layanan di setiap restoran yang terdaftar di GolekMakanRek!.

Pengalaman pengguna semakin dipersonalisasi dengan adanya fitur wishlist, yang artinya pengguna dapat menyimpan daftar makanan yang ingin dicoba di kemudian hari. Ini membuat GolekMakanRek! tidak hanya sekadar direktori makanan, tetapi juga tempat bagi komunitas kuliner untuk berbagi pengalaman, memberi rekomendasi, dan membantu orang lain menemukan tempat makan terbaik di Surabaya.
## 📔 Daftar Modul
Berikut adalah daftar modul yang akan di-implementasikan:
 
| Modul | Pengembang | Penjelasan |
| -- | -- | -- |
| **Autentikasi & Admin** | All | **Autentikasi:** Berperan mengatur Registrasi dan Login akun pengguna dan admin. <br> **Admin:** Berperan dalam mengelola konten aplikasi. Admin memiliki hak untuk menambahkan, menghapus, dan mengubah data restoran atau makanan. Selain itu, Admin juga dapat mengawasi dan memoderasi ulasan pengguna. |
| **User Dashboard** | Bram | Berisikan informasi pengguna seperti nama, umur, nomor handphone, dan alamat. Pengguna juga dapat mengedit informasi pribadinya. Selain itu, pengguna juga dapat memperoleh informasi Top 3 product recomendations|
| **Homepage: Search, Filter, Like** | Joshua | Pada homepage, pengguna dapat melihat dan mencari dari data-data yang tersedia pada aplikasi. Pengguna dapat memilih untuk mencari dari daftar restoran ataupun daftar makanan. Selain itu, pengguna dapat melakukan reaction yaitu menyukai makanan yang ditampilkan pada Homepage. Nantinya, angka dari *like* tersebut akan dijumlahkan dari semua user yang menyukai makanan tersebut. |
| **Restaurant Preview & Follow** | Ais | Fitur ini menampilkan restoran-restoran beserta deskripsinya. Ditampilkan pula daftar menu yang tersedia. Pengguna dapat memberikan rating yang hasilnya akan terakumulasi sebagai rating restoran dan melakukan _follow-unfollow_ restoran. |
| **Food Preview** | Hafizh | Pada fitur Food Preview, pengguna dapat memberikan ulasan dan rating mengenai produk makanan yang ada pada setiap restoran. Setiap ulasan yang diberikan akan ditampikan ketika pengguna melakukan klik pada button terkait “ulasan produk”. Selain itu, terdapat penghitungan rating yang memungkinkan hasil rata-rata dari setiap rating yang diberikan pengguna akan ditampilkan pada masing-masing produk makanan. |
| **Wishlist** | Falah | Pengguna dapat menambahkan suatu makanan ke dalam daftar berupa wishlist. Daftar ini berisikan makanan-makanan yang diinginkan pengguna. Pengguna dapat melihat daftar tersebut dan mengedit daftarnya seperti menambahkan makanan lainnya dan juga menghapus suatu makanan dari wishlist. |
| **Forum Kuliner** | Kaindra | Antar para pengguna dapat melakukan komunikasi dalam bentuk forum yang dibuat. Sebagai contoh, Pengguna A membuka topik pembicaraan di forum. Nantinya, Pengguna B atau Pengguna lainnya dapat ikut mengikuti forum tersebut dengan melakukan reply. |

## 🤺 *Role*/Peran Pengguna
### 1. 👨🏻‍💻 Pengguna
#### a. 🔐 Pengguna (terautentikasi)
Pengguna yang sudah melakukan register dan login dapat:
- Melakukan pencarian dan filtering daftar makanan dan restoran.
- Membuka fitur food preview dan restaurant preview.
- Membuka dan mengubah informasi pengguna pada user dashboard.
- Membuka dan menambahkan wishlist pribadi pengguna.
#### b. 🔒 Pengguna (belum terautentikasi)
Pengguna yang belum melakukan register dan login hanya dapat:
- Membuka homepage.
- Melakukan pencarian dan filtering daftar makanan dan restoran. 
- Membuka fitur food preview dan restaurant preview tetapi tidak bisa memberikan rating maupun ulasan.

## Alur Integrasi
Alur integrasi aplikasi Flutter ke proyek web kami adalah sebagai berikut:
1. Aplikasi Flutter akan menggunakan library `http` untuk melakukan *request* dan *response* HTTP kepada server Django, khususnya kepada endpoint yang mengembalikan data dalam bentuk JSON. 
2. Aplikasi Flutter juga akan menggunakan library `pbp_django_auth` untuk memfasilitasi proses otentikasi (login, logout, register) dan menyimpan *session* lewat *cookie*.
3. Untuk setiap model yang digunakan dalam aplikasi Django, akan dibuatkan model yang bersesuaian pada aplikasi Flutter untuk melakukan serialisasi dan deserialisasi data JSON ketika mengirim dan menerima data dari server Django.
4. Untuk menerima request GET dan POST dari Flutter, akan dibuatkan endpoint (jika diperlukan) yang dapat mengolah request berisi JSON (POST) dari Flutter. Endpoint ini juga dapat mengembalikan response JSON (GET & POST) yang akan di-*parse* dan diolah oleh aplikasi Flutter.

## *Dataset* yang Digunakan
Dataset yang digunakan berasal dari [Kaggle - Indonesia food delivery Gofood product list](https://www.kaggle.com/datasets/ariqsyahalam/indonesia-food-delivery-gofood-product-list).

## Video Aplikasi
Link video iklan aplikasi [GolekMakanRek! - Aplikasi Pecinta Kuliner Surabaya](https://www.canva.com/design/DAGZ_amFZD0/2i301yF57D61PJ0H9fpb_A/watch?utm_content=DAGZ_amFZD0&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h18464180a9).

## Berita Acara Kelompok F10
Berita acara kelompok F10 dapat diakses di [link berikut](https://docs.google.com/spreadsheets/d/1wk12z7HfZcbrUoaX8TTx7DbVCwNlyiNLAyX6wdyXSx8/edit?gid=0#gid=0)


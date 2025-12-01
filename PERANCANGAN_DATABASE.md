# PERANCANGAN DATA - PIZZA DELIVERY APP

## TABEL YANG SUDAH ADA (REVISI)

### 1. SPESIFIKASI TABEL AKUN

**Nama Tabel:** `tb_akun`  
**Primary Key:** `id_akun`

| Kolom       | Tipe Data                            | Keterangan                    |
| ----------- | ------------------------------------ | ----------------------------- |
| id_akun     | INT (PK, AUTO_INCREMENT)             | ID unik                       |
| nama        | VARCHAR(100)                         | Nama pengguna                 |
| email       | VARCHAR(100) UNIQUE                  | Unik untuk login              |
| password    | VARCHAR(255)                         | Disimpan dalam bentuk hash    |
| no_hp       | VARCHAR(20)                          | Nomor telepon                 |
| alamat      | TEXT                                 | Alamat lengkap pelanggan      |
| role        | ENUM('pelanggan', 'driver', 'staff') | Hak akses                     |
| foto_profil | VARCHAR(255)                         | Path gambar profil (opsional) |
| created_at  | TIMESTAMP                            | Waktu registrasi              |
| updated_at  | TIMESTAMP                            | Waktu update terakhir         |

---

### 2. SPESIFIKASI TABEL MENU

**Nama Tabel:** `tb_menu`  
**Primary Key:** `id_menu`

| Kolom                 | Tipe Data                                   | Keterangan               |
| --------------------- | ------------------------------------------- | ------------------------ |
| id_menu               | INT (PK, AUTO_INCREMENT)                    | ID unik                  |
| nama_menu             | VARCHAR(100)                                | Nama makanan/minuman     |
| deskripsi             | TEXT                                        | Keterangan singkat       |
| kategori              | ENUM('pizza','minuman','dessert','lainnya') | Jenis menu               |
| harga                 | DECIMAL(10,2)                               | Harga per item           |
| stok                  | INT                                         | Jumlah tersedia          |
| status                | ENUM('tersedia','habis')                    | Status ketersediaan      |
| gambar                | VARCHAR(255)                                | Path foto menu           |
| **discount**          | INT DEFAULT 0                               | Diskon (dalam persen)    |
| **is_favorite_count** | INT DEFAULT 0                               | Jumlah yang nge-favorite |
| created_at            | TIMESTAMP                                   | Waktu ditambahkan        |
| updated_at            | TIMESTAMP                                   | Waktu update terakhir    |

---

### 3. SPESIFIKASI TABEL PESANAN

**Nama Tabel:** `tb_pesanan`  
**Primary Key:** `id_pesanan`

| Kolom              | Tipe Data                                                   | Keterangan                        |
| ------------------ | ----------------------------------------------------------- | --------------------------------- |
| id_pesanan         | INT (PK, AUTO_INCREMENT)                                    | ID unik                           |
| id_akun            | INT (FK → tb_akun)                                          | Pelanggan                         |
| id_driver          | INT (FK → tb_akun) NULL                                     | Pengantar (nullable)              |
| tanggal_pesan      | DATETIME                                                    | Waktu transaksi                   |
| alamat_kirim       | TEXT                                                        | Alamat pengiriman                 |
| **nama_alamat**    | VARCHAR(50)                                                 | Label alamat (Rumah, Kantor, dll) |
| total_harga        | DECIMAL(10,2)                                               | Total keseluruhan                 |
| **subtotal**       | DECIMAL(10,2)                                               | Subtotal sebelum ongkir           |
| **ongkir**         | DECIMAL(10,2) DEFAULT 0                                     | Biaya pengiriman                  |
| metode_bayar       | ENUM('tunai', 'kartu', 'e-wallet')                          | Metode pembayaran                 |
| status_pesanan     | ENUM('pending','diproses','dikirim','selesai','dibatalkan') | Status proses                     |
| **alasan_batal**   | TEXT NULL                                                   | Alasan pembatalan pesanan         |
| id_outlet          | INT (FK → tb_outlet)                                        | Lokasi restoran                   |
| catatan            | TEXT NULL                                                   | Catatan pelanggan                 |
| **estimasi_waktu** | INT DEFAULT 30                                              | Estimasi pengiriman (menit)       |
| created_at         | TIMESTAMP                                                   | Waktu dibuat                      |
| updated_at         | TIMESTAMP                                                   | Waktu update terakhir             |

---

### 4. SPESIFIKASI TABEL OUTLET

**Nama Tabel:** `tb_outlet`  
**Primary Key:** `id_outlet`

| Kolom           | Tipe Data                       | Keterangan                     |
| --------------- | ------------------------------- | ------------------------------ |
| id_outlet       | INT (PK, AUTO_INCREMENT)        | ID unik outlet                 |
| nama_outlet     | VARCHAR(100)                    | Nama outlet dan lokasi cabang  |
| alamat          | TEXT                            | Alamat lengkap outlet          |
| kota            | VARCHAR(50)                     | Kota lokasi outlet             |
| latitude        | DECIMAL(10,8)                   | Koordinat lokasi outlet (peta) |
| longitude       | DECIMAL(11,8)                   | Koordinat lokasi outlet (peta) |
| no_telp         | VARCHAR(20)                     | Nomor kontak outlet            |
| jam_operasional | VARCHAR(50)                     | Misal: "09:00–22:00"           |
| status_outlet   | ENUM('aktif','tutup sementara') | Status operasional outlet      |
| created_at      | TIMESTAMP                       | Waktu ditambahkan              |
| updated_at      | TIMESTAMP                       | Waktu update terakhir          |

---

## TABEL BARU YANG PERLU DITAMBAHKAN

### 5. SPESIFIKASI TABEL DETAIL PESANAN ⭐ BARU

**Nama Tabel:** `tb_detail_pesanan`  
**Primary Key:** `id_detail`

| Kolom        | Tipe Data                                         | Keterangan                    |
| ------------ | ------------------------------------------------- | ----------------------------- |
| id_detail    | INT (PK, AUTO_INCREMENT)                          | ID unik detail                |
| id_pesanan   | INT (FK → tb_pesanan)                             | Mengacu ke pesanan            |
| id_menu      | INT (FK → tb_menu)                                | Menu yang dipesan             |
| nama_menu    | VARCHAR(100)                                      | Nama menu (snapshot)          |
| harga_satuan | DECIMAL(10,2)                                     | Harga per item saat transaksi |
| jumlah       | INT                                               | Quantity                      |
| porsi        | ENUM('personal','medium','familiar','jumbo') NULL | Ukuran pizza                  |
| subtotal     | DECIMAL(10,2)                                     | harga_satuan × jumlah         |
| created_at   | TIMESTAMP                                         | Waktu ditambahkan             |

**Fungsi:** Menyimpan detail item yang dipesan (karena 1 pesanan bisa banyak item)

---

### 6. SPESIFIKASI TABEL ALAMAT PENGIRIMAN ⭐ BARU

**Nama Tabel:** `tb_alamat_pengiriman`  
**Primary Key:** `id_alamat`

| Kolom          | Tipe Data                | Keterangan                      |
| -------------- | ------------------------ | ------------------------------- |
| id_alamat      | INT (PK, AUTO_INCREMENT) | ID unik alamat                  |
| id_akun        | INT (FK → tb_akun)       | Pemilik alamat                  |
| nama_alamat    | VARCHAR(50)              | Label (Rumah Ryan, Kantor, dll) |
| alamat_lengkap | TEXT                     | Alamat detail                   |
| kota           | VARCHAR(50)              | Kota                            |
| kecamatan      | VARCHAR(50)              | Kecamatan                       |
| kode_pos       | VARCHAR(10)              | Kode pos                        |
| latitude       | DECIMAL(10,8) NULL       | Koordinat (opsional)            |
| longitude      | DECIMAL(11,8) NULL       | Koordinat (opsional)            |
| is_default     | BOOLEAN DEFAULT FALSE    | Alamat utama                    |
| catatan_alamat | TEXT NULL                | Patokan/catatan                 |
| created_at     | TIMESTAMP                | Waktu ditambahkan               |
| updated_at     | TIMESTAMP                | Waktu update terakhir           |

**Fungsi:** Menyimpan multiple alamat per user (sesuai fitur app yang ada)

---

### 7. SPESIFIKASI TABEL FAVORIT ⭐ BARU

**Nama Tabel:** `tb_favorit`  
**Primary Key:** `id_favorit`

| Kolom      | Tipe Data                | Keterangan             |
| ---------- | ------------------------ | ---------------------- |
| id_favorit | INT (PK, AUTO_INCREMENT) | ID unik favorit        |
| id_akun    | INT (FK → tb_akun)       | Pelanggan              |
| id_menu    | INT (FK → tb_menu)       | Menu yang difavoritkan |
| created_at | TIMESTAMP                | Waktu ditambahkan      |

**Index:** UNIQUE(id_akun, id_menu) - prevent duplicate  
**Fungsi:** Menyimpan menu favorit user (sesuai fitur love/favorite di app)

---

### 8. SPESIFIKASI TABEL ULASAN (REVIEW) ⭐ BARU

**Nama Tabel:** `tb_ulasan`  
**Primary Key:** `id_ulasan`

| Kolom          | Tipe Data                              | Keterangan                 |
| -------------- | -------------------------------------- | -------------------------- |
| id_ulasan      | INT (PK, AUTO_INCREMENT)               | ID unik ulasan             |
| id_akun        | INT (FK → tb_akun)                     | Pelanggan yang review      |
| id_menu        | INT (FK → tb_menu)                     | Menu yang direview         |
| id_pesanan     | INT (FK → tb_pesanan) NULL             | Pesanan terkait (opsional) |
| rating         | INT CHECK(rating >= 1 AND rating <= 5) | Bintang 1-5                |
| komentar       | TEXT                                   | Isi ulasan                 |
| tanggal_ulasan | DATETIME                               | Waktu review dibuat        |
| helpful_count  | INT DEFAULT 0                          | Jumlah yang klik "helpful" |
| created_at     | TIMESTAMP                              | Waktu ditambahkan          |

**Fungsi:** Menyimpan review pelanggan (sesuai fitur Leave Review di app)

---

### 9. SPESIFIKASI TABEL KERANJANG (CART) ⭐ BARU

**Nama Tabel:** `tb_keranjang`  
**Primary Key:** `id_keranjang`

| Kolom        | Tipe Data                                         | Keterangan                |
| ------------ | ------------------------------------------------- | ------------------------- |
| id_keranjang | INT (PK, AUTO_INCREMENT)                          | ID unik cart              |
| id_akun      | INT (FK → tb_akun)                                | Pelanggan                 |
| id_menu      | INT (FK → tb_menu)                                | Menu dalam cart           |
| jumlah       | INT                                               | Quantity                  |
| porsi        | ENUM('personal','medium','familiar','jumbo') NULL | Ukuran pizza              |
| harga_satuan | DECIMAL(10,2)                                     | Harga saat ditambahkan    |
| created_at   | TIMESTAMP                                         | Waktu ditambahkan ke cart |
| updated_at   | TIMESTAMP                                         | Waktu update terakhir     |

**Fungsi:** Temporary storage sebelum checkout (persistent cart)

---

### 10. SPESIFIKASI TABEL PROMOSI ⭐ BARU

**Nama Tabel:** `tb_promosi`  
**Primary Key:** `id_promosi`

| Kolom           | Tipe Data                                            | Keterangan                        |
| --------------- | ---------------------------------------------------- | --------------------------------- |
| id_promosi      | INT (PK, AUTO_INCREMENT)                             | ID unik promosi                   |
| judul           | VARCHAR(100)                                         | Judul promosi                     |
| deskripsi       | TEXT                                                 | Detail promosi                    |
| tipe_promosi    | ENUM('diskon_persen','diskon_nominal','buy_1_get_1') | Jenis promo                       |
| nilai_diskon    | DECIMAL(10,2)                                        | Nilai diskon                      |
| tanggal_mulai   | DATE                                                 | Mulai berlaku                     |
| tanggal_selesai | DATE                                                 | Akhir promo                       |
| id_menu         | INT (FK → tb_menu) NULL                              | Menu spesifik (NULL = semua menu) |
| kode_promo      | VARCHAR(20) UNIQUE NULL                              | Kode voucher (opsional)           |
| min_pembelian   | DECIMAL(10,2) DEFAULT 0                              | Minimal transaksi                 |
| status          | ENUM('aktif','nonaktif')                             | Status promo                      |
| banner_image    | VARCHAR(255) NULL                                    | Gambar banner promo               |
| created_at      | TIMESTAMP                                            | Waktu dibuat                      |

**Fungsi:** Sistem promosi & diskon (sesuai fitur "You Might Like" di app)

---

### 11. SPESIFIKASI TABEL NOTIFIKASI ⭐ BARU

**Nama Tabel:** `tb_notifikasi`  
**Primary Key:** `id_notifikasi`

| Kolom         | Tipe Data                                       | Keterangan              |
| ------------- | ----------------------------------------------- | ----------------------- |
| id_notifikasi | INT (PK, AUTO_INCREMENT)                        | ID unik notifikasi      |
| id_akun       | INT (FK → tb_akun)                              | Penerima notifikasi     |
| judul         | VARCHAR(100)                                    | Judul notif             |
| pesan         | TEXT                                            | Isi notifikasi          |
| tipe          | ENUM('pesanan','promosi','sistem','pengiriman') | Kategori notif          |
| is_read       | BOOLEAN DEFAULT FALSE                           | Status sudah dibaca     |
| link_terkait  | VARCHAR(255) NULL                               | Link ke halaman terkait |
| icon          | VARCHAR(50) NULL                                | Nama icon               |
| created_at    | TIMESTAMP                                       | Waktu notif dibuat      |

**Fungsi:** Sistem notifikasi (sesuai halaman Notifications di app)

---

## TABEL LOG (REVISI)

### 12. SPESIFIKASI TABEL LOG RIWAYAT PEMESANAN (REVISI)

**Nama Tabel:** `tb_log_riwayat_pemesanan`  
**Primary Key:** `id_riwayat_pemesanan`

| Kolom                | Tipe Data                        | Keterangan           |
| -------------------- | -------------------------------- | -------------------- |
| id_riwayat_pemesanan | INT (PK, AUTO_INCREMENT)         | ID unik riwayat      |
| id_pesanan           | INT (FK → tb_pesanan)            | Pesanan terkait      |
| id_pelanggan         | INT (FK → tb_akun)               | Pelanggan            |
| tanggal_pemesanan    | DATETIME                         | Waktu pesanan dibuat |
| status_pesanan       | ENUM('selesai','dibatalkan')     | Status akhir         |
| total_harga          | DECIMAL(10,2)                    | Total pembayaran     |
| metode_pembayaran    | ENUM('tunai','kartu','e-wallet') | Metode bayar         |
| id_outlet            | INT (FK → tb_outlet)             | Outlet asal          |
| alamat_kirim         | TEXT                             | Alamat pengiriman    |
| **jumlah_item**      | INT                              | Total item dipesan   |
| created_at           | TIMESTAMP                        | Waktu log dibuat     |

**Note:** Pisahkan ulasan ke tabel `tb_ulasan` (sudah ada di atas)

---

### 13. SPESIFIKASI TABEL LOG RIWAYAT PENGANTARAN (REVISI)

**Nama Tabel:** `tb_log_riwayat_pengantaran`  
**Primary Key:** `id_riwayat_pengantaran`

| Kolom                  | Tipe Data                                    | Keterangan                       |
| ---------------------- | -------------------------------------------- | -------------------------------- |
| id_riwayat_pengantaran | INT (PK, AUTO_INCREMENT)                     | ID unik riwayat                  |
| id_pesanan             | INT (FK → tb_pesanan)                        | Pesanan yang dikirim             |
| id_driver              | INT (FK → tb_akun)                           | Driver                           |
| id_outlet              | INT (FK → tb_outlet)                         | Outlet asal                      |
| waktu_ambil            | DATETIME                                     | Waktu ambil dari outlet          |
| waktu_kirim            | DATETIME                                     | Waktu mulai kirim                |
| waktu_selesai          | DATETIME                                     | Waktu sampai                     |
| status_pengantaran     | ENUM('menunggu','dikirim','selesai','gagal') | Status                           |
| jarak_tempuh           | DECIMAL(5,2)                                 | Jarak (km)                       |
| waktu_pengantaran      | INT                                          | Durasi antar (menit)             |
| catatan_driver         | TEXT NULL                                    | Catatan dari driver              |
| **lokasi_real_time**   | TEXT NULL                                    | Koordinat saat ini (JSON format) |
| created_at             | TIMESTAMP                                    | Waktu log dibuat                 |
| updated_at             | TIMESTAMP                                    | Update terakhir                  |

---

## RELASI ANTAR TABEL

### Entity Relationship:

```
tb_akun (1) ←→ (N) tb_pesanan
tb_akun (1) ←→ (N) tb_alamat_pengiriman
tb_akun (1) ←→ (N) tb_favorit
tb_akun (1) ←→ (N) tb_ulasan
tb_akun (1) ←→ (N) tb_keranjang
tb_akun (1) ←→ (N) tb_notifikasi

tb_menu (1) ←→ (N) tb_detail_pesanan
tb_menu (1) ←→ (N) tb_favorit
tb_menu (1) ←→ (N) tb_ulasan
tb_menu (1) ←→ (N) tb_keranjang
tb_menu (1) ←→ (1) tb_promosi

tb_pesanan (1) ←→ (N) tb_detail_pesanan
tb_pesanan (1) ←→ (1) tb_log_riwayat_pemesanan
tb_pesanan (1) ←→ (1) tb_log_riwayat_pengantaran

tb_outlet (1) ←→ (N) tb_pesanan
tb_outlet (1) ←→ (N) tb_log_riwayat_pengantaran
```

---

## INDEXING YANG DISARANKAN

### Untuk Performa Query:

```sql
-- Tabel Akun
CREATE INDEX idx_email ON tb_akun(email);
CREATE INDEX idx_role ON tb_akun(role);

-- Tabel Menu
CREATE INDEX idx_kategori ON tb_menu(kategori);
CREATE INDEX idx_status ON tb_menu(status);

-- Tabel Pesanan
CREATE INDEX idx_akun_pesanan ON tb_pesanan(id_akun);
CREATE INDEX idx_status_pesanan ON tb_pesanan(status_pesanan);
CREATE INDEX idx_tanggal ON tb_pesanan(tanggal_pesan);

-- Tabel Detail Pesanan
CREATE INDEX idx_pesanan_detail ON tb_detail_pesanan(id_pesanan);

-- Tabel Favorit
CREATE UNIQUE INDEX idx_favorit_unique ON tb_favorit(id_akun, id_menu);

-- Tabel Ulasan
CREATE INDEX idx_menu_ulasan ON tb_ulasan(id_menu);
CREATE INDEX idx_akun_ulasan ON tb_ulasan(id_akun);

-- Tabel Notifikasi
CREATE INDEX idx_akun_notif ON tb_notifikasi(id_akun);
CREATE INDEX idx_is_read ON tb_notifikasi(is_read);
```

---

## RINGKASAN TABEL

### Tabel Utama (4):

1. ✅ tb_akun
2. ✅ tb_menu
3. ✅ tb_pesanan
4. ✅ tb_outlet

### Tabel Tambahan (7):

5. ⭐ tb_detail_pesanan (WAJIB)
6. ⭐ tb_alamat_pengiriman (WAJIB)
7. ⭐ tb_favorit (WAJIB)
8. ⭐ tb_ulasan (WAJIB)
9. ⭐ tb_keranjang (WAJIB)
10. ⭐ tb_promosi (WAJIB)
11. ⭐ tb_notifikasi (WAJIB)

### Tabel Log (2):

12. ✅ tb_log_riwayat_pemesanan (REVISI)
13. ✅ tb_log_riwayat_pengantaran (REVISI)

**Total: 13 Tabel**

---

## CATATAN PENTING

1. **tb_detail_pesanan** WAJIB ada karena 1 pesanan bisa punya banyak item
2. **tb_alamat_pengiriman** diperlukan untuk fitur "Delivery Address" yang sudah ada di app
3. **tb_favorit** untuk fitur love/favorite menu
4. **tb_ulasan** untuk fitur "Leave Review" dan "My Reviews"
5. **tb_keranjang** untuk persistent cart (data tidak hilang saat logout)
6. **tb_promosi** untuk fitur "You Might Like" dan sistem diskon
7. **tb_notifikasi** untuk halaman Notifications

Semua tabel sudah disesuaikan dengan fitur yang ada di aplikasi Flutter yang sudah kita buat! 🎉

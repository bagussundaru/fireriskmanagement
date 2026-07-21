# Fire Risk Assessment - Hybrid AHP-Fuzzy Decision Support System

Sebuah sistem cerdas berbasis instrumen audit digital yang dirancang untuk mengukur tingkat kepatuhan standar keselamatan dan manajemen pencegahan kebakaran di suatu fasilitas pabrik. 

Berbeda dari aplikasi ceklis statis konvensional, aplikasi ini terintegrasi dengan mesin kecerdasan komputasional **Hybrid AHP-Fuzzy Inference System**. Ini menjadikannya sebuah *Decision Support System* (Sistem Pendukung Keputusan) yang memiliki landasan teori mumpuni dan bebas dari probabilitas ambang batas yang bias (*Crisp Boundary Bias*), sehingga sangat bernilai untuk kebaruan akademis (*Academic Novelty*).

## ✨ Fitur Utama
- **Penilaian Berbasis AHP-Fuzzy**: Kalkulasi risiko dinilai secara objektif dengan agregasi _Mamdani/Sugeno Fuzzy Rules_ dan bobot matriks kepentingan relatif AHP.
- **Manajemen Survei Multi-Draf**: Asesor dapat mengevaluasi 5 pabrik serentak di lapangan dan menunda/menyimpan proses sementara asinkron dengan _Local Storage Component_.
- **Sistem Hierarki Kategorikal**: Menyajikan 87 parameter pemeriksaan esensial mencakup *Legal Compliance*, *Fire Prevention Measures*, *Fire Protection System*, dan *Evacuation/Emergency*.
- **Otomatisasi Laporan (PDF Export)**: Menyajikan dokumen audit komprehensif, valid secara administratif yang diperkuat dengan slogan dan metrik sertifikasi komputasional.
- **Clean Light/Corporate Aesthetic**: Antarmuka terpoles untuk kenyamanan pandang standar perbankan / audit ekstensif.

---

## 🔬 Kerangka Teori Matematis (Bahan Diskusi Disertasi)

Kekuatan inti aplikasi ini berada pada dua fondasi teori yang menyokong `ScoringService`:

### 1. Analytic Hierarchy Process (AHP) Weighting
Aplikasi mendistribusikan pengaruh tiap kategori tidak berasaskan kehendak subjektif seorang _Data Entry_, melainkan menggunakan bobot matriks turunan *Eigenvector*. Proporsi yang disimulasikan dari persetujuan konsensus pakar diformulasikan ke dalam basis data sebagai:
- **(A) Legal Compliance**: `15.0%`
- **(B) Fire Prevention Measures**: `38.0%`
- **(C) Fire Protection System**: `27.0%`
- **(D) Evacuation and Emergency Preparedness**: `20.0%`

### 2. Fuzzy Comprehensive Evaluation Matrix
Aplikasi menolak cara pemotongan konvensional *(misalnya: Jika > 70% maka "Aman")*. Komputasi yang terjadi secara senyap (_under the hood_) pada `FuzzyLogicService.dart` mengeksekusi tahapan berikut:
1. **Fuzzifikasi Input**: Skor audit murni per kategori dimasukkan ke dalam fungsi keanggotaan *(Membership Function)* bersudut tumpul (_Trapezoidal/Triangular_) demi melabelkan nilai probabilitas sebagai tipe himpunan `Danger`, `Warning`, atau `Safe`.
2. **Matrix Aggregation**: Derajat himpunan linguistik dikalikan dengan bobot *Eigenvector* AHP yang mengkalkulasi sebuah *Fuzzy Synthesis Decision Vector*. Alih-alih mendapatkan satu angka mentah, skor akan terpetakan di 3 sumbu probabilitas.
3. **Defuzzifikasi (*Sugeno Centroid*)**: Mengekstrak kembali gabungan probabilitas *Fuzzy* ke *Crisp Point* yang akurat guna menjustifikasi keputusan level akhir keparahan fasilitas (*LOW*, *MEDIUM*, atau *HIGH Risk*).

---

## 🚀 Panduan Eksekusi Teknis (*Deploy* di VPS Linux)

Sistem rekayasa ini dikonstruksi utuh di jembatan kerja kerangka **Flutter**. Karena ini disasarkan ke sebuah *Virtual Private Server* (VPS), metode yang paling elegan adalah men-*deploy*-nya secara kompilasi **Web Server** melalui penanganan infrastruktur peladen `Nginx`.

### Persyaratan VPS *(Prerequisites)* 
- Sistem Operasi Ubuntu/Debian terbaru.
- `git` untuk kloning modul (atau bisa metode *push/pull* Anda).
- Akses ke profil root VPS (`sudo`).
- SDK `flutter` terpasang penuh pada variabel _environment_ VPS.

### Langkah 1: Penarikan Kode di Lingkungan Produksi (VPS)
Masuk terminal _remote_ SSH pada VPS Anda:
```bash
# Ubah /var/www ke direktori penyimpanan website
cd /var/www
# Kloning sistem langsung dari repositori Anda
git clone https://github.com/bagussundaru/fireriskmanagement.git
# Pindah ke akar direktori proyek
cd fireriskmanagement/fire_risk_flutter
```

### Langkah 2: Konstruksi Bangun (Production Build)
Selesaikan masalah _dependencies_ dan berikan instruksi _generate web bundle_ ke mesin server Dart/Flutter.
```bash
# Selesaikan masalah library terutama (shared_preferences, dsb)
flutter pub get

# Lakukan kompilasi pemampatan proyek khusus distribusi Web production
flutter build web --release 
```
*Hasil proses di atas akan memekarkan repositori kode termampatkan HTML/Javascript di folder `build/web`.*

### Langkah 3: Konfigurasi NGINX Web Server
Konfigurasi Nginx untuk menyampaikan statik berkas aplikasi Flutter.

```bash
# Pastikan Nginx Terpasang
sudo apt update
sudo apt install nginx -y

# Buat blok konfigurasi virtual host khusus
sudo nano /etc/nginx/sites-available/firerisk-app
```

Masukkan _script directive_ berikut (Ubah nama `server_name` dengan IP Publik Server Anda atau Nama Domain):
```nginx
server {
    listen 80;
    server_name IP_ADDRESS_VPS_ANDA; # Contoh: 192.168.10.15 atau firerisk.examole.com

    # Arahkan target direktori akses secara tepat ke luaran folder 'build/web'
    root /var/www/fireriskmanagement/fire_risk_flutter/build/web;
    index index.html;

    location / {
        # Agar navigasi internal browser Flutter tidak rusak saat Anda menekan f5 (refresh)
        try_files $uri $uri/ /index.html;
    }
}
```
Simpan dan keluarlah dari peramban nano teks (Ctrl+O, Enter, Ctrl+X).

### Langkah 4: Aktivasikan & Verifikasi Koneksi
Nyalakan tautan proksi dari blok _sites-available_ tadi ke sistem publik mesin Nginx dan perbarui layanannya.
```bash
sudo ln -s /etc/nginx/sites-available/firerisk-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

> **Verifikasi Keberhasilan Ceklis:** Cobalah untuk mengetikkan IP Adress VPS Anda dari peramban peranti Desktop/Ponsel dan sistem AHP-Fuzzy Assessment ini seyogianya langsung menyambut pengguna.

---
**Pusat Integrasi Tambahan (Supabase)**: Jika Anda ingin kembali menyalakan sinkronisasi pangkalan data yang memanjang antar mesin penilai (sirkulasi penyimpanan asessor lapangan secara global), pastikan Anda menyediakan nilai token _Supabase_ valid di file arsitektur internal: `lib/services/supabase_service.dart`.

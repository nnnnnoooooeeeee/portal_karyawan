# Portal Karyawan (proof of concept)

Aplikasi Flutter untuk Android dan web (PWA). Belum memakai database:
semua data adalah contoh yang disimpan di memori.

## Fitur

- Daftar dan masuk (akun demo: `demo@perusahaan.com` / `demo123`)
- Beranda dengan ringkasan cuti, slip gaji, event, dan survey
- Berita: cari, saring kategori, suka, komentar
- Event: kalender bulanan dengan penanda tanggal, daftar event, tombol ikut
- Layanan: pengajuan cuti, slip gaji (nominal bisa disembunyikan), survey
- Profil: ubah data, pilih mode terang/gelap, keluar
- Tata letak menyesuaikan: sidebar di PC, rail ikon di tablet, menu bawah di HP

## Yang tersimpan dan yang tidak

Tersimpan di perangkat (shared_preferences): akun yang didaftarkan, sesi
login, dan pilihan tema. Kata sandi disimpan apa adanya, jadi ini hanya
untuk percobaan.

Tidak tersimpan (hilang saat aplikasi ditutup atau halaman dimuat ulang):
suka, komentar, pengajuan cuti, jawaban survey, dan pendaftaran event.

## Menjalankan di komputer

Perlu Flutter SDK (channel stable).

```
flutter create --platforms=android,web --project-name portal_karyawan .
flutter pub get
flutter run -d chrome
```

Perintah `flutter create` membuat folder `android/` dan `web/`. File yang
sudah ada tidak ditimpa. Sebaiknya commit kedua folder itu ke repo.
Hapus `test/widget_test.dart` yang ikut dibuat, karena isinya mengacu ke
aplikasi contoh bawaan Flutter.

## Build otomatis (GitHub Actions)

Workflow ada di `.github/workflows/build.yml`.

1. Buat repo di GitHub dan push project ini ke branch `main`.
2. Buka Settings > Pages, lalu pilih Source: **GitHub Actions**.
3. Setiap push ke `main`, versi web dibangun dan dipasang di
   `https://<user>.github.io/<nama-repo>/`.
4. Untuk APK, buat tag lalu push:

   ```
   git tag v0.1.0
   git push origin v0.1.0
   ```

   APK muncul di halaman Releases. Workflow juga bisa dijalankan manual
   dari tab Actions.

## Memasang di iPhone atau iPad

Buka alamat web di Safari, ketuk tombol Bagikan, lalu pilih
"Tambahkan ke Layar Utama".

## Catatan

- APK ditandatangani dengan kunci debug yang dibuat ulang di setiap build.
  Untuk memasang versi baru, hapus dulu versi lama. Sebelum dipakai
  sungguhan, siapkan keystore sendiri.
- Nama aplikasi di Android bisa diubah di
  `android/app/src/main/AndroidManifest.xml` (`android:label`), dan nama
  PWA di `web/manifest.json` serta `web/index.html`.
- Repo GitHub gratis harus publik agar bisa memakai GitHub Pages.

# Portal Karyawan (proof of concept)

Aplikasi Flutter untuk Android dan web (PWA). Belum memakai database:
semua data adalah contoh yang disimpan di memori.

## Fitur

- Daftar dan masuk memakai no. finger (akun demo: no. finger `1001` /
  kata sandi `demo123`)
- Beranda dengan ringkasan cuti, slip gaji, event, dan survey
- Berita: cari, saring kategori, suka, komentar
- Event: kalender bulanan dengan penanda tanggal, daftar event, tombol ikut
- Layanan: sisa cuti (hanya lihat, tanpa pengajuan), slip gaji (nominal
  bisa disembunyikan), survey
- Profil: NIK, no. finger, departemen, dan jabatan (tidak bisa diubah
  karyawan), mode terang/gelap, bahasa, tes notifikasi, cek update, keluar
- Bahasa Indonesia dan Inggris
- Update dalam aplikasi (Android): pemberitahuan saat ada versi baru, lalu
  unduh dan pasang tanpa membuka GitHub
- Tata letak menyesuaikan: sidebar di PC, rail ikon di tablet, menu bawah di HP

## Yang tersimpan dan yang tidak

Tersimpan di perangkat (shared_preferences): akun yang didaftarkan, sesi
login, pilihan tema, dan pilihan bahasa. Kata sandi disimpan apa adanya,
jadi ini hanya untuk percobaan.

Tidak tersimpan (hilang saat aplikasi ditutup atau halaman dimuat ulang):
suka, komentar, jawaban survey, dan pendaftaran event.

## Menambah bahasa

1. Salin `lib/l10n/id.dart` menjadi file baru, misalnya `lib/l10n/jv.dart`,
   lalu ganti nama variabelnya (misalnya `kTextJv`).
2. Terjemahkan nilainya. Kunci di sebelah kiri jangan diubah.
3. Daftarkan di `kLanguages` dalam `lib/l10n.dart`:
   `Language('jv', 'Basa Jawa', kTextJv),`

Bahasa baru langsung muncul di halaman masuk dan Profil. Teks yang belum
diterjemahkan memakai bahasa Indonesia. `flutter test` memeriksa apakah
ada kunci yang terlewat.

Isi berita, event, survey, dan slip gaji adalah data contoh, jadi tidak
ikut diterjemahkan.

## Menjalankan di komputer

Perlu Flutter SDK (channel stable).

```
flutter create --platforms=android,web --project-name portal_karyawan .
flutter pub get
flutter run -d chrome
```

Perintah `flutter create` membuat folder `android/` dan `web/`. File yang
sudah ada tidak ditimpa. Kedua folder itu sudah ada di repo ini.

## Build (GitHub Actions)

Workflow ada di `.github/workflows/build.yml`.

1. Buat repo di GitHub dan push project ini ke branch `main`.
2. Buka Settings > Pages, lalu pilih Source: **GitHub Actions**.
3. Workflow hanya dijalankan manual. Buka tab Actions, pilih
   "Build Android dan Web", tekan **Run workflow**, lalu isi:
   - **versi**: nomor versi, misalnya `0.2.0`
   - **jenis**:
     - `rilis`: siap dipakai semua orang. APK diunggah sebagai rilis
       `v0.2.0`, aplikasi di HP pengguna menawarkan update, dan versi web
       dipasang di `https://<user>.github.io/<nama-repo>/` (kalau
       dijalankan dari branch `main`).
     - `eksperimental`: hanya untuk dicoba. APK diunggah sebagai pra-rilis
       `v0.2.0-exp.<nomor run>`, pengguna tidak diberi tahu, dan versi web
       tidak diubah. Unduh APK-nya dari halaman Releases untuk dites.

   Nomor versi rilis harus lebih tinggi dari rilis sebelumnya supaya
   ditawarkan sebagai update. HP yang sudah memasang build eksperimental
   `0.2.0` tidak ditawari rilis `0.2.0` karena nomornya sama; pakai nomor
   berikutnya untuk rilis, atau pasang rilisnya secara manual.

## Update dalam aplikasi

Setiap dibuka, aplikasi Android membandingkan versinya dengan rilis terbaru
di GitHub. Kalau ada yang lebih baru, muncul dialog; karyawan menekan
Update, APK diunduh di dalam aplikasi, lalu layar pemasangan Android
terbuka. Android tetap meminta konfirmasi pasang, dan pada update pertama
meminta izin "pasang aplikasi dari sumber ini". Tombol "Cek update" juga
ada di Profil.

Supaya update bisa dipasang di atas versi lama, semua rilis harus
ditandatangani dengan kunci yang sama. Siapkan sekali saja:

1. Buat keystore (simpan file dan kata sandinya, jangan sampai hilang):

   ```
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Di GitHub, buka Settings > Secrets and variables > Actions, lalu buat
   empat secret:
   - `KEYSTORE_BASE64`: isi file keystore dalam base64
     (PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))`)
   - `KEYSTORE_PASSWORD`: kata sandi keystore
   - `KEY_ALIAS`: `upload`
   - `KEY_PASSWORD`: kata sandi kunci (biasanya sama dengan kata sandi keystore)

Tanpa secret itu, build tetap jalan tapi memakai kunci debug yang berbeda
di setiap build, sehingga update gagal dipasang. HP yang masih memakai APK
lama (sebelum ada kunci tetap) perlu menghapus aplikasi lalu memasang
ulang satu kali.

Untuk build rilis di komputer sendiri, buat `android/key.properties`
(tidak ikut di git) berisi `storeFile`, `storePassword`, `keyAlias`, dan
`keyPassword`; `storeFile` relatif terhadap `android/app/`.

## Memasang di iPhone atau iPad

Buka alamat web di Safari, ketuk tombol Bagikan, lalu pilih
"Tambahkan ke Layar Utama".

## Catatan

- Tes notifikasi dan update dalam aplikasi hanya ada di aplikasi Android,
  tidak di versi web.
- Nama aplikasi di Android bisa diubah di
  `android/app/src/main/AndroidManifest.xml` (`android:label`), dan nama
  PWA di `web/manifest.json` serta `web/index.html`.
- Repo GitHub gratis harus publik agar bisa memakai GitHub Pages.

import 'l10n/en.dart';
import 'l10n/id.dart';

class Language {
  final String code, name;
  final Map<String, String> text;
  const Language(this.code, this.name, this.text);
}

/// Daftar bahasa aplikasi. Bahasa pertama adalah bahasa bawaan dan dipakai
/// sebagai cadangan kalau sebuah teks belum diterjemahkan.
///
/// Cara menambah bahasa:
/// 1. Salin lib/l10n/id.dart menjadi file baru, misalnya lib/l10n/jv.dart.
/// 2. Terjemahkan nilainya (kunci di sebelah kiri jangan diubah).
/// 3. Daftarkan di bawah ini.
const List<Language> kLanguages = [
  Language('id', 'Bahasa Indonesia', kTextId),
  Language('en', 'English', kTextEn),
];

Language _current = kLanguages.first;

Language get currentLanguage => _current;

void setCurrentLanguage(String code) {
  for (final l in kLanguages) {
    if (l.code == code) _current = l;
  }
}

/// Teks untuk [key] dalam bahasa aktif. Penanda seperti {n} diganti
/// dengan nilai dari [args].
String tr(String key, [Map<String, Object> args = const {}]) =>
    trOr(key, key, args);

/// Sama seperti [tr], tapi mengembalikan [fallback] kalau kuncinya tidak ada.
String trOr(String key, String fallback,
    [Map<String, Object> args = const {}]) {
  var s = _current.text[key] ?? kLanguages.first.text[key] ?? fallback;
  args.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
  return s;
}

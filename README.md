# GM Cebi

Türkçe, 5e uyumlu masaüstü FRP yardımcısı (GM ve oyuncular için mobil uygulama).
Kurallar, durumlar, büyüler ve canavarlar çevrimdışı, Türkçe ve İngilizce aranabilir.

> Durum: **Faz 1 — uygulama (test sürümü).** Ayrıntı: [docs/status.md](docs/status.md).
> Test grubu için: [docs/test-guide.md](docs/test-guide.md).

## Depo düzeni

| Yol | İçerik |
|---|---|
| `lib/` | Flutter uygulaması (Riverpod, drift) |
| `test/` | Birim ve widget testleri |
| `android/`, `ios/` | Platform projeleri (Android 8+, iOS 15+) |
| `pipeline/` | Python 3.11 veri hattı: SRD PDF → yapılandırılmış JSON → Türkçe çeviri → uygulama asset'leri |
| `pipeline/glossary.csv` | Türkçe terim sözlüğü (tek gerçek kaynak) |
| `pipeline/data/source/` | SRD'den ayrıştırılmış İngilizce kayıtlar |
| `pipeline/translations/tm.jsonl` | Çeviri belleği: cümle düzeyinde, kaynak metinle yan yana |
| `assets/data/` | Uygulamanın okuduğu JSON (İngilizce + Türkçe) |
| `docs/` | Kararlar, durum, veri modeli, kaynaklar, sözlük incelemesi |

Uygulama:

```bash
flutter pub get
flutter test
flutter run --dart-define=GMCEBI_INTERNAL=true --dart-define=GMCEBI_GM_PACK=true
flutter build apk --release --dart-define=GMCEBI_INTERNAL=true --dart-define=GMCEBI_GM_PACK=true
dart run build_runner build   # lib/db/database.dart değişince
```

Veri hattı:

```bash
cd pipeline
pip install -r requirements.txt
python -m gmcebi_pipeline.fetch          # SRD 5.2.1 PDF'ini indirir, SHA-256 doğrular
python -m gmcebi_pipeline.build_source   # PDF → data/source/*.json
python -m gmcebi_pipeline.build_assets   # kaynak + çeviri belleği → ../assets/data/*.json
python -m pytest -q
```

Çeviri iş akışı için: [pipeline/README.md](pipeline/README.md).

## Lisans ve atıf

This work includes material from the System Reference Document 5.2.1 (“SRD 5.2.1”) by Wizards of the Coast LLC, available at https://www.dndbeyond.com/srd. The SRD 5.2.1 is licensed under the Creative Commons Attribution 4.0 International License, available at https://creativecommons.org/licenses/by/4.0/legalcode.

GM Cebi 5e uyumludur (“5E compatible”). Türkçe metinler SRD 5.2.1'in çevirisidir ve
orijinal metinden türetilmiş, değiştirilmiş bir çalışmadır.

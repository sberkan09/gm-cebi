# GM Cebi

Türkçe, 5e uyumlu masaüstü FRP yardımcısı (GM ve oyuncular için mobil uygulama).
Kurallar, durumlar, büyüler ve canavarlar çevrimdışı, Türkçe ve İngilizce aranabilir.

> Durum: **Faz 0 — veri.** Uygulama kodu Faz 1'de gelecek. Ayrıntı: [docs/status.md](docs/status.md).

## Depo düzeni

| Yol | İçerik |
|---|---|
| `pipeline/` | Python 3.11 veri hattı: SRD PDF → yapılandırılmış JSON → Türkçe çeviri → uygulama asset'leri |
| `pipeline/glossary.csv` | Türkçe terim sözlüğü (tek gerçek kaynak) |
| `pipeline/data/source/` | SRD'den ayrıştırılmış İngilizce kayıtlar |
| `pipeline/translations/tm.jsonl` | Çeviri belleği: cümle düzeyinde, kaynak metinle yan yana |
| `assets/data/` | Uygulamanın okuduğu JSON (İngilizce + Türkçe) |
| `docs/` | Kararlar, durum, veri modeli, kaynaklar, sözlük incelemesi |

Hızlı başlangıç:

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

# Veri hattı

Python 3.11. Tüm komutlar `pipeline/` dizininden çalışır.

```bash
pip install -r requirements.txt
python -m gmcebi_pipeline.fetch            # raw/SRD_CC_v5.2.1.pdf (SHA-256 doğrulamalı)
python -m gmcebi_pipeline.build_source     # PDF → data/source/*.json (+ _warnings.json)
python -m gmcebi_pipeline.build_assets     # data/source + translations/tm.jsonl → ../assets/data
python -m gmcebi_pipeline.report           # docs/glossary-review.md, docs/pilot-samples.md
python -m pytest -q
```

## Modüller

| Modül | İş |
|---|---|
| `fetch.py` | Resmi PDF'i indirir, özeti doğrular |
| `extract.py` | PDF → biçimli satır akışı (yazı tipi, punto, konum); satır sonu tirelerini birleştirir |
| `structure.py` | Başlık düzeylerine göre bölümleme, markdown üretimi, tablo yeniden kurma |
| `parse.py` | Veri kümesine özgü ayrıştırıcılar (kural sözlüğü, büyü, canavar, sınıf, köken, hüner, ekipman) |
| `models.py` | Pydantic şeması (`docs/data-model.md`) |
| `license.py` | Ürün kimliği yasaklı listesi |
| `glossary.py` | `glossary.csv` yükleme, Türkçe çekime dayanıklı terim eşleme |
| `segments.py` | Kayıtları cümle segmentlerine bölme ve çeviriyi geri birleştirme |
| `tm.py` | Çeviri belleği (`translations/tm.jsonl`) |
| `qc.py` | Kalite kontrolleri |
| `translate.py` | Çeviri komut satırı (kuyruk, API, içe aktarma, QC, inceleme) |
| `check_batch.py` | Tek bir çeviri partisini belleğe yazmadan denetler |
| `build_assets.py` | Uygulama asset'leri ve `manifest.json` |
| `report.py` | İnceleme belgelerini üretir |

## Çeviri iş akışı

```bash
python -m gmcebi_pipeline.translate queue --pilot          # pilot.json kapsamı
python -m gmcebi_pipeline.translate queue --datasets monsters
# ya API ile (ANTHROPIC_API_KEY gerekir):
python -m gmcebi_pipeline.translate api --model claude-opus-5-5
# ya da translations/out/batch_NNN.jsonl dosyaları başka yoldan üretilir; sonra:
python -m gmcebi_pipeline.translate import translations/out/*.jsonl --engine <model-id>
python -m gmcebi_pipeline.translate review                  # translations/review_queue.csv
python -m gmcebi_pipeline.translate apply-review translations/review_queue.csv --reviewer <ad>
python -m gmcebi_pipeline.translate qc                      # sözlük değişince tüm belleği yeniden denetle
```

`review_queue.csv` sütunları: `decision` = `ok` (olduğu gibi onayla), `fix`
(`tr_fixed` sütunundaki metni kullan), `reject`. Onaylanan segment `reviewed`
olur ve makine çıktısı onu bir daha ezemez.

## Kalite kontrol

Her segment içe aktarılırken (`qc.py`):

1. **Terim tutarlılığı** — `enforce=yes` olan her sözlük terimi kaynakta geçiyorsa çeviride de (çekimli biçimi dahil) geçmeli.
2. **Sayı ve zar** — sayıların ve zar ifadelerinin (2d6+3) çok kümesi birebir aynı.
3. **Referanslar** — tırnaklı başlık atıfları (“Rules Glossary”) ve italik büyü adları bilinen Türkçe başlığa çözülmeli.
4. **Biçim** — `**` / `*` sayıları ve başlık etiketleri korunmalı.
5. **Ürün kimliği** — yasaklı adlar geçmemeli; ayrıca İngilizce kelime kalıntısı uyarısı.

Bulgular segmentin `qc` alanına yazılır ve inceleme kuyruğunda öne alınır.

## Sözlük

`glossary.csv` tek gerçek kaynaktır. Sütunlar: `id, en, tr, category, status,
alternatives, note, evidence, enforce, en_pattern`. `en_pattern` boşsa İngilizce
terim büyük/küçük harfe duyarlı tam kelime olarak aranır. Bir terimi değiştirince
`translate qc` ile belleği yeniden denetle; yeni bulgular inceleme kuyruğuna düşer.

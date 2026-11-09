# Çeviriler

| Dosya | İçerik |
|---|---|
| `tm.jsonl` | Çeviri belleği; her satır bir benzersiz İngilizce segment ve Türkçe karşılığı (şema: `docs/data-model.md`) |
| `review_queue.csv` | İnceleme kuyruğu: QC bulgulu segmentler önde, kaynak ve çeviri yan yana |
| `queue/`, `out/` | Geçici çeviri partileri (git dışı) |

## Pilot (2026-10-21)

- Talimat: `pipeline/prompts/translate_tr.md` (sürüm 1).
- Üretici: `claude-opus-5-5`, oturum içi; partiler `translate queue --pilot` ile üretildi,
  `translate import` ile QC'den geçirilerek belleğe alındı.
- Çevirmen notlarından belleğe yansıyan ortak üslup kararları:
  - *See also* → *Ayrıca bkz.*
  - "have Advantage/Disadvantage" → "Avantajlısın / Dezavantajlısın"
  - Canavar kartı sütunları MOD SAVE → DEĞ KZ; "Recharges after a Long Rest" → "Uzun Dinlenmeden Sonra Yenilenir"
  - Bileşen kısaltmaları V, S, M → S (Sözlü), B (Bedensel), M (Malzeme)
  - Henüz sözlükte olmayan büyü adları italik ve İngilizce bırakılır (ör. *Greater Restoration*)

## Tam çeviri (2026-11-09)

- Talimat aynı (`prompts/translate_tr.md`); üretici `claude-opus-5-5`, oturum içi, 16 paralel çevirmen.
- Önce ad geçişi (büyü, canavar, ekipman adları sözlüğe), sonra `translate queue` → 64 parti →
  her parti `check_batch` ile temiz → `translate import`.
- Paralel partilerin ayrıştığı ifadeler için tek bir üslup tablosuyla ikinci geçiş yapıldı (323
  segment). Ortak kararlar `docs/decisions.md`'de (2026-11-09).
- Belleğin tamamı QC'den bulgusuz geçiyor; insan incelemesi henüz yapılmadı.

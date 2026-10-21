# Durum

Son güncelleme: 2026-10-21 (Faz 0 oturumu sonu)

## Faz 0 — veri: tamamlandı, onay bekliyor

PR: `claude/phase-0-data` → `main`.

### Veri sayıları (İngilizce kaynak, `pipeline/data/source/`)

| Veri kümesi | Kayıt | Not |
|---|---|---|
| rules_glossary | 140 | Kurallar Sözlüğü girdileri (durumlar hariç) |
| conditions | 15 | Tümü |
| spells | 339 | Büyü içindeki çağrılan yaratık blokları (4) ait oldukları büyüye eklendi |
| monsters | 330 | Monsters A–Z + Animals, tüm istatistik blokları |
| classes | 12 | Temel özellikler, gelişim tabloları, büyü listeleri, sınıf özellikleri |
| subclasses | 12 | SRD'deki 12 alt sınıf |
| species | 9 | |
| backgrounds | 4 | |
| feats | 17 | Origin 4, General 2, Fighting Style 4, Epic Boon 7 |
| equipment | 192 | 38 silah, 13 zırh, 25 alet, 83 eşya, 8 binek, 25 taşıt/koşum |
| weapon_properties | 10 | |
| weapon_mastery | 8 | |

### Sözlük

- `pipeline/glossary.csv`: 416 çekirdek terim + 50 pilot büyü adı + 21 bölüm/başlık adı.
- Durum: 116 topluluk, 257 öneri, 43 tartışmalı.
- İnceleme belgesi: `docs/glossary-review.md` (tartışmalılar en üstte).

### Pilot çeviri

- Kapsam: 15 durum + 140 kural sözlüğü girdisi + 50 büyü (`pipeline/pilot.json`).
- 1.298 benzersiz segment (yaklaşık 14.400 İngilizce kelime): 1.087 LLM çevirisi, 211 doğrudan sözlükten.
- QC: 1.297 temiz, 1 bulgu (henüz çevrilmemiş iki büyü adı İngilizce kaldı — beklenen).
- Asset'ler: 205 kayıt tam Türkçe, 29 kısa büyü kısmen (paylaşılan alanlar); toplam 1,6 MB (bütçe 10 MB).
- Örnekler: `docs/pilot-samples.md`. Tüm segmentler yan yana: `pipeline/translations/review_queue.csv`.

### Testler

`pipeline/` altında 50 pytest testi; Python 3.11 ve 3.13'te geçiyor. PDF'i yeniden ayrıştırıp
depodaki JSON ile birebir karşılaştıran test dahil.

## Bilinen sınırlamalar

- **Satır sonu tireleri:** dizgide bir bileşik kelimenin kendi tiresinde satır kırılmışsa tire düşebilir (sözlüksüz ayırt edilemiyor). Taramada 1 şüpheli kaldı ("shin- and" — doğru, bilinçli).
- **Tablolar:** sağa hizalı sütunlu birkaç tabloda (Adventuring Gear vb.) sütunlar kayabiliyor; ekipman için ağırlık/fiyat ayrıştırıcıda düzeltiliyor, diğer tablolar için görsel kontrol gerekecek.
- **Soy alt seçenekleri** (Forest Gnome, Rock Gnome; Goliath atalık seçenekleri) ayrı `traits` girdisi olarak duruyor; Faz 1'de üst özelliğin altına gruplanabilir.
- **Magic Items**, **Gameplay Toolbox** ve **Playing the Game** bölümleri ayrıştırılmadı (Faz 0 listesinde yoktu).
- Çeviri bu oturumda API anahtarı olmadığı için oturum içi Claude ile yapıldı; aynı talimat API arka ucuyla da çalışır (`translate api`).

## Onay bekleyenler (ürün sahibi)

1. Sözlük: özellikle 43 tartışmalı terim (Güç/Kuvvet, Bilgelik, Yetkinlik, Cantrip, Sehhar, para birimleri…).
2. Pilot çeviri kalitesi ve üslup (`docs/pilot-samples.md`).
3. Türkçe "değiştirilmiş eser" notu ve atıf metninin "Hakkında" ekranındaki biçimi (`docs/decisions.md`).

## Sonraki adımlar

- Sözlük kararlarından sonra `translate qc` ile pilotu yeniden denetle, düzeltmeleri uygula.
- Kalan veri kümelerinin (büyülerin geri kalanı, canavarlar, sınıflar…) toplu çevirisi.
- Faz 1: Flutter uygulaması (onaydan sonra).

# Durum

Son güncelleme: 2026-10-23 (Faz 1)

## Faz 1 — uygulama: test sürümü hazır

PR: https://github.com/sberkan09/gm-cebi/pull/3 (`claude/phase-1-app` → `main`). Bağımsız incelemenin 4 engelleyici bulgusu düzeltildi.

### Ekranlar

| Ekran | Durum |
|---|---|
| Ara | Tek kutu (ekranın altında), Türkçe + İngilizce, çevrimdışı; boşken veri kümelerine göz atma. Gerçek veride en kötü sorgu ~0,5 ms (masaüstü AOT). |
| Kayıt sayfaları | Kural, durum, büyü (büyü kartı), canavar (istatistik bloğu), sınıf, alt sınıf, soy, geçmiş, hüner, ekipman, silah özelliği/ustalığı, terim. TR/EN tek dokunuş; çevrilmemiş kayıtta uyarı. |
| Zar | İfade ayrıştırıcı (`2d20kh1+5`, `4d6dl1`, `(1d8+3)*2`, `d%`), zar düğmeleri, ±1, Avantaj/Dezavantaj, geçmiş. |
| İnisiyatif (GM Paketi) | Ekle (serbest / canavar listesi / canavar sayfasından), inisiyatif atma, sıra ve tur, CP hasar/iyileştirme, durum etiketleri, yeni karşılaşma. Kalıcı (drift). |
| Oturum notları (GM Paketi) | Liste, arama, sabitleme, kendiliğinden kaydetme, silme. |
| Ayarlar ve Hakkında | Tema (koyu varsayılan), varsayılan içerik dili, GM Paketi durumu (+ test sürümünde test anahtarı), atıf metni, açık kaynak lisansları. |

Ekran görüntüleri: `docs/screenshots/`. Test grubu notu: `docs/test-guide.md`.
iOS hazırlığı: `docs/ios-testflight.md`. Türkçe metin kuralları: `docs/turkish-text.md`.

### Testler

- Flutter: 82 test — Türkçe metin (büyük/küçük harf, sıralama, ekler), zar ayrıştırıcı, Markdown,
  arama (gerçek veriyle, her sorgu <100 ms; ölçüm masaüstünde), veritabanı (inisiyatif, notlar,
  ayarlar), bayraklar, uygulamanın tamamını açan 14 widget testi ve çevrilmiş ya da tablolu her
  kaydı iki dilde çizen bir test. `flutter analyze` temiz.
- Pipeline: 60 pytest testi (Türkçe kayıtların yapısının İngilizceyle aynı olduğu denetimi eklendi).
- Ekran görüntüsü testi (`test/screenshots`) gerçek yazı tipleriyle çizer; elle çalıştırılır.

## Faz 0 — veri: tamamlandı

- PR #1 (veri, sözlük, pilot) birleşti.
- PR #2: bağımsız alt ajan incelemesinin bulguları — Animals gruplaması, sözlük eşleşmesinin sıkılaştırılması, reddedilen alternatif ve büyük/küçük harf denetimi, binlik ayırıcı, liste ve paragraf ayrıştırma, yumuşak tire, asset yayımlama eşiği, CI sabitleme.

### Veri sayıları (İngilizce kaynak, `pipeline/data/source/`)

| Veri kümesi | Kayıt | Not |
|---|---|---|
| rules_glossary | 140 | Kurallar Sözlüğü girdileri (durumlar hariç) |
| conditions | 15 | Tümü |
| spells | 339 | Büyü içindeki çağrılan yaratık blokları (4) ait oldukları büyüye eklendi |
| monsters | 330 | Monsters A–Z (235) + Animals (95); hayvanların ailesi yok |
| classes | 12 | Temel özellikler, gelişim tabloları, büyü listeleri, sınıf özellikleri |
| subclasses | 12 | SRD'deki 12 alt sınıf |
| species | 9 | |
| backgrounds | 4 | |
| feats | 17 | Origin 4, General 2, Fighting Style 4, Epic Boon 7 |
| equipment | 192 | 38 silah, 13 zırh, 25 alet, 83 eşya, 8 binek, 25 taşıt/koşum |
| weapon_properties | 10 | |
| weapon_mastery | 8 | |

### Sözlük

- `pipeline/glossary.csv`: 416 çekirdek terim + 50 pilot büyü adı + 25 bölüm/başlık adı.
- Durum: 116 topluluk, 257 öneri, 43 tartışmalı.
- İnceleme belgesi: `docs/glossary-review.md` (tartışmalılar en üstte).

### Pilot çeviri

- Kapsam: 15 durum + 140 kural sözlüğü girdisi + 50 büyü (`pipeline/pilot.json`).
- 1.348 benzersiz segment: 1.092 LLM çevirisi (64'ü büyük/küçük harf düzeltmesiyle), 256 doğrudan sözlükten (liste maddeleri dahil).
- QC (sıkılaştırılmış eşleşme, reddedilen alternatif ve harf denetimiyle): 1.347 temiz, 1 bulgu (henüz sözlükte olmayan iki büyü adı İngilizce kaldı — beklenen).
- Asset'ler: 205 kayıt tam Türkçe; kısmen İngilizce kayıt yayımlanmıyor; toplam 1,6 MB (bütçe 10 MB).
- Örnekler: `docs/pilot-samples.md`. Tüm segmentler yan yana: `pipeline/translations/review_queue.csv`.

### Testler

`pipeline/` altında 58 pytest testi; Python 3.11 ve 3.13'te geçiyor. PDF'i yeniden ayrıştırıp
depodaki JSON ile birebir karşılaştıran test dahil. GitHub Actions'ta `ci` (PDF indirme + pytest)
ve `agentgate` (gözlem modu, çakışma yok) PR #1 üzerinde yeşil; Flutter adımları `pubspec.yaml`
olmadığı için atlanıyor.

## Bilinen sınırlamalar

- **Satır sonu tireleri:** dizgide bir bileşik kelimenin kendi tiresinde satır kırılmışsa tire düşebilir (sözlüksüz ayırt edilemiyor). Yumuşak tireler (U+00AD) artık temizleniyor ve testle denetleniyor.
- **Tablolar:** sağa hizalı sütunlu birkaç tabloda (Adventuring Gear vb.) sütunlar kayabiliyor; ekipman için ağırlık/fiyat ayrıştırıcıda düzeltiliyor, diğer tablolar için görsel kontrol gerekecek.
- **Soy alt seçenekleri** (Forest Gnome, Rock Gnome; Goliath atalık seçenekleri) ayrı `traits` girdisi olarak duruyor; Faz 1'de üst özelliğin altına gruplanabilir. Vampire zaafları ve Sphinx kükremeleri gibi canavar alt maddeleri tek özellik metninde.
- **Spell Scroll** ekipmanda üç kayıt (Cantrip, Level 1 ve açıklamalı ana kayıt); Faz 1'de tek kayıtta birleştirilebilir.
- **Ayrıştırılmayan sayfalar** (101–106 büyü yapma kuralları vb.) yüzünden bazı kural atıfları uygulamada karşılıksız kalacak.
- **Magic Items**, **Gameplay Toolbox** ve **Playing the Game** bölümleri ayrıştırılmadı (Faz 0 listesinde yoktu).
- Çeviri bu oturumda API anahtarı olmadığı için oturum içi Claude ile yapıldı; aynı talimat API arka ucuyla da çalışır (`translate api`).

## Onay bekleyenler (ürün sahibi)

1. Sözlük: özellikle 43 tartışmalı terim (Güç/Kuvvet, Bilgelik, Yetkinlik, Cantrip, Sehhar, para birimleri…) ve inceleme ajanının işaret ettiği "Hayvan" (Beast) ↔ "Hayvanlar" (Animals bölümü) yakınlığı.
2. Pilot çeviri kalitesi ve üslup (`docs/pilot-samples.md`).
3. Türkçe "değiştirilmiş eser" notu ve atıf metninin "Hakkında" ekranındaki biçimi (`docs/decisions.md`). Şu an Ayarlar ve Hakkında ekranında öneri metniyle duruyor.
4. Uygulama adı ("GM Cebi") ve paket adı (şimdilik `com.example.gm_cebi` / `com.example.gmCebi`).

## Toplu çeviri öncesi takip maddeleri (PR #2 ikinci inceleme)

1. Sıradan kelime olan reddedilen alternatifler (Tür, Ses, Buz, Felç, Kesme, Koşma, Yuva, Körlük, etken) yanlış alarm üretecek; alternatif bazında "reddedilmez" işareti eklenmeli.
2. Kısa kökler sesteş kelimeleri hâlâ geçiriyor (İn ↔ İnce, Din ↔ dinle, Küp ↔ küpe, Ork ↔ orkide…); en az Lair ve Religion için `tr_pattern`/istisna. Doğal türetmeler (Dirençli, Bağışık, fitliğine) `tr_pattern` ile açılmalı.
3. Sayı denetimi sırasız (yer değiştirmiş sayılar geçiyor); Türkçe ondalık virgül (1,5) henüz reddediliyor.
4. `see_also` içindeki "NPC" sözlüğe eklenmeli.

## Sonraki adımlar

- Uygulama adı ve paket adı kararı (yer tutucu: `com.example.*`), ardından mağaza imzası.
- Test grubundan ilk geri bildirim; sözlük kararları.
- Toplu çeviri öncesi takip maddeleri (yukarıda), ardından kalan veri kümelerinin çevirisi.
- Faz 2 planı: ses kaydı → özet → NPC/mekân defteri; Fate desteği.

# Durum

Son güncelleme: 2026-11-09 (SRD içeriğinin tamamı Türkçe)

## Kenar kutuları ve kalan SRD bölümleri (dal `claude/srd-remaining`, #19, #20)

- Bölüm ortasındaki 15 kenar kutusu (GillSans 9 pt metin, 11 pt küçük büyük harf başlık) kestiği
  paragraftan çıkarılıp bulunduğu alt bölümün sonuna "### / #### Başlık" olarak taşınıyor
  (`lift_sidebars`). Kural bölümleri, Paladin ve Büyücü sınıf özellikleri, Doğruluk Lütfu hüneri ve
  Hafif silah özelliği düzeldi.
- **18 yeni kural bölümü** (toplam 52): Büyüler bölümünün başı (s. 104–106: büyü edinme, hazırlama,
  büyü yapma kuralları) ve Ekipman bölümünün düzyazısı (sikkeler, silah/zırh/alet yetkinliği,
  binekler ve taşıtlar, yaşam giderleri, yiyecek/konaklama tablosu, kiralık yardımcılar, büyü
  hizmetleri, büyülü eşya kullanımı, zanaat, iksir ve parşömen). Ekipman veri kümelerinde zaten
  bulunan eşya girdileri ve tabloları tekrarlanmıyor.
- Formül satırları ("Spell save DC = …") kendi paragrafı; alt satırı ("+ Proficiency Bonus")
  artık kaybolmuyor.
- Çeviri: 76 yeni bölüm başlığı ve 7 yaşam tarzı düzeyi sözlüğe (başlıklar sözlükten doluyor);
  379 segment toplu çeviri (4 parti, her biri QC'den temiz) ve AI düzeltme turu (18 segment: ör.
  "Armor Class benefit" → "avantaj" Advantage terimiyle karışıyordu; "Massive Damage"de "artan
  hasar" yerine "geriye kalan hasar").
- Bağlam ad alanı: başlığı "Rarity" olan tablo sütunları nadirlik anahtarıyla ("Common" = Yaygın);
  düz "Common" hücresi şarap kalitesi ("Sıradan"). Sözlük: "Dodge out of harm's way" Kaçınma eylemi
  sayılmıyor, "unhealthy conditions" Durum terimi sayılmıyor.
- Bellek: 14.488 segment, QC bulgusu 0. 52 kural bölümünün tamamı Türkçe; asset'ler 4,0 MB.

## Büyülü eşyalar ve kural bölümleri (dal `claude/magic-items`)

- **258 büyülü eşya** (tür, nadirlik, uyumlanma, italik tür satırı, metin, tablolar ve gömülü stat
  blokları: Dev Sinek, Ölüm Avatarı) ve **34 kural bölümü**: Oyunun Oynanışı, Karakter Oluşturma,
  Oyun Araç Kutusu (yolculuk, lanetler ve salgınlar, çevre, korku, zehirler, tuzaklar, savaş
  karşılaşmaları) ve büyülü eşya kuralları; bölüm girişleri (`playing-intro` kenar kutularıyla,
  `magic-items-intro`, "A'dan Z'ye Büyülü Eşyalar") ayrı bölüm olarak. Uygulamada "Büyülü Eşyalar"
  ve "Kural Bölümleri" olarak aranır ve gezilir.
- Tablo kurucu (`structure.py`): farklı başlıklı tablo önceki tabloyu bitirir (Eylemler tablosu
  Beceriler'e karışmıyor); başlık satırındaki farklı punto/kalınlıktaki hücreler başlık sayılır;
  sağa/ortaya hizalı sütunlar tek sütun; birleşik hücreler span konumundan bölünür; yan yana basılmış
  iki kopya tablo (Nadirlik | Değer | Nadirlik | Değer) alt alta dizilir. Testler her tablonun
  dikdörtgen olduğunu ve başlık hücrelerinin dolu olduğunu denetler.
- SRD metninin kendisinde geçen birkaç ürün adı ("D&D", "Tiamat", "yuan-ti") derlemede nötr ifadeyle
  değiştiriliyor (`TEXT_FIXUPS`, `build_source.py`).
- Çeviri: 257 eşya adı ve 214 bölüm başlığı sözlüğe, 3.735 segment toplu çeviri, tutarlılık geçişi ve
  AI düzeltme turu (61 segment). Bağlama bağlı yeni ad alanları: nadirlik alanı ("Common" = Yaygın),
  silah ustalığı hücreleri ("Slow" = Yavaşlatma), dil tabloları ("Giant" = Devce).
- Bellek: 14.034 segment, QC bulgusu 0. Asset'ler 3,9 MB.

## Tam çeviri (dal `claude/full-translation`)

SRD 5.2.1'deki 1.080 kaydın tamamı Türkçe: 339 büyü, 330 canavar, 12 sınıf + 12 alt sınıf,
9 soy, 4 geçmiş, 17 hüner, 184 ekipman, 15 durum, 140 kural sözlüğü girdisi, silah özellik ve
ustalıkları. Asset'ler 2,9 MB (bütçe 10 MB).

- **Ad geçişi:** 289 büyü, 330 canavar ve 121 ekipman adı sözlüğe eklendi (`öneri`, zorunlu değil);
  dil adları (`dil`). Dizi kuralları: Lesser/Greater = Küçük/Üstün, Conjure = Çağır,
  Summon = Celp Et; ejderhalar [Yaş] [Renk] Ejderha; devler "X Devi"; Devil = Şeytan.
- **Toplu çeviri:** 7.302 segment, 64 parti; her parti içe aktarılmadan önce QC'den temiz geçti.
  Partiler paralel çevrildiği için ikinci bir tutarlılık geçişi yapıldı: stat bloğu etiketleri,
  kullanım sınırları ("Günde 3", "İstediği Zaman"), hasar türü dilbilgisi (Delici hasar / Ateş
  hasarı), dil ve düzlem adları, sınıf özelliği adları tek biçime çekildi (323 segment).
- **Bellek:** 9.647 segment, QC bulgusu 0. Kalitenin insan incelemesi yapılmadı; mağaza metinleri
  ve Ayarlar'daki not bunu söylüyor. Canavar ve sınıf metinlerinde bir AI düzeltme turu yapıldı (74 segment);
  insan incelemesi için öncelik sırası ve açık kararlar `docs/translation-review.md`'de.
- **Veri hattı düzeltmeleri:** sınıf büyü listesi hücreleri büyü adı olarak anahtarlanıyor ("Light"
  orada Işık, silah özelliği değil); canavarların dil satırı ayrı ad alanında ("Giant" dili ≠ Dev);
  araç/eyer/gemi tabloları düzgün ayrıştırılıyor (eski "Speed", "Exotic", yemek satırı kayıtları
  kalktı); "11/2 pints" → "1½".
- **QC takip maddeleri kapandı:** `?` önekli serbest alternatifler (Tür, Buz…), kısa köklerde
  -ce/-le eki kabul edilmiyor (ince ≠ İn), Dirençli/Bağışık/fitliğine, ondalık virgül, NPC,
  "Grappling Hook" ve "weather conditions" yanlış alarmları, "büyü kurtarma ZD'n".
  Sayı denetimi bilerek sırasız: Türkçede öğe dizilişi değişiyor.
- **Uygulama:** canavar kartı ve ekipman alan başlıkları Türkçe (Beceriler, Duyular, Fiyat…);
  Türkçe ek geri düşmesi yalnızca gövde metni eşleştiğinde de çalışıyor.

## Çevrimiçi sahne (isteğe bağlı, NeuraCraft Cloud)

Dal: `claude/online-scene` (savaş haritası dalının üstünde). Haritadaki arazi çizimi sunucuda resme
dönüşür, resim alt katman olur, jetonlar üstte kalır. Yalnızca `NC_API_URL` + `NC_CLIENT_ID` ile
derlenen sürümlerde görünür; mağaza/test derlemeleri bugünkü gibi tamamen çevrimdışı.
İstemci, oturum yöneticisi, üretim akışı, Ayarlar (aç/kapa, gizlilik, hesap), Türkçe hata mesajları ve
testler hazır; yerel neuracraft-cloud API'sine karşı `tool/nc_smoke.dart` ile uçtan uca denendi.
2026-11-10: uygulama token'ı yerine e-postaya gelen kodla kullanıcı girişi (neuracraft-cloud #48);
token'lar güvenli depoda, tek uçuşlu yenileme, uygulama içi "Hesabımı sil". Girişli sürüm canlı
serviste henüz denenmedi (servis bugün `auth.sign_in_unavailable` dönüyor). Mağazaya açık derleme gitmeden önce gizlilik beyanları güncellenmeli
(`docs/online-scene.md`, "Gizlilik ve mağaza beyanları").

## Savaş haritası (GM Paketi, çevrimdışı)

Dal: `claude/tactical-map`. İnisiyatif ekranındaki harita simgesi → kalem/silgi, 4 renk, ızgara,
geri al; inisiyatif katılımcıları jeton olarak (sıra numarası, sıradaki halkası, CP çubuğu); sıra
haritadan ilerletilir. Ekran görüntüsü: `docs/screenshots/11-harita.png`.

Kroki → sahne denemesi: `docs/spikes/sketch-to-scene/README.md` (V100'de harita modu 0,5 sn,
atmosfer modu 1,6 sn; jetonlar modele gönderilmemeli). Servis tarafında gerekenler (token ile kimlik doğrulama, iş şablonu, model kataloğu, prompt
adımı, gecikme, şikâyet, faturalama, veri saklama) neuracraft-cloud'da açıldı: takip issue'su
https://github.com/sberkan09/neuracraft-cloud/issues/13 (alt issue'lar #14–#21).

## Yayın hazırlığı: Play kapalı/açık test ve TestFlight

PR #4 2026-11-09'da birleşti (inceleme düzeltmeleriyle). Ayrıntı: `docs/release.md`, `docs/ios-testflight.md`, `docs/store/`.

- Sürüm `1.0.0+1`; paket kimliği Android ve iOS'ta `io.github.sberkan09.gmcebi` (onay bekliyor).
- Android yükleme anahtarıyla imza (`android/key.properties`, git dışı); `release-aab` iş akışı
  `v*` etiketinde test + imzalı AAB üretir ve denetler. Yerelde atılık bir anahtarla derlendi ve doğrulandı
  (imzalayan = yükleme anahtarı; test anahtarı izi yok; İnternet izni yok). `GMCEBI_INTERNAL=true`
  derlemesinde aynı denetim beklendiği gibi başarısız oldu.
- Bayraklar: mağaza derlemesi `GMCEBI_INTERNAL=false`, `GMCEBI_GM_PACK=true`. Test anahtarının
  kayıtlı tercihi artık mağaza derlemesinde okunmuyor (sızıntı düzeltildi, testli).
- Mağaza materyalleri: TR/EN açıklamalar, gizlilik politikası, Play veri güvenliği taslağı, 512 px ikon,
  öne çıkan görsel, 6+6 ekran görüntüsü.
- Mağaza hesapları, keystore, secret'lar ve yükleme ürün sahibinde (`docs/release.md`).

## Faz 1 — uygulama: test sürümü hazır

PR #3 (`claude/phase-1-app` → `main`) 2026-10-23'te birleşti. Bağımsız incelemenin 4 engelleyici bulgusu düzeltildi.

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

- Flutter: 86 test (yayın hazırlığıyla +4: bayrak sızıntısı, sürüm uyumu, atıf metni) — Türkçe metin (büyük/küçük harf, sıralama, ekler), zar ayrıştırıcı, Markdown,
  arama (gerçek veriyle, her sorgu <100 ms; ölçüm masaüstünde), veritabanı (inisiyatif, notlar,
  ayarlar), bayraklar, uygulamanın tamamını açan 14 widget testi ve çevrilmiş ya da tablolu her
  kaydı iki dilde çizen bir test. `flutter analyze` temiz.
- Pipeline: 59 pytest testi (Türkçe kayıtların yapısının İngilizceyle aynı olduğu denetimi eklendi).
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

- `pipeline/glossary.csv`: 1.251 satır — çekirdek terimler, 339 büyü adı, 330 canavar adı, ekipman, 19 dil, 25 bölüm/başlık.
- Durum: 116 topluluk, 1.092 öneri, 43 tartışmalı.
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
- Büyü yapma kuralları (s. 104–106), yaşam giderleri, yemek ve konaklama tablosu, ücretli hizmetler henüz ayrıştırılmadı.
- Çeviri bu oturumda API anahtarı olmadığı için oturum içi Claude ile yapıldı; aynı talimat API arka ucuyla da çalışır (`translate api`).

## Onay bekleyenler (ürün sahibi)

1. Sözlük: 740 yeni ad (büyü, canavar, ekipman) ve özellikle 43 tartışmalı terim (Güç/Kuvvet, Bilgelik, Yetkinlik, Cantrip, Sehhar, para birimleri…) ve inceleme ajanının işaret ettiği "Hayvan" (Beast) ↔ "Hayvanlar" (Animals bölümü) yakınlığı.
2. Pilot çeviri kalitesi ve üslup (`docs/pilot-samples.md`).
3. Türkçe "değiştirilmiş eser" notu ve atıf metninin "Hakkında" ekranındaki biçimi (`docs/decisions.md`). Şu an Ayarlar ve Hakkında ekranında öneri metniyle duruyor.
4. Uygulama adı ("GM Cebi") ve paket adı (önerilen: `io.github.sberkan09.gmcebi`, Android ve iOS aynı; ilk yüklemeden sonra değişmez).
5. Üretime çıkmadan önce GM Paketi'nin ücretsiz mi kalacağı (test kanallarında açık).

## Sonraki adımlar

- Paket adı onayı, ardından Play iç/kapalı test ve TestFlight'a ilk yükleme (`docs/release.md`).
- Test grubundan ilk geri bildirim; sözlük kararları.
- Çevirinin insan incelemesi: önce canavar kartları ve sınıf özellikleri; tartışmalı terimler ve yeni adlar (Efsuncu, Sihirci, Wight, Kâbus…) için ürün sahibi kararı.
- Kaynakta kalan iki bozuk segment (Find Steed metnine yapışan Find the Path cümlesi, Antipathy/Sympathy'de kesik cümle) ayrıştırıcıda düzeltilmeli.
- Faz 2 planı: ses kaydı → özet → NPC/mekân defteri; Fate desteği.

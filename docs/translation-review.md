# Çeviri incelemesi — insan inceleyiciler için

Çevirinin tamamı makine destekli. Otomatik kalite kontrol (sözlük terimleri, sayı, zar, biçim)
belleğin tamamında temiz. Bunun üstüne bir **AI düzeltme turu** yapıldı. Bu belge, insan
incelemesinin nereden başlaması gerektiğini ve hangi kararların açık olduğunu anlatır.

## AI düzeltme turu (2026-11-09)

330 canavar, 12 sınıf ve 12 alt sınıf kayıt kayıt okundu. 74 segment düzeltildi: 34 terim, 28
Türkçe, 10 kural (mekanik), 2 anlam. Bulunan hata türleri ve örnekler:

| Tür | Örnek | Düzeltme |
|---|---|---|
| Tur/sıra karışıklığı | Eldritch Smite, Lifedrinker: "once per turn" → "turda bir kez" (her **tur**) | "sırada bir kez" |
| "ve/veya" kapsamı | Monk Martial Arts: "zırh giymiyor **ya da** Kalkan kuşanmıyorken" | "ve" |
| | Rust Monster: "giyilmeyen veya taşınmayan" (taşınan nesne de sayılıyordu) | "kimsenin giymediği ve taşımadığı" |
| | Zombie, Undead Fortitude; Lemure, Hellish Restoration | olumsuzluğun kapsamı netleştirildi |
| Süre kaybı | Gold Dragon, Banish: Etkisiz durumu için bitiş belirtilmemişti | süre iki etkiye de bağlandı |
| Zaman | Spirit Naga: "1d6 gün içinde" (within) | "1d6 gün sonra" |
| Ad tutarsızlığı | Çoklu Saldırı metninde eylemin başlıktakinden farklı adı (Sıkıştırma/Sıkma, İçine Alma/Sarıp Yutma) | başlıktaki ad |
| Terim çakışması | Evasion = "Kaçınma" (Dodge eylemiyle aynı) | "Sıyrılma" |
| Türkçe | "kafası sayısı", "Yerde olarak", "bu sıra" | "kafa sayısı", "Yerde durumunda", "bu sırada" |

Kurallar `pipeline/prompts/translate_tr.md` ve karar kaydında (`docs/decisions.md`).

Büyülü eşyalar ve kural bölümlerinde ikinci bir AI düzeltme turu yapıldı (61 segment): "within 30
feet" ifadesinin "30 fit mesafede" (tam 30 fit) diye çevrilmesi, öznesi kaybolan cümleler ("senin
nerede olduğunu"), "bir yüzyıl içinde" (yüz yıl sonra) ve başlıkla metin arasındaki terim farkları.

## İnsan incelemesi: öncelik sırası

1. **Canavar kartlarının eylem metinleri** (`monsters`, "Eylemler" ve "Efsanevi Eylemler"). Masada en
   çok okunan ve kural hatasının en pahalı olduğu yer. Özellikle kurtarma zarı sonuçları
   (*Başarısızlık:* / *Başarı:*), süreler ("bir sonraki sırasının sonuna kadar") ve mesafeler
   ("ondan 30 fit uzaklıktaki").
2. **Sınıf özellikleri** (12 sınıf + 12 alt sınıf): özellik adlarının tablo ve metinde aynı olması;
   "Uzun Dinlenmeyi bitirdiğinde harcanmış kullanımları geri kazanırsın" gibi kaynak kuralları.
3. **Büyüler**: menzil, süre ve "Daha Yüksek Seviyeli Büyü Slotu Kullanma" bölümleri.
4. **Büyülü eşyalar**: yük (charge) kuralları, uyumlanma kısıtları ve "bir sonraki şafak" süreleri.
5. **Kural bölümleri** (Oyunun Oynanışı, Oyun Araç Kutusu): tablolar ve ara kutularla bölünmüş
   cümleler (kaynakta da bölünmüş).
6. **Ekipman ve kurallar sözlüğü**: kısa, daha az risk.

İnceleme yolu: `python -m gmcebi_pipeline.translate review` → `translations/review_queue.csv`
(`decision`: ok / fix / reject), sonra `apply-review`. Onaylanan segment `reviewed` olur ve makine
çıktısı onu bir daha ezemez (`pipeline/README.md`).

## Ürün sahibinin kararı gereken terimler

- **43 tartışmalı sözlük terimi**: `docs/glossary-review.md` (Güç/Kuvvet, Bilgelik, Yetkinlik,
  Cantrip, Sehhar, para birimleri…).
- **Yeni adlar**: Mage = Efsuncu ve Archmage = Ulu Efsuncu (Büyücü ve Sihirbaz sınıf adı olduğu için);
  Druid'in Magician seçeneği = Sihirci; Priest = Din Adamı (Rahip, Cleric sınıfı); Wight,
  Doppelganger, Quasit, Stirge özgün adıyla; Nightmare = Kâbus; Will-o'-Wisp = Bataklık Feneri;
  demon çevrilmedi (Fiend = İblis dolu).
- **Dil adları**: Ortak Dil, Ejderce, Elfçe, Devce, Abis Dili, Cehennem Dili, Göksel Dil, Derin Dil,
  İlkel Dil, Sylvan Dili, Yeraltı Ortak Dili.
- **Yenilenme** üç yerde: eylem etiketi "(Yenilenme 5–6)", canavar özelliği "Şeytani Yenilenme"
  (Restoration) ve *Regenerate* büyüsünün adı. Okurken karışıyorsa büyü adı değişebilir.
- **Kesme işareti**: eylem ve özellik adları ad gibi ek alıyor ("Isırık'ı", "İlahi Müdahale'yi");
  küçük harfli yabancı yaratık adları kayıtlar arasında karışık ("aboleth'in" / "balorun").
  Tek kural seçilirse toplu düzeltilebilir.

- **Hizalama kısaltmaları** (LG, NG, CE…) İngilizce bırakıldı; Türkçe bir kısaltma takımı istenirse
  karar gerekiyor (Kuralcı ve Kaotik ikisi de K ile başlıyor).
- **Düzlem adlarında kesme işareti** karışık: "Astral Düzlem'de" (çoğunluk) / "Astral Düzlemde".

## Kaynakta kalan bozukluklar

- Find Steed'in "Daha Yüksek Seviye" metnine Find the Path'in bir cümlesi yapışmış; Find the Path'te
  "Whenever you" diye kesik bir parça var.
- Antipathy/Sympathy'de bir cümle "can make a" diye kesiliyor; Antilife Shell ve Animate Objects'te
  iki cümle birleşik.

Bunlar ayrıştırıcıda düzeltilmeli; çeviri İngilizcedeki kesikliği aynen taşıyor.

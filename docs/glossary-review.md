# Sözlük incelemesi

> Üretildi: `python -m gmcebi_pipeline.report` — elle düzenleme; değişiklikleri `pipeline/glossary.csv`'ye yap.

Çekirdek terim: **416** — topluluk: 116, öneri: 257, tartışmalı: 43. Ayrıca 50 pilot büyü adı ve 21 bölüm adı (en altta).

## Nasıl incelenir

- **tartışmalı** satırlarla başla (aşağıda ilk bölüm). Her biri için ya seçimi onayla ya da alternatiflerden birini seç.
- **öneri** satırları için topluluk kullanımı bulunamadı; dil duygusuna göre onayla veya düzelt.
- **topluluk** satırları kanıtlı; yalnızca göze batanlara bak.
- Bir terimi değiştirmek için `pipeline/glossary.csv`'de `tr` sütununu düzelt (ya da bana liste halinde ilet). Hat, eski biçimle çevrilmiş tüm segmentleri yeniden inceleme kuyruğuna alır.
- **Zorunlu** sütunu: ✔ olan terim, kaynakta geçtiğinde çeviride de geçmek zorundadır.

## Tartışmalı terimler (öncelikli)

| İngilizce | Seçim | Alternatifler | Gerekçe | Kanıt |
|---|---|---|---|---|
| Ability | **Yetenek** | Özellik, Kabiliyet | Yetenek/Özellik/Kabiliyet üçü de kullanılıyor; Beceri (skill) ile çakışmayan en yaygın biçim seçildi. | R,N,C,I,A |
| Ability Score | **Yetenek Puanı** | Özellik Puanı, Kabiliyet Puanı | — | R,C,I,A |
| ability modifier | **yetenek değiştiricisi** | ayar, tamamlayıcı, etken | Topluluk bölünmüş (Ayar, Tamamlayıcı, Etken, Değiştirici); en anlaşılır olan seçildi. | C,A,J,I |
| modifier | **değiştirici** | ayar, tamamlayıcı, etken | — | C,A,J,I |
| Ability Check | **Yetenek Testi** | Kabiliyet Zarı, Yetenek Zarı | 2024 kurallarında check bir D20 Testi türü; 'Test' bunu yansıtıyor. | E,A,B |
| Initiative | **İnisiyatif** | Öncelik | Topluluk Öncelik/İnisiyatif arasında bölünmüş; ürün sahibinin kendi brief'i 'İnisiyatif' kullanıyor. | B,K,I |
| Proficiency | **Yetkinlik** | Yeterlilik, Uzmanlık | Uzmanlık 'Expertise' ile çakışıyor; Yetkinlik/Yeterlilik eşit yaygın. | A,E,K,F,J |
| Proficiency Bonus | **Yetkinlik Bonusu** | Yeterlilik Bonusu | — | A,E,F,J |
| Difficulty Class | **Zorluk Derecesi** | Zorluk Seviyesi | Kısaltma ZD. 'Zorluk Seviyesi (ZS)' Zırh Sınıfı kısaltmasıyla çakışıyor. | D,I,A,B |
| DC | **ZD** | ZS | Zorluk Derecesi kısaltması. | D,I |
| CR | **TD** | ZD | Tehlike Derecesi; FRP-SRD 'ZD' kullanıyor ama ZD bizde Zorluk Derecesi. | A |
| Challenge Rating | **Tehlike Derecesi** | Zorluk Derecesi | FRP-SRD 'Zorluk Derecesi' diyor; DC ile çakıştığı için ayrıştırıldı. | A |
| Cantrip | **Cantrip** | Bazbüyü, Sıfırıncı Seviye Büyü | Topluluk İngilizce bırakıyor (kural gereği seçildi); BG3 resmi çevirisi 'Bazbüyü'. Türkçeleştirme isteniyorsa 'Bazbüyü' önerilir. | B,F,V,J |
| Species | **Soy** | Irk, Tür | 5.1'de 'Irk' (race) kullanılıyordu; 2024 'species' için 'Soy' öneriliyor. 'Tür' Yaratık Türü ile çakışıyor. | A,R |
| Copper Piece | **bakır** | BP | Kısaltma yerine kelime: '5 CP' → '5 bakır'. İngilizce kısaltmalar (GP=gold) Türkçe okumada yanıltıcı. | — |
| Silver Piece | **gümüş** | — | '1 SP' → '1 gümüş'. | — |
| Electrum Piece | **elektrum** | — | '1 EP' → '1 elektrum'. | — |
| Gold Piece | **altın** | AP, GP | '50 GP' → '50 altın'. | — |
| Platinum Piece | **platin** | — | '10 PP' → '10 platin'. | — |
| feet | **fit** | ayak, ft | Sayılar değişmez (QC). 30 feet → 30 fit. Metrik gösterim ileride uygulama ayarı olabilir. | — |
| Strength | **Güç** | Kuvvet | Topluluk yaklaşık yarı yarıya bölünmüş; BG3 'Kuvvet'. Force (hasar türü) 'Kuvvet' olduğundan Güç seçildi. | A,C,D,E,I,O,B,H,J |
| Wisdom | **Bilgelik** | Akıl, İrfan, Sezgi | Bilgelik/Akıl/İrfan arasında uzlaşma yok; FRP-SRD ve FRPNET Bilgelik. | A,C,D,E,B,H,J |
| Str | **Güç** | Kuv | Canavar kartı kısaltması. | — |
| Animal Handling | **Hayvan Terbiyesi** | Hayvanlarla İlgilenme | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| Arcana | **Arkana** | Gizli İlimler, Büyü Bilgisi | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| Intimidation | **Gözdağı** | Korkutma, Yıldırma | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| Performance | **Gösteri** | Performans | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| Bludgeoning | **Ezici** | Küt | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | K |
| Necrotic | **Nekrotik** | Çürüme | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |
| Radiant | **Işıltı** | Radyant, Işık | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |
| Thunder | **Gök Gürültüsü** | Ses | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |
| Abjuration | **Koruma** | Sakınma, Abjurasyon | — | F,S,K,B |
| Enchantment | **Efsunlama** | Büyüleme | — | K,S |
| Evocation | **Oluşturma** | Evokasyon | — | A,K,B |
| Transmutation | **Dönüşüm** | Transmutasyon, Başkalaşım | — | F,B,K |
| Beast | **Hayvan** | Canavar | FRP-SRD 'Canavar'ı beast için kullanıyor; biz Canavar'ı 'monster' için ayırdık. | A |
| Fiend | **İblis** | Şeytan, Zebani | — | K,B |
| Cleric | **Rahip** | Ruhban | FRP-SRD/FRPNET Rahip; BG3 Ruhban. | A,B,C,H,G,J,K |
| Ranger | **Korucu** | Kolcu | Yaklaşık eşit bölünmüş. | A,G,K,B,J,O |
| Sorcerer | **Sihirbaz** | Sorcerer | Çoğu oyuncu İngilizce bırakıyor; Türkçe biçim olarak Sihirbaz yerleşik. | A,G,J,K,L,B,F,S |
| Warlock | **Sehhar** | Warlock | Topluluk çoğunlukla İngilizce 'Warlock' diyor; Türkçe tek yerleşik biçim BG3'ün 'Sehhar'ı. Karar ürün sahibinde. | L,B,G,S |
| Two-Handed | **İki Elli** | Çift Elli | — | A |
| Versatile | **Çok Yönlü** | Ayarlanabilir | — | A |

## Tüm çekirdek terimler

### Kural

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 1 | Ability | **Yetenek** | tartışmalı |  | Özellik, Kabiliyet | Yetenek/Özellik/Kabiliyet üçü de kullanılıyor; Beceri (skill) ile çakışmayan en yaygın biçim seçildi. | R,N,C,I,A |
| 2 | Ability Score | **Yetenek Puanı** | tartışmalı | ✔ | Özellik Puanı, Kabiliyet Puanı |  | R,C,I,A |
| 3 | Ability Score Improvement | **Yetenek Puanı Artışı** | öneri | ✔ |  |  |  |
| 4 | ability modifier | **yetenek değiştiricisi** | tartışmalı | ✔ | ayar, tamamlayıcı, etken | Topluluk bölünmüş (Ayar, Tamamlayıcı, Etken, Değiştirici); en anlaşılır olan seçildi. | C,A,J,I |
| 5 | modifier | **değiştirici** | tartışmalı |  | ayar, tamamlayıcı, etken |  | C,A,J,I |
| 6 | Ability Check | **Yetenek Testi** | tartışmalı | ✔ | Kabiliyet Zarı, Yetenek Zarı | 2024 kurallarında check bir D20 Testi türü; 'Test' bunu yansıtıyor. | E,A,B |
| 7 | D20 Test | **D20 Testi** | öneri | ✔ |  |  |  |
| 8 | Saving Throw | **Kurtarma Zarı** | topluluk | ✔ | Kurtulma Zarı, Kurtarma Atışı | En yaygın biçim. | A,E,F,K |
| 9 | Death Saving Throw | **Ölüm Kurtarma Zarı** | öneri | ✔ | Ölüm Kurtarma Atışı |  | I |
| 10 | Attack Roll | **Saldırı Zarı** | topluluk | ✔ | İsabet Zarı |  | A,B,E |
| 11 | Damage Roll | **Hasar Zarı** | öneri | ✔ |  |  |  |
| 12 | Advantage | **Avantaj** | topluluk | ✔ |  | Evrensel. | A,B,E,F |
| 13 | Disadvantage | **Dezavantaj** | topluluk | ✔ |  | Evrensel. | A,B,E,F |
| 14 | Hit Points | **Can Puanı** | topluluk | ✔ | Can |  | A,C,D,F,I,K |
| 15 | Hit Point Maximum | **azami Can Puanı** | öneri |  |  |  |  |
| 16 | Temporary Hit Points | **Geçici Can Puanı** | öneri | ✔ |  |  |  |
| 17 | Hit Point Dice | **Can Zarı** | topluluk | ✔ |  | 2024'te Hit Dice → Hit Point Dice; Türkçe biçim aynı kalır. | A,D,I |
| 18 | Armor Class | **Zırh Sınıfı** | topluluk | ✔ | Zırh Seviyesi |  | C,D,E,I,J |
| 19 | Initiative | **İnisiyatif** | tartışmalı | ✔ | Öncelik | Topluluk Öncelik/İnisiyatif arasında bölünmüş; ürün sahibinin kendi brief'i 'İnisiyatif' kullanıyor. | B,K,I |
| 20 | Proficiency | **Yetkinlik** | tartışmalı | ✔ | Yeterlilik, Uzmanlık | Uzmanlık 'Expertise' ile çakışıyor; Yetkinlik/Yeterlilik eşit yaygın. | A,E,K,F,J |
| 21 | Proficiency Bonus | **Yetkinlik Bonusu** | tartışmalı | ✔ | Yeterlilik Bonusu |  | A,E,F,J |
| 22 | Expertise | **Uzmanlık** | öneri | ✔ | Ekspertiz |  | B |
| 23 | Skill | **Beceri** | topluluk | ✔ | Yetenek |  | A,E |
| 24 | Difficulty Class | **Zorluk Derecesi** | tartışmalı | ✔ | Zorluk Seviyesi | Kısaltma ZD. 'Zorluk Seviyesi (ZS)' Zırh Sınıfı kısaltmasıyla çakışıyor. | D,I,A,B |
| 25 | Challenge Rating | **Tehlike Derecesi** | tartışmalı | ✔ | Zorluk Derecesi | FRP-SRD 'Zorluk Derecesi' diyor; DC ile çakıştığı için ayrıştırıldı. | A |
| 26 | Experience Points | **Tecrübe Puanı** | topluluk | ✔ | Deneyim Puanı | Oyuncular arasında 'TP' yaygın. |  |
| 27 | Critical Hit | **Kritik Vuruş** | topluluk | ✔ |  |  | A,J |
| 28 | Short Rest | **Kısa Dinlenme** | topluluk | ✔ |  |  | I,J,U |
| 29 | Long Rest | **Uzun Dinlenme** | topluluk | ✔ |  |  | A,I,J,N,U |
| 30 | Heroic Inspiration | **Kahramanca İlham** | öneri | ✔ | İlham | 5e'deki 'Inspiration' için İlham yaygın; 2024 adı eklendi. | A,I |
| 31 | Concentration | **Konsantrasyon** | topluluk | ✔ |  | Evrensel. | A,B,F,J |
| 32 | Ritual | **Ritüel** | topluluk | ✔ | Ayin |  | A,S |
| 33 | Spell | **Büyü** | topluluk | ✔ |  |  | A,F |
| 34 | Spell Slot | **Büyü Slotu** | topluluk | ✔ | Büyü Yuvası, Büyü Hanesi | Topluluk ağırlıkla 'slot' kullanıyor. | A,B,F,R |
| 35 | Cantrip | **Cantrip** | tartışmalı | ✔ | Bazbüyü, Sıfırıncı Seviye Büyü | Topluluk İngilizce bırakıyor (kural gereği seçildi); BG3 resmi çevirisi 'Bazbüyü'. Türkçeleştirme isteniyorsa 'Bazbüyü' önerilir. | B,F,V,J |
| 36 | Spellcasting | **Büyü Yapma** | öneri |  |  |  | S |
| 37 | Spellcasting Ability | **büyü yeteneği** | öneri | ✔ |  |  |  |
| 38 | Spellcasting Focus | **Büyü Odağı** | öneri | ✔ |  |  |  |
| 39 | Spell Attack | **Büyü Saldırısı** | öneri | ✔ |  |  |  |
| 40 | spell save DC | **büyü kurtarma ZD'si** | öneri | ✔ |  |  | B |
| 41 | Level | **Seviye** | topluluk |  | Düzey | 'Level 2 Evocation' → '2. Seviye Oluşturma'. | A |
| 42 | Spellbook | **Büyü Kitabı** | öneri | ✔ |  |  |  |
| 43 | Unarmed Strike | **Silahsız Vuruş** | öneri | ✔ |  |  |  |
| 44 | Speed | **Hız** | topluluk | ✔ |  |  | A |
| 45 | Fly Speed | **Uçma Hızı** | öneri | ✔ |  |  |  |
| 46 | Swim Speed | **Yüzme Hızı** | öneri | ✔ |  |  |  |
| 47 | Climb Speed | **Tırmanma Hızı** | öneri | ✔ |  |  |  |
| 48 | Burrow Speed | **Kazma Hızı** | öneri | ✔ |  |  |  |
| 49 | Difficult Terrain | **Zorlu Arazi** | öneri | ✔ |  |  |  |
| 50 | Cover | **Siper** | öneri | ✔ | Örtü |  |  |
| 51 | Half Cover | **Yarım Siper** | öneri | ✔ |  |  |  |
| 52 | Three-Quarters Cover | **Üç Çeyrek Siper** | öneri | ✔ |  |  |  |
| 53 | Total Cover | **Tam Siper** | öneri | ✔ |  |  |  |
| 54 | Bright Light | **Parlak Işık** | öneri | ✔ |  |  |  |
| 55 | Dim Light | **Loş Işık** | öneri | ✔ |  |  |  |
| 56 | Darkness | **Karanlık** | öneri | ✔ |  |  |  |
| 57 | Lightly Obscured | **Hafif Örtülü** | öneri | ✔ |  |  |  |
| 58 | Heavily Obscured | **Yoğun Örtülü** | öneri | ✔ |  |  |  |
| 59 | Bloodied | **Kanlı** | öneri | ✔ | Yaralı |  |  |
| 60 | Healing | **İyileşme** | öneri |  |  |  |  |
| 61 | Stable | **Stabil** | öneri |  | Durağan |  |  |
| 62 | Dead | **Ölü** | öneri |  |  |  |  |
| 63 | Surprise | **Baskın** | öneri |  | Şaşkınlık |  |  |
| 64 | Grappling | **Kapışma** | öneri | ✔ |  |  |  |
| 65 | Encounter | **Karşılaşma** | öneri |  |  |  |  |
| 66 | Monster | **Canavar** | topluluk |  | Yaratık |  | A |
| 67 | Creature | **Yaratık** | topluluk |  |  |  | A |
| 68 | Creature Type | **Yaratık Türü** | öneri | ✔ |  |  | A |
| 69 | Game Master | **Oyun Yöneticisi** | topluluk | ✔ | DM | Kısaltma 'GM' korunur (uygulama adı da GM Cebi). | A,E,I |
| 70 | Player Character | **Oyuncu Karakteri** | öneri | ✔ |  |  | I |
| 71 | Nonplayer Character | **Oyuncu Olmayan Karakter** | öneri | ✔ | NPC | Kısaltma 'NPC' korunur. |  |
| 72 | Alignment | **Yönelim** | topluluk | ✔ | Hizalanma |  | A,D |
| 73 | Round | **Tur** | topluluk |  | Raunt |  |  |
| 74 | Turn | **Sıra** | öneri |  | Hamle | Tur (round) ile karışmaması için 'Sıra'. |  |
| 75 | Target | **Hedef** | topluluk |  |  |  |  |
| 76 | Hazard | **Tehlike** | öneri |  |  |  |  |
| 77 | Falling | **Düşme** | öneri |  |  |  |  |
| 78 | Suffocation | **Boğulma** | öneri |  |  |  |  |
| 79 | Teleportation | **Işınlanma** | öneri |  |  |  |  |
| 80 | Shape-Shifting | **Biçim Değiştirme** | öneri |  |  |  |  |
| 81 | Curse | **Lanet** | öneri |  |  |  |  |
| 82 | Possession | **Ele Geçirilme** | öneri |  |  |  |  |
| 83 | Illusion | **İllüzyon** | topluluk |  | Yanılsama |  | B,F |
| 84 | Attitude | **Tavır** | öneri |  |  |  |  |
| 85 | Friendly | **Dostça** | öneri | ✔ |  |  |  |
| 86 | Hostile | **Düşmanca** | öneri | ✔ |  |  |  |
| 87 | Indifferent | **Kayıtsız** | öneri | ✔ |  |  |  |
| 88 | Carrying Capacity | **Taşıma Kapasitesi** | öneri | ✔ |  |  |  |
| 89 | Jumping | **Zıplama** | öneri | ✔ |  |  |  |
| 90 | Long Jump | **Uzun Atlama** | öneri | ✔ |  |  |  |
| 91 | High Jump | **Yüksek Atlama** | öneri | ✔ |  |  |  |
| 92 | Occupied Space | **Dolu Alan** | öneri | ✔ |  |  |  |
| 93 | Unoccupied Space | **Boş Alan** | öneri | ✔ |  |  |  |
| 94 | See also | **Ayrıca bkz.** | öneri |  |  | Çapraz referans kalıbı. |  |

### Kısaltma

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 95 | DC | **ZD** | tartışmalı | ✔ | ZS | Zorluk Derecesi kısaltması. | D,I |
| 96 | AC | **ZS** | öneri | ✔ |  | Zırh Sınıfı kısaltması. |  |
| 97 | HP | **CP** | öneri | ✔ |  | Can Puanı kısaltması. Bakır para kısaltması kullanılmadığı için çakışma yok. |  |
| 98 | XP | **TP** | öneri | ✔ |  | Tecrübe Puanı. |  |
| 99 | PB | **YB** | öneri | ✔ |  | Yetkinlik Bonusu. |  |
| 100 | CR | **TD** | tartışmalı | ✔ | ZD | Tehlike Derecesi; FRP-SRD 'ZD' kullanıyor ama ZD bizde Zorluk Derecesi. | A |
| 101 | GM | **GM** | topluluk | ✔ | DM, OY |  | B,C |
| 102 | Str | **Güç** | tartışmalı |  | Kuv | Canavar kartı kısaltması. |  |
| 103 | Dex | **Çev** | öneri |  |  |  |  |
| 104 | Con | **Day** | öneri |  |  |  |  |
| 105 | Int | **Zek** | öneri |  |  |  |  |
| 106 | Wis | **Bil** | öneri |  |  |  |  |
| 107 | Cha | **Kar** | öneri |  |  |  |  |

### Yetenek

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 108 | Strength | **Güç** | tartışmalı | ✔ | Kuvvet | Topluluk yaklaşık yarı yarıya bölünmüş; BG3 'Kuvvet'. Force (hasar türü) 'Kuvvet' olduğundan Güç seçildi. | A,C,D,E,I,O,B,H,J |
| 109 | Dexterity | **Çeviklik** | topluluk | ✔ |  | Evrensel. | A,B,C,E,F,J |
| 110 | Constitution | **Dayanıklılık** | topluluk | ✔ |  | Evrensel. | A,B,C,E,F,H,J |
| 111 | Intelligence | **Zeka** | topluluk | ✔ |  |  | A,B,C,E,J |
| 112 | Wisdom | **Bilgelik** | tartışmalı | ✔ | Akıl, İrfan, Sezgi | Bilgelik/Akıl/İrfan arasında uzlaşma yok; FRP-SRD ve FRPNET Bilgelik. | A,C,D,E,B,H,J |
| 113 | Charisma | **Karizma** | topluluk | ✔ |  |  | A,B,C,E,J |

### Beceri

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 114 | Acrobatics | **Akrobasi** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 115 | Animal Handling | **Hayvan Terbiyesi** | tartışmalı | ✔ | Hayvanlarla İlgilenme | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 116 | Arcana | **Arkana** | tartışmalı | ✔ | Gizli İlimler, Büyü Bilgisi | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 117 | Athletics | **Atletizm** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 118 | Deception | **Aldatma** | topluluk | ✔ | Kandırma | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 119 | History | **Tarih** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 120 | Insight | **Sezgi** | topluluk | ✔ | Önsezi | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 121 | Intimidation | **Gözdağı** | tartışmalı | ✔ | Korkutma, Yıldırma | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 122 | Investigation | **Araştırma** | topluluk | ✔ | Soruşturma | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 123 | Medicine | **Tıp** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 124 | Nature | **Doğa** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 125 | Perception | **Algı** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 126 | Performance | **Gösteri** | tartışmalı | ✔ | Performans | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 127 | Persuasion | **İkna** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 128 | Religion | **Din** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 129 | Sleight of Hand | **El Çabukluğu** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 130 | Stealth | **Gizlilik** | topluluk | ✔ | Sinsilik | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 131 | Survival | **Hayatta Kalma** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |

### Durum

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 132 | Blinded | **Kör** | öneri | ✔ | Körlük | Durum adları sıfat olarak: 'Kör durumunda'. | A,K |
| 133 | Charmed | **Büyülenmiş** | öneri | ✔ | Efsunlanmış |  | F,K |
| 134 | Deafened | **Sağır** | öneri | ✔ | Sağırlık |  | A |
| 135 | Exhaustion | **Yorgunluk** | topluluk | ✔ | Bitkinlik |  | A |
| 136 | Frightened | **Korkmuş** | öneri | ✔ | Dehşete Düşmüş |  |  |
| 137 | Grappled | **Yakalanmış** | topluluk | ✔ | Tutulmuş |  | B |
| 138 | Incapacitated | **Etkisiz** | öneri | ✔ | Aciz |  |  |
| 139 | Invisible | **Görünmez** | topluluk | ✔ |  |  | F |
| 140 | Paralyzed | **Felçli** | topluluk | ✔ | Felç |  | J,K |
| 141 | Petrified | **Taşlaşmış** | öneri | ✔ |  |  |  |
| 142 | Poisoned | **Zehirlenmiş** | öneri | ✔ |  |  | K |
| 143 | Prone | **Yerde** | topluluk | ✔ | Yere Yığılmış |  | B |
| 144 | Restrained | **Kısıtlanmış** | öneri | ✔ | Bağlanmış |  |  |
| 145 | Stunned | **Sersemlemiş** | öneri | ✔ |  |  | K |
| 146 | Unconscious | **Bilinçsiz** | topluluk | ✔ | Baygın |  | B |
| 147 | Condition | **Durum** | topluluk | ✔ |  |  |  |

### Eylem

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 148 | Action | **Eylem** | topluluk | ✔ | Aksiyon |  | A,B,I |
| 149 | Bonus Action | **Bonus Eylem** | topluluk | ✔ | Bonus Aksiyon |  | A,B,I |
| 150 | Reaction | **Reaksiyon** | topluluk | ✔ | Tepki | BG3 ve çoğu topluluk kaynağı Reaksiyon; FRP-SRD Tepki. | B,I,J,N,U,A |
| 151 | Opportunity Attack | **Fırsat Saldırısı** | topluluk | ✔ |  |  | B,I |
| 152 | Attack [Action] | **Saldırı** | topluluk |  |  | 'Attack action' → 'Saldırı eylemi'. | A,B |
| 153 | Dash | **Atılma** | öneri | ✔ | Koşma |  |  |
| 154 | Disengage | **Geri Çekilme** | öneri | ✔ |  |  |  |
| 155 | Dodge | **Kaçınma** | öneri | ✔ | Savuşturma |  |  |
| 156 | Help | **Yardım** | öneri | ✔ |  |  |  |
| 157 | Hide | **Saklanma** | öneri | ✔ |  |  |  |
| 158 | Influence | **Etkileme** | öneri | ✔ |  |  |  |
| 159 | Magic [Action] | **Büyü** | öneri | ✔ |  | 'Magic action' → 'Büyü eylemi'. |  |
| 160 | Ready | **Hazırlanma** | öneri | ✔ |  |  |  |
| 161 | Search | **Arama** | öneri | ✔ |  |  |  |
| 162 | Study | **İnceleme** | öneri | ✔ |  |  |  |
| 163 | Utilize | **Kullanma** | öneri | ✔ |  |  |  |

### Hasar

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 164 | Resistance | **Direnç** | topluluk | ✔ |  |  | F,J,K,N |
| 165 | Vulnerability | **Zafiyet** | öneri | ✔ | Hassaslık | BG3 'Hassaslık' kullanıyor. | J |
| 166 | Immunity | **Bağışıklık** | topluluk | ✔ |  |  | A,F,J |
| 167 | Damage | **Hasar** | topluluk | ✔ |  |  | A,C,F,N |
| 168 | Damage Threshold | **Hasar Eşiği** | öneri | ✔ |  |  |  |

### Hasar türü

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 169 | Acid | **Asit** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | F,J,N |
| 170 | Bludgeoning | **Ezici** | tartışmalı | ✔ | Küt | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | K |
| 171 | Cold | **Soğuk** | topluluk | ✔ | Buz | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | F,N,J |
| 172 | Fire | **Ateş** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | A,F,J,N |
| 173 | Force | **Kuvvet** | öneri | ✔ | Saf Enerji | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. |  |
| 174 | Lightning | **Yıldırım** | topluluk | ✔ | Elektrik | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | J,N,F |
| 175 | Necrotic | **Nekrotik** | tartışmalı | ✔ | Çürüme | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |
| 176 | Piercing | **Delici** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | K |
| 177 | Poison | **Zehir** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | A,J,N |
| 178 | Psychic | **Psişik** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | J,N |
| 179 | Radiant | **Işıltı** | tartışmalı | ✔ | Radyant, Işık | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |
| 180 | Slashing | **Kesici** | topluluk | ✔ | Kesme | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | K,J |
| 181 | Thunder | **Gök Gürültüsü** | tartışmalı | ✔ | Ses | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |

### Duyu

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 182 | Darkvision | **Karanlık Görüş** | öneri | ✔ | Karanlıkta Görme |  |  |
| 183 | Blindsight | **Kör Görüş** | öneri | ✔ |  |  |  |
| 184 | Tremorsense | **Titreşim Algısı** | öneri | ✔ |  |  |  |
| 185 | Truesight | **Gerçek Görüş** | öneri | ✔ |  |  |  |
| 186 | Passive Perception | **Pasif Algı** | öneri | ✔ |  |  |  |
| 187 | Telepathy | **Telepati** | öneri | ✔ |  |  |  |

### Alan

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 188 | Area of Effect | **Etki Alanı** | öneri | ✔ |  |  |  |
| 189 | Cone | **Koni** | öneri | ✔ |  |  |  |
| 190 | Cube | **Küp** | öneri | ✔ |  |  |  |
| 191 | Cylinder | **Silindir** | öneri | ✔ |  |  |  |
| 192 | Emanation | **Yayılım** | öneri | ✔ |  |  |  |
| 193 | Line | **Çizgi** | öneri | ✔ | Hat |  |  |
| 194 | Sphere | **Küre** | öneri | ✔ |  |  |  |

### Büyü

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 195 | Casting Time | **Yapma Süresi** | öneri | ✔ |  | Büyü kartı alanı. |  |
| 196 | Range | **Menzil** | topluluk |  |  | Büyü kartı alanı ve silah özelliği. |  |
| 197 | Components | **Bileşenler** | öneri | ✔ |  |  |  |
| 198 | Verbal | **Sözlü** | öneri |  |  | V → S (Sözlü). |  |
| 199 | Somatic | **Bedensel** | öneri |  |  | S → B (Bedensel). |  |
| 200 | Material | **Malzeme** | öneri |  |  | M → M (Malzeme). |  |
| 201 | Duration | **Süre** | topluluk | ✔ |  |  |  |
| 202 | Instantaneous | **Anlık** | öneri | ✔ |  |  |  |
| 203 | Using a Higher-Level Spell Slot | **Daha Yüksek Seviyeli Büyü Slotu Kullanma** | öneri | ✔ |  |  |  |
| 204 | Cantrip Upgrade | **Cantrip Gelişimi** | öneri | ✔ |  |  |  |

### Büyü okulu

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 205 | Abjuration | **Koruma** | tartışmalı |  | Sakınma, Abjurasyon |  | F,S,K,B |
| 206 | Conjuration | **Çağırma** | topluluk |  | Konjurasyon |  | F,K,S |
| 207 | Divination | **Kehanet** | topluluk |  | Divinasyon |  | F,K |
| 208 | Enchantment | **Efsunlama** | tartışmalı |  | Büyüleme |  | K,S |
| 209 | Evocation | **Oluşturma** | tartışmalı |  | Evokasyon |  | A,K,B |
| 210 | Illusion | **İllüzyon** | topluluk |  | Yanılsama |  | B,F |
| 211 | Necromancy | **Nekromansi** | topluluk |  | Ölüm İlmi |  | A,B,K |
| 212 | Transmutation | **Dönüşüm** | tartışmalı |  | Transmutasyon, Başkalaşım |  | F,B,K |
| 213 | School of Magic | **Büyü Okulu** | topluluk |  | Ekol |  | B,F,A |

### Sınıf

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 214 | Class | **Sınıf** | topluluk |  |  |  | A,B,F |
| 215 | Subclass | **Alt Sınıf** | topluluk | ✔ |  |  | A,B,F |
| 216 | Class Feature | **Sınıf Özelliği** | öneri |  |  |  |  |
| 217 | Multiclassing | **Çoklu Sınıf** | öneri |  |  |  |  |
| 218 | Barbarian | **Barbar** | topluluk | ✔ |  |  | A,B,D,G,J,K |
| 219 | Bard | **Ozan** | topluluk | ✔ | Bard |  | A,B,G,J,K |
| 220 | Cleric | **Rahip** | tartışmalı | ✔ | Ruhban | FRP-SRD/FRPNET Rahip; BG3 Ruhban. | A,B,C,H,G,J,K |
| 221 | Druid | **Druid** | topluluk | ✔ |  |  | A,B,G,H,J,K |
| 222 | Fighter | **Savaşçı** | topluluk | ✔ | Dövüşçü | BG3 bilinçli olarak Dövüşçü seçti. | A,B,C,G,O,J |
| 223 | Monk | **Keşiş** | topluluk | ✔ |  |  | A,B,G,J,K |
| 224 | Paladin | **Paladin** | topluluk | ✔ |  |  | A,B,G,J,K |
| 225 | Ranger | **Korucu** | tartışmalı | ✔ | Kolcu | Yaklaşık eşit bölünmüş. | A,G,K,B,J,O |
| 226 | Rogue | **Düzenbaz** | topluluk | ✔ | Hırsız | Hırsız alt sınıf (Thief) için ayrıldı. | A,B,C,G,J,K,T |
| 227 | Sorcerer | **Sihirbaz** | tartışmalı | ✔ | Sorcerer | Çoğu oyuncu İngilizce bırakıyor; Türkçe biçim olarak Sihirbaz yerleşik. | A,G,J,K,L,B,F,S |
| 228 | Warlock | **Sehhar** | tartışmalı | ✔ | Warlock | Topluluk çoğunlukla İngilizce 'Warlock' diyor; Türkçe tek yerleşik biçim BG3'ün 'Sehhar'ı. Karar ürün sahibinde. | L,B,G,S |
| 229 | Wizard | **Büyücü** | topluluk | ✔ |  |  | A,C,F,G,J,K |
| 230 | Wild Shape | **Vahşi Biçim** | öneri | ✔ |  | Druid özelliği. |  |

### Alt sınıf

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 231 | Path of the Berserker | **Gözü Dönmüş Yolu** | öneri | ✔ |  |  |  |
| 232 | College of Lore | **İrfan Okulu** | öneri | ✔ |  |  |  |
| 233 | Life Domain | **Yaşam Alanı** | öneri | ✔ |  |  |  |
| 234 | Circle of the Land | **Toprak Çemberi** | öneri | ✔ |  |  |  |
| 235 | Champion | **Şampiyon** | öneri | ✔ |  |  |  |
| 236 | Warrior of the Open Hand | **Açık El Savaşçısı** | öneri | ✔ |  |  |  |
| 237 | Oath of Devotion | **Bağlılık Yemini** | öneri | ✔ |  |  |  |
| 238 | Hunter | **Avcı** | öneri | ✔ |  |  |  |
| 239 | Thief | **Hırsız** | öneri | ✔ |  |  |  |
| 240 | Draconic Sorcery | **Ejderha Sihri** | öneri | ✔ |  |  |  |
| 241 | Fiend Patron | **İblis Hamisi** | öneri | ✔ |  |  |  |
| 242 | Evoker | **Oluşturucu** | öneri | ✔ |  |  |  |

### Soy

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 243 | Dragonborn | **Ejderdoğan** | topluluk | ✔ |  |  | A,O,P |
| 244 | Dwarf | **Cüce** | topluluk | ✔ |  |  | A,B,H,I,K,O |
| 245 | Elf | **Elf** | topluluk | ✔ |  |  | A,B,I,K,O |
| 246 | Gnome | **Gnom** | topluluk | ✔ | Gnome |  | A,K |
| 247 | Goliath | **Goliat** | öneri | ✔ | Goliath |  | B |
| 248 | Halfling | **Buçukluk** | topluluk | ✔ | Halfling |  | A,K,O |
| 249 | Human | **İnsan** | topluluk | ✔ |  |  | A,I |
| 250 | Orc | **Ork** | topluluk | ✔ |  |  | A,B,K |
| 251 | Tiefling | **Tiefling** | topluluk | ✔ | Şeytanımsı |  | J,O |
| 252 | Drow | **Drow** | öneri |  | Kara Elf | Elf soyu; SRD 5.2.1'de geçtiği için lisanslı. |  |
| 253 | High Elf | **Yüksek Elf** | öneri | ✔ |  |  |  |
| 254 | Wood Elf | **Orman Elfi** | öneri | ✔ |  |  |  |
| 255 | Forest Gnome | **Orman Gnomu** | öneri | ✔ |  |  |  |
| 256 | Rock Gnome | **Kaya Gnomu** | öneri | ✔ |  |  |  |

### Köken

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 257 | Feat | **Hüner** | topluluk | ✔ | Yetenek |  | A,B,H,T |
| 258 | Origin Feat | **Köken Hüneri** | öneri | ✔ |  |  |  |
| 259 | General Feat | **Genel Hüner** | öneri | ✔ |  |  |  |
| 260 | Fighting Style Feat | **Dövüş Tarzı Hüneri** | öneri | ✔ |  |  |  |
| 261 | Epic Boon Feat | **Destansı Lütuf Hüneri** | öneri | ✔ |  |  |  |
| 262 | Background | **Geçmiş** | topluluk | ✔ |  |  | A,B,I,N,R |
| 263 | Species | **Soy** | tartışmalı | ✔ | Irk, Tür | 5.1'de 'Irk' (race) kullanılıyordu; 2024 'species' için 'Soy' öneriliyor. 'Tür' Yaratık Türü ile çakışıyor. | A,R |

### Geçmiş

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 264 | Acolyte | **Mürit** | öneri |  |  |  |  |
| 265 | Criminal | **Suçlu** | öneri |  |  |  |  |
| 266 | Sage | **Bilge** | öneri |  |  |  |  |
| 267 | Soldier | **Asker** | öneri |  |  |  |  |

### Hüner

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 268 | Alert | **Tetikte** | öneri |  |  |  |  |
| 269 | Magic Initiate | **Büyü Çırağı** | öneri |  |  |  |  |
| 270 | Savage Attacker | **Vahşi Saldırgan** | öneri |  |  |  |  |
| 271 | Skilled | **Becerikli** | öneri |  |  |  |  |
| 272 | Grappler | **Güreşçi** | öneri |  |  |  |  |
| 273 | Archery | **Okçuluk** | öneri |  |  |  |  |
| 274 | Defense | **Savunma** | öneri |  |  |  |  |
| 275 | Great Weapon Fighting | **Büyük Silah Dövüşü** | öneri |  |  |  |  |
| 276 | Two-Weapon Fighting | **İki Silahla Dövüş** | öneri |  |  |  |  |
| 277 | Boon of Combat Prowess | **Savaş Hüneri Lütfu** | öneri |  |  |  |  |
| 278 | Boon of Dimensional Travel | **Boyutlar Arası Yolculuk Lütfu** | öneri |  |  |  |  |
| 279 | Boon of Fate | **Kader Lütfu** | öneri |  |  |  |  |
| 280 | Boon of Irresistible Offense | **Karşı Konulmaz Saldırı Lütfu** | öneri |  |  |  |  |
| 281 | Boon of Spell Recall | **Büyü Hatırlama Lütfu** | öneri |  |  |  |  |
| 282 | Boon of the Night Spirit | **Gece Ruhu Lütfu** | öneri |  |  |  |  |
| 283 | Boon of Truesight | **Gerçek Görüş Lütfu** | öneri |  |  |  |  |

### Yönelim

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 284 | Lawful | **Kuralcı** | topluluk | ✔ |  |  | A,C,D,K |
| 285 | Chaotic | **Kaotik** | topluluk | ✔ |  |  | A,C,D,K |
| 286 | Neutral | **Tarafsız** | topluluk | ✔ |  |  | A,C,D,K |
| 287 | Good | **İyi** | topluluk |  |  |  | C,K |
| 288 | Evil | **Kötü** | topluluk |  |  |  | C,K |
| 289 | Unaligned | **Yönelimsiz** | öneri | ✔ |  |  |  |

### Boyut

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 290 | Tiny | **Minik** | öneri |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 291 | Small | **Küçük** | topluluk |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 292 | Medium | **Orta** | topluluk |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 293 | Large | **Büyük** | topluluk |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 294 | Huge | **Devasa** | öneri |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 295 | Gargantuan | **Muazzam** | öneri |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 296 | Size | **Boyut** | topluluk |  |  |  | A |

### Yaratık türü

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 297 | Aberration | **Garabet** | öneri |  | Aberasyon |  |  |
| 298 | Beast | **Hayvan** | tartışmalı |  | Canavar | FRP-SRD 'Canavar'ı beast için kullanıyor; biz Canavar'ı 'monster' için ayırdık. | A |
| 299 | Celestial | **Göksel** | öneri |  |  |  |  |
| 300 | Construct | **Yapıt** | öneri |  | Yapay Varlık |  |  |
| 301 | Dragon | **Ejderha** | topluluk |  |  |  | K |
| 302 | Elemental | **Elemental** | topluluk |  |  |  | K |
| 303 | Fey | **Peri** | topluluk |  |  |  | A |
| 304 | Fiend | **İblis** | tartışmalı |  | Şeytan, Zebani |  | K,B |
| 305 | Giant | **Dev** | topluluk |  |  |  | K |
| 306 | Humanoid | **İnsansı** | topluluk |  |  |  | A,B |
| 307 | Monstrosity | **Ucube** | öneri |  |  |  |  |
| 308 | Ooze | **Balçık** | öneri |  |  |  |  |
| 309 | Plant | **Bitki** | öneri |  |  |  |  |
| 310 | Undead | **Hortlak** | topluluk |  | Yaşayan Ölü |  | A,K,F |

### Canavar

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 311 | Multiattack | **Çoklu Saldırı** | öneri | ✔ |  |  |  |
| 312 | Legendary Action | **Efsanevi Eylem** | öneri | ✔ |  |  | A |
| 313 | Legendary Resistance | **Efsanevi Direnç** | öneri | ✔ |  |  |  |
| 314 | Lair | **İn** | öneri | ✔ | Yuva |  |  |
| 315 | Stat Block | **İstatistik Bloğu** | öneri | ✔ | Değer Kartı |  |  |
| 316 | Traits | **Özellikler** | öneri |  |  | Canavar kartı bölüm başlığı. |  |

### Silah

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 317 | Weapon Mastery | **Silah Ustalığı** | öneri | ✔ |  |  |  |
| 318 | Improvised Weapon | **Doğaçlama Silah** | öneri | ✔ |  |  |  |
| 319 | Simple Weapon | **Basit Silah** | öneri | ✔ |  |  |  |
| 320 | Martial Weapon | **Savaş Silahı** | öneri | ✔ | Askerî Silah |  |  |
| 321 | Club | **Sopa** | öneri |  |  |  |  |
| 322 | Dagger | **Hançer** | öneri |  |  |  |  |
| 323 | Greatclub | **Büyük Sopa** | öneri |  |  |  |  |
| 324 | Handaxe | **El Baltası** | öneri |  |  |  |  |
| 325 | Javelin | **Cirit** | öneri |  |  |  |  |
| 326 | Light Hammer | **Hafif Çekiç** | öneri |  |  |  |  |
| 327 | Mace | **Topuz** | öneri |  |  |  |  |
| 328 | Quarterstaff | **Asa** | öneri |  |  |  |  |
| 329 | Sickle | **Orak** | öneri |  |  |  |  |
| 330 | Spear | **Mızrak** | öneri |  |  |  |  |
| 331 | Dart | **Dart** | öneri |  |  |  |  |
| 332 | Light Crossbow | **Hafif Arbalet** | öneri |  |  |  |  |
| 333 | Shortbow | **Kısa Yay** | öneri |  |  |  |  |
| 334 | Sling | **Sapan** | öneri |  |  |  |  |
| 335 | Battleaxe | **Savaş Baltası** | öneri |  |  |  |  |
| 336 | Flail | **Döven** | öneri |  |  |  |  |
| 337 | Glaive | **Glaive** | öneri |  |  |  |  |
| 338 | Greataxe | **Büyük Balta** | öneri |  |  |  |  |
| 339 | Greatsword | **Büyük Kılıç** | öneri |  |  |  |  |
| 340 | Halberd | **Teber** | öneri |  |  |  |  |
| 341 | Lance | **Kargı** | öneri |  |  |  |  |
| 342 | Longsword | **Uzun Kılıç** | öneri |  |  |  |  |
| 343 | Maul | **Gürz** | öneri |  |  |  |  |
| 344 | Morningstar | **Çivili Gürz** | öneri |  |  |  |  |
| 345 | Pike | **Uzun Mızrak** | öneri |  |  |  |  |
| 346 | Rapier | **Meç** | öneri |  |  |  |  |
| 347 | Scimitar | **Pala** | öneri |  |  |  |  |
| 348 | Shortsword | **Kısa Kılıç** | öneri |  |  |  |  |
| 349 | Trident | **Üç Dişli Mızrak** | öneri |  |  |  |  |
| 350 | Warhammer | **Savaş Çekici** | öneri |  |  |  |  |
| 351 | War Pick | **Savaş Kazması** | öneri |  |  |  |  |
| 352 | Whip | **Kırbaç** | öneri |  |  |  |  |
| 353 | Blowgun | **Üfleme Borusu** | öneri |  |  |  |  |
| 354 | Hand Crossbow | **El Arbaleti** | öneri |  |  |  |  |
| 355 | Heavy Crossbow | **Ağır Arbalet** | öneri |  |  |  |  |
| 356 | Longbow | **Uzun Yay** | öneri |  |  |  |  |
| 357 | Musket | **Misket Tüfeği** | öneri |  |  |  |  |
| 358 | Pistol | **Tabanca** | öneri |  |  |  |  |

### Silah özelliği

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 359 | Ammunition | **Mühimmat** | öneri |  | Cephane |  |  |
| 360 | Finesse | **İncelik** | öneri |  | Zarafet |  |  |
| 361 | Heavy | **Ağır** | topluluk |  |  |  | A |
| 362 | Light | **Hafif** | topluluk |  |  |  | A |
| 363 | Loading | **Doldurma** | öneri |  |  |  |  |
| 364 | Reach | **Erişim** | topluluk |  | Uzanım |  | A |
| 365 | Thrown | **Fırlatma** | öneri |  | Fırlatılabilir |  |  |
| 366 | Two-Handed | **İki Elli** | tartışmalı |  | Çift Elli |  | A |
| 367 | Versatile | **Çok Yönlü** | tartışmalı |  | Ayarlanabilir |  | A |

### Silah ustalığı

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 368 | Cleave | **Yarma** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 369 | Graze | **Sıyırma** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 370 | Nick | **Çentik** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 371 | Push | **İtme** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 372 | Sap | **Zayıflatma** | öneri |  | Sersemletme | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 373 | Slow | **Yavaşlatma** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 374 | Topple | **Devirme** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 375 | Vex | **Taciz** | öneri |  | Rahatsız Etme | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |

### Zırh

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 376 | Armor Training | **Zırh Eğitimi** | öneri | ✔ |  |  |  |
| 377 | Light Armor | **Hafif Zırh** | topluluk | ✔ |  |  | A,H |
| 378 | Medium Armor | **Orta Zırh** | topluluk | ✔ |  |  | A,H |
| 379 | Heavy Armor | **Ağır Zırh** | topluluk | ✔ |  |  | A,H |
| 380 | Shield | **Kalkan** | topluluk | ✔ |  |  | A,H |
| 381 | Padded Armor | **Kapitone Zırh** | öneri |  |  |  |  |
| 382 | Leather Armor | **Deri Zırh** | öneri |  |  |  |  |
| 383 | Studded Leather Armor | **Perçinli Deri Zırh** | öneri |  |  |  |  |
| 384 | Hide Armor | **Post Zırh** | öneri |  |  |  |  |
| 385 | Chain Shirt | **Zincir Gömlek** | öneri |  |  |  |  |
| 386 | Scale Mail | **Pullu Zırh** | öneri |  |  |  |  |
| 387 | Breastplate | **Göğüslük** | öneri |  |  |  |  |
| 388 | Half Plate Armor | **Yarım Plaka Zırh** | öneri |  |  |  |  |
| 389 | Ring Mail | **Halkalı Zırh** | öneri |  |  |  |  |
| 390 | Chain Mail | **Zincir Zırh** | öneri |  |  |  |  |
| 391 | Splint Armor | **Lamalı Zırh** | öneri |  |  |  |  |
| 392 | Plate Armor | **Plaka Zırh** | öneri |  |  |  |  |

### Ekipman

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 393 | Coin | **Sikke** | öneri |  | Para |  |  |
| 394 | Artisan’s Tools | **Zanaatkâr Aletleri** | öneri |  |  |  |  |
| 395 | Thieves’ Tools | **Hırsız Aletleri** | öneri |  |  |  |  |
| 396 | Herbalism Kit | **Bitki Bilimi Takımı** | öneri |  |  |  |  |
| 397 | Musical Instrument | **Müzik Aleti** | öneri |  |  |  |  |
| 398 | Gaming Set | **Oyun Takımı** | öneri |  |  |  |  |
| 399 | Holy Symbol | **Kutsal Sembol** | öneri |  |  |  |  |
| 400 | Arcane Focus | **Arkana Odağı** | öneri |  |  |  |  |
| 401 | Druidic Focus | **Druid Odağı** | öneri |  |  |  |  |
| 402 | Component Pouch | **Bileşen Kesesi** | öneri |  |  |  |  |
| 403 | Explorer’s Pack | **Kâşif Çantası** | öneri |  |  |  |  |
| 404 | Healer’s Kit | **Şifacı Takımı** | öneri |  |  |  |  |
| 405 | Potion of Healing | **Şifa İksiri** | öneri |  |  |  |  |
| 406 | Spell Scroll | **Büyü Parşömeni** | öneri |  |  |  |  |

### Eşya

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 407 | Attunement | **Uyumlanma** | öneri | ✔ |  |  |  |
| 408 | Magic Item | **Büyülü Eşya** | öneri | ✔ |  |  |  |

### Para

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 409 | Copper Piece | **bakır** | tartışmalı | ✔ | BP | Kısaltma yerine kelime: '5 CP' → '5 bakır'. İngilizce kısaltmalar (GP=gold) Türkçe okumada yanıltıcı. |  |
| 410 | Silver Piece | **gümüş** | tartışmalı | ✔ |  | '1 SP' → '1 gümüş'. |  |
| 411 | Electrum Piece | **elektrum** | tartışmalı | ✔ |  | '1 EP' → '1 elektrum'. |  |
| 412 | Gold Piece | **altın** | tartışmalı | ✔ | AP, GP | '50 GP' → '50 altın'. |  |
| 413 | Platinum Piece | **platin** | tartışmalı | ✔ |  | '10 PP' → '10 platin'. |  |

### Birim

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 414 | feet | **fit** | tartışmalı | ✔ | ayak, ft | Sayılar değişmez (QC). 30 feet → 30 fit. Metrik gösterim ileride uygulama ayarı olabilir. |  |
| 415 | mile | **mil** | öneri | ✔ |  |  |  |
| 416 | pound (lb.) | **lb** | öneri |  | libre | Ağırlık birimi kısaltması korunur. |  |

## Pilot büyü adları ve bölüm adları

| İngilizce | Türkçe | Tür |
|---|---|---|
| Playing the Game | Oyunun Oynanışı | bölüm |
| Character Creation | Karakter Oluşturma | bölüm |
| Classes | Sınıflar | bölüm |
| Character Origins | Karakter Kökenleri | bölüm |
| Feats | Hünerler | bölüm |
| Equipment | Ekipman | bölüm |
| Spells | Büyüler | bölüm |
| Rules Glossary | Kurallar Sözlüğü | bölüm |
| Gameplay Toolbox | Oyun Araç Kutusu | bölüm |
| Magic Items | Büyülü Eşyalar | bölüm |
| Monsters | Canavarlar | bölüm |
| Fire Bolt | Ateş Oku | büyü adı |
| Light | Işık | büyü adı |
| Mage Hand | Büyücü Eli | büyü adı |
| Minor Illusion | Küçük İllüzyon | büyü adı |
| Prestidigitation | El Çabukluğu Büyüsü | büyü adı |
| Sacred Flame | Kutsal Alev | büyü adı |
| Guidance | Rehberlik | büyü adı |
| Eldritch Blast | Kadim Patlama | büyü adı |
| Vicious Mockery | Acımasız Alay | büyü adı |
| Ray of Frost | Ayaz Işını | büyü adı |
| Shocking Grasp | Şok Edici Kavrayış | büyü adı |
| Thaumaturgy | Mucizecilik | büyü adı |
| Druidcraft | Druid Hüneri | büyü adı |
| Acid Splash | Asit Sıçraması | büyü adı |
| Bless | Kutsama | büyü adı |
| Cure Wounds | Yaraları İyileştir | büyü adı |
| Healing Word | Şifa Sözü | büyü adı |
| Magic Missile | Büyülü Füze | büyü adı |
| Shield | Kalkan Büyüsü | büyü adı |
| Sleep | Uyku | büyü adı |
| Detect Magic | Büyü Algıla | büyü adı |
| Charm Person | Kişiyi Büyüle | büyü adı |
| Thunderwave | Gök Gürültüsü Dalgası | büyü adı |
| Burning Hands | Yanan Eller | büyü adı |
| Faerie Fire | Peri Ateşi | büyü adı |
| Guiding Bolt | Yol Gösteren Şimşek | büyü adı |
| Command | Emir | büyü adı |
| Hunter’s Mark | Avcının İşareti | büyü adı |
| Mage Armor | Büyücü Zırhı | büyü adı |
| Feather Fall | Tüy Düşüşü | büyü adı |
| Identify | Tanımla | büyü adı |
| Misty Step | Sisli Adım | büyü adı |
| Hold Person | Kişiyi Durdur | büyü adı |
| Invisibility | Görünmezlik | büyü adı |
| Spiritual Weapon | Ruhani Silah | büyü adı |
| Scorching Ray | Kavurucu Işın | büyü adı |
| Web | Ağ | büyü adı |
| Suggestion | Telkin | büyü adı |
| Darkness | Karanlık | büyü adı |
| Lesser Restoration | Küçük Onarım | büyü adı |
| Fireball | Ateş Topu | büyü adı |
| Counterspell | Karşı Büyü | büyü adı |
| Dispel Magic | Büyüyü Boz | büyü adı |
| Fly | Uçma | büyü adı |
| Haste | Hız Büyüsü | büyü adı |
| Revivify | Dirilt | büyü adı |
| Lightning Bolt | Yıldırım Oku | büyü adı |
| Spirit Guardians | Ruh Muhafızları | büyü adı |
| Polymorph | Biçim Değiştir | büyü adı |
| Greater Invisibility | Üstün Görünmezlik | büyü adı |
| Combat | Savaş | bölüm |
| Exploration | Keşif | bölüm |
| Social Interaction | Sosyal Etkileşim | bölüm |
| Damage and Healing | Hasar ve İyileşme | bölüm |
| Level Advancement | Seviye Atlama | bölüm |
| The Six Abilities | Altı Yetenek | bölüm |
| Create Your Character | Karakterini Oluştur | bölüm |
| Combat Encounters | Savaş Karşılaşmaları | bölüm |
| Animals | Hayvanlar | bölüm |
| D20 Tests | D20 Testleri | bölüm |

## Kaynaklar

Kanıt sütunundaki harfler. Yalnızca tek tek terimler alındı; metin kopyalanmadı. Erişilemeyen kaynaklar: Zindan Efendisi blogu, araklon.com, Scribd/anyflip hayran çevirileri. duruNdragons, Gordion Game Fate Core çevirisi, Türkçe Discord wiki'leri için dizinlenmiş sayfa bulunamadı; Fate için yalnızca d12Macera'nın Fate Condensed çevirisi podcast sayfası bulundu (Aspekt, Stres, Sonuç).

| Anahtar | Kaynak |
|---|---|
| A | [FRP-SRD v0.1 — SRD 5.1 Türkçe hayran çevirisi (Barış Can Kaştaş, GM Binder)](https://www.gmbinder.com/share/-NLKXk7KDdEM4yxpBCaC) |
| B | [5eTürkçe (Tumblr) — 5e kurallarını Türkçe anlatan blog](https://www.tumblr.com/5eturkce) |
| C | [FRPNET — DM Dersleri 3](https://frpnet.net/rehber/dm-dersleri-3) |
| D | [FRPNET — DM Dersleri 7 (3.x dönemi)](https://frpnet.net/rehber/dm-dersleri-7) |
| E | [FRPNET — D&D 2024 Başlangıç Rehberi: Temel Sistem](https://frpnet.net/rehber/dungeons-and-dragons-2024-baslangic-rehberi-temel-sistem) |
| F | [FRPNET — 5e'de Büyü ve Büyücüler](https://frpnet.net/incelemeler/dungeons-dragons-5th-editionda-buyu-ve-buyuculer) |
| G | [FRPNET — 5th Edition Sınıfları](https://frpnet.net/incelemeler/dungeons-dragons-5th-edition-siniflari) |
| H | [RoleplayTürk — Cüce Rahip Rehberi](https://roleplayturk.net/dd-5e-cuce-rahip-rehberi/) |
| I | [Zar ve Kalem (frprehberi.com) — başlangıç rehberi ve sözlük](https://frprehberi.com/) |
| J | [Steam rehberi — Baldur's Gate 3 resmî Türkçe arayüz terimleri](https://steamcommunity.com/sharedfiles/filedetails/?id=3565603051) |
| K | [Baldur's Gate: EE Türkçe terim belgesi (hayran yerelleştirmesi, AD&D terimleri)](https://forums.beamdog.com/uploads/FileUpload/d1/c344a2a0afa6470d7c6ea3d18545ef.pdf) |
| L | [FRPNET — BG3 Türkçe yerelleştirme röportajı](https://frpnet.net/makaleler/baldurs-gate-3un-turkce-yerellestirme-sureci-ve-en-cok-merak-edilen-sorular) |
| N | [DungeonLib TR — makine çevirisi izlenimi veriyor, zayıf kanıt](https://www.dungeonlib.com/tr/2024/conditions) |
| O | [trfrp.blogspot — Karakter Oluşturma](https://trfrp.blogspot.com/2020/04/d-karakter-olusturma.html) |
| P | [Ekşi Sözlük — dragonborn](https://eksisozluk.com/dragonborn--3139766) |
| R | [games.gg TR — Solasta 2 / 5e kuralları](https://games.gg/tr/solasta-ii/guides/solasta-2-rehberi-dd-5e-kurallarını-hızlıca-öğrenin/) |
| S | [draconism.com — Büyü](https://draconism.com/dnd-ve-buyu/) |
| T | [DonanımHaber — Pathfinder: Kingmaker Türkçe yama başlığı](https://forum.donanimhaber.com/pathfinder-kingmaker-turkce-dil-yamasi-terminolojiye-sadik-duzeltilmis-surum-2025--162515112) |
| U | [Steam rehberi — BG3 25 ipucu](https://steamcommunity.com/sharedfiles/filedetails/?l=turkish&id=3023579472) |
| V | [Ekşi Sözlük — dungeons and dragons fifth edition](https://eksisozluk.com/dungeons-and-dragons-fifth-edition--3215290) |

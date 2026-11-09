# Sözlük incelemesi

> Üretildi: `python -m gmcebi_pipeline.report` — elle düzenleme; değişiklikleri `pipeline/glossary.csv`'ye yap.

Çekirdek terim: **1168** — topluluk: 116, öneri: 1009, tartışmalı: 43. Ayrıca 339 pilot büyü adı ve 315 bölüm adı (en altta).

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
| feet | **fit** | ft | Sayılar değişmez (QC). 30 feet → 30 fit. Metrik gösterim ileride uygulama ayarı olabilir. "5 fitlik" kabul edilir; "ayak" (vücut) normal kelime olarak serbest. | — |
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
| 40 | spell save DC | **büyü kurtarma ZD'si** | öneri | ✔ |  | "ZD'n" (senin ZD'n) da kabul edilir. | B |
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
| 64 | Grappling | **Kapışma** | öneri | ✔ |  | Grappling Hook (eşya) hariç. |  |
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
| 108 | NPC | **NPC** | öneri | ✔ | OOK, Oyuncu Olmayan Karakter | Türkçe topluluk "NPC" kısaltmasını kullanır; ilk geçişte açıklama gerekmez. |  |

### Yetenek

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 109 | Strength | **Güç** | tartışmalı | ✔ | Kuvvet | Topluluk yaklaşık yarı yarıya bölünmüş; BG3 'Kuvvet'. Force (hasar türü) 'Kuvvet' olduğundan Güç seçildi. | A,C,D,E,I,O,B,H,J |
| 110 | Dexterity | **Çeviklik** | topluluk | ✔ |  | Evrensel. | A,B,C,E,F,J |
| 111 | Constitution | **Dayanıklılık** | topluluk | ✔ |  | Evrensel. | A,B,C,E,F,H,J |
| 112 | Intelligence | **Zeka** | topluluk | ✔ |  |  | A,B,C,E,J |
| 113 | Wisdom | **Bilgelik** | tartışmalı | ✔ | Akıl, İrfan, Sezgi | Bilgelik/Akıl/İrfan arasında uzlaşma yok; FRP-SRD ve FRPNET Bilgelik. | A,C,D,E,B,H,J |
| 114 | Charisma | **Karizma** | topluluk | ✔ |  |  | A,B,C,E,J |

### Beceri

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 115 | Acrobatics | **Akrobasi** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 116 | Animal Handling | **Hayvan Terbiyesi** | tartışmalı | ✔ | Hayvanlarla İlgilenme | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 117 | Arcana | **Arkana** | tartışmalı | ✔ | Gizli İlimler, Büyü Bilgisi | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 118 | Athletics | **Atletizm** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 119 | Deception | **Aldatma** | topluluk | ✔ | Kandırma | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 120 | History | **Tarih** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 121 | Insight | **Sezgi** | topluluk | ✔ | Önsezi | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 122 | Intimidation | **Gözdağı** | tartışmalı | ✔ | Korkutma, Yıldırma | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 123 | Investigation | **Araştırma** | topluluk | ✔ | Soruşturma | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 124 | Medicine | **Tıp** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 125 | Nature | **Doğa** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 126 | Perception | **Algı** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 127 | Performance | **Gösteri** | tartışmalı | ✔ | Performans | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 128 | Persuasion | **İkna** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 129 | Religion | **Din** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 130 | Sleight of Hand | **El Çabukluğu** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 131 | Stealth | **Gizlilik** | topluluk | ✔ | Sinsilik | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |
| 132 | Survival | **Hayatta Kalma** | topluluk | ✔ |  | 5eTürkçe beceri listesiyle karşılaştırılmalı (kaynak özetten okundu). | B |

### Durum

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 133 | Blinded | **Kör** | öneri | ✔ | Körlük | Durum adları sıfat olarak: 'Kör durumunda'. | A,K |
| 134 | Charmed | **Büyülenmiş** | öneri | ✔ | Efsunlanmış |  | F,K |
| 135 | Deafened | **Sağır** | öneri | ✔ | Sağırlık |  | A |
| 136 | Exhaustion | **Yorgunluk** | topluluk | ✔ | Bitkinlik |  | A |
| 137 | Frightened | **Korkmuş** | öneri | ✔ | Dehşete Düşmüş |  |  |
| 138 | Grappled | **Yakalanmış** | topluluk | ✔ | Tutulmuş |  | B |
| 139 | Incapacitated | **Etkisiz** | öneri | ✔ | Aciz |  |  |
| 140 | Invisible | **Görünmez** | topluluk | ✔ |  |  | F |
| 141 | Paralyzed | **Felçli** | topluluk | ✔ | Felç |  | J,K |
| 142 | Petrified | **Taşlaşmış** | öneri | ✔ |  |  |  |
| 143 | Poisoned | **Zehirlenmiş** | öneri | ✔ |  |  | K |
| 144 | Prone | **Yerde** | topluluk | ✔ | Yere Yığılmış |  | B |
| 145 | Restrained | **Kısıtlanmış** | öneri | ✔ | Bağlanmış |  |  |
| 146 | Stunned | **Sersemlemiş** | öneri | ✔ |  |  | K |
| 147 | Unconscious | **Bilinçsiz** | topluluk | ✔ | Baygın |  | B |
| 148 | Condition | **Durum** | topluluk | ✔ |  | "weather conditions" (hava koşulları) hariç. |  |

### Eylem

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 149 | Action | **Eylem** | topluluk | ✔ | Aksiyon |  | A,B,I |
| 150 | Bonus Action | **Bonus Eylem** | topluluk | ✔ | Bonus Aksiyon |  | A,B,I |
| 151 | Reaction | **Reaksiyon** | topluluk | ✔ | Tepki | BG3 ve çoğu topluluk kaynağı Reaksiyon; FRP-SRD Tepki. | B,I,J,N,U,A |
| 152 | Opportunity Attack | **Fırsat Saldırısı** | topluluk | ✔ |  |  | B,I |
| 153 | Attack [Action] | **Saldırı** | topluluk |  |  | 'Attack action' → 'Saldırı eylemi'. | A,B |
| 154 | Dash | **Atılma** | öneri | ✔ | Koşma |  |  |
| 155 | Disengage | **Geri Çekilme** | öneri | ✔ |  |  |  |
| 156 | Dodge | **Kaçınma** | öneri | ✔ | Savuşturma |  |  |
| 157 | Help | **Yardım** | öneri | ✔ |  |  |  |
| 158 | Hide | **Saklanma** | öneri | ✔ |  |  |  |
| 159 | Influence | **Etkileme** | öneri | ✔ |  |  |  |
| 160 | Magic [Action] | **Büyü** | öneri | ✔ |  | 'Magic action' → 'Büyü eylemi'. |  |
| 161 | Ready | **Hazırlanma** | öneri | ✔ |  |  |  |
| 162 | Search | **Arama** | öneri | ✔ |  |  |  |
| 163 | Study | **İnceleme** | öneri | ✔ |  |  |  |
| 164 | Utilize | **Kullanma** | öneri | ✔ |  |  |  |

### Hasar

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 165 | Resistance | **Direnç** | topluluk | ✔ |  |  | F,J,K,N |
| 166 | Vulnerability | **Zafiyet** | öneri | ✔ | Hassaslık | BG3 'Hassaslık' kullanıyor. | J |
| 167 | Immunity | **Bağışıklık** | topluluk | ✔ |  |  | A,F,J |
| 168 | Damage | **Hasar** | topluluk | ✔ |  |  | A,C,F,N |
| 169 | Damage Threshold | **Hasar Eşiği** | öneri | ✔ |  |  |  |

### Hasar türü

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 170 | Acid | **Asit** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | F,J,N |
| 171 | Bludgeoning | **Ezici** | tartışmalı | ✔ | Küt | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | K |
| 172 | Cold | **Soğuk** | topluluk | ✔ | Buz | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | F,N,J |
| 173 | Fire | **Ateş** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | A,F,J,N |
| 174 | Force | **Kuvvet** | öneri | ✔ | Saf Enerji | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. |  |
| 175 | Lightning | **Yıldırım** | topluluk | ✔ | Elektrik | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | J,N,F |
| 176 | Necrotic | **Nekrotik** | tartışmalı | ✔ | Çürüme | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |
| 177 | Piercing | **Delici** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | K |
| 178 | Poison | **Zehir** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | A,J,N |
| 179 | Psychic | **Psişik** | topluluk | ✔ |  | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | J,N |
| 180 | Radiant | **Işıltı** | tartışmalı | ✔ | Radyant, Işık | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |
| 181 | Slashing | **Kesici** | topluluk | ✔ | Kesme | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | K,J |
| 182 | Thunder | **Gök Gürültüsü** | tartışmalı | ✔ | Ses | Hasar türleri büyük harfle: '2d6 Ateş hasarı'. | N,J |

### Duyu

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 183 | Darkvision | **Karanlık Görüş** | öneri | ✔ | Karanlıkta Görme |  |  |
| 184 | Blindsight | **Kör Görüş** | öneri | ✔ |  |  |  |
| 185 | Tremorsense | **Titreşim Algısı** | öneri | ✔ |  |  |  |
| 186 | Truesight | **Gerçek Görüş** | öneri | ✔ |  |  |  |
| 187 | Passive Perception | **Pasif Algı** | öneri | ✔ |  |  |  |
| 188 | Telepathy | **Telepati** | öneri | ✔ |  |  |  |

### Alan

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 189 | Area of Effect | **Etki Alanı** | öneri | ✔ |  |  |  |
| 190 | Cone | **Koni** | öneri | ✔ |  |  |  |
| 191 | Cube | **Küp** | öneri | ✔ |  |  |  |
| 192 | Cylinder | **Silindir** | öneri | ✔ |  |  |  |
| 193 | Emanation | **Yayılım** | öneri | ✔ |  |  |  |
| 194 | Line | **Çizgi** | öneri | ✔ |  | "hat" sıradan kelime olarak da geçtiği için alternatif listesinden çıkarıldı. |  |
| 195 | Sphere | **Küre** | öneri | ✔ |  |  |  |

### Büyü

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 196 | Casting Time | **Yapma Süresi** | öneri | ✔ |  | Büyü kartı alanı. |  |
| 197 | Range | **Menzil** | topluluk |  |  | Büyü kartı alanı ve silah özelliği. |  |
| 198 | Components | **Bileşenler** | öneri | ✔ |  |  |  |
| 199 | Verbal | **Sözlü** | öneri |  |  | V → S (Sözlü). |  |
| 200 | Somatic | **Bedensel** | öneri |  |  | S → B (Bedensel). |  |
| 201 | Material | **Malzeme** | öneri |  |  | M → M (Malzeme). |  |
| 202 | Duration | **Süre** | topluluk | ✔ |  |  |  |
| 203 | Instantaneous | **Anlık** | öneri | ✔ |  |  |  |
| 204 | Using a Higher-Level Spell Slot | **Daha Yüksek Seviyeli Büyü Slotu Kullanma** | öneri | ✔ |  |  |  |
| 205 | Cantrip Upgrade | **Cantrip Gelişimi** | öneri | ✔ |  |  |  |

### Büyü okulu

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 206 | Abjuration | **Koruma** | tartışmalı |  | Sakınma, Abjurasyon |  | F,S,K,B |
| 207 | Conjuration | **Çağırma** | topluluk |  | Konjurasyon |  | F,K,S |
| 208 | Divination | **Kehanet** | topluluk |  | Divinasyon |  | F,K |
| 209 | Enchantment | **Efsunlama** | tartışmalı |  | Büyüleme |  | K,S |
| 210 | Evocation | **Oluşturma** | tartışmalı |  | Evokasyon |  | A,K,B |
| 211 | Illusion | **İllüzyon** | topluluk |  | Yanılsama |  | B,F |
| 212 | Necromancy | **Nekromansi** | topluluk |  | Ölüm İlmi |  | A,B,K |
| 213 | Transmutation | **Dönüşüm** | tartışmalı |  | Transmutasyon, Başkalaşım |  | F,B,K |
| 214 | School of Magic | **Büyü Okulu** | topluluk |  | Ekol |  | B,F,A |

### Sınıf

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 215 | Class | **Sınıf** | topluluk |  |  |  | A,B,F |
| 216 | Subclass | **Alt Sınıf** | topluluk | ✔ |  |  | A,B,F |
| 217 | Class Feature | **Sınıf Özelliği** | öneri |  |  |  |  |
| 218 | Multiclassing | **Çoklu Sınıf** | öneri |  |  |  |  |
| 219 | Barbarian | **Barbar** | topluluk | ✔ |  |  | A,B,D,G,J,K |
| 220 | Bard | **Ozan** | topluluk | ✔ | Bard |  | A,B,G,J,K |
| 221 | Cleric | **Rahip** | tartışmalı | ✔ | Ruhban | FRP-SRD/FRPNET Rahip; BG3 Ruhban. | A,B,C,H,G,J,K |
| 222 | Druid | **Druid** | topluluk | ✔ |  |  | A,B,G,H,J,K |
| 223 | Fighter | **Savaşçı** | topluluk | ✔ | Dövüşçü | BG3 bilinçli olarak Dövüşçü seçti. | A,B,C,G,O,J |
| 224 | Monk | **Keşiş** | topluluk | ✔ |  |  | A,B,G,J,K |
| 225 | Paladin | **Paladin** | topluluk | ✔ |  |  | A,B,G,J,K |
| 226 | Ranger | **Korucu** | tartışmalı | ✔ | Kolcu | Yaklaşık eşit bölünmüş. | A,G,K,B,J,O |
| 227 | Rogue | **Düzenbaz** | topluluk | ✔ | Hırsız | Hırsız alt sınıf (Thief) için ayrıldı. | A,B,C,G,J,K,T |
| 228 | Sorcerer | **Sihirbaz** | tartışmalı | ✔ | Sorcerer | Çoğu oyuncu İngilizce bırakıyor; Türkçe biçim olarak Sihirbaz yerleşik. | A,G,J,K,L,B,F,S |
| 229 | Warlock | **Sehhar** | tartışmalı | ✔ | Warlock | Topluluk çoğunlukla İngilizce 'Warlock' diyor; Türkçe tek yerleşik biçim BG3'ün 'Sehhar'ı. Karar ürün sahibinde. | L,B,G,S |
| 230 | Wizard | **Büyücü** | topluluk | ✔ |  |  | A,C,F,G,J,K |
| 231 | Wild Shape | **Vahşi Biçim** | öneri | ✔ |  | Druid özelliği. |  |

### Alt sınıf

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 232 | Path of the Berserker | **Gözü Dönmüş Yolu** | öneri | ✔ |  |  |  |
| 233 | College of Lore | **İrfan Okulu** | öneri | ✔ |  |  |  |
| 234 | Life Domain | **Yaşam Alanı** | öneri | ✔ |  |  |  |
| 235 | Circle of the Land | **Toprak Çemberi** | öneri | ✔ |  |  |  |
| 236 | Champion | **Şampiyon** | öneri | ✔ |  |  |  |
| 237 | Warrior of the Open Hand | **Açık El Savaşçısı** | öneri | ✔ |  |  |  |
| 238 | Oath of Devotion | **Bağlılık Yemini** | öneri | ✔ |  |  |  |
| 239 | Hunter | **Avcı** | öneri | ✔ |  |  |  |
| 240 | Thief | **Hırsız** | öneri | ✔ |  |  |  |
| 241 | Draconic Sorcery | **Ejderha Sihri** | öneri | ✔ |  |  |  |
| 242 | Fiend Patron | **İblis Hamisi** | öneri | ✔ |  |  |  |
| 243 | Evoker | **Oluşturucu** | öneri | ✔ |  |  |  |

### Soy

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 244 | Dragonborn | **Ejderdoğan** | topluluk | ✔ |  |  | A,O,P |
| 245 | Dwarf | **Cüce** | topluluk | ✔ |  |  | A,B,H,I,K,O |
| 246 | Elf | **Elf** | topluluk | ✔ |  |  | A,B,I,K,O |
| 247 | Gnome | **Gnom** | topluluk | ✔ | Gnome |  | A,K |
| 248 | Goliath | **Goliat** | öneri | ✔ | Goliath |  | B |
| 249 | Halfling | **Buçukluk** | topluluk | ✔ | Halfling |  | A,K,O |
| 250 | Human | **İnsan** | topluluk | ✔ |  |  | A,I |
| 251 | Orc | **Ork** | topluluk | ✔ |  |  | A,B,K |
| 252 | Tiefling | **Tiefling** | topluluk | ✔ | Şeytanımsı |  | J,O |
| 253 | Drow | **Drow** | öneri |  | Kara Elf | Elf soyu; SRD 5.2.1'de geçtiği için lisanslı. |  |
| 254 | High Elf | **Yüksek Elf** | öneri | ✔ |  |  |  |
| 255 | Wood Elf | **Orman Elfi** | öneri | ✔ |  |  |  |
| 256 | Forest Gnome | **Orman Gnomu** | öneri | ✔ |  |  |  |
| 257 | Rock Gnome | **Kaya Gnomu** | öneri | ✔ |  |  |  |

### Köken

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 258 | Feat | **Hüner** | topluluk | ✔ | Yetenek |  | A,B,H,T |
| 259 | Origin Feat | **Köken Hüneri** | öneri | ✔ |  |  |  |
| 260 | General Feat | **Genel Hüner** | öneri | ✔ |  |  |  |
| 261 | Fighting Style Feat | **Dövüş Tarzı Hüneri** | öneri | ✔ |  |  |  |
| 262 | Epic Boon Feat | **Destansı Lütuf Hüneri** | öneri | ✔ |  |  |  |
| 263 | Background | **Geçmiş** | topluluk | ✔ |  |  | A,B,I,N,R |
| 264 | Species | **Soy** | tartışmalı | ✔ | Irk, Tür | 5.1'de 'Irk' (race) kullanılıyordu; 2024 'species' için 'Soy' öneriliyor. 'Tür' Yaratık Türü ile çakışıyor. | A,R |

### Geçmiş

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 265 | Acolyte | **Mürit** | öneri |  |  |  |  |
| 266 | Criminal | **Suçlu** | öneri |  |  |  |  |
| 267 | Sage | **Bilge** | öneri |  |  |  |  |
| 268 | Soldier | **Asker** | öneri |  |  |  |  |

### Hüner

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 269 | Alert | **Tetikte** | öneri |  |  |  |  |
| 270 | Magic Initiate | **Büyü Çırağı** | öneri |  |  |  |  |
| 271 | Savage Attacker | **Vahşi Saldırgan** | öneri |  |  |  |  |
| 272 | Skilled | **Becerikli** | öneri |  |  |  |  |
| 273 | Grappler | **Güreşçi** | öneri |  |  |  |  |
| 274 | Archery | **Okçuluk** | öneri |  |  |  |  |
| 275 | Defense | **Savunma** | öneri |  |  |  |  |
| 276 | Great Weapon Fighting | **Büyük Silah Dövüşü** | öneri |  |  |  |  |
| 277 | Two-Weapon Fighting | **İki Silahla Dövüş** | öneri |  |  |  |  |
| 278 | Boon of Combat Prowess | **Savaş Hüneri Lütfu** | öneri |  |  |  |  |
| 279 | Boon of Dimensional Travel | **Boyutlar Arası Yolculuk Lütfu** | öneri |  |  |  |  |
| 280 | Boon of Fate | **Kader Lütfu** | öneri |  |  |  |  |
| 281 | Boon of Irresistible Offense | **Karşı Konulmaz Saldırı Lütfu** | öneri |  |  |  |  |
| 282 | Boon of Spell Recall | **Büyü Hatırlama Lütfu** | öneri |  |  |  |  |
| 283 | Boon of the Night Spirit | **Gece Ruhu Lütfu** | öneri |  |  |  |  |
| 284 | Boon of Truesight | **Gerçek Görüş Lütfu** | öneri |  |  |  |  |

### Yönelim

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 285 | Lawful | **Kuralcı** | topluluk | ✔ |  |  | A,C,D,K |
| 286 | Chaotic | **Kaotik** | topluluk | ✔ |  |  | A,C,D,K |
| 287 | Neutral | **Tarafsız** | topluluk | ✔ |  |  | A,C,D,K |
| 288 | Good | **İyi** | topluluk |  |  |  | C,K |
| 289 | Evil | **Kötü** | topluluk |  |  |  | C,K |
| 290 | Unaligned | **Yönelimsiz** | öneri | ✔ |  |  |  |

### Boyut

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 291 | Tiny | **Minik** | öneri |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 292 | Small | **Küçük** | topluluk |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 293 | Medium | **Orta** | topluluk |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 294 | Large | **Büyük** | topluluk |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 295 | Huge | **Devasa** | öneri |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 296 | Gargantuan | **Muazzam** | öneri |  |  | Küçük/Orta/Büyük FRP-SRD'de var; diğerleri öneri. | A |
| 297 | Size | **Boyut** | topluluk |  |  |  | A |

### Yaratık türü

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 298 | Aberration | **Garabet** | öneri |  | Aberasyon |  |  |
| 299 | Beast | **Hayvan** | tartışmalı |  | Canavar | FRP-SRD 'Canavar'ı beast için kullanıyor; biz Canavar'ı 'monster' için ayırdık. | A |
| 300 | Celestial | **Göksel** | öneri |  |  |  |  |
| 301 | Construct | **Yapıt** | öneri |  | Yapay Varlık |  |  |
| 302 | Dragon | **Ejderha** | topluluk |  |  |  | K |
| 303 | Elemental | **Elemental** | topluluk |  |  |  | K |
| 304 | Fey | **Peri** | topluluk |  |  |  | A |
| 305 | Fiend | **İblis** | tartışmalı |  | Şeytan, Zebani |  | K,B |
| 306 | Giant | **Dev** | topluluk |  |  |  | K |
| 307 | Humanoid | **İnsansı** | topluluk |  |  |  | A,B |
| 308 | Monstrosity | **Ucube** | öneri |  |  |  |  |
| 309 | Ooze | **Balçık** | öneri |  |  |  |  |
| 310 | Plant | **Bitki** | öneri |  |  |  |  |
| 311 | Undead | **Hortlak** | topluluk |  | Yaşayan Ölü |  | A,K,F |

### Canavar

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 312 | Multiattack | **Çoklu Saldırı** | öneri | ✔ |  |  |  |
| 313 | Legendary Action | **Efsanevi Eylem** | öneri | ✔ |  |  | A |
| 314 | Legendary Resistance | **Efsanevi Direnç** | öneri | ✔ |  |  |  |
| 315 | Lair | **İn** | öneri | ✔ | Yuva |  |  |
| 316 | Stat Block | **İstatistik Bloğu** | öneri | ✔ | Değer Kartı |  |  |
| 317 | Traits | **Özellikler** | öneri |  |  | Canavar kartı bölüm başlığı. |  |

### Silah

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 318 | Weapon Mastery | **Silah Ustalığı** | öneri | ✔ |  |  |  |
| 319 | Improvised Weapon | **Doğaçlama Silah** | öneri | ✔ |  |  |  |
| 320 | Simple Weapon | **Basit Silah** | öneri | ✔ |  |  |  |
| 321 | Martial Weapon | **Savaş Silahı** | öneri | ✔ | Askerî Silah |  |  |
| 322 | Club | **Sopa** | öneri |  |  |  |  |
| 323 | Dagger | **Hançer** | öneri |  |  |  |  |
| 324 | Greatclub | **Büyük Sopa** | öneri |  |  |  |  |
| 325 | Handaxe | **El Baltası** | öneri |  |  |  |  |
| 326 | Javelin | **Cirit** | öneri |  |  |  |  |
| 327 | Light Hammer | **Hafif Çekiç** | öneri |  |  |  |  |
| 328 | Mace | **Topuz** | öneri |  |  |  |  |
| 329 | Quarterstaff | **Asa** | öneri |  |  |  |  |
| 330 | Sickle | **Orak** | öneri |  |  |  |  |
| 331 | Spear | **Mızrak** | öneri |  |  |  |  |
| 332 | Dart | **Dart** | öneri |  |  |  |  |
| 333 | Light Crossbow | **Hafif Arbalet** | öneri |  |  |  |  |
| 334 | Shortbow | **Kısa Yay** | öneri |  |  |  |  |
| 335 | Sling | **Sapan** | öneri |  |  |  |  |
| 336 | Battleaxe | **Savaş Baltası** | öneri |  |  |  |  |
| 337 | Flail | **Döven** | öneri |  |  |  |  |
| 338 | Glaive | **Glaive** | öneri |  |  |  |  |
| 339 | Greataxe | **Büyük Balta** | öneri |  |  |  |  |
| 340 | Greatsword | **Büyük Kılıç** | öneri |  |  |  |  |
| 341 | Halberd | **Teber** | öneri |  |  |  |  |
| 342 | Lance | **Kargı** | öneri |  |  |  |  |
| 343 | Longsword | **Uzun Kılıç** | öneri |  |  |  |  |
| 344 | Maul | **Gürz** | öneri |  |  |  |  |
| 345 | Morningstar | **Çivili Gürz** | öneri |  |  |  |  |
| 346 | Pike | **Uzun Mızrak** | öneri |  |  |  |  |
| 347 | Rapier | **Meç** | öneri |  |  |  |  |
| 348 | Scimitar | **Pala** | öneri |  |  |  |  |
| 349 | Shortsword | **Kısa Kılıç** | öneri |  |  |  |  |
| 350 | Trident | **Üç Dişli Mızrak** | öneri |  |  |  |  |
| 351 | Warhammer | **Savaş Çekici** | öneri |  |  |  |  |
| 352 | War Pick | **Savaş Kazması** | öneri |  |  |  |  |
| 353 | Whip | **Kırbaç** | öneri |  |  |  |  |
| 354 | Blowgun | **Üfleme Borusu** | öneri |  |  |  |  |
| 355 | Hand Crossbow | **El Arbaleti** | öneri |  |  |  |  |
| 356 | Heavy Crossbow | **Ağır Arbalet** | öneri |  |  |  |  |
| 357 | Longbow | **Uzun Yay** | öneri |  |  |  |  |
| 358 | Musket | **Misket Tüfeği** | öneri |  |  |  |  |
| 359 | Pistol | **Tabanca** | öneri |  |  |  |  |

### Silah özelliği

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 360 | Ammunition | **Mühimmat** | öneri |  | Cephane |  |  |
| 361 | Finesse | **İncelik** | öneri |  | Zarafet |  |  |
| 362 | Heavy | **Ağır** | topluluk |  |  |  | A |
| 363 | Light | **Hafif** | topluluk |  |  |  | A |
| 364 | Loading | **Doldurma** | öneri |  |  |  |  |
| 365 | Reach | **Erişim** | topluluk |  | Uzanım |  | A |
| 366 | Thrown | **Fırlatma** | öneri |  | Fırlatılabilir |  |  |
| 367 | Two-Handed | **İki Elli** | tartışmalı |  | Çift Elli |  | A |
| 368 | Versatile | **Çok Yönlü** | tartışmalı |  | Ayarlanabilir |  | A |

### Silah ustalığı

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 369 | Cleave | **Yarma** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 370 | Graze | **Sıyırma** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 371 | Nick | **Çentik** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 372 | Push | **İtme** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 373 | Sap | **Zayıflatma** | öneri |  | Sersemletme | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 374 | Slow | **Yavaşlatma** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 375 | Topple | **Devirme** | öneri |  |  | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |
| 376 | Vex | **Taciz** | öneri |  | Rahatsız Etme | 2024 ustalık terimleri için topluluk kullanımı bulunamadı. |  |

### Zırh

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 377 | Armor Training | **Zırh Eğitimi** | öneri | ✔ |  |  |  |
| 378 | Light Armor | **Hafif Zırh** | topluluk | ✔ |  |  | A,H |
| 379 | Medium Armor | **Orta Zırh** | topluluk | ✔ |  |  | A,H |
| 380 | Heavy Armor | **Ağır Zırh** | topluluk | ✔ |  |  | A,H |
| 381 | Shield | **Kalkan** | topluluk | ✔ |  |  | A,H |
| 382 | Padded Armor | **Kapitone Zırh** | öneri |  |  |  |  |
| 383 | Leather Armor | **Deri Zırh** | öneri |  |  |  |  |
| 384 | Studded Leather Armor | **Perçinli Deri Zırh** | öneri |  |  |  |  |
| 385 | Hide Armor | **Post Zırh** | öneri |  |  |  |  |
| 386 | Chain Shirt | **Zincir Gömlek** | öneri |  |  |  |  |
| 387 | Scale Mail | **Pullu Zırh** | öneri |  |  |  |  |
| 388 | Breastplate | **Göğüslük** | öneri |  |  |  |  |
| 389 | Half Plate Armor | **Yarım Plaka Zırh** | öneri |  |  |  |  |
| 390 | Ring Mail | **Halkalı Zırh** | öneri |  |  |  |  |
| 391 | Chain Mail | **Zincir Zırh** | öneri |  |  |  |  |
| 392 | Splint Armor | **Lamalı Zırh** | öneri |  |  |  |  |
| 393 | Plate Armor | **Plaka Zırh** | öneri |  |  |  |  |

### Ekipman

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 394 | Coin | **Sikke** | öneri |  | Para |  |  |
| 395 | Artisan’s Tools | **Zanaatkâr Aletleri** | öneri |  |  |  |  |
| 396 | Thieves’ Tools | **Hırsız Aletleri** | öneri |  |  |  |  |
| 397 | Herbalism Kit | **Bitki Bilimi Takımı** | öneri |  |  |  |  |
| 398 | Musical Instrument | **Müzik Aleti** | öneri |  |  |  |  |
| 399 | Gaming Set | **Oyun Takımı** | öneri |  |  |  |  |
| 400 | Holy Symbol | **Kutsal Sembol** | öneri |  |  |  |  |
| 401 | Arcane Focus | **Arkana Odağı** | öneri |  |  |  |  |
| 402 | Druidic Focus | **Druid Odağı** | öneri |  |  |  |  |
| 403 | Component Pouch | **Bileşen Kesesi** | öneri |  |  |  |  |
| 404 | Explorer’s Pack | **Kâşif Çantası** | öneri |  |  |  |  |
| 405 | Healer’s Kit | **Şifacı Takımı** | öneri |  |  |  |  |
| 406 | Potion of Healing | **Şifa İksiri** | öneri |  |  |  |  |
| 407 | Spell Scroll | **Büyü Parşömeni** | öneri |  |  |  |  |
| 408 | Alchemist’s Supplies | **Simyacı Malzemeleri** | öneri |  |  |  |  |
| 409 | Brewer’s Supplies | **Biracı Malzemeleri** | öneri |  |  |  |  |
| 410 | Calligrapher’s Supplies | **Hattat Malzemeleri** | öneri |  |  |  |  |
| 411 | Carpenter’s Tools | **Marangoz Aletleri** | öneri |  |  |  |  |
| 412 | Cartographer’s Tools | **Haritacı Aletleri** | öneri |  |  |  |  |
| 413 | Cobbler’s Tools | **Kunduracı Aletleri** | öneri |  |  |  |  |
| 414 | Cook’s Utensils | **Aşçı Gereçleri** | öneri |  |  | Utensils → Gereçleri (alet değil mutfak gereci) |  |
| 415 | Glassblower’s Tools | **Camcı Aletleri** | öneri |  |  |  |  |
| 416 | Jeweler’s Tools | **Kuyumcu Aletleri** | öneri |  |  |  |  |
| 417 | Leatherworker’s Tools | **Deri İşçisi Aletleri** | öneri |  |  | Alternatif: Saraç Aletleri |  |
| 418 | Mason’s Tools | **Taş Ustası Aletleri** | öneri |  |  |  |  |
| 419 | Painter’s Supplies | **Ressam Malzemeleri** | öneri |  |  |  |  |
| 420 | Potter’s Tools | **Çömlekçi Aletleri** | öneri |  |  |  |  |
| 421 | Smith’s Tools | **Demirci Aletleri** | öneri |  |  |  |  |
| 422 | Tinker’s Tools | **Tamirci Aletleri** | öneri |  |  | Tinker: küçük eşya tamircisi; alternatif Kalaycı Aletleri |  |
| 423 | Weaver’s Tools | **Dokumacı Aletleri** | öneri |  |  |  |  |
| 424 | Woodcarver’s Tools | **Oymacı Aletleri** | öneri |  |  | Ahşap oymacısı |  |
| 425 | Disguise Kit | **Kılık Değiştirme Takımı** | öneri |  |  |  |  |
| 426 | Forgery Kit | **Sahtecilik Takımı** | öneri |  |  |  |  |
| 427 | Navigator’s Tools | **Seyir Aletleri** | öneri |  |  | Navigator: denizde/karada rota bulma aletleri |  |
| 428 | Poisoner’s Kit | **Zehirci Takımı** | öneri |  |  |  |  |
| 429 | Acid | **Asit Şişesi** | öneri |  |  | Hasar türü Asit ile karışmasın diye Şişesi eklendi |  |
| 430 | Alchemist’s Fire | **Simyacı Ateşi** | öneri |  |  |  |  |
| 431 | Ammunition | **Mühimmat** | öneri |  |  | Glossary: Ammunition = Mühimmat (silah özelliği); aynı kavram |  |
| 432 | Antitoxin | **Antitoksin** | öneri |  |  |  |  |
| 433 | Backpack | **Sırt Çantası** | öneri |  |  |  |  |
| 434 | Ball Bearings | **Bilyeler** | öneri |  |  |  |  |
| 435 | Barrel | **Fıçı** | öneri |  |  |  |  |
| 436 | Basket | **Sepet** | öneri |  |  |  |  |
| 437 | Bedroll | **Uyku Tulumu** | öneri |  |  |  |  |
| 438 | Bell | **Zil** | öneri |  |  |  |  |
| 439 | Blanket | **Battaniye** | öneri |  |  |  |  |
| 440 | Block and Tackle | **Palanga** | öneri |  |  |  |  |
| 441 | Book | **Kitap** | öneri |  |  |  |  |
| 442 | Bottle, Glass | **Cam Şişe** | öneri |  |  |  |  |
| 443 | Bucket | **Kova** | öneri |  |  |  |  |
| 444 | Burglar’s Pack | **Soyguncu Çantası** | öneri |  |  | Hırsız Aletleri ile ayrışsın diye Soyguncu |  |
| 445 | Caltrops | **Demir Dikenler** | öneri |  |  | Caltrops |  |
| 446 | Candle | **Mum** | öneri |  |  |  |  |
| 447 | Case, Crossbow Bolt | **Arbalet Oku Kutusu** | öneri |  |  |  |  |
| 448 | Case, Map or Scroll | **Harita/Parşömen Kutusu** | öneri |  |  |  |  |
| 449 | Chain | **Zincir** | öneri |  |  |  |  |
| 450 | Chest | **Sandık** | öneri |  |  |  |  |
| 451 | Climber’s Kit | **Tırmanış Takımı** | öneri |  |  |  |  |
| 452 | Clothes, Fine | **Şık Giysiler** | öneri |  |  |  |  |
| 453 | Clothes, Traveler’s | **Seyahat Giysileri** | öneri |  |  |  |  |
| 454 | Costume | **Kostüm** | öneri |  |  |  |  |
| 455 | Crowbar | **Levye** | öneri |  |  |  |  |
| 456 | Diplomat’s Pack | **Diplomat Çantası** | öneri |  |  |  |  |
| 457 | Dungeoneer’s Pack | **Zindan Gezgini Çantası** | öneri |  |  | Kâşif Çantası (Explorer’s Pack) ile ayrışsın diye |  |
| 458 | Entertainer’s Pack | **Eğlendirici Çantası** | öneri |  |  |  |  |
| 459 | Flask | **Matara** | öneri |  |  |  |  |
| 460 | Grappling Hook | **Tırmanma Kancası** | öneri |  |  | Halat ayrı satılır; yalnızca kanca |  |
| 461 | Holy Water | **Kutsal Su** | öneri |  |  |  |  |
| 462 | Hunting Trap | **Av Kapanı** | öneri |  |  |  |  |
| 463 | Ink | **Mürekkep** | öneri |  |  |  |  |
| 464 | Ink Pen | **Mürekkep Kalemi** | öneri |  |  |  |  |
| 465 | Jug | **Testi** | öneri |  |  |  |  |
| 466 | Ladder | **Merdiven** | öneri |  |  |  |  |
| 467 | Lamp | **Kandil** | öneri |  |  |  |  |
| 468 | Lantern, Bullseye | **Odaklı Fener** | öneri |  |  | Koni biçiminde ışık veren fener |  |
| 469 | Lantern, Hooded | **Kapaklı Fener** | öneri |  |  |  |  |
| 470 | Lock | **Kilit** | öneri |  |  |  |  |
| 471 | Magnifying Glass | **Büyüteç** | öneri |  |  |  |  |
| 472 | Manacles | **Kelepçe** | öneri |  |  |  |  |
| 473 | Map | **Harita** | öneri |  |  |  |  |
| 474 | Mirror | **Ayna** | öneri |  |  |  |  |
| 475 | Net | **Atma Ağı** | öneri |  |  | Ağ büyüsü (Web) ile çakışmasın diye |  |
| 476 | Oil | **Lamba Yağı** | öneri |  |  |  |  |
| 477 | Paper | **Kâğıt** | öneri |  |  |  |  |
| 478 | Parchment | **Parşömen** | öneri |  |  |  |  |
| 479 | Perfume | **Parfüm** | öneri |  |  |  |  |
| 480 | Poison, Basic | **Basit Zehir** | öneri |  |  | Hasar türü Zehir ile ayrışır |  |
| 481 | Pole | **Sırık** | öneri |  |  |  |  |
| 482 | Pot, Iron | **Demir Tencere** | öneri |  |  |  |  |
| 483 | Pouch | **Kese** | öneri |  |  |  |  |
| 484 | Priest’s Pack | **Din Adamı Çantası** | öneri |  |  | Rahip = Cleric sınıfı olduğundan Din Adamı |  |
| 485 | Quiver | **Sadak** | öneri |  |  |  |  |
| 486 | Ram, Portable | **Taşınabilir Koçbaşı** | öneri |  |  |  |  |
| 487 | Rations | **Erzak** | öneri |  |  |  |  |
| 488 | Robe | **Cüppe** | öneri |  |  |  |  |
| 489 | Rope | **Halat** | öneri |  |  |  |  |
| 490 | Sack | **Çuval** | öneri |  |  |  |  |
| 491 | Scholar’s Pack | **Âlim Çantası** | öneri |  |  | Bilge (Sage geçmişi) ile ayrışsın diye Âlim |  |
| 492 | Shovel | **Kürek** | öneri |  |  |  |  |
| 493 | Signal Whistle | **İşaret Düdüğü** | öneri |  |  |  |  |
| 494 | Spell Scroll (Cantrip) | **Büyü Parşömeni (Cantrip)** | öneri |  |  | Glossary: Cantrip = Cantrip |  |
| 495 | Spell Scroll (Level 1) | **Büyü Parşömeni (1. Seviye)** | öneri |  |  |  |  |
| 496 | Spikes, Iron | **Demir Çiviler** | öneri |  |  |  |  |
| 497 | Spyglass | **Dürbün** | öneri |  |  |  |  |
| 498 | String | **Sicim** | öneri |  |  |  |  |
| 499 | Tent | **Çadır** | öneri |  |  |  |  |
| 500 | Tinderbox | **Çakmak Kutusu** | öneri |  |  |  |  |
| 501 | Torch | **Meşale** | öneri |  |  |  |  |
| 502 | Vial | **Şişecik** | öneri |  |  |  |  |
| 503 | Waterskin | **Su Tulumu** | öneri |  |  |  |  |
| 504 | Camel | **Deve** | öneri |  |  |  |  |
| 505 | Elephant | **Fil** | öneri |  |  |  |  |
| 506 | Horse, Draft | **Koşum Atı** | öneri |  |  |  |  |
| 507 | Horse, Riding | **Binek Atı** | öneri |  |  |  |  |
| 508 | Mastiff | **Mastif** | öneri |  |  |  |  |
| 509 | Mule | **Katır** | öneri |  |  |  |  |
| 510 | Pony | **Midilli** | öneri |  |  |  |  |
| 511 | Warhorse | **Savaş Atı** | öneri |  |  |  |  |
| 512 | Carriage | **Fayton** | öneri |  |  |  |  |
| 513 | Cart | **At Arabası** | öneri |  |  |  |  |
| 514 | Chariot | **Savaş Arabası** | öneri |  |  |  |  |
| 515 | Feed per day | **Yem (Günlük)** | öneri |  |  |  |  |
| 516 | Saddle, Exotic | **Egzotik Eyer** | öneri |  |  | Kaynakta yalnızca Exotic; Eyer tablosunun alt satırı |  |
| 517 | Saddle, Military | **Askerî Eyer** | öneri |  |  | Kaynakta yalnızca Military; Eyer tablosunun alt satırı |  |
| 518 | Saddle, Riding | **Binek Eyeri** | öneri |  |  | Kaynakta yalnızca Riding; Eyer tablosunun alt satırı |  |
| 519 | Sled | **Kızak** | öneri |  |  |  |  |
| 520 | Stabling per day | **Ahır (Günlük)** | öneri |  |  |  |  |
| 521 | Wagon | **Yük Arabası** | öneri |  |  |  |  |
| 522 | Airship | **Hava Gemisi** | öneri |  |  |  |  |
| 523 | Galley | **Kadırga** | öneri |  |  |  |  |
| 524 | Keelboat | **Nehir Teknesi** | öneri |  |  | Keelboat; alternatif Omurgalı Tekne |  |
| 525 | Longship | **Uzun Gemi** | öneri |  |  |  |  |
| 526 | Rowboat | **Sandal** | öneri |  |  |  |  |
| 527 | Sailing Ship | **Yelkenli** | öneri |  |  |  |  |
| 528 | Warship | **Savaş Gemisi** | öneri |  |  |  |  |
| 529 | Wretched | **Sefil** | öneri |  |  | Yaşam tarzı düzeyi (Yaşam Tarzı Giderleri, Yiyecek tablosu). |  |
| 530 | Squalid | **Perişan** | öneri |  |  | Yaşam tarzı düzeyi (Yaşam Tarzı Giderleri, Yiyecek tablosu). |  |
| 531 | Poor | **Yoksul** | öneri |  |  | Yaşam tarzı düzeyi (Yaşam Tarzı Giderleri, Yiyecek tablosu). |  |
| 532 | Modest | **Mütevazı** | öneri |  |  | Yaşam tarzı düzeyi (Yaşam Tarzı Giderleri, Yiyecek tablosu). |  |
| 533 | Comfortable | **Rahat** | öneri |  |  | Yaşam tarzı düzeyi (Yaşam Tarzı Giderleri, Yiyecek tablosu). |  |
| 534 | Wealthy | **Varlıklı** | öneri |  |  | Yaşam tarzı düzeyi (Yaşam Tarzı Giderleri, Yiyecek tablosu). |  |
| 535 | Aristocratic | **Aristokrat** | öneri |  |  | Yaşam tarzı düzeyi (Yaşam Tarzı Giderleri, Yiyecek tablosu). |  |

### Eşya

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 536 | Attunement | **Uyumlanma** | öneri | ✔ |  |  |  |
| 537 | Magic Item | **Büyülü Eşya** | öneri | ✔ |  |  |  |
| 538 | Requires Attunement | **Uyumlanma Gerektirir** | öneri | ✔ |  |  |  |

### Para

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 539 | Copper Piece | **bakır** | tartışmalı | ✔ | BP | Kısaltma yerine kelime: '5 CP' → '5 bakır'. İngilizce kısaltmalar (GP=gold) Türkçe okumada yanıltıcı. |  |
| 540 | Silver Piece | **gümüş** | tartışmalı | ✔ |  | '1 SP' → '1 gümüş'. |  |
| 541 | Electrum Piece | **elektrum** | tartışmalı | ✔ |  | '1 EP' → '1 elektrum'. |  |
| 542 | Gold Piece | **altın** | tartışmalı | ✔ | AP, GP | '50 GP' → '50 altın'. |  |
| 543 | Platinum Piece | **platin** | tartışmalı | ✔ |  | '10 PP' → '10 platin'. |  |

### Birim

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 544 | feet | **fit** | tartışmalı | ✔ | ft | Sayılar değişmez (QC). 30 feet → 30 fit. Metrik gösterim ileride uygulama ayarı olabilir. "5 fitlik" kabul edilir; "ayak" (vücut) normal kelime olarak serbest. |  |
| 545 | mile | **mil** | öneri | ✔ |  |  |  |
| 546 | pound (lb.) | **lb** | öneri |  | libre | Ağırlık birimi kısaltması korunur. |  |

### Canavar adı

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 547 | Aboleth | **Aboleth** | öneri |  |  |  |  |
| 548 | Air Elemental | **Hava Elementali** | öneri |  |  |  |  |
| 549 | Animated Armor | **Canlanmış Zırh** | öneri |  |  |  |  |
| 550 | Animated Flying Sword | **Canlanmış Uçan Kılıç** | öneri |  |  |  |  |
| 551 | Animated Rug of Smothering | **Canlanmış Boğucu Halı** | öneri |  |  |  |  |
| 552 | Ankheg | **Ankheg** | öneri |  |  |  |  |
| 553 | Assassin | **Suikastçı** | öneri |  |  |  |  |
| 554 | Awakened Shrub | **Uyanmış Çalı** | öneri |  |  |  |  |
| 555 | Awakened Tree | **Uyanmış Ağaç** | öneri |  |  |  |  |
| 556 | Axe Beak | **Balta Gagalı** | öneri |  |  |  |  |
| 557 | Azer Sentinel | **Azer Nöbetçisi** | öneri |  |  |  |  |
| 558 | Balor | **Balor** | öneri |  |  | Demon (iblis türü) adı korunmuştur. |  |
| 559 | Bandit | **Haydut** | öneri |  |  |  |  |
| 560 | Bandit Captain | **Haydut Reisi** | öneri |  |  | Captain bağlama göre: Reis (haydut), Kaptan (korsan), Komutan (muhafız, hobgoblin). |  |
| 561 | Barbed Devil | **Dikenli Şeytan** | öneri |  |  | Devil = Şeytan. |  |
| 562 | Basilisk | **Basilisk** | öneri |  |  |  |  |
| 563 | Bearded Devil | **Sakallı Şeytan** | öneri |  |  |  |  |
| 564 | Behir | **Behir** | öneri |  |  |  |  |
| 565 | Berserker | **Gözü Dönmüş** | öneri |  |  | Path of the Berserker = Gözü Dönmüş Yolu ile uyumlu. |  |
| 566 | Black Dragon Wyrmling | **Yavru Kara Ejderha** | öneri |  |  | Kalıp: [Yaş] [Renk] Ejderha; Wyrmling = Yavru. |  |
| 567 | Young Black Dragon | **Genç Kara Ejderha** | öneri |  |  |  |  |
| 568 | Adult Black Dragon | **Yetişkin Kara Ejderha** | öneri |  |  |  |  |
| 569 | Ancient Black Dragon | **Kadim Kara Ejderha** | öneri |  |  |  |  |
| 570 | Black Pudding | **Kara Puding** | öneri |  |  |  |  |
| 571 | Blink Dog | **Işınlanan Köpek** | öneri |  |  |  |  |
| 572 | Blue Dragon Wyrmling | **Yavru Mavi Ejderha** | öneri |  |  |  |  |
| 573 | Young Blue Dragon | **Genç Mavi Ejderha** | öneri |  |  |  |  |
| 574 | Adult Blue Dragon | **Yetişkin Mavi Ejderha** | öneri |  |  |  |  |
| 575 | Ancient Blue Dragon | **Kadim Mavi Ejderha** | öneri |  |  |  |  |
| 576 | Bone Devil | **Kemik Şeytanı** | öneri |  |  |  |  |
| 577 | Brass Dragon Wyrmling | **Yavru Pirinç Ejderha** | öneri |  |  |  |  |
| 578 | Young Brass Dragon | **Genç Pirinç Ejderha** | öneri |  |  |  |  |
| 579 | Adult Brass Dragon | **Yetişkin Pirinç Ejderha** | öneri |  |  |  |  |
| 580 | Ancient Brass Dragon | **Kadim Pirinç Ejderha** | öneri |  |  |  |  |
| 581 | Bronze Dragon Wyrmling | **Yavru Bronz Ejderha** | öneri |  |  |  |  |
| 582 | Young Bronze Dragon | **Genç Bronz Ejderha** | öneri |  |  |  |  |
| 583 | Adult Bronze Dragon | **Yetişkin Bronz Ejderha** | öneri |  |  |  |  |
| 584 | Ancient Bronze Dragon | **Kadim Bronz Ejderha** | öneri |  |  |  |  |
| 585 | Bugbear Stalker | **Bugbear Pusucusu** | öneri |  |  |  |  |
| 586 | Bugbear Warrior | **Bugbear Savaşçısı** | öneri |  |  | Warrior = "X Savaşçısı" kalıbı. |  |
| 587 | Bulette | **Bulette** | öneri |  |  |  |  |
| 588 | Centaur Trooper | **Sentor Askeri** | öneri |  |  |  |  |
| 589 | Chain Devil | **Zincir Şeytanı** | öneri |  |  |  |  |
| 590 | Chimera | **Kimera** | öneri |  |  |  |  |
| 591 | Chuul | **Chuul** | öneri |  |  |  |  |
| 592 | Clay Golem | **Kil Golemi** | öneri |  |  |  |  |
| 593 | Cloaker | **Pelerinimsi** | öneri |  |  |  |  |
| 594 | Cloud Giant | **Bulut Devi** | öneri |  |  |  |  |
| 595 | Cockatrice | **Kokatris** | öneri |  |  |  |  |
| 596 | Commoner | **Halktan Biri** | öneri |  |  |  |  |
| 597 | Copper Dragon Wyrmling | **Yavru Bakır Ejderha** | öneri |  |  |  |  |
| 598 | Young Copper Dragon | **Genç Bakır Ejderha** | öneri |  |  |  |  |
| 599 | Adult Copper Dragon | **Yetişkin Bakır Ejderha** | öneri |  |  |  |  |
| 600 | Ancient Copper Dragon | **Kadim Bakır Ejderha** | öneri |  |  |  |  |
| 601 | Couatl | **Couatl** | öneri |  |  |  |  |
| 602 | Swarm of Crawling Claws | **Sürünen Pençe Sürüsü** | öneri |  |  |  |  |
| 603 | Cultist | **Tarikatçı** | öneri |  |  |  |  |
| 604 | Cultist Fanatic | **Fanatik Tarikatçı** | öneri |  |  |  |  |
| 605 | Darkmantle | **Kara Örtü** | öneri |  |  |  |  |
| 606 | Death Dog | **Ölüm Köpeği** | öneri |  |  |  |  |
| 607 | Deva | **Deva** | öneri |  |  |  |  |
| 608 | Djinni | **Cin** | öneri |  |  |  |  |
| 609 | Doppelganger | **Doppelganger** | öneri |  |  |  |  |
| 610 | Dragon Turtle | **Ejderha Kaplumbağası** | öneri |  |  |  |  |
| 611 | Dretch | **Dretch** | öneri |  |  |  |  |
| 612 | Drider | **Drider** | öneri |  |  |  |  |
| 613 | Druid | **Druid** | öneri |  |  | Sınıf adıyla aynı; NPC bir druid olduğu için bilinçli. |  |
| 614 | Dryad | **Driyad** | öneri |  |  |  |  |
| 615 | Earth Elemental | **Toprak Elementali** | öneri |  |  |  |  |
| 616 | Efreeti | **İfrit** | öneri |  |  |  |  |
| 617 | Erinyes | **Erinyes** | öneri |  |  |  |  |
| 618 | Ettercap | **Ettercap** | öneri |  |  |  |  |
| 619 | Ettin | **Ettin** | öneri |  |  |  |  |
| 620 | Fire Elemental | **Ateş Elementali** | öneri |  |  |  |  |
| 621 | Fire Giant | **Ateş Devi** | öneri |  |  |  |  |
| 622 | Flesh Golem | **Et Golemi** | öneri |  |  |  |  |
| 623 | Frost Giant | **Ayaz Devi** | öneri |  |  | Ray of Frost = Ayaz Işını ile uyumlu. |  |
| 624 | Shrieker Fungus | **Çığlıkçı Mantar** | öneri |  |  |  |  |
| 625 | Violet Fungus | **Eflatun Mantar** | öneri |  |  | Purple Worm (Mor Solucan) ile karışmasın diye Eflatun. |  |
| 626 | Gargoyle | **Gargoyl** | öneri |  |  |  |  |
| 627 | Gelatinous Cube | **Jelatinimsi Küp** | öneri |  |  |  |  |
| 628 | Ghast | **Kokuşmuş Gulyabani** | öneri |  |  | Ghoul = Gulyabani serisi. |  |
| 629 | Ghost | **Hayalet** | öneri |  |  |  |  |
| 630 | Ghoul | **Gulyabani** | öneri |  |  |  |  |
| 631 | Gibbering Mouther | **Geveleyen Ağız** | öneri |  |  |  |  |
| 632 | Glabrezu | **Glabrezu** | öneri |  |  |  |  |
| 633 | Gladiator | **Gladyatör** | öneri |  |  |  |  |
| 634 | Gnoll Warrior | **Gnoll Savaşçısı** | öneri |  |  |  |  |
| 635 | Goblin Minion | **Goblin Uşağı** | öneri |  |  |  |  |
| 636 | Goblin Warrior | **Goblin Savaşçısı** | öneri |  |  |  |  |
| 637 | Goblin Boss | **Goblin Elebaşı** | öneri |  |  | Boss = Elebaşı. |  |
| 638 | Gold Dragon Wyrmling | **Yavru Altın Ejderha** | öneri |  |  |  |  |
| 639 | Young Gold Dragon | **Genç Altın Ejderha** | öneri |  |  |  |  |
| 640 | Adult Gold Dragon | **Yetişkin Altın Ejderha** | öneri |  |  |  |  |
| 641 | Ancient Gold Dragon | **Kadim Altın Ejderha** | öneri |  |  |  |  |
| 642 | Gorgon | **Gorgon** | öneri |  |  |  |  |
| 643 | Gray Ooze | **Gri Balçık** | öneri |  |  |  |  |
| 644 | Green Dragon Wyrmling | **Yavru Yeşil Ejderha** | öneri |  |  |  |  |
| 645 | Young Green Dragon | **Genç Yeşil Ejderha** | öneri |  |  |  |  |
| 646 | Adult Green Dragon | **Yetişkin Yeşil Ejderha** | öneri |  |  |  |  |
| 647 | Ancient Green Dragon | **Kadim Yeşil Ejderha** | öneri |  |  |  |  |
| 648 | Green Hag | **Yeşil Cadı** | öneri |  |  | Hag = Cadı. |  |
| 649 | Grick | **Grik** | öneri |  |  |  |  |
| 650 | Griffon | **Grifon** | öneri |  |  |  |  |
| 651 | Grimlock | **Grimlock** | öneri |  |  |  |  |
| 652 | Guardian Naga | **Muhafız Naga** | öneri |  |  |  |  |
| 653 | Guard | **Muhafız** | öneri |  |  |  |  |
| 654 | Guard Captain | **Muhafız Komutanı** | öneri |  |  |  |  |
| 655 | Half-Dragon | **Yarı Ejderha** | öneri |  |  |  |  |
| 656 | Harpy | **Harpi** | öneri |  |  |  |  |
| 657 | Hell Hound | **Cehennem Tazısı** | öneri |  |  |  |  |
| 658 | Hezrou | **Hezrou** | öneri |  |  |  |  |
| 659 | Hill Giant | **Tepe Devi** | öneri |  |  |  |  |
| 660 | Hippogriff | **Hipogrif** | öneri |  |  |  |  |
| 661 | Hobgoblin Warrior | **Hobgoblin Savaşçısı** | öneri |  |  |  |  |
| 662 | Hobgoblin Captain | **Hobgoblin Komutanı** | öneri |  |  |  |  |
| 663 | Homunculus | **Homunkulus** | öneri |  |  |  |  |
| 664 | Horned Devil | **Boynuzlu Şeytan** | öneri |  |  |  |  |
| 665 | Hydra | **Hidra** | öneri |  |  |  |  |
| 666 | Ice Devil | **Buz Şeytanı** | öneri |  |  |  |  |
| 667 | Imp | **Şeytancık** | öneri |  |  |  |  |
| 668 | Incubus | **İnkübus** | öneri |  |  |  |  |
| 669 | Invisible Stalker | **Görünmez Takipçi** | öneri |  |  |  |  |
| 670 | Iron Golem | **Demir Golemi** | öneri |  |  |  |  |
| 671 | Knight | **Şövalye** | öneri |  |  |  |  |
| 672 | Kobold Warrior | **Kobold Savaşçısı** | öneri |  |  |  |  |
| 673 | Kraken | **Kraken** | öneri |  |  |  |  |
| 674 | Lamia | **Lamia** | öneri |  |  |  |  |
| 675 | Lemure | **Lemure** | öneri |  |  | Lemür (hayvan) ile karışmasın diye özgün yazım. |  |
| 676 | Lich | **Lich** | öneri |  |  |  |  |
| 677 | Mage | **Efsuncu** | öneri |  |  | Wizard = Büyücü, Sorcerer = Sihirbaz dolu olduğu için. |  |
| 678 | Archmage | **Ulu Efsuncu** | öneri |  |  |  |  |
| 679 | Magmin | **Magmin** | öneri |  |  |  |  |
| 680 | Manticore | **Mantikor** | öneri |  |  |  |  |
| 681 | Marilith | **Marilith** | öneri |  |  |  |  |
| 682 | Medusa | **Medusa** | öneri |  |  |  |  |
| 683 | Dust Mephit | **Toz Mefiti** | öneri |  |  |  |  |
| 684 | Ice Mephit | **Buz Mefiti** | öneri |  |  |  |  |
| 685 | Magma Mephit | **Magma Mefiti** | öneri |  |  |  |  |
| 686 | Steam Mephit | **Buhar Mefiti** | öneri |  |  |  |  |
| 687 | Merfolk Skirmisher | **Deniz Halkı Akıncısı** | öneri |  |  |  |  |
| 688 | Merrow | **Merrow** | öneri |  |  |  |  |
| 689 | Mimic | **Taklitçi** | öneri |  |  |  |  |
| 690 | Minotaur of Baphomet | **Baphomet Minotoru** | öneri |  |  |  |  |
| 691 | Mummy | **Mumya** | öneri |  |  |  |  |
| 692 | Mummy Lord | **Mumya Efendisi** | öneri |  |  |  |  |
| 693 | Nalfeshnee | **Nalfeshnee** | öneri |  |  |  |  |
| 694 | Night Hag | **Gece Cadısı** | öneri |  |  |  |  |
| 695 | Nightmare | **Kâbus** | öneri |  |  | Ateş saçan cehennem atı. |  |
| 696 | Noble | **Soylu** | öneri |  |  |  |  |
| 697 | Ochre Jelly | **Okra Jölesi** | öneri |  |  |  |  |
| 698 | Ogre | **Ogre** | öneri |  |  | Giant = Dev ile karışmasın diye. |  |
| 699 | Oni | **Oni** | öneri |  |  |  |  |
| 700 | Otyugh | **Otyugh** | öneri |  |  |  |  |
| 701 | Owlbear | **Baykuşayı** | öneri |  |  |  |  |
| 702 | Pegasus | **Pegasus** | öneri |  |  |  |  |
| 703 | Phase Spider | **Faz Örümceği** | öneri |  |  |  |  |
| 704 | Pirate | **Korsan** | öneri |  |  |  |  |
| 705 | Pirate Captain | **Korsan Kaptanı** | öneri |  |  |  |  |
| 706 | Pit Fiend | **Çukur İblisi** | öneri |  |  | Fiend = İblis; kendisi bir şeytan (devil). |  |
| 707 | Planetar | **Planetar** | öneri |  |  |  |  |
| 708 | Priest Acolyte | **Tapınak Çömezi** | öneri |  |  | Acolyte (geçmiş) = Mürit, Cleric = Rahip dolu olduğu için. |  |
| 709 | Priest | **Din Adamı** | öneri |  |  | Cleric = Rahip ile çakışmasın diye. |  |
| 710 | Pseudodragon | **Sözde Ejderha** | öneri |  |  |  |  |
| 711 | Purple Worm | **Mor Solucan** | öneri |  |  |  |  |
| 712 | Quasit | **Quasit** | öneri |  |  |  |  |
| 713 | Rakshasa | **Rakşasa** | öneri |  |  |  |  |
| 714 | Red Dragon Wyrmling | **Yavru Kırmızı Ejderha** | öneri |  |  |  |  |
| 715 | Young Red Dragon | **Genç Kırmızı Ejderha** | öneri |  |  |  |  |
| 716 | Adult Red Dragon | **Yetişkin Kırmızı Ejderha** | öneri |  |  |  |  |
| 717 | Ancient Red Dragon | **Kadim Kırmızı Ejderha** | öneri |  |  |  |  |
| 718 | Remorhaz | **Remorhaz** | öneri |  |  |  |  |
| 719 | Roc | **Rok** | öneri |  |  |  |  |
| 720 | Roper | **Kementçi** | öneri |  |  |  |  |
| 721 | Rust Monster | **Pas Canavarı** | öneri |  |  |  |  |
| 722 | Sahuagin Warrior | **Sahuagin Savaşçısı** | öneri |  |  |  |  |
| 723 | Salamander | **Semender** | öneri |  |  |  |  |
| 724 | Satyr | **Satir** | öneri |  |  |  |  |
| 725 | Scout | **İzci** | öneri |  |  |  |  |
| 726 | Sea Hag | **Deniz Cadısı** | öneri |  |  |  |  |
| 727 | Shadow | **Gölge** | öneri |  |  |  |  |
| 728 | Shambling Mound | **Yürüyen Höyük** | öneri |  |  |  |  |
| 729 | Shield Guardian | **Kalkan Muhafızı** | öneri |  |  |  |  |
| 730 | Silver Dragon Wyrmling | **Yavru Gümüş Ejderha** | öneri |  |  |  |  |
| 731 | Young Silver Dragon | **Genç Gümüş Ejderha** | öneri |  |  |  |  |
| 732 | Adult Silver Dragon | **Yetişkin Gümüş Ejderha** | öneri |  |  |  |  |
| 733 | Ancient Silver Dragon | **Kadim Gümüş Ejderha** | öneri |  |  |  |  |
| 734 | Skeleton | **İskelet** | öneri |  |  |  |  |
| 735 | Warhorse Skeleton | **Savaş Atı İskeleti** | öneri |  |  |  |  |
| 736 | Minotaur Skeleton | **Minotor İskeleti** | öneri |  |  |  |  |
| 737 | Solar | **Solar** | öneri |  |  |  |  |
| 738 | Specter | **Tayf** | öneri |  |  | Ghost = Hayalet, Specter = Tayf, Wraith = Karaltı, Shadow = Gölge. |  |
| 739 | Sphinx of Wonder | **Mucize Sfenksi** | öneri |  |  |  |  |
| 740 | Sphinx of Lore | **İrfan Sfenksi** | öneri |  |  | College of Lore = İrfan Okulu ile uyumlu. |  |
| 741 | Sphinx of Valor | **Yiğitlik Sfenksi** | öneri |  |  |  |  |
| 742 | Spirit Naga | **Ruh Naga** | öneri |  |  |  |  |
| 743 | Sprite | **Kanatlı Peri** | öneri |  |  |  |  |
| 744 | Spy | **Casus** | öneri |  |  |  |  |
| 745 | Stirge | **Stirge** | öneri |  |  |  |  |
| 746 | Stone Giant | **Taş Devi** | öneri |  |  |  |  |
| 747 | Stone Golem | **Taş Golemi** | öneri |  |  |  |  |
| 748 | Storm Giant | **Fırtına Devi** | öneri |  |  |  |  |
| 749 | Succubus | **Sukübus** | öneri |  |  |  |  |
| 750 | Tarrasque | **Tarrasque** | öneri |  |  |  |  |
| 751 | Tough | **Kabadayı** | öneri |  |  |  |  |
| 752 | Tough Boss | **Kabadayı Elebaşı** | öneri |  |  |  |  |
| 753 | Treant | **Ağaçadam** | öneri |  |  |  |  |
| 754 | Troll | **Trol** | öneri |  |  |  |  |
| 755 | Troll Limb | **Trol Uzvu** | öneri |  |  |  |  |
| 756 | Unicorn | **Tek Boynuzlu At** | öneri |  |  |  |  |
| 757 | Vampire Familiar | **Vampir Hizmetkârı** | öneri |  |  |  |  |
| 758 | Vampire Spawn | **Vampir Yavrusu** | öneri |  |  |  |  |
| 759 | Vampire | **Vampir** | öneri |  |  |  |  |
| 760 | Vrock | **Vrock** | öneri |  |  |  |  |
| 761 | Warrior Infantry | **Piyade Savaşçı** | öneri |  |  |  |  |
| 762 | Warrior Veteran | **Kıdemli Savaşçı** | öneri |  |  |  |  |
| 763 | Water Elemental | **Su Elementali** | öneri |  |  |  |  |
| 764 | Werebear | **Ayı Adam** | öneri |  |  |  |  |
| 765 | Wereboar | **Yaban Domuzu Adam** | öneri |  |  |  |  |
| 766 | Wererat | **Sıçan Adam** | öneri |  |  |  |  |
| 767 | Weretiger | **Kaplan Adam** | öneri |  |  |  |  |
| 768 | Werewolf | **Kurt Adam** | öneri |  |  |  |  |
| 769 | White Dragon Wyrmling | **Yavru Beyaz Ejderha** | öneri |  |  |  |  |
| 770 | Young White Dragon | **Genç Beyaz Ejderha** | öneri |  |  |  |  |
| 771 | Adult White Dragon | **Yetişkin Beyaz Ejderha** | öneri |  |  |  |  |
| 772 | Ancient White Dragon | **Kadim Beyaz Ejderha** | öneri |  |  |  |  |
| 773 | Wight | **Wight** | öneri |  |  | Alternatif: Höyük Hortlağı (Undead = Hortlak ile karışmasın diye kullanılmadı). |  |
| 774 | Will-o’-Wisp | **Bataklık Feneri** | öneri |  |  | Halk adı "cinfeneri"; Djinni = Cin ile karışmasın diye. |  |
| 775 | Winter Wolf | **Kış Kurdu** | öneri |  |  |  |  |
| 776 | Worg | **Worg** | öneri |  |  |  |  |
| 777 | Wraith | **Karaltı** | öneri |  |  |  |  |
| 778 | Wyvern | **Wyvern** | öneri |  |  |  |  |
| 779 | Xorn | **Xorn** | öneri |  |  |  |  |
| 780 | Zombie | **Zombi** | öneri |  |  |  |  |
| 781 | Ogre Zombie | **Ogre Zombisi** | öneri |  |  |  |  |
| 782 | Allosaurus | **Allosaurus** | öneri |  |  |  |  |
| 783 | Ankylosaurus | **Ankylosaurus** | öneri |  |  |  |  |
| 784 | Ape | **Maymun** | öneri |  |  |  |  |
| 785 | Archelon | **Archelon** | öneri |  |  |  |  |
| 786 | Baboon | **Babun** | öneri |  |  |  |  |
| 787 | Badger | **Porsuk** | öneri |  |  |  |  |
| 788 | Bat | **Yarasa** | öneri |  |  |  |  |
| 789 | Black Bear | **Kara Ayı** | öneri |  |  |  |  |
| 790 | Blood Hawk | **Kan Şahini** | öneri |  |  |  |  |
| 791 | Boar | **Yaban Domuzu** | öneri |  |  |  |  |
| 792 | Brown Bear | **Boz Ayı** | öneri |  |  |  |  |
| 793 | Camel | **Deve** | öneri |  |  |  |  |
| 794 | Cat | **Kedi** | öneri |  |  |  |  |
| 795 | Constrictor Snake | **Boğucu Yılan** | öneri |  |  |  |  |
| 796 | Crab | **Yengeç** | öneri |  |  |  |  |
| 797 | Crocodile | **Timsah** | öneri |  |  |  |  |
| 798 | Deer | **Geyik** | öneri |  |  |  |  |
| 799 | Dire Wolf | **Ulu Kurt** | öneri |  |  |  |  |
| 800 | Draft Horse | **Koşum Atı** | öneri |  |  |  |  |
| 801 | Eagle | **Kartal** | öneri |  |  |  |  |
| 802 | Elephant | **Fil** | öneri |  |  |  |  |
| 803 | Elk | **Kızıl Geyik** | öneri |  |  |  |  |
| 804 | Flying Snake | **Uçan Yılan** | öneri |  |  |  |  |
| 805 | Frog | **Kurbağa** | öneri |  |  |  |  |
| 806 | Giant Ape | **Dev Maymun** | öneri |  |  |  |  |
| 807 | Giant Badger | **Dev Porsuk** | öneri |  |  |  |  |
| 808 | Giant Bat | **Dev Yarasa** | öneri |  |  |  |  |
| 809 | Giant Boar | **Dev Yaban Domuzu** | öneri |  |  |  |  |
| 810 | Giant Centipede | **Dev Kırkayak** | öneri |  |  |  |  |
| 811 | Giant Constrictor Snake | **Dev Boğucu Yılan** | öneri |  |  |  |  |
| 812 | Giant Crab | **Dev Yengeç** | öneri |  |  |  |  |
| 813 | Giant Crocodile | **Dev Timsah** | öneri |  |  |  |  |
| 814 | Giant Eagle | **Dev Kartal** | öneri |  |  |  |  |
| 815 | Giant Elk | **Dev Kızıl Geyik** | öneri |  |  |  |  |
| 816 | Giant Fire Beetle | **Dev Ateş Böceği** | öneri |  |  |  |  |
| 817 | Giant Frog | **Dev Kurbağa** | öneri |  |  |  |  |
| 818 | Giant Goat | **Dev Keçi** | öneri |  |  |  |  |
| 819 | Giant Hyena | **Dev Sırtlan** | öneri |  |  |  |  |
| 820 | Giant Lizard | **Dev Kertenkele** | öneri |  |  |  |  |
| 821 | Giant Octopus | **Dev Ahtapot** | öneri |  |  |  |  |
| 822 | Giant Owl | **Dev Baykuş** | öneri |  |  |  |  |
| 823 | Giant Rat | **Dev Sıçan** | öneri |  |  |  |  |
| 824 | Giant Scorpion | **Dev Akrep** | öneri |  |  |  |  |
| 825 | Giant Seahorse | **Dev Denizatı** | öneri |  |  |  |  |
| 826 | Giant Shark | **Dev Köpekbalığı** | öneri |  |  |  |  |
| 827 | Giant Spider | **Dev Örümcek** | öneri |  |  |  |  |
| 828 | Giant Toad | **Dev Karakurbağası** | öneri |  |  |  |  |
| 829 | Giant Venomous Snake | **Dev Zehirli Yılan** | öneri |  |  |  |  |
| 830 | Giant Vulture | **Dev Akbaba** | öneri |  |  |  |  |
| 831 | Giant Wasp | **Dev Eşekarısı** | öneri |  |  |  |  |
| 832 | Giant Weasel | **Dev Gelincik** | öneri |  |  |  |  |
| 833 | Giant Wolf Spider | **Dev Kurt Örümceği** | öneri |  |  |  |  |
| 834 | Goat | **Keçi** | öneri |  |  |  |  |
| 835 | Hawk | **Şahin** | öneri |  |  |  |  |
| 836 | Hippopotamus | **Su Aygırı** | öneri |  |  |  |  |
| 837 | Hunter Shark | **Avcı Köpekbalığı** | öneri |  |  |  |  |
| 838 | Hyena | **Sırtlan** | öneri |  |  |  |  |
| 839 | Jackal | **Çakal** | öneri |  |  |  |  |
| 840 | Killer Whale | **Katil Balina** | öneri |  |  |  |  |
| 841 | Lion | **Aslan** | öneri |  |  |  |  |
| 842 | Lizard | **Kertenkele** | öneri |  |  |  |  |
| 843 | Mammoth | **Mamut** | öneri |  |  |  |  |
| 844 | Mastiff | **Mastif** | öneri |  |  |  |  |
| 845 | Mule | **Katır** | öneri |  |  |  |  |
| 846 | Octopus | **Ahtapot** | öneri |  |  |  |  |
| 847 | Owl | **Baykuş** | öneri |  |  |  |  |
| 848 | Panther | **Panter** | öneri |  |  |  |  |
| 849 | Piranha | **Pirana** | öneri |  |  |  |  |
| 850 | Plesiosaurus | **Plesiosaurus** | öneri |  |  |  |  |
| 851 | Polar Bear | **Kutup Ayısı** | öneri |  |  |  |  |
| 852 | Pony | **Midilli** | öneri |  |  |  |  |
| 853 | Pteranodon | **Pteranodon** | öneri |  |  |  |  |
| 854 | Rat | **Sıçan** | öneri |  |  |  |  |
| 855 | Raven | **Kuzgun** | öneri |  |  |  |  |
| 856 | Reef Shark | **Resif Köpekbalığı** | öneri |  |  |  |  |
| 857 | Rhinoceros | **Gergedan** | öneri |  |  |  |  |
| 858 | Riding Horse | **Binek Atı** | öneri |  |  |  |  |
| 859 | Saber-Toothed Tiger | **Kılıç Dişli Kaplan** | öneri |  |  |  |  |
| 860 | Scorpion | **Akrep** | öneri |  |  |  |  |
| 861 | Seahorse | **Denizatı** | öneri |  |  |  |  |
| 862 | Spider | **Örümcek** | öneri |  |  |  |  |
| 863 | Swarm of Bats | **Yarasa Sürüsü** | öneri |  |  |  |  |
| 864 | Swarm of Insects | **Böcek Sürüsü** | öneri |  |  |  |  |
| 865 | Swarm of Piranhas | **Pirana Sürüsü** | öneri |  |  |  |  |
| 866 | Swarm of Rats | **Sıçan Sürüsü** | öneri |  |  |  |  |
| 867 | Swarm of Ravens | **Kuzgun Sürüsü** | öneri |  |  |  |  |
| 868 | Swarm of Venomous Snakes | **Zehirli Yılan Sürüsü** | öneri |  |  |  |  |
| 869 | Tiger | **Kaplan** | öneri |  |  |  |  |
| 870 | Triceratops | **Triceratops** | öneri |  |  |  |  |
| 871 | Tyrannosaurus Rex | **Tyrannosaurus Rex** | öneri |  |  |  |  |
| 872 | Venomous Snake | **Zehirli Yılan** | öneri |  |  |  |  |
| 873 | Vulture | **Akbaba** | öneri |  |  |  |  |
| 874 | Warhorse | **Savaş Atı** | öneri |  |  |  |  |
| 875 | Weasel | **Gelincik** | öneri |  |  |  |  |
| 876 | Wolf | **Kurt** | öneri |  |  |  |  |

### Dil

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 877 | Common | **Ortak Dil** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 878 | Common Sign Language | **Ortak İşaret Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 879 | Draconic | **Ejderce** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 880 | Dwarvish | **Cücece** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 881 | Elvish | **Elfçe** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 882 | Giant | **Devce** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 883 | Gnomish | **Gnomca** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 884 | Goblin | **Goblince** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 885 | Halfling | **Buçuklukça** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 886 | Orc | **Orkça** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 887 | Abyssal | **Abis Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 888 | Celestial | **Göksel Dil** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 889 | Deep Speech | **Derin Dil** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 890 | Infernal | **Cehennem Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 891 | Primordial | **İlkel Dil** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 892 | Sylvan | **Sylvan Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 893 | Undercommon | **Yeraltı Ortak Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 894 | Druidic | **Druidce** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 895 | Thieves’ Cant | **Hırsız Argosu** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |

### Sihirli eşya türü

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 896 | Armor | **Zırh** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |
| 897 | Potion | **İksir** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |
| 898 | Ring | **Yüzük** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |
| 899 | Rod | **Çubuk** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |
| 900 | Scroll | **Parşömen** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |
| 901 | Staff | **Asa** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |
| 902 | Wand | **Değnek** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |
| 903 | Weapon | **Silah** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |
| 904 | Wondrous Item | **Harikulade Eşya** | öneri |  |  | Sihirli eşya türü (eşya kartındaki italik satır). |  |

### Nadirlik

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 905 | Common | **Yaygın** | öneri |  |  | "Common" dil adıyla (Ortak Dil) çakıştığı için zorunlu değil. |  |
| 906 | Uncommon | **Az Bulunur** | öneri | ✔ |  |  |  |
| 907 | Rare | **Nadir** | öneri | ✔ |  |  |  |
| 908 | Very Rare | **Çok Nadir** | öneri | ✔ |  |  |  |
| 909 | Legendary | **Efsanevi** | öneri |  |  |  |  |
| 910 | Artifact | **Artefakt** | öneri | ✔ |  |  |  |
| 911 | Rarity Varies | **Nadirliği Değişir** | öneri | ✔ |  |  |  |

### Sihirli eşya adı

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 912 | Adamantine Armor | **Adamantin Zırh** | öneri |  |  |  |  |
| 913 | Ammunition, +1, +2, or +3 | **Mühimmat, +1, +2 veya +3** | öneri |  |  |  |  |
| 914 | Ammunition of Slaying | **Öldürücü Mühimmat** | öneri |  |  |  |  |
| 915 | Amulet of Health | **Sağlık Muskası** | öneri |  |  | Amulet = Muska, Periapt = Nazarlık, Talisman = Tılsım |  |
| 916 | Amulet of Proof against Detection and Location | **Algılanma ve Bulunmaya Karşı Muska** | öneri |  |  |  |  |
| 917 | Amulet of the Planes | **Düzlemler Muskası** | öneri |  |  |  |  |
| 918 | Animated Shield | **Canlanmış Kalkan** | öneri |  |  |  |  |
| 919 | Apparatus of the Crab | **Yengeç Aygıtı** | öneri |  |  |  |  |
| 920 | Armor, +1, +2, or +3 | **Zırh, +1, +2 veya +3** | öneri |  |  |  |  |
| 921 | Armor of Invulnerability | **Dokunulmazlık Zırhı** | öneri |  |  |  |  |
| 922 | Armor of Resistance | **Direnç Zırhı** | öneri |  |  |  |  |
| 923 | Armor of Vulnerability | **Zafiyet Zırhı** | öneri |  |  |  |  |
| 924 | Arrow-Catching Shield | **Ok Yakalayan Kalkan** | öneri |  |  |  |  |
| 925 | Bag of Beans | **Fasulye Torbası** | öneri |  |  |  |  |
| 926 | Bag of Devouring | **Yutucu Torba** | öneri |  |  |  |  |
| 927 | Bag of Holding | **Dipsiz Torba** | öneri |  |  | Dipsiz Torba: deyimsel, doğal ad (sınırsız değil, 500 lb) |  |
| 928 | Bag of Tricks | **Marifetler Torbası** | öneri |  |  |  |  |
| 929 | Bead of Force | **Kuvvet Boncuğu** | öneri |  |  |  |  |
| 930 | Bead of Nourishment | **Besin Boncuğu** | öneri |  |  |  |  |
| 931 | Belt of Dwarvenkind | **Cüce Kemeri** | öneri |  |  |  |  |
| 932 | Belt of Giant Strength | **Dev Gücü Kemeri** | öneri |  |  |  |  |
| 933 | Berserker Axe | **Gözü Dönmüş Baltası** | öneri |  |  |  |  |
| 934 | Boots of Elvenkind | **Elf Çizmeleri** | öneri |  |  |  |  |
| 935 | Boots of Levitation | **Havalanma Çizmeleri** | öneri |  |  |  |  |
| 936 | Boots of Speed | **Hız Çizmeleri** | öneri |  |  |  |  |
| 937 | Boots of Striding and Springing | **Uzun Adım ve Sıçrama Çizmeleri** | öneri |  |  |  |  |
| 938 | Boots of the Winterlands | **Kış Diyarı Çizmeleri** | öneri |  |  |  |  |
| 939 | Bowl of Commanding Water Elementals | **Su Elementallerine Hükmetme Kâsesi** | öneri |  |  |  |  |
| 940 | Bracers of Archery | **Okçuluk Bilezikleri** | öneri |  |  |  |  |
| 941 | Bracers of Defense | **Savunma Bilezikleri** | öneri |  |  |  |  |
| 942 | Brazier of Commanding Fire Elementals | **Ateş Elementallerine Hükmetme Mangalı** | öneri |  |  |  |  |
| 943 | Brooch of Shielding | **Kalkan Broşu** | öneri |  |  |  |  |
| 944 | Broom of Flying | **Uçan Süpürge** | öneri |  |  |  |  |
| 945 | Candle of Invocation | **Yakarış Mumu** | öneri |  |  |  |  |
| 946 | Cape of the Mountebank | **Şarlatan Pelerini** | öneri |  |  |  |  |
| 947 | Carpet of Flying | **Uçan Halı** | öneri |  |  |  |  |
| 948 | Censer of Controlling Air Elementals | **Hava Elementallerini Yönetme Buhurdanı** | öneri |  |  |  |  |
| 949 | Chime of Opening | **Açma Çanı** | öneri |  |  |  |  |
| 950 | Circlet of Blasting | **Patlama Tacı** | öneri |  |  |  |  |
| 951 | Cloak of Arachnida | **Örümcek Pelerini** | öneri |  |  |  |  |
| 952 | Cloak of Displacement | **Yer Değiştirme Pelerini** | öneri |  |  |  |  |
| 953 | Cloak of Elvenkind | **Elf Pelerini** | öneri |  |  |  |  |
| 954 | Cloak of Invisibility | **Görünmezlik Pelerini** | öneri |  |  |  |  |
| 955 | Cloak of Protection | **Koruma Pelerini** | öneri |  |  |  |  |
| 956 | Cloak of the Bat | **Yarasa Pelerini** | öneri |  |  |  |  |
| 957 | Cloak of the Manta Ray | **Vatoz Pelerini** | öneri |  |  |  |  |
| 958 | Crystal Ball | **Kristal Küre** | öneri |  |  |  |  |
| 959 | Crystal Ball of Mind Reading | **Zihin Okuma Kristal Küresi** | öneri |  |  |  |  |
| 960 | Crystal Ball of Telepathy | **Telepati Kristal Küresi** | öneri |  |  |  |  |
| 961 | Crystal Ball of True Seeing | **Gerçeği Görme Kristal Küresi** | öneri |  |  |  |  |
| 962 | Cube of Force | **Kuvvet Küpü** | öneri |  |  |  |  |
| 963 | Cubic Gate | **Kübik Geçit** | öneri |  |  |  |  |
| 964 | Dagger of Venom | **Zehir Hançeri** | öneri |  |  |  |  |
| 965 | Dancing Sword | **Dans Eden Kılıç** | öneri |  |  |  |  |
| 966 | Decanter of Endless Water | **Bitmeyen Su Sürahisi** | öneri |  |  |  |  |
| 967 | Deck of Illusions | **İllüzyon Destesi** | öneri |  |  |  |  |
| 968 | Defender | **Koruyucu** | öneri |  |  |  |  |
| 969 | Demon Armor | **Demon Zırhı** | öneri |  |  | Biçem kılavuzu: demon = demon (İblis = Fiend) |  |
| 970 | Dimensional Shackles | **Boyutsal Prangalar** | öneri |  |  |  |  |
| 971 | Dragon Orb | **Ejderha Küresi** | öneri |  |  |  |  |
| 972 | Dragon Scale Mail | **Ejderha Pullu Zırh** | öneri |  |  |  |  |
| 973 | Dragon Slayer | **Ejderha Avcısı** | öneri |  |  |  |  |
| 974 | Dust of Disappearance | **Kaybolma Tozu** | öneri |  |  |  |  |
| 975 | Dust of Dryness | **Kuruluk Tozu** | öneri |  |  |  |  |
| 976 | Dust of Sneezing and Choking | **Hapşırma ve Boğulma Tozu** | öneri |  |  |  |  |
| 977 | Dwarven Plate | **Cüce Plaka Zırhı** | öneri |  |  |  |  |
| 978 | Dwarven Thrower | **Cüce Fırlatıcısı** | öneri |  |  |  |  |
| 979 | Efficient Quiver | **Verimli Sadak** | öneri |  |  |  |  |
| 980 | Efreeti Bottle | **İfrit Şişesi** | öneri |  |  |  |  |
| 981 | Elemental Gem | **Elemental Mücevheri** | öneri |  |  |  |  |
| 982 | Elixir of Health | **Sağlık Eliksiri** | öneri |  |  |  |  |
| 983 | Elven Chain | **Elf Zincir Zırhı** | öneri |  |  |  |  |
| 984 | Energy Bow | **Enerji Yayı** | öneri |  |  |  |  |
| 985 | Eversmoking Bottle | **Bitmeyen Duman Şişesi** | öneri |  |  |  |  |
| 986 | Eyes of Charming | **Büyüleme Gözleri** | öneri |  |  |  |  |
| 987 | Eyes of Minute Seeing | **Ayrıntı Görme Gözleri** | öneri |  |  |  |  |
| 988 | Eyes of the Eagle | **Kartal Gözleri** | öneri |  |  |  |  |
| 989 | Feather Token | **Tüy Nişanesi** | öneri |  |  |  |  |
| 990 | Figurine of Wondrous Power | **Harikulade Güç Heykelciği** | öneri |  |  |  |  |
| 991 | Flame Tongue | **Alev Dili** | öneri |  |  |  |  |
| 992 | Folding Boat | **Katlanır Tekne** | öneri |  |  |  |  |
| 993 | Frost Brand | **Ayaz Kılıcı** | öneri |  |  |  |  |
| 994 | Gauntlets of Ogre Power | **Ogre Gücü Eldivenleri** | öneri |  |  |  |  |
| 995 | Gem of Brightness | **Parlaklık Mücevheri** | öneri |  |  |  |  |
| 996 | Gem of Seeing | **Görme Mücevheri** | öneri |  |  |  |  |
| 997 | Giant Slayer | **Dev Avcısı** | öneri |  |  |  |  |
| 998 | Glamoured Studded Leather | **Kılık Değiştiren Perçinli Deri Zırh** | öneri |  |  |  |  |
| 999 | Gloves of Missile Snaring | **Mermi Yakalama Eldivenleri** | öneri |  |  |  |  |
| 1000 | Gloves of Swimming and Climbing | **Yüzme ve Tırmanma Eldivenleri** | öneri |  |  |  |  |
| 1001 | Gloves of Thievery | **Hırsızlık Eldivenleri** | öneri |  |  |  |  |
| 1002 | Goggles of Night | **Gece Gözlüğü** | öneri |  |  |  |  |
| 1003 | Hammer of Thunderbolts | **Şimşek Çekici** | öneri |  |  |  |  |
| 1004 | Handy Haversack | **Kullanışlı Heybe** | öneri |  |  |  |  |
| 1005 | Hat of Disguise | **Kılık Değiştirme Şapkası** | öneri |  |  |  |  |
| 1006 | Hat of Many Spells | **Sayısız Büyü Şapkası** | öneri |  |  |  |  |
| 1007 | Headband of Intellect | **Zeka Alın Bandı** | öneri |  |  |  |  |
| 1008 | Helm of Brilliance | **Parıltı Miğferi** | öneri |  |  |  |  |
| 1009 | Helm of Comprehending Languages | **Dilleri Anlama Miğferi** | öneri |  |  |  |  |
| 1010 | Helm of Telepathy | **Telepati Miğferi** | öneri |  |  |  |  |
| 1011 | Helm of Teleportation | **Işınlanma Miğferi** | öneri |  |  |  |  |
| 1012 | Holy Avenger | **Kutsal İntikamcı** | öneri |  |  |  |  |
| 1013 | Horn of Blasting | **Patlama Borusu** | öneri |  |  |  |  |
| 1014 | Horn of Valhalla | **Valhalla Borusu** | öneri |  |  |  |  |
| 1015 | Horseshoes of a Zephyr | **Meltem Nalları** | öneri |  |  |  |  |
| 1016 | Horseshoes of Speed | **Hız Nalları** | öneri |  |  |  |  |
| 1017 | Immovable Rod | **Kımıldamaz Çubuk** | öneri |  |  |  |  |
| 1018 | Instant Fortress | **Anında Kale** | öneri |  |  |  |  |
| 1019 | Ioun Stone | **Ioun Taşı** | öneri |  |  |  |  |
| 1020 | Iron Bands | **Demir Bağlar** | öneri |  |  |  |  |
| 1021 | Iron Flask | **Demir Şişe** | öneri |  |  |  |  |
| 1022 | Javelin of Lightning | **Yıldırım Ciridi** | öneri |  |  |  |  |
| 1023 | Lantern of Revealing | **İfşa Feneri** | öneri |  |  |  |  |
| 1024 | Luck Blade | **Şans Kılıcı** | öneri |  |  |  |  |
| 1025 | Mace of Disruption | **Yıkım Topuzu** | öneri |  |  |  |  |
| 1026 | Mace of Smiting | **Darbe Topuzu** | öneri |  |  |  |  |
| 1027 | Mace of Terror | **Dehşet Topuzu** | öneri |  |  |  |  |
| 1028 | Mantle of Spell Resistance | **Büyü Direnci Örtüsü** | öneri |  |  |  |  |
| 1029 | Manual of Bodily Health | **Beden Sağlığı Kılavuzu** | öneri |  |  |  |  |
| 1030 | Manual of Gainful Exercise | **Verimli Egzersiz Kılavuzu** | öneri |  |  |  |  |
| 1031 | Manual of Golems | **Golem Kılavuzu** | öneri |  |  |  |  |
| 1032 | Manual of Quickness of Action | **Eylem Çabukluğu Kılavuzu** | öneri |  |  |  |  |
| 1033 | Marvelous Pigments | **Mucizevi Boyalar** | öneri |  |  |  |  |
| 1034 | Medallion of Thoughts | **Düşünce Madalyonu** | öneri |  |  |  |  |
| 1035 | Mirror of Life Trapping | **Yaşam Kapanı Aynası** | öneri |  |  |  |  |
| 1036 | Mithral Armor | **Mithral Zırh** | öneri |  |  |  |  |
| 1037 | Mysterious Deck | **Gizemli Deste** | öneri |  |  | SRD'deki yeni ad (Deck of Many Things yerine); düz çeviri |  |
| 1038 | Necklace of Adaptation | **Uyum Kolyesi** | öneri |  |  |  |  |
| 1039 | Necklace of Fireballs | **Ateş Topu Kolyesi** | öneri |  |  |  |  |
| 1040 | Necklace of Prayer Beads | **Dua Boncuğu Kolyesi** | öneri |  |  |  |  |
| 1041 | Nine Lives Stealer | **Dokuz Can Hırsızı** | öneri |  |  |  |  |
| 1042 | Oathbow | **Yemin Yayı** | öneri |  |  |  |  |
| 1043 | Oil of Etherealness | **Eterikleşme Yağı** | öneri |  |  |  |  |
| 1044 | Oil of Sharpness | **Keskinlik Yağı** | öneri |  |  |  |  |
| 1045 | Oil of Slipperiness | **Kayganlık Yağı** | öneri |  |  |  |  |
| 1046 | Pearl of Power | **Kudret İncisi** | öneri |  |  |  |  |
| 1047 | Periapt of Health | **Sağlık Nazarlığı** | öneri |  |  |  |  |
| 1048 | Periapt of Proof against Poison | **Zehre Karşı Nazarlık** | öneri |  |  |  |  |
| 1049 | Periapt of Wound Closure | **Yara Kapama Nazarlığı** | öneri |  |  |  |  |
| 1050 | Philter of Love | **Aşk İksiri** | öneri |  |  | Philter: yerleşik 'Aşk İksiri' kalıbı |  |
| 1051 | Pipes of Haunting | **Ürperti Kavalı** | öneri |  |  |  |  |
| 1052 | Pipes of the Sewers | **Lağım Kavalı** | öneri |  |  |  |  |
| 1053 | Plate Armor of Etherealness | **Eterikleşme Plaka Zırhı** | öneri |  |  |  |  |
| 1054 | Portable Hole | **Taşınabilir Delik** | öneri |  |  |  |  |
| 1055 | Potion of Animal Friendship | **Hayvan Dostluğu İksiri** | öneri |  |  |  |  |
| 1056 | Potion of Clairvoyance | **Durugörü İksiri** | öneri |  |  |  |  |
| 1057 | Potion of Climbing | **Tırmanma İksiri** | öneri |  |  |  |  |
| 1058 | Potion of Diminution | **Küçülme İksiri** | öneri |  |  |  |  |
| 1059 | Potion of Flying | **Uçma İksiri** | öneri |  |  |  |  |
| 1060 | Potion of Gaseous Form | **Gaz Biçimi İksiri** | öneri |  |  |  |  |
| 1061 | Potion of Giant Strength | **Dev Gücü İksiri** | öneri |  |  |  |  |
| 1062 | Potion of Growth | **Büyüme İksiri** | öneri |  |  |  |  |
| 1063 | Potions of Healing | **Şifa İksirleri** | öneri |  |  | Şifa İksiri (sözlük) çoğulu; giriş birden çok tür kapsar |  |
| 1064 | Potion of Heroism | **Kahramanlık İksiri** | öneri |  |  |  |  |
| 1065 | Potion of Invisibility | **Görünmezlik İksiri** | öneri |  |  |  |  |
| 1066 | Potion of Invulnerability | **Dokunulmazlık İksiri** | öneri |  |  |  |  |
| 1067 | Potion of Longevity | **Uzun Ömür İksiri** | öneri |  |  |  |  |
| 1068 | Potion of Mind Reading | **Zihin Okuma İksiri** | öneri |  |  |  |  |
| 1069 | Potion of Poison | **Zehir İksiri** | öneri |  |  |  |  |
| 1070 | Potion of Resistance | **Direnç İksiri** | öneri |  |  |  |  |
| 1071 | Potion of Speed | **Hız İksiri** | öneri |  |  |  |  |
| 1072 | Potion of Vitality | **Dirilik İksiri** | öneri |  |  |  |  |
| 1073 | Potion of Water Breathing | **Suda Nefes Alma İksiri** | öneri |  |  |  |  |
| 1074 | Quarterstaff of the Acrobat | **Akrobat Asası** | öneri |  |  |  |  |
| 1075 | Ring of Animal Influence | **Hayvan Etkileme Yüzüğü** | öneri |  |  |  |  |
| 1076 | Ring of Djinni Summoning | **Cin Çağırma Yüzüğü** | öneri |  |  |  |  |
| 1077 | Ring of Elemental Command | **Elementallere Hükmetme Yüzüğü** | öneri |  |  |  |  |
| 1078 | Ring of Evasion | **Sıyrılma Yüzüğü** | öneri |  |  |  |  |
| 1079 | Ring of Feather Falling | **Tüy Düşüşü Yüzüğü** | öneri |  |  |  |  |
| 1080 | Ring of Free Action | **Serbest Hareket Yüzüğü** | öneri |  |  |  |  |
| 1081 | Ring of Invisibility | **Görünmezlik Yüzüğü** | öneri |  |  |  |  |
| 1082 | Ring of Jumping | **Zıplama Yüzüğü** | öneri |  |  |  |  |
| 1083 | Ring of Mind Shielding | **Zihin Kalkanı Yüzüğü** | öneri |  |  |  |  |
| 1084 | Ring of Protection | **Koruma Yüzüğü** | öneri |  |  |  |  |
| 1085 | Ring of Regeneration | **Rejenerasyon Yüzüğü** | öneri |  |  |  |  |
| 1086 | Ring of Resistance | **Direnç Yüzüğü** | öneri |  |  |  |  |
| 1087 | Ring of Shooting Stars | **Kayan Yıldız Yüzüğü** | öneri |  |  |  |  |
| 1088 | Ring of Spell Storing | **Büyü Saklama Yüzüğü** | öneri |  |  |  |  |
| 1089 | Ring of Spell Turning | **Büyü Yansıtma Yüzüğü** | öneri |  |  |  |  |
| 1090 | Ring of Swimming | **Yüzme Yüzüğü** | öneri |  |  |  |  |
| 1091 | Ring of Telekinesis | **Telekinezi Yüzüğü** | öneri |  |  |  |  |
| 1092 | Ring of the Ram | **Koç Yüzüğü** | öneri |  |  |  |  |
| 1093 | Ring of Three Wishes | **Üç Dilek Yüzüğü** | öneri |  |  |  |  |
| 1094 | Ring of Warmth | **Sıcaklık Yüzüğü** | öneri |  |  |  |  |
| 1095 | Ring of Water Walking | **Su Üstünde Yürüme Yüzüğü** | öneri |  |  |  |  |
| 1096 | Ring of X-ray Vision | **X Işını Görüşü Yüzüğü** | öneri |  |  |  |  |
| 1097 | Robe of Eyes | **Gözler Cüppesi** | öneri |  |  |  |  |
| 1098 | Robe of Scintillating Colors | **Işıldayan Renkler Cüppesi** | öneri |  |  |  |  |
| 1099 | Robe of Stars | **Yıldızlar Cüppesi** | öneri |  |  |  |  |
| 1100 | Robe of the Archmagi | **Ulu Efsuncular Cüppesi** | öneri |  |  | Archmage = Ulu Efsuncu (sözlük) |  |
| 1101 | Robe of Useful Items | **Faydalı Eşyalar Cüppesi** | öneri |  |  |  |  |
| 1102 | Rod of Absorption | **Emilim Çubuğu** | öneri |  |  |  |  |
| 1103 | Rod of Alertness | **Uyanıklık Çubuğu** | öneri |  |  |  |  |
| 1104 | Rod of Lordly Might | **Hükümdar Kudreti Çubuğu** | öneri |  |  |  |  |
| 1105 | Rod of Resurrection | **Diriliş Çubuğu** | öneri |  |  |  |  |
| 1106 | Rod of Rulership | **Hükümranlık Çubuğu** | öneri |  |  |  |  |
| 1107 | Rod of Security | **Güvenlik Çubuğu** | öneri |  |  |  |  |
| 1108 | Rope of Climbing | **Tırmanma Halatı** | öneri |  |  |  |  |
| 1109 | Rope of Entanglement | **Dolaştırma Halatı** | öneri |  |  |  |  |
| 1110 | Scarab of Protection | **Koruma Skarabesi** | öneri |  |  |  |  |
| 1111 | Scimitar of Speed | **Hız Palası** | öneri |  |  |  |  |
| 1112 | Sending Stones | **Haber Taşları** | öneri |  |  |  |  |
| 1113 | Sentinel Shield | **Nöbetçi Kalkanı** | öneri |  |  |  |  |
| 1114 | Shield, +1, +2, or +3 | **Kalkan, +1, +2 veya +3** | öneri |  |  |  |  |
| 1115 | Shield of Missile Attraction | **Mermi Çeken Kalkan** | öneri |  |  |  |  |
| 1116 | Shield of the Cavalier | **Süvari Kalkanı** | öneri |  |  |  |  |
| 1117 | Slippers of Spider Climbing | **Örümcek Tırmanışı Terlikleri** | öneri |  |  |  |  |
| 1118 | Sovereign Glue | **Mutlak Yapıştırıcı** | öneri |  |  |  |  |
| 1119 | Spellguard Shield | **Büyüsavar Kalkan** | öneri |  |  |  |  |
| 1120 | Sphere of Annihilation | **Yok Oluş Küresi** | öneri |  |  |  |  |
| 1121 | Staff of Charming | **Büyüleme Asası** | öneri |  |  |  |  |
| 1122 | Staff of Fire | **Ateş Asası** | öneri |  |  |  |  |
| 1123 | Staff of Frost | **Ayaz Asası** | öneri |  |  |  |  |
| 1124 | Staff of Healing | **Şifa Asası** | öneri |  |  |  |  |
| 1125 | Staff of Power | **Kudret Asası** | öneri |  |  |  |  |
| 1126 | Staff of Striking | **Vuruş Asası** | öneri |  |  |  |  |
| 1127 | Staff of Swarming Insects | **Böcek Sürüsü Asası** | öneri |  |  |  |  |
| 1128 | Staff of the Magi | **Efsuncular Asası** | öneri |  |  | Mage = Efsuncu (sözlük) |  |
| 1129 | Staff of the Python | **Piton Asası** | öneri |  |  |  |  |
| 1130 | Staff of the Woodlands | **Ormanlar Asası** | öneri |  |  |  |  |
| 1131 | Staff of Thunder and Lightning | **Gök Gürültüsü ve Yıldırım Asası** | öneri |  |  |  |  |
| 1132 | Staff of Withering | **Soldurma Asası** | öneri |  |  |  |  |
| 1133 | Stone of Controlling Earth Elementals | **Toprak Elementallerini Yönetme Taşı** | öneri |  |  |  |  |
| 1134 | Stone of Good Luck (Luckstone) | **İyi Talih Taşı (Şans Taşı)** | öneri |  |  |  |  |
| 1135 | Sun Blade | **Güneş Kılıcı** | öneri |  |  |  |  |
| 1136 | Sword of Life Stealing | **Can Çalan Kılıç** | öneri |  |  |  |  |
| 1137 | Sword of Sharpness | **Keskinlik Kılıcı** | öneri |  |  |  |  |
| 1138 | Sword of Wounding | **Yaralama Kılıcı** | öneri |  |  |  |  |
| 1139 | Talisman of Pure Good | **Saf İyilik Tılsımı** | öneri |  |  |  |  |
| 1140 | Talisman of the Sphere | **Küre Tılsımı** | öneri |  |  |  |  |
| 1141 | Talisman of Ultimate Evil | **Mutlak Kötülük Tılsımı** | öneri |  |  |  |  |
| 1142 | Thunderous Greatclub | **Gürleyen Büyük Sopa** | öneri |  |  |  |  |
| 1143 | Tome of Clear Thought | **Berrak Düşünce Kitabı** | öneri |  |  |  |  |
| 1144 | Tome of Leadership and Influence | **Liderlik ve Nüfuz Kitabı** | öneri |  |  |  |  |
| 1145 | Tome of Understanding | **Anlayış Kitabı** | öneri |  |  |  |  |
| 1146 | Trident of Fish Command | **Balıklara Hükmeden Üç Dişli Mızrak** | öneri |  |  |  |  |
| 1147 | Universal Solvent | **Evrensel Çözücü** | öneri |  |  |  |  |
| 1148 | Vicious Weapon | **Acımasız Silah** | öneri |  |  |  |  |
| 1149 | Vorpal Sword | **Vorpal Kılıç** | öneri |  |  |  |  |
| 1150 | Wand of Binding | **Bağlama Değneği** | öneri |  |  |  |  |
| 1151 | Wand of Enemy Detection | **Düşman Algılama Değneği** | öneri |  |  |  |  |
| 1152 | Wand of Fear | **Korku Değneği** | öneri |  |  |  |  |
| 1153 | Wand of Fireballs | **Ateş Topu Değneği** | öneri |  |  |  |  |
| 1154 | Wand of Lightning Bolts | **Yıldırım Oku Değneği** | öneri |  |  |  |  |
| 1155 | Wand of Magic Detection | **Büyü Algılama Değneği** | öneri |  |  |  |  |
| 1156 | Wand of Magic Missiles | **Büyülü Füze Değneği** | öneri |  |  |  |  |
| 1157 | Wand of Paralysis | **Felç Değneği** | öneri |  |  |  |  |
| 1158 | Wand of Polymorph | **Biçim Değiştirme Değneği** | öneri |  |  |  |  |
| 1159 | Wand of Secrets | **Sırlar Değneği** | öneri |  |  |  |  |
| 1160 | Wand of the War Mage, +1, +2, or +3 | **Savaş Büyücüsü Değneği, +1, +2 veya +3** | öneri |  |  |  |  |
| 1161 | Wand of Web | **Ağ Değneği** | öneri |  |  |  |  |
| 1162 | Wand of Wonder | **Mucize Değneği** | öneri |  |  |  |  |
| 1163 | Weapon, +1, +2, or +3 | **Silah, +1, +2 veya +3** | öneri |  |  |  |  |
| 1164 | Weapon of Warning | **Uyarı Silahı** | öneri |  |  |  |  |
| 1165 | Well of Many Worlds | **Sayısız Dünya Kuyusu** | öneri |  |  |  |  |
| 1166 | Wind Fan | **Rüzgâr Yelpazesi** | öneri |  |  |  |  |
| 1167 | Winged Boots | **Kanatlı Çizmeler** | öneri |  |  |  |  |
| 1168 | Wings of Flying | **Uçma Kanatları** | öneri |  |  |  |  |

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
| Prestidigitation | Hokkabazlık | büyü adı |
| Sacred Flame | Kutsal Alev | büyü adı |
| Guidance | Rehberlik | büyü adı |
| Eldritch Blast | Kadim Patlama | büyü adı |
| Vicious Mockery | Acımasız Alay | büyü adı |
| Ray of Frost | Ayaz Işını | büyü adı |
| Shocking Grasp | Şok Edici Kavrayış | büyü adı |
| Thaumaturgy | Mucizecilik | büyü adı |
| Druidcraft | Druid Sanatı | büyü adı |
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
| Actions | Eylemler | bölüm |
| Weapons | Silahlar | bölüm |
| Armor | Zırh | bölüm |
| Casting Spells | Büyü Yapma | bölüm |
| Acid Arrow | Asit Oku | büyü adı |
| Aid | Destek | büyü adı |
| Alarm | Alarm | büyü adı |
| Alter Self | Kendini Değiştir | büyü adı |
| Animal Friendship | Hayvan Dostluğu | büyü adı |
| Animal Messenger | Haberci Hayvan | büyü adı |
| Animal Shapes | Hayvan Biçimleri | büyü adı |
| Animate Dead | Ölüleri Canlandır | büyü adı |
| Animate Objects | Nesneleri Canlandır | büyü adı |
| Antimagic Field | Antibüyü Alanı | büyü adı |
| Antipathy/Sympathy | Antipati/Sempati | büyü adı |
| Antilife Shell | Antiyaşam Kabuğu | büyü adı |
| Arcane Eye | Arkana Gözü | büyü adı |
| Arcane Hand | Arkana Eli | büyü adı |
| Arcane Lock | Arkana Kilidi | büyü adı |
| Arcane Sword | Arkana Kılıcı | büyü adı |
| Arcanist’s Magic Aura | Arkanistin Büyü Aurası | büyü adı |
| Astral Projection | Astral Yansıtma | büyü adı |
| Augury | Alamet | büyü adı |
| Aura of Life | Yaşam Aurası | büyü adı |
| Awaken | Uyandır | büyü adı |
| Bane | Uğursuzluk | büyü adı |
| Banishment | Sürgün | büyü adı |
| Barkskin | Kabuk Deri | büyü adı |
| Beacon of Hope | Umut Feneri | büyü adı |
| Befuddlement | Zihin Bulandırma | büyü adı |
| Bestow Curse | Lanetle | büyü adı |
| Black Tentacles | Kara Dokunaçlar | büyü adı |
| Blade Barrier | Bıçak Bariyeri | büyü adı |
| Blight | Soldurma | büyü adı |
| Blindness/Deafness | Körlük/Sağırlık | büyü adı |
| Blink | Yanıp Sönme | büyü adı |
| Blur | Bulanıklık | büyü adı |
| Call Lightning | Yıldırım Çağır | büyü adı |
| Calm Emotions | Duyguları Yatıştır | büyü adı |
| Chain Lightning | Zincirleme Yıldırım | büyü adı |
| Charm Monster | Canavarı Büyüle | büyü adı |
| Chill Touch | Soğuk Dokunuş | büyü adı |
| Chromatic Orb | Renkli Küre | büyü adı |
| Circle of Death | Ölüm Çemberi | büyü adı |
| Clairvoyance | Durugörü | büyü adı |
| Clone | Klon | büyü adı |
| Cloudkill | Ölüm Bulutu | büyü adı |
| Color Spray | Renk Saçılımı | büyü adı |
| Commune | İlahi İletişim | büyü adı |
| Commune with Nature | Doğayla İletişim | büyü adı |
| Comprehend Languages | Dilleri Anla | büyü adı |
| Compulsion | Zorlama | büyü adı |
| Cone of Cold | Soğuk Konisi | büyü adı |
| Confusion | Kafa Karışıklığı | büyü adı |
| Conjure Animals | Hayvan Çağır | büyü adı |
| Conjure Celestial | Göksel Çağır | büyü adı |
| Conjure Elemental | Elemental Çağır | büyü adı |
| Conjure Fey | Peri Çağır | büyü adı |
| Conjure Minor Elementals | Küçük Elemental Çağır | büyü adı |
| Conjure Woodland Beings | Orman Varlığı Çağır | büyü adı |
| Contact Other Plane | Başka Düzlemle Temas | büyü adı |
| Contagion | Salgın | büyü adı |
| Contingency | Tedbir | büyü adı |
| Continual Flame | Sönmeyen Alev | büyü adı |
| Control Water | Suyu Yönet | büyü adı |
| Control Weather | Havayı Yönet | büyü adı |
| Create Food and Water | Yiyecek ve Su Yarat | büyü adı |
| Create or Destroy Water | Su Yarat veya Yok Et | büyü adı |
| Create Undead | Hortlak Yarat | büyü adı |
| Creation | Yaratım | büyü adı |
| Dancing Lights | Dans Eden Işıklar | büyü adı |
| Darkvision | Karanlık Görüş | büyü adı |
| Daylight | Gün Işığı | büyü adı |
| Death Ward | Ölüm Tılsımı | büyü adı |
| Delayed Blast Fireball | Gecikmeli Ateş Topu | büyü adı |
| Demiplane | Yarı Düzlem | büyü adı |
| Detect Evil and Good | İyi ve Kötüyü Algıla | büyü adı |
| Detect Poison and Disease | Zehir ve Hastalık Algıla | büyü adı |
| Detect Thoughts | Düşünce Algıla | büyü adı |
| Dimension Door | Boyut Kapısı | büyü adı |
| Disguise Self | Kılık Değiştir | büyü adı |
| Disintegrate | Toza Çevir | büyü adı |
| Dispel Evil and Good | İyi ve Kötüyü Defet | büyü adı |
| Dissonant Whispers | Uyumsuz Fısıltılar | büyü adı |
| Divination | Kehanet Büyüsü | büyü adı |
| Divine Favor | İlahi Lütuf | büyü adı |
| Divine Smite | İlahi Darbe | büyü adı |
| Divine Word | İlahi Söz | büyü adı |
| Dominate Beast | Hayvana Hükmet | büyü adı |
| Dominate Monster | Canavara Hükmet | büyü adı |
| Dominate Person | Kişiye Hükmet | büyü adı |
| Dragon’s Breath | Ejderha Nefesi | büyü adı |
| Dream | Rüya | büyü adı |
| Earthquake | Deprem | büyü adı |
| Elementalism | Elementalizm | büyü adı |
| Enhance Ability | Yeteneği Güçlendir | büyü adı |
| Enlarge/Reduce | Büyüt/Küçült | büyü adı |
| Ensnaring Strike | Sarmalayan Vuruş | büyü adı |
| Entangle | Dolaştır | büyü adı |
| Enthrall | Mest Et | büyü adı |
| Etherealness | Eterikleşme | büyü adı |
| Expeditious Retreat | Hızlı Kaçış | büyü adı |
| Eyebite | Kem Göz | büyü adı |
| Fabricate | İmal Et | büyü adı |
| Faithful Hound | Sadık Tazı | büyü adı |
| False Life | Sahte Yaşam | büyü adı |
| Fear | Korku | büyü adı |
| Find Familiar | Ruh Yoldaşı Bul | büyü adı |
| Find Steed | Binek Bul | büyü adı |
| Find Traps | Tuzak Bul | büyü adı |
| Finger of Death | Ölüm Parmağı | büyü adı |
| Find the Path | Yolu Bul | büyü adı |
| Fire Shield | Ateş Kalkanı | büyü adı |
| Fire Storm | Ateş Fırtınası | büyü adı |
| Flame Blade | Alev Kılıcı | büyü adı |
| Flame Strike | Alev Sütunu | büyü adı |
| Flaming Sphere | Alevli Küre | büyü adı |
| Flesh to Stone | Taşa Çevir | büyü adı |
| Floating Disk | Süzülen Disk | büyü adı |
| Fog Cloud | Sis Bulutu | büyü adı |
| Forbiddance | Yasaklama | büyü adı |
| Forcecage | Kuvvet Kafesi | büyü adı |
| Foresight | Öngörü | büyü adı |
| Freedom of Movement | Hareket Özgürlüğü | büyü adı |
| Freezing Sphere | Donduran Küre | büyü adı |
| Gaseous Form | Gaz Biçimi | büyü adı |
| Gate | Geçit | büyü adı |
| Geas | Buyruk | büyü adı |
| Gentle Repose | Dingin İstirahat | büyü adı |
| Giant Insect | Dev Böcek | büyü adı |
| Glibness | Dilbazlık | büyü adı |
| Globe of Invulnerability | Dokunulmazlık Küresi | büyü adı |
| Glyph of Warding | Koruma Mührü | büyü adı |
| Goodberry | Şifalı Meyve | büyü adı |
| Grease | Kaygan Yağ | büyü adı |
| Greater Restoration | Üstün Onarım | büyü adı |
| Guardian of Faith | İnanç Muhafızı | büyü adı |
| Guards and Wards | Bekçiler ve Tılsımlar | büyü adı |
| Gust of Wind | Sert Rüzgâr | büyü adı |
| Hallow | Kutsallaştır | büyü adı |
| Hallucinatory Terrain | Hayali Arazi | büyü adı |
| Harm | Zarar | büyü adı |
| Heal | Şifa | büyü adı |
| Heat Metal | Metali Isıt | büyü adı |
| Hellish Rebuke | Cehennem Misillemesi | büyü adı |
| Heroes’ Feast | Kahramanların Ziyafeti | büyü adı |
| Heroism | Kahramanlık | büyü adı |
| Hex | Beddua | büyü adı |
| Hideous Laughter | Dayanılmaz Kahkaha | büyü adı |
| Hold Monster | Canavarı Durdur | büyü adı |
| Holy Aura | Kutsal Aura | büyü adı |
| Hypnotic Pattern | Hipnotik Desen | büyü adı |
| Ice Knife | Buz Bıçağı | büyü adı |
| Ice Storm | Buz Fırtınası | büyü adı |
| Illusory Script | Yanıltıcı Yazı | büyü adı |
| Imprisonment | Hapsetme | büyü adı |
| Incendiary Cloud | Yakıcı Bulut | büyü adı |
| Inflict Wounds | Yara Aç | büyü adı |
| Insect Plague | Böcek Vebası | büyü adı |
| Instant Summons | Anında Celp | büyü adı |
| Irresistible Dance | Karşı Konulmaz Dans | büyü adı |
| Jump | Sıçrama | büyü adı |
| Knock | Kilit Aç | büyü adı |
| Legend Lore | Efsane Bilgisi | büyü adı |
| Levitate | Havalandır | büyü adı |
| Locate Animals or Plants | Hayvan veya Bitki Bul | büyü adı |
| Locate Creature | Yaratık Bul | büyü adı |
| Locate Object | Nesne Bul | büyü adı |
| Longstrider | Uzun Adım | büyü adı |
| Magic Circle | Büyülü Çember | büyü adı |
| Magic Jar | Büyülü Kavanoz | büyü adı |
| Magic Mouth | Büyülü Ağız | büyü adı |
| Magic Weapon | Büyülü Silah | büyü adı |
| Magnificent Mansion | Muhteşem Konak | büyü adı |
| Major Image | Büyük Görüntü | büyü adı |
| Mass Cure Wounds | Yaraları Toplu İyileştir | büyü adı |
| Mass Heal | Toplu Şifa | büyü adı |
| Mass Healing Word | Toplu Şifa Sözü | büyü adı |
| Mass Suggestion | Toplu Telkin | büyü adı |
| Maze | Labirent | büyü adı |
| Meld into Stone | Taşla Bütünleş | büyü adı |
| Mending | Tamir | büyü adı |
| Message | Mesaj | büyü adı |
| Meteor Swarm | Meteor Yağmuru | büyü adı |
| Mind Blank | Zihin Perdesi | büyü adı |
| Mind Spike | Zihin Dikeni | büyü adı |
| Mirage Arcane | Arkana Serabı | büyü adı |
| Mirror Image | Ayna Görüntüleri | büyü adı |
| Mislead | Yanılt | büyü adı |
| Modify Memory | Hafızayı Değiştir | büyü adı |
| Moonbeam | Ay Işını | büyü adı |
| Move Earth | Toprağı Oynat | büyü adı |
| Nondetection | Algılanmazlık | büyü adı |
| Passwall | Duvardan Geçiş | büyü adı |
| Pass without Trace | İz Bırakmadan Geçiş | büyü adı |
| Phantasmal Force | Kuruntu Kuvveti | büyü adı |
| Phantasmal Killer | Kuruntu Katili | büyü adı |
| Phantom Steed | Hayalet Binek | büyü adı |
| Planar Ally | Düzlemsel Müttefik | büyü adı |
| Planar Binding | Düzlemsel Bağlama | büyü adı |
| Plane Shift | Düzlem Geçişi | büyü adı |
| Plant Growth | Bitki Büyümesi | büyü adı |
| Poison Spray | Zehir Püskürtme | büyü adı |
| Power Word Heal | Kudret Sözü: Şifa | büyü adı |
| Power Word Kill | Kudret Sözü: Ölüm | büyü adı |
| Power Word Stun | Kudret Sözü: Sersemletme | büyü adı |
| Prayer of Healing | Şifa Duası | büyü adı |
| Prismatic Spray | Prizmatik Saçılım | büyü adı |
| Prismatic Wall | Prizmatik Duvar | büyü adı |
| Private Sanctum | Özel Mabet | büyü adı |
| Produce Flame | Alev Çıkar | büyü adı |
| Programmed Illusion | Programlı İllüzyon | büyü adı |
| Project Image | Görüntü Yansıt | büyü adı |
| Protection from Energy | Enerjiye Karşı Koruma | büyü adı |
| Protection from Evil and Good | İyi ve Kötüye Karşı Koruma | büyü adı |
| Protection from Poison | Zehre Karşı Koruma | büyü adı |
| Purify Food and Drink | Yiyecek ve İçeceği Arındır | büyü adı |
| Raise Dead | Ölüyü Dirilt | büyü adı |
| Ray of Enfeeblement | Zayıflık Işını | büyü adı |
| Regenerate | Yenilenme | büyü adı |
| Ray of Sickness | Hastalık Işını | büyü adı |
| Reincarnate | Reenkarnasyon | büyü adı |
| Remove Curse | Laneti Kaldır | büyü adı |
| Resilient Sphere | Sarsılmaz Küre | büyü adı |
| Resistance | Direnç Büyüsü | büyü adı |
| Resurrection | Diriliş | büyü adı |
| Reverse Gravity | Ters Yer Çekimi | büyü adı |
| Rope Trick | İp Numarası | büyü adı |
| Sanctuary | Sığınak | büyü adı |
| Scrying | Uzaktan Gözetleme | büyü adı |
| Searing Smite | Dağlayan Darbe | büyü adı |
| Secret Chest | Gizli Sandık | büyü adı |
| See Invisibility | Görünmezi Gör | büyü adı |
| Seeming | Sahte Görünüm | büyü adı |
| Sending | Haber Gönder | büyü adı |
| Sequester | Tecrit | büyü adı |
| Shapechange | Başkalaşım | büyü adı |
| Shatter | Paramparça | büyü adı |
| Shield of Faith | İnanç Kalkanı | büyü adı |
| Shillelagh | Druid Sopası | büyü adı |
| Shining Smite | Parlayan Darbe | büyü adı |
| Silence | Sessizlik | büyü adı |
| Silent Image | Sessiz Görüntü | büyü adı |
| Simulacrum | Suret | büyü adı |
| Sleet Storm | Sulu Kar Fırtınası | büyü adı |
| Slow | Yavaşlatma Büyüsü | büyü adı |
| Sorcerous Burst | Sihir Patlaması | büyü adı |
| Spare the Dying | Can Çekişeni Kurtar | büyü adı |
| Speak with Animals | Hayvanlarla Konuş | büyü adı |
| Speak with Dead | Ölülerle Konuş | büyü adı |
| Speak with Plants | Bitkilerle Konuş | büyü adı |
| Spider Climb | Örümcek Tırmanışı | büyü adı |
| Spike Growth | Diken Büyümesi | büyü adı |
| Starry Wisp | Yıldız Kıvılcımı | büyü adı |
| Stinking Cloud | Kokuşmuş Bulut | büyü adı |
| Stone Shape | Taşa Biçim Ver | büyü adı |
| Stoneskin | Taş Deri | büyü adı |
| Storm of Vengeance | İntikam Fırtınası | büyü adı |
| Summon Dragon | Ejderha Celp Et | büyü adı |
| Sunbeam | Güneş Işını | büyü adı |
| Sunburst | Güneş Patlaması | büyü adı |
| Symbol | Sembol | büyü adı |
| Telekinesis | Telekinezi | büyü adı |
| Telepathic Bond | Telepatik Bağ | büyü adı |
| Teleport | Işınlan | büyü adı |
| Teleportation Circle | Işınlanma Çemberi | büyü adı |
| Time Stop | Zamanı Durdur | büyü adı |
| Tiny Hut | Minik Kulübe | büyü adı |
| Tongues | Diller | büyü adı |
| Transport via Plants | Bitkilerle Yolculuk | büyü adı |
| Tree Stride | Ağaçtan Ağaca | büyü adı |
| True Polymorph | Gerçek Biçim Değiştir | büyü adı |
| True Resurrection | Gerçek Diriliş | büyü adı |
| True Seeing | Gerçeği Görme | büyü adı |
| True Strike | Kesin Vuruş | büyü adı |
| Tsunami | Tsunami | büyü adı |
| Unseen Servant | Görünmez Hizmetkâr | büyü adı |
| Vampiric Touch | Vampir Dokunuşu | büyü adı |
| Vitriolic Sphere | Kezzap Küresi | büyü adı |
| Wall of Fire | Ateş Duvarı | büyü adı |
| Wall of Force | Kuvvet Duvarı | büyü adı |
| Wall of Ice | Buz Duvarı | büyü adı |
| Wall of Stone | Taş Duvar | büyü adı |
| Wall of Thorns | Diken Duvarı | büyü adı |
| Warding Bond | Koruma Bağı | büyü adı |
| Water Breathing | Suda Nefes Alma | büyü adı |
| Water Walk | Su Üstünde Yürüme | büyü adı |
| Weird | Dehşet | büyü adı |
| Wind Walk | Rüzgâr Yürüyüşü | büyü adı |
| Wind Wall | Rüzgâr Duvarı | büyü adı |
| Wish | Dilek | büyü adı |
| Word of Recall | Dönüş Sözü | büyü adı |
| Zone of Truth | Doğruluk Bölgesi | büyü adı |
| Rhythm of Play | Oyunun Ritmi | bölüm |
| Ability Scores | Yetenek Puanları | bölüm |
| Ability Modifiers | Yetenek Değiştiricileri | bölüm |
| Ability Checks | Yetenek Testleri | bölüm |
| Ability Modifier | Yetenek Değiştiricisi | bölüm |
| Saving Throws | Kurtarma Zarları | bölüm |
| Attack Rolls | Saldırı Zarları | bölüm |
| Rolling 20 or 1 | 20 veya 1 Atma | bölüm |
| Advantage/Disadvantage | Avantaj/Dezavantaj | bölüm |
| Roll Two D20s | İki D20 At | bölüm |
| They Don’t Stack | Birikmezler | bölüm |
| Interactions with Rerolls | Yeniden Atışlarla Etkileşim | bölüm |
| The Bonus Doesn’t Stack | Bonus Birikmez | bölüm |
| Skill Proficiencies | Beceri Yetkinlikleri | bölüm |
| Skill List | Beceri Listesi | bölüm |
| Determining Skills | Beceriyi Belirleme | bölüm |
| Saving Throw Proficiencies | Kurtarma Zarı Yetkinlikleri | bölüm |
| Equipment Proficiencies | Ekipman Yetkinlikleri | bölüm |
| One Thing at a Time | Bir Seferde Tek İş | bölüm |
| Bonus Actions | Bonus Eylemler | bölüm |
| Reactions | Reaksiyonlar | bölüm |
| Roleplaying | Rol Yapma | bölüm |
| Adventuring Equipment | Macera Ekipmanı | bölüm |
| Vision and Light | Görüş ve Işık | bölüm |
| Obscured Areas | Örtülü Alanlar | bölüm |
| Special Senses | Özel Duyular | bölüm |
| Hiding | Saklanma | bölüm |
| Interacting with Objects | Nesnelerle Etkileşim | bölüm |
| What Is an Object? | Nesne Nedir? | bölüm |
| Time-Limited Object Interactions | Süre Sınırlı Nesne Etkileşimleri | bölüm |
| Finding Hidden Objects | Gizli Nesneleri Bulma | bölüm |
| Carrying Objects | Nesne Taşıma | bölüm |
| Breaking Objects | Nesneleri Kırma | bölüm |
| Hazards | Tehlikeler | bölüm |
| Travel | Yolculuk | bölüm |
| Travel Pace | Yolculuk Temposu | bölüm |
| Vehicles | Taşıtlar | bölüm |
| The Order of Combat | Savaşın Düzeni | bölüm |
| Combat Step by Step | Adım Adım Savaş | bölüm |
| Your Turn | Senin Sıran | bölüm |
| Ending Combat | Savaşı Bitirme | bölüm |
| Movement and Position | Hareket ve Konum | bölüm |
| Breaking Up Your Move | Hareketini Bölme | bölüm |
| Dropping Prone | Yerde Durumuna Geçme | bölüm |
| Creature Size | Yaratık Boyutu | bölüm |
| Moving around Other Creatures | Diğer Yaratıkların Çevresinde Hareket | bölüm |
| Making an Attack | Saldırı Yapma | bölüm |
| Ranged Attacks | Menzilli Saldırılar | bölüm |
| Ranged Attacks in Close Combat | Yakın Dövüşte Menzilli Saldırılar | bölüm |
| Melee Attacks | Yakın Dövüş Saldırıları | bölüm |
| Opportunity Attacks | Fırsat Saldırıları | bölüm |
| Mounted Combat | Binekli Savaş | bölüm |
| Mounting and Dismounting | Bineğe Binme ve İnme | bölüm |
| Controlling a Mount | Bineği Yönetme | bölüm |
| Falling Off | Binekten Düşme | bölüm |
| Underwater Combat | Su Altında Savaş | bölüm |
| Impeded Weapons | Engellenen Silahlar | bölüm |
| Fire Resistance | Ateş Direnci | bölüm |
| Damage Rolls | Hasar Zarları | bölüm |
| Critical Hits | Kritik Vuruşlar | bölüm |
| Saving Throws and Damage | Kurtarma Zarları ve Hasar | bölüm |
| Damage against Multiple Targets | Birden Fazla Hedefe Hasar | bölüm |
| Half Damage | Yarım Hasar | bölüm |
| Damage Types | Hasar Türleri | bölüm |
| Resistance and Vulnerability | Direnç ve Zafiyet | bölüm |
| No Stacking | Birikme Yok | bölüm |
| Order of Application | Uygulama Sırası | bölüm |
| Dropping to 0 Hit Points | 0 Can Puanına Düşme | bölüm |
| Instant Death | Anında Ölüm | bölüm |
| Character Demise | Karakterin Ölümü | bölüm |
| Falling Unconscious | Bilinçsiz Kalma | bölüm |
| Death Saving Throws | Ölüm Kurtarma Zarları | bölüm |
| Stabilizing a Character | Karakteri Stabil Hâle Getirme | bölüm |
| Lose Temporary Hit Points First | Önce Geçici Can Puanı Kaybedilir | bölüm |
| They’re Not Hit Points or Healing | Can Puanı veya İyileşme Değildir | bölüm |
| Choose a Character Sheet | Karakter Kâğıdı Seç | bölüm |
| Step 1: Choose Class | 1. Adım: Sınıf Seç | bölüm |
| Write Your Level | Seviyeni Yaz | bölüm |
| Note Armor Training | Zırh Eğitimini Not Et | bölüm |
| Step 2: Character Origin | 2. Adım: Karakter Kökeni | bölüm |
| Choose a Background | Geçmiş Seç | bölüm |
| Choose Starting Equipment | Başlangıç Ekipmanını Seç | bölüm |
| Choose a Species | Soy Seç | bölüm |
| Imagine Your Past and Present | Geçmişini ve Bugününü Hayal Et | bölüm |
| Choose Languages | Dilleri Seç | bölüm |
| Step 3: Ability Scores | 3. Adım: Yetenek Puanları | bölüm |
| Generate Your Scores | Puanlarını Belirle | bölüm |
| Assign Ability Scores | Yetenek Puanlarını Ata | bölüm |
| Adjust Ability Scores | Yetenek Puanlarını Ayarla | bölüm |
| Determine Ability Modifiers | Yetenek Değiştiricilerini Belirle | bölüm |
| Step 4: Alignment | 4. Adım: Yönelim | bölüm |
| The Nine Alignments | Dokuz Yönelim | bölüm |
| Step 5: Character Creation Details | 5. Adım: Karakter Oluşturma Ayrıntıları | bölüm |
| Record Class Features | Sınıf Özelliklerini Kaydet | bölüm |
| Fill In Numbers | Sayıları Doldur | bölüm |
| Gaining a Level | Seviye Kazanma | bölüm |
| Tiers of Play | Oyun Kademeleri | bölüm |
| Tier 1 (Levels 1–4) | 1. Kademe (1–4. Seviyeler) | bölüm |
| Tier 2 (Levels 5–10) | 2. Kademe (5–10. Seviyeler) | bölüm |
| Tier 3 (Levels 11–16) | 3. Kademe (11–16. Seviyeler) | bölüm |
| Tier 4 (Levels 17–20) | 4. Kademe (17–20. Seviyeler) | bölüm |
| Starting at Higher Levels | Daha Yüksek Seviyelerde Başlama | bölüm |
| Creating Your Character | Karakterini Oluşturma | bölüm |
| Starting Equipment | Başlangıç Ekipmanı | bölüm |
| Prerequisites | Ön Koşullar | bölüm |
| Hit Points and Hit Point Dice | Can Puanı ve Can Zarı | bölüm |
| Proficiencies | Yetkinlikler | bölüm |
| Class Features | Sınıf Özellikleri | bölüm |
| Extra Attack | Ekstra Saldırı | bölüm |
| Trinkets | Biblolar | bölüm |
| Good Roads | İyi Yollar | bölüm |
| Slower Travelers | Daha Yavaş Yolcular | bölüm |
| Extended Travel | Uzun Yolculuk | bölüm |
| Special Movement | Özel Hareket | bölüm |
| Creating a Background | Geçmiş Oluşturma | bölüm |
| 1: Choose Abilities | 1. Yetenekleri Seç | bölüm |
| 2: Choose a Feat | 2. Hüner Seç | bölüm |
| 3: Choose Skill Proficiencies | 3. Beceri Yetkinliklerini Seç | bölüm |
| 4: Choose a Tool Proficiency | 4. Alet Yetkinliği Seç | bölüm |
| 5: Choose Equipment | 5. Ekipman Seç | bölüm |
| Curses and Magical Contagions | Lanetler ve Büyülü Salgınlar | bölüm |
| Curses | Lanetler | bölüm |
| Cursed Creatures | Lanetli Yaratıklar | bölüm |
| Cursed Magic Items | Lanetli Büyülü Eşyalar | bölüm |
| Narrative Curses | Anlatısal Lanetler | bölüm |
| Environmental Curses | Çevresel Lanetler | bölüm |
| Magical Contagions | Büyülü Salgınlar | bölüm |
| Rest and Recuperation | Dinlenme ve Toparlanma | bölüm |
| Example Contagions | Örnek Salgınlar | bölüm |
| Cackle Fever | Kahkaha Humması | bölüm |
| Sewer Plague | Lağım Vebası | bölüm |
| Sight Rot | Göz Çürüğü | bölüm |
| Environmental Effects | Çevresel Etkiler | bölüm |
| Deep Water | Derin Su | bölüm |
| Extreme Cold | Aşırı Soğuk | bölüm |
| Extreme Heat | Aşırı Sıcak | bölüm |
| Frigid Water | Buz Gibi Su | bölüm |
| Heavy Precipitation | Yoğun Yağış | bölüm |
| High Altitude | Yüksek İrtifa | bölüm |
| Slippery Ice | Kaygan Buz | bölüm |
| Strong Wind | Kuvvetli Rüzgâr | bölüm |
| Thin Ice | İnce Buz | bölüm |
| Fear and Mental Stress | Korku ve Zihinsel Stres | bölüm |
| Fear Effects | Korku Etkileri | bölüm |
| Mental Stress Effects | Zihinsel Stres Etkileri | bölüm |
| Prolonged Effects | Uzun Süreli Etkiler | bölüm |
| Purchasing Poison | Zehir Satın Alma | bölüm |
| Harvesting Poison | Zehir Toplama | bölüm |
| Sample Poisons | Örnek Zehirler | bölüm |
| Assassin’s Blood (150 GP) | Suikastçı Kanı (150 altın) | bölüm |
| Burnt Othur Fumes (500 GP) | Yanık Othur Dumanı (500 altın) | bölüm |
| Crawler Mucus (200 GP) | Sürüngen Mukusu (200 altın) | bölüm |
| Essence of Ether (300 GP) | Eter Özü (300 altın) | bölüm |
| Malice (250 GP) | Kin (250 altın) | bölüm |
| Midnight Tears (1,500 GP) | Gece Yarısı Gözyaşları (1.500 altın) | bölüm |
| Oil of Taggit (400 GP) | Taggit Yağı (400 altın) | bölüm |
| Pale Tincture (250 GP) | Solgun Tentür (250 altın) | bölüm |
| Purple Worm Poison (2,000 GP) | Mor Solucan Zehri (2.000 altın) | bölüm |
| Serpent Venom (200 GP) | Yılan Zehri (200 altın) | bölüm |
| Spider’s Sting (200 GP) | Örümcek İğnesi (200 altın) | bölüm |
| Torpor (600 GP) | Uyuşukluk (600 altın) | bölüm |
| Truth Serum (150 GP) | Doğruluk Serumu (150 altın) | bölüm |
| Wyvern Poison (1,200 GP) | Wyvern Zehri (1.200 altın) | bölüm |
| Traps | Tuzaklar | bölüm |
| Parts of a Trap | Tuzağın Parçaları | bölüm |
| Example Traps | Örnek Tuzaklar | bölüm |
| Collapsing Roof | Çöken Tavan | bölüm |
| Falling Net | Düşen Ağ | bölüm |
| Fire-Casting Statue | Ateş Saçan Heykel | bölüm |
| Hidden Pit | Gizli Çukur | bölüm |
| Poisoned Darts | Zehirli Dartlar | bölüm |
| Poisoned Needle | Zehirli İğne | bölüm |
| Rolling Stone | Yuvarlanan Kaya | bölüm |
| Spiked Pit | Kazıklı Çukur | bölüm |
| Combat Encounter Difficulty | Savaş Karşılaşması Zorluğu | bölüm |
| Step 1: Choose a Difficulty | 1. Adım: Zorluk Seç | bölüm |
| Step 2: Determine Your XP Budget | 2. Adım: TP Bütçeni Belirle | bölüm |
| Step 3: Spend Your Budget | 3. Adım: Bütçeni Harca | bölüm |
| Troubleshooting | Sorun Giderme | bölüm |
| Many Creatures | Çok Sayıda Yaratık | bölüm |
| Adjustments | Ayarlamalar | bölüm |
| CR 0 Creatures | TD 0 Yaratıklar | bölüm |
| Number of Stat Blocks | İstatistik Bloğu Sayısı | bölüm |
| Powerful Creatures | Güçlü Yaratıklar | bölüm |
| Unusual Features | Sıra Dışı Özellikler | bölüm |
| Magic Item Categories | Büyülü Eşya Kategorileri | bölüm |
| Potions | İksirler | bölüm |
| Rings | Yüzükler | bölüm |
| Rods | Çubuklar | bölüm |
| Scrolls | Parşömenler | bölüm |
| Staffs | Asalar | bölüm |
| Wands | Değnekler | bölüm |
| Wondrous Items | Harikulade Eşyalar | bölüm |
| Magic Item Rarity | Büyülü Eşya Nadirliği | bölüm |
| Magic Item Values by Rarity | Nadirliğe Göre Büyülü Eşya Değerleri | bölüm |
| Activating a Magic Item | Büyülü Eşyayı Etkinleştirme | bölüm |
| Command Word | Komut Sözcüğü | bölüm |
| Consumable Items | Tüketilebilir Eşyalar | bölüm |
| Spells Cast from Items | Eşyalardan Yapılan Büyüler | bölüm |
| Charges | Yükler | bölüm |
| “The Next Dawn” | “Sonraki Şafak” | bölüm |
| Cursed Items | Lanetli Eşyalar | bölüm |
| Magic Item Resilience | Büyülü Eşya Sağlamlığı | bölüm |
| Crafting Magic Items | Büyülü Eşya Yapımı | bölüm |
| Arcana Proficiency | Arkana Yetkinliği | bölüm |
| Tools | Aletler | bölüm |
| Time and Cost | Süre ve Maliyet | bölüm |
| Sentient Magic Items | Bilinçli Büyülü Eşyalar | bölüm |
| Sentient Magic Item Traits | Bilinçli Büyülü Eşya Özellikleri | bölüm |
| Abilities | Yetenekler | bölüm |
| Communication | İletişim | bölüm |
| Senses | Duyular | bölüm |
| Special Purpose | Özel Amaç | bölüm |
| Conflict | Çatışma | bölüm |
| Marching Order | Yürüyüş Düzeni | bölüm |
| Playing on a Grid | Izgara Üzerinde Oynama | bölüm |
| Unseen Attackers and Targets | Görülmeyen Saldırganlar ve Hedefler | bölüm |
| Resting | Dinlenme | bölüm |
| Knocking Out a Creature | Bir Yaratığı Bayıltma | bölüm |
| Unaligned Creatures | Yönelimsiz Yaratıklar | bölüm |
| Bonus Feats at Level 20 | 20. Seviyede Bonus Hünerler | bölüm |
| Breaking Your Oath | Yemini Bozma | bölüm |
| Expanding and Replacing a Spellbook | Büyü Kitabını Genişletme ve Yenileme | bölüm |
| Magic Item Rules | Büyülü Eşya Kuralları | bölüm |
| Selling Equipment | Ekipman Satma | bölüm |
| Coins | Sikkeler | bölüm |
| Coin Values | Sikke Değerleri | bölüm |
| Weapon Proficiency | Silah Yetkinliği | bölüm |
| Properties | Özellikler | bölüm |
| Improvised Weapons | Doğaçlama Silahlar | bölüm |
| Mastery Properties | Ustalık Özellikleri | bölüm |
| Light, Medium, or Heavy Armor | Hafif, Orta veya Ağır Zırh | bölüm |
| One at a Time | Bir Seferde Bir Tane | bölüm |
| Tool Proficiency | Alet Yetkinliği | bölüm |
| Other Tools | Diğer Aletler | bölüm |
| Adventuring Gear | Macera Ekipmanı | bölüm |
| Mounts and Vehicles | Binekler ve Taşıtlar | bölüm |
| Mounts and Cargo | Binekler ve Yük | bölüm |
| Barding | Binek Zırhı | bölüm |
| Saddles | Eyerler | bölüm |
| Large Vehicles | Büyük Taşıtlar | bölüm |
| Crew | Mürettebat | bölüm |
| Passengers | Yolcular | bölüm |
| Ship Repair | Gemi Onarımı | bölüm |
| Lifestyle Expenses | Yaşam Tarzı Giderleri | bölüm |
| Wretched (Free) | Sefil (Ücretsiz) | bölüm |
| Squalid (1 SP per Day) | Perişan (Günde 1 gümüş) | bölüm |
| Poor (2 SP per Day) | Yoksul (Günde 2 gümüş) | bölüm |
| Modest (1 GP per Day) | Mütevazı (Günde 1 altın) | bölüm |
| Comfortable (2 GP per Day) | Rahat (Günde 2 altın) | bölüm |
| Wealthy (4 GP per Day) | Varlıklı (Günde 4 altın) | bölüm |
| Aristocratic (10 GP per Day) | Aristokrat (Günde 10 altın) | bölüm |
| Food, Drink, and Lodging | Yiyecek, İçecek ve Konaklama | bölüm |
| Hirelings | Kiralık Yardımcılar | bölüm |
| Spellcasting Services | Büyü Yapma Hizmetleri | bölüm |
| Identifying a Magic Item | Büyülü Eşyayı Tanımlama | bölüm |
| Attune during a Short Rest | Kısa Dinlenme Sırasında Uyumlanma | bölüm |
| No More Than Three Items | En Fazla Üç Eşya | bölüm |
| Ending Attunement | Uyumlanmayı Sonlandırma | bölüm |
| Wearing and Wielding Items | Eşyaları Giyme ve Kuşanma | bölüm |
| Multiple Items of the Same Kind | Aynı Türden Birden Fazla Eşya | bölüm |
| Paired Items | Çift Eşyalar | bölüm |
| Crafting Nonmagical Items | Büyülü Olmayan Eşya Yapımı | bölüm |
| Raw Materials | Ham Maddeler | bölüm |
| Time | Süre | bölüm |
| Brewing Potions of Healing | Şifa İksiri Demleme | bölüm |
| Scribing Spell Scrolls | Büyü Parşömeni Yazma | bölüm |
| Spell Scroll Costs | Büyü Parşömeni Maliyetleri | bölüm |
| Prerequisites for the Scribe | Yazıcı İçin Ön Koşullar | bölüm |
| Cantrips | Cantrip'ler | bölüm |
| Casting in Armor | Zırhla Büyü Yapma | bölüm |
| Gaining Spells | Büyü Edinme | bölüm |
| Preparing Spells | Büyü Hazırlama | bölüm |
| Spell Preparation by Class | Sınıfa Göre Büyü Hazırlama | bölüm |
| Always-Prepared Spells | Her Zaman Hazırlanmış Büyüler | bölüm |
| Spell Level | Büyü Seviyesi | bölüm |
| Spell Slots | Büyü Slotları | bölüm |
| Casting without Slots | Slot Harcamadan Büyü Yapma | bölüm |
| Schools of Magic | Büyü Okulları | bölüm |
| Class Spell Lists | Sınıf Büyü Listeleri | bölüm |
| One Spell with a Spell Slot per Turn | Her Sırada Büyü Slotuyla Tek Büyü | bölüm |
| Reaction and Bonus Action Triggers | Reaksiyon ve Bonus Eylem Tetikleyicileri | bölüm |
| Longer Casting Times | Daha Uzun Yapma Süreleri | bölüm |
| Verbal (V) | Sözlü (S) | bölüm |
| Somatic (S) | Bedensel (B) | bölüm |
| Material (M) | Malzeme (M) | bölüm |
| Identifying an Ongoing Spell | Süren Bir Büyüyü Tanımlama | bölüm |
| Effects | Etkiler | bölüm |
| Targets | Hedefler | bölüm |
| Combining Spell Effects | Büyü Etkilerini Birleştirme | bölüm |

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

# Sözlük incelemesi

> Üretildi: `python -m gmcebi_pipeline.report` — elle düzenleme; değişiklikleri `pipeline/glossary.csv`'ye yap.

Çekirdek terim: **887** — topluluk: 116, öneri: 728, tartışmalı: 43. Ayrıca 339 pilot büyü adı ve 25 bölüm adı (en altta).

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

### Eşya

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 529 | Attunement | **Uyumlanma** | öneri | ✔ |  |  |  |
| 530 | Magic Item | **Büyülü Eşya** | öneri | ✔ |  |  |  |

### Para

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 531 | Copper Piece | **bakır** | tartışmalı | ✔ | BP | Kısaltma yerine kelime: '5 CP' → '5 bakır'. İngilizce kısaltmalar (GP=gold) Türkçe okumada yanıltıcı. |  |
| 532 | Silver Piece | **gümüş** | tartışmalı | ✔ |  | '1 SP' → '1 gümüş'. |  |
| 533 | Electrum Piece | **elektrum** | tartışmalı | ✔ |  | '1 EP' → '1 elektrum'. |  |
| 534 | Gold Piece | **altın** | tartışmalı | ✔ | AP, GP | '50 GP' → '50 altın'. |  |
| 535 | Platinum Piece | **platin** | tartışmalı | ✔ |  | '10 PP' → '10 platin'. |  |

### Birim

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 536 | feet | **fit** | tartışmalı | ✔ | ft | Sayılar değişmez (QC). 30 feet → 30 fit. Metrik gösterim ileride uygulama ayarı olabilir. "5 fitlik" kabul edilir; "ayak" (vücut) normal kelime olarak serbest. |  |
| 537 | mile | **mil** | öneri | ✔ |  |  |  |
| 538 | pound (lb.) | **lb** | öneri |  | libre | Ağırlık birimi kısaltması korunur. |  |

### Canavar adı

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 539 | Aboleth | **Aboleth** | öneri |  |  |  |  |
| 540 | Air Elemental | **Hava Elementali** | öneri |  |  |  |  |
| 541 | Animated Armor | **Canlanmış Zırh** | öneri |  |  |  |  |
| 542 | Animated Flying Sword | **Canlanmış Uçan Kılıç** | öneri |  |  |  |  |
| 543 | Animated Rug of Smothering | **Canlanmış Boğucu Halı** | öneri |  |  |  |  |
| 544 | Ankheg | **Ankheg** | öneri |  |  |  |  |
| 545 | Assassin | **Suikastçı** | öneri |  |  |  |  |
| 546 | Awakened Shrub | **Uyanmış Çalı** | öneri |  |  |  |  |
| 547 | Awakened Tree | **Uyanmış Ağaç** | öneri |  |  |  |  |
| 548 | Axe Beak | **Balta Gagalı** | öneri |  |  |  |  |
| 549 | Azer Sentinel | **Azer Nöbetçisi** | öneri |  |  |  |  |
| 550 | Balor | **Balor** | öneri |  |  | Demon (iblis türü) adı korunmuştur. |  |
| 551 | Bandit | **Haydut** | öneri |  |  |  |  |
| 552 | Bandit Captain | **Haydut Reisi** | öneri |  |  | Captain bağlama göre: Reis (haydut), Kaptan (korsan), Komutan (muhafız, hobgoblin). |  |
| 553 | Barbed Devil | **Dikenli Şeytan** | öneri |  |  | Devil = Şeytan. |  |
| 554 | Basilisk | **Basilisk** | öneri |  |  |  |  |
| 555 | Bearded Devil | **Sakallı Şeytan** | öneri |  |  |  |  |
| 556 | Behir | **Behir** | öneri |  |  |  |  |
| 557 | Berserker | **Gözü Dönmüş** | öneri |  |  | Path of the Berserker = Gözü Dönmüş Yolu ile uyumlu. |  |
| 558 | Black Dragon Wyrmling | **Yavru Kara Ejderha** | öneri |  |  | Kalıp: [Yaş] [Renk] Ejderha; Wyrmling = Yavru. |  |
| 559 | Young Black Dragon | **Genç Kara Ejderha** | öneri |  |  |  |  |
| 560 | Adult Black Dragon | **Yetişkin Kara Ejderha** | öneri |  |  |  |  |
| 561 | Ancient Black Dragon | **Kadim Kara Ejderha** | öneri |  |  |  |  |
| 562 | Black Pudding | **Kara Puding** | öneri |  |  |  |  |
| 563 | Blink Dog | **Işınlanan Köpek** | öneri |  |  |  |  |
| 564 | Blue Dragon Wyrmling | **Yavru Mavi Ejderha** | öneri |  |  |  |  |
| 565 | Young Blue Dragon | **Genç Mavi Ejderha** | öneri |  |  |  |  |
| 566 | Adult Blue Dragon | **Yetişkin Mavi Ejderha** | öneri |  |  |  |  |
| 567 | Ancient Blue Dragon | **Kadim Mavi Ejderha** | öneri |  |  |  |  |
| 568 | Bone Devil | **Kemik Şeytanı** | öneri |  |  |  |  |
| 569 | Brass Dragon Wyrmling | **Yavru Pirinç Ejderha** | öneri |  |  |  |  |
| 570 | Young Brass Dragon | **Genç Pirinç Ejderha** | öneri |  |  |  |  |
| 571 | Adult Brass Dragon | **Yetişkin Pirinç Ejderha** | öneri |  |  |  |  |
| 572 | Ancient Brass Dragon | **Kadim Pirinç Ejderha** | öneri |  |  |  |  |
| 573 | Bronze Dragon Wyrmling | **Yavru Bronz Ejderha** | öneri |  |  |  |  |
| 574 | Young Bronze Dragon | **Genç Bronz Ejderha** | öneri |  |  |  |  |
| 575 | Adult Bronze Dragon | **Yetişkin Bronz Ejderha** | öneri |  |  |  |  |
| 576 | Ancient Bronze Dragon | **Kadim Bronz Ejderha** | öneri |  |  |  |  |
| 577 | Bugbear Stalker | **Bugbear Pusucusu** | öneri |  |  |  |  |
| 578 | Bugbear Warrior | **Bugbear Savaşçısı** | öneri |  |  | Warrior = "X Savaşçısı" kalıbı. |  |
| 579 | Bulette | **Bulette** | öneri |  |  |  |  |
| 580 | Centaur Trooper | **Sentor Askeri** | öneri |  |  |  |  |
| 581 | Chain Devil | **Zincir Şeytanı** | öneri |  |  |  |  |
| 582 | Chimera | **Kimera** | öneri |  |  |  |  |
| 583 | Chuul | **Chuul** | öneri |  |  |  |  |
| 584 | Clay Golem | **Kil Golemi** | öneri |  |  |  |  |
| 585 | Cloaker | **Pelerinimsi** | öneri |  |  |  |  |
| 586 | Cloud Giant | **Bulut Devi** | öneri |  |  |  |  |
| 587 | Cockatrice | **Kokatris** | öneri |  |  |  |  |
| 588 | Commoner | **Halktan Biri** | öneri |  |  |  |  |
| 589 | Copper Dragon Wyrmling | **Yavru Bakır Ejderha** | öneri |  |  |  |  |
| 590 | Young Copper Dragon | **Genç Bakır Ejderha** | öneri |  |  |  |  |
| 591 | Adult Copper Dragon | **Yetişkin Bakır Ejderha** | öneri |  |  |  |  |
| 592 | Ancient Copper Dragon | **Kadim Bakır Ejderha** | öneri |  |  |  |  |
| 593 | Couatl | **Couatl** | öneri |  |  |  |  |
| 594 | Swarm of Crawling Claws | **Sürünen Pençe Sürüsü** | öneri |  |  |  |  |
| 595 | Cultist | **Tarikatçı** | öneri |  |  |  |  |
| 596 | Cultist Fanatic | **Fanatik Tarikatçı** | öneri |  |  |  |  |
| 597 | Darkmantle | **Kara Örtü** | öneri |  |  |  |  |
| 598 | Death Dog | **Ölüm Köpeği** | öneri |  |  |  |  |
| 599 | Deva | **Deva** | öneri |  |  |  |  |
| 600 | Djinni | **Cin** | öneri |  |  |  |  |
| 601 | Doppelganger | **Doppelganger** | öneri |  |  |  |  |
| 602 | Dragon Turtle | **Ejderha Kaplumbağası** | öneri |  |  |  |  |
| 603 | Dretch | **Dretch** | öneri |  |  |  |  |
| 604 | Drider | **Drider** | öneri |  |  |  |  |
| 605 | Druid | **Druid** | öneri |  |  | Sınıf adıyla aynı; NPC bir druid olduğu için bilinçli. |  |
| 606 | Dryad | **Driyad** | öneri |  |  |  |  |
| 607 | Earth Elemental | **Toprak Elementali** | öneri |  |  |  |  |
| 608 | Efreeti | **İfrit** | öneri |  |  |  |  |
| 609 | Erinyes | **Erinyes** | öneri |  |  |  |  |
| 610 | Ettercap | **Ettercap** | öneri |  |  |  |  |
| 611 | Ettin | **Ettin** | öneri |  |  |  |  |
| 612 | Fire Elemental | **Ateş Elementali** | öneri |  |  |  |  |
| 613 | Fire Giant | **Ateş Devi** | öneri |  |  |  |  |
| 614 | Flesh Golem | **Et Golemi** | öneri |  |  |  |  |
| 615 | Frost Giant | **Ayaz Devi** | öneri |  |  | Ray of Frost = Ayaz Işını ile uyumlu. |  |
| 616 | Shrieker Fungus | **Çığlıkçı Mantar** | öneri |  |  |  |  |
| 617 | Violet Fungus | **Eflatun Mantar** | öneri |  |  | Purple Worm (Mor Solucan) ile karışmasın diye Eflatun. |  |
| 618 | Gargoyle | **Gargoyl** | öneri |  |  |  |  |
| 619 | Gelatinous Cube | **Jelatinimsi Küp** | öneri |  |  |  |  |
| 620 | Ghast | **Kokuşmuş Gulyabani** | öneri |  |  | Ghoul = Gulyabani serisi. |  |
| 621 | Ghost | **Hayalet** | öneri |  |  |  |  |
| 622 | Ghoul | **Gulyabani** | öneri |  |  |  |  |
| 623 | Gibbering Mouther | **Geveleyen Ağız** | öneri |  |  |  |  |
| 624 | Glabrezu | **Glabrezu** | öneri |  |  |  |  |
| 625 | Gladiator | **Gladyatör** | öneri |  |  |  |  |
| 626 | Gnoll Warrior | **Gnoll Savaşçısı** | öneri |  |  |  |  |
| 627 | Goblin Minion | **Goblin Uşağı** | öneri |  |  |  |  |
| 628 | Goblin Warrior | **Goblin Savaşçısı** | öneri |  |  |  |  |
| 629 | Goblin Boss | **Goblin Elebaşı** | öneri |  |  | Boss = Elebaşı. |  |
| 630 | Gold Dragon Wyrmling | **Yavru Altın Ejderha** | öneri |  |  |  |  |
| 631 | Young Gold Dragon | **Genç Altın Ejderha** | öneri |  |  |  |  |
| 632 | Adult Gold Dragon | **Yetişkin Altın Ejderha** | öneri |  |  |  |  |
| 633 | Ancient Gold Dragon | **Kadim Altın Ejderha** | öneri |  |  |  |  |
| 634 | Gorgon | **Gorgon** | öneri |  |  |  |  |
| 635 | Gray Ooze | **Gri Balçık** | öneri |  |  |  |  |
| 636 | Green Dragon Wyrmling | **Yavru Yeşil Ejderha** | öneri |  |  |  |  |
| 637 | Young Green Dragon | **Genç Yeşil Ejderha** | öneri |  |  |  |  |
| 638 | Adult Green Dragon | **Yetişkin Yeşil Ejderha** | öneri |  |  |  |  |
| 639 | Ancient Green Dragon | **Kadim Yeşil Ejderha** | öneri |  |  |  |  |
| 640 | Green Hag | **Yeşil Cadı** | öneri |  |  | Hag = Cadı. |  |
| 641 | Grick | **Grik** | öneri |  |  |  |  |
| 642 | Griffon | **Grifon** | öneri |  |  |  |  |
| 643 | Grimlock | **Grimlock** | öneri |  |  |  |  |
| 644 | Guardian Naga | **Muhafız Naga** | öneri |  |  |  |  |
| 645 | Guard | **Muhafız** | öneri |  |  |  |  |
| 646 | Guard Captain | **Muhafız Komutanı** | öneri |  |  |  |  |
| 647 | Half-Dragon | **Yarı Ejderha** | öneri |  |  |  |  |
| 648 | Harpy | **Harpi** | öneri |  |  |  |  |
| 649 | Hell Hound | **Cehennem Tazısı** | öneri |  |  |  |  |
| 650 | Hezrou | **Hezrou** | öneri |  |  |  |  |
| 651 | Hill Giant | **Tepe Devi** | öneri |  |  |  |  |
| 652 | Hippogriff | **Hipogrif** | öneri |  |  |  |  |
| 653 | Hobgoblin Warrior | **Hobgoblin Savaşçısı** | öneri |  |  |  |  |
| 654 | Hobgoblin Captain | **Hobgoblin Komutanı** | öneri |  |  |  |  |
| 655 | Homunculus | **Homunkulus** | öneri |  |  |  |  |
| 656 | Horned Devil | **Boynuzlu Şeytan** | öneri |  |  |  |  |
| 657 | Hydra | **Hidra** | öneri |  |  |  |  |
| 658 | Ice Devil | **Buz Şeytanı** | öneri |  |  |  |  |
| 659 | Imp | **Şeytancık** | öneri |  |  |  |  |
| 660 | Incubus | **İnkübus** | öneri |  |  |  |  |
| 661 | Invisible Stalker | **Görünmez Takipçi** | öneri |  |  |  |  |
| 662 | Iron Golem | **Demir Golemi** | öneri |  |  |  |  |
| 663 | Knight | **Şövalye** | öneri |  |  |  |  |
| 664 | Kobold Warrior | **Kobold Savaşçısı** | öneri |  |  |  |  |
| 665 | Kraken | **Kraken** | öneri |  |  |  |  |
| 666 | Lamia | **Lamia** | öneri |  |  |  |  |
| 667 | Lemure | **Lemure** | öneri |  |  | Lemür (hayvan) ile karışmasın diye özgün yazım. |  |
| 668 | Lich | **Lich** | öneri |  |  |  |  |
| 669 | Mage | **Efsuncu** | öneri |  |  | Wizard = Büyücü, Sorcerer = Sihirbaz dolu olduğu için. |  |
| 670 | Archmage | **Ulu Efsuncu** | öneri |  |  |  |  |
| 671 | Magmin | **Magmin** | öneri |  |  |  |  |
| 672 | Manticore | **Mantikor** | öneri |  |  |  |  |
| 673 | Marilith | **Marilith** | öneri |  |  |  |  |
| 674 | Medusa | **Medusa** | öneri |  |  |  |  |
| 675 | Dust Mephit | **Toz Mefiti** | öneri |  |  |  |  |
| 676 | Ice Mephit | **Buz Mefiti** | öneri |  |  |  |  |
| 677 | Magma Mephit | **Magma Mefiti** | öneri |  |  |  |  |
| 678 | Steam Mephit | **Buhar Mefiti** | öneri |  |  |  |  |
| 679 | Merfolk Skirmisher | **Deniz Halkı Akıncısı** | öneri |  |  |  |  |
| 680 | Merrow | **Merrow** | öneri |  |  |  |  |
| 681 | Mimic | **Taklitçi** | öneri |  |  |  |  |
| 682 | Minotaur of Baphomet | **Baphomet Minotoru** | öneri |  |  |  |  |
| 683 | Mummy | **Mumya** | öneri |  |  |  |  |
| 684 | Mummy Lord | **Mumya Efendisi** | öneri |  |  |  |  |
| 685 | Nalfeshnee | **Nalfeshnee** | öneri |  |  |  |  |
| 686 | Night Hag | **Gece Cadısı** | öneri |  |  |  |  |
| 687 | Nightmare | **Kâbus** | öneri |  |  | Ateş saçan cehennem atı. |  |
| 688 | Noble | **Soylu** | öneri |  |  |  |  |
| 689 | Ochre Jelly | **Okra Jölesi** | öneri |  |  |  |  |
| 690 | Ogre | **Ogre** | öneri |  |  | Giant = Dev ile karışmasın diye. |  |
| 691 | Oni | **Oni** | öneri |  |  |  |  |
| 692 | Otyugh | **Otyugh** | öneri |  |  |  |  |
| 693 | Owlbear | **Baykuşayı** | öneri |  |  |  |  |
| 694 | Pegasus | **Pegasus** | öneri |  |  |  |  |
| 695 | Phase Spider | **Faz Örümceği** | öneri |  |  |  |  |
| 696 | Pirate | **Korsan** | öneri |  |  |  |  |
| 697 | Pirate Captain | **Korsan Kaptanı** | öneri |  |  |  |  |
| 698 | Pit Fiend | **Çukur İblisi** | öneri |  |  | Fiend = İblis; kendisi bir şeytan (devil). |  |
| 699 | Planetar | **Planetar** | öneri |  |  |  |  |
| 700 | Priest Acolyte | **Tapınak Çömezi** | öneri |  |  | Acolyte (geçmiş) = Mürit, Cleric = Rahip dolu olduğu için. |  |
| 701 | Priest | **Din Adamı** | öneri |  |  | Cleric = Rahip ile çakışmasın diye. |  |
| 702 | Pseudodragon | **Sözde Ejderha** | öneri |  |  |  |  |
| 703 | Purple Worm | **Mor Solucan** | öneri |  |  |  |  |
| 704 | Quasit | **Quasit** | öneri |  |  |  |  |
| 705 | Rakshasa | **Rakşasa** | öneri |  |  |  |  |
| 706 | Red Dragon Wyrmling | **Yavru Kırmızı Ejderha** | öneri |  |  |  |  |
| 707 | Young Red Dragon | **Genç Kırmızı Ejderha** | öneri |  |  |  |  |
| 708 | Adult Red Dragon | **Yetişkin Kırmızı Ejderha** | öneri |  |  |  |  |
| 709 | Ancient Red Dragon | **Kadim Kırmızı Ejderha** | öneri |  |  |  |  |
| 710 | Remorhaz | **Remorhaz** | öneri |  |  |  |  |
| 711 | Roc | **Rok** | öneri |  |  |  |  |
| 712 | Roper | **Kementçi** | öneri |  |  |  |  |
| 713 | Rust Monster | **Pas Canavarı** | öneri |  |  |  |  |
| 714 | Sahuagin Warrior | **Sahuagin Savaşçısı** | öneri |  |  |  |  |
| 715 | Salamander | **Semender** | öneri |  |  |  |  |
| 716 | Satyr | **Satir** | öneri |  |  |  |  |
| 717 | Scout | **İzci** | öneri |  |  |  |  |
| 718 | Sea Hag | **Deniz Cadısı** | öneri |  |  |  |  |
| 719 | Shadow | **Gölge** | öneri |  |  |  |  |
| 720 | Shambling Mound | **Yürüyen Höyük** | öneri |  |  |  |  |
| 721 | Shield Guardian | **Kalkan Muhafızı** | öneri |  |  |  |  |
| 722 | Silver Dragon Wyrmling | **Yavru Gümüş Ejderha** | öneri |  |  |  |  |
| 723 | Young Silver Dragon | **Genç Gümüş Ejderha** | öneri |  |  |  |  |
| 724 | Adult Silver Dragon | **Yetişkin Gümüş Ejderha** | öneri |  |  |  |  |
| 725 | Ancient Silver Dragon | **Kadim Gümüş Ejderha** | öneri |  |  |  |  |
| 726 | Skeleton | **İskelet** | öneri |  |  |  |  |
| 727 | Warhorse Skeleton | **Savaş Atı İskeleti** | öneri |  |  |  |  |
| 728 | Minotaur Skeleton | **Minotor İskeleti** | öneri |  |  |  |  |
| 729 | Solar | **Solar** | öneri |  |  |  |  |
| 730 | Specter | **Tayf** | öneri |  |  | Ghost = Hayalet, Specter = Tayf, Wraith = Karaltı, Shadow = Gölge. |  |
| 731 | Sphinx of Wonder | **Mucize Sfenksi** | öneri |  |  |  |  |
| 732 | Sphinx of Lore | **İrfan Sfenksi** | öneri |  |  | College of Lore = İrfan Okulu ile uyumlu. |  |
| 733 | Sphinx of Valor | **Yiğitlik Sfenksi** | öneri |  |  |  |  |
| 734 | Spirit Naga | **Ruh Naga** | öneri |  |  |  |  |
| 735 | Sprite | **Kanatlı Peri** | öneri |  |  |  |  |
| 736 | Spy | **Casus** | öneri |  |  |  |  |
| 737 | Stirge | **Stirge** | öneri |  |  |  |  |
| 738 | Stone Giant | **Taş Devi** | öneri |  |  |  |  |
| 739 | Stone Golem | **Taş Golemi** | öneri |  |  |  |  |
| 740 | Storm Giant | **Fırtına Devi** | öneri |  |  |  |  |
| 741 | Succubus | **Sukübus** | öneri |  |  |  |  |
| 742 | Tarrasque | **Tarrasque** | öneri |  |  |  |  |
| 743 | Tough | **Kabadayı** | öneri |  |  |  |  |
| 744 | Tough Boss | **Kabadayı Elebaşı** | öneri |  |  |  |  |
| 745 | Treant | **Ağaçadam** | öneri |  |  |  |  |
| 746 | Troll | **Trol** | öneri |  |  |  |  |
| 747 | Troll Limb | **Trol Uzvu** | öneri |  |  |  |  |
| 748 | Unicorn | **Tek Boynuzlu At** | öneri |  |  |  |  |
| 749 | Vampire Familiar | **Vampir Hizmetkârı** | öneri |  |  |  |  |
| 750 | Vampire Spawn | **Vampir Yavrusu** | öneri |  |  |  |  |
| 751 | Vampire | **Vampir** | öneri |  |  |  |  |
| 752 | Vrock | **Vrock** | öneri |  |  |  |  |
| 753 | Warrior Infantry | **Piyade Savaşçı** | öneri |  |  |  |  |
| 754 | Warrior Veteran | **Kıdemli Savaşçı** | öneri |  |  |  |  |
| 755 | Water Elemental | **Su Elementali** | öneri |  |  |  |  |
| 756 | Werebear | **Ayı Adam** | öneri |  |  |  |  |
| 757 | Wereboar | **Yaban Domuzu Adam** | öneri |  |  |  |  |
| 758 | Wererat | **Sıçan Adam** | öneri |  |  |  |  |
| 759 | Weretiger | **Kaplan Adam** | öneri |  |  |  |  |
| 760 | Werewolf | **Kurt Adam** | öneri |  |  |  |  |
| 761 | White Dragon Wyrmling | **Yavru Beyaz Ejderha** | öneri |  |  |  |  |
| 762 | Young White Dragon | **Genç Beyaz Ejderha** | öneri |  |  |  |  |
| 763 | Adult White Dragon | **Yetişkin Beyaz Ejderha** | öneri |  |  |  |  |
| 764 | Ancient White Dragon | **Kadim Beyaz Ejderha** | öneri |  |  |  |  |
| 765 | Wight | **Wight** | öneri |  |  | Alternatif: Höyük Hortlağı (Undead = Hortlak ile karışmasın diye kullanılmadı). |  |
| 766 | Will-o’-Wisp | **Bataklık Feneri** | öneri |  |  | Halk adı "cinfeneri"; Djinni = Cin ile karışmasın diye. |  |
| 767 | Winter Wolf | **Kış Kurdu** | öneri |  |  |  |  |
| 768 | Worg | **Worg** | öneri |  |  |  |  |
| 769 | Wraith | **Karaltı** | öneri |  |  |  |  |
| 770 | Wyvern | **Wyvern** | öneri |  |  |  |  |
| 771 | Xorn | **Xorn** | öneri |  |  |  |  |
| 772 | Zombie | **Zombi** | öneri |  |  |  |  |
| 773 | Ogre Zombie | **Ogre Zombisi** | öneri |  |  |  |  |
| 774 | Allosaurus | **Allosaurus** | öneri |  |  |  |  |
| 775 | Ankylosaurus | **Ankylosaurus** | öneri |  |  |  |  |
| 776 | Ape | **Maymun** | öneri |  |  |  |  |
| 777 | Archelon | **Archelon** | öneri |  |  |  |  |
| 778 | Baboon | **Babun** | öneri |  |  |  |  |
| 779 | Badger | **Porsuk** | öneri |  |  |  |  |
| 780 | Bat | **Yarasa** | öneri |  |  |  |  |
| 781 | Black Bear | **Kara Ayı** | öneri |  |  |  |  |
| 782 | Blood Hawk | **Kan Şahini** | öneri |  |  |  |  |
| 783 | Boar | **Yaban Domuzu** | öneri |  |  |  |  |
| 784 | Brown Bear | **Boz Ayı** | öneri |  |  |  |  |
| 785 | Camel | **Deve** | öneri |  |  |  |  |
| 786 | Cat | **Kedi** | öneri |  |  |  |  |
| 787 | Constrictor Snake | **Boğucu Yılan** | öneri |  |  |  |  |
| 788 | Crab | **Yengeç** | öneri |  |  |  |  |
| 789 | Crocodile | **Timsah** | öneri |  |  |  |  |
| 790 | Deer | **Geyik** | öneri |  |  |  |  |
| 791 | Dire Wolf | **Ulu Kurt** | öneri |  |  |  |  |
| 792 | Draft Horse | **Koşum Atı** | öneri |  |  |  |  |
| 793 | Eagle | **Kartal** | öneri |  |  |  |  |
| 794 | Elephant | **Fil** | öneri |  |  |  |  |
| 795 | Elk | **Kızıl Geyik** | öneri |  |  |  |  |
| 796 | Flying Snake | **Uçan Yılan** | öneri |  |  |  |  |
| 797 | Frog | **Kurbağa** | öneri |  |  |  |  |
| 798 | Giant Ape | **Dev Maymun** | öneri |  |  |  |  |
| 799 | Giant Badger | **Dev Porsuk** | öneri |  |  |  |  |
| 800 | Giant Bat | **Dev Yarasa** | öneri |  |  |  |  |
| 801 | Giant Boar | **Dev Yaban Domuzu** | öneri |  |  |  |  |
| 802 | Giant Centipede | **Dev Kırkayak** | öneri |  |  |  |  |
| 803 | Giant Constrictor Snake | **Dev Boğucu Yılan** | öneri |  |  |  |  |
| 804 | Giant Crab | **Dev Yengeç** | öneri |  |  |  |  |
| 805 | Giant Crocodile | **Dev Timsah** | öneri |  |  |  |  |
| 806 | Giant Eagle | **Dev Kartal** | öneri |  |  |  |  |
| 807 | Giant Elk | **Dev Kızıl Geyik** | öneri |  |  |  |  |
| 808 | Giant Fire Beetle | **Dev Ateş Böceği** | öneri |  |  |  |  |
| 809 | Giant Frog | **Dev Kurbağa** | öneri |  |  |  |  |
| 810 | Giant Goat | **Dev Keçi** | öneri |  |  |  |  |
| 811 | Giant Hyena | **Dev Sırtlan** | öneri |  |  |  |  |
| 812 | Giant Lizard | **Dev Kertenkele** | öneri |  |  |  |  |
| 813 | Giant Octopus | **Dev Ahtapot** | öneri |  |  |  |  |
| 814 | Giant Owl | **Dev Baykuş** | öneri |  |  |  |  |
| 815 | Giant Rat | **Dev Sıçan** | öneri |  |  |  |  |
| 816 | Giant Scorpion | **Dev Akrep** | öneri |  |  |  |  |
| 817 | Giant Seahorse | **Dev Denizatı** | öneri |  |  |  |  |
| 818 | Giant Shark | **Dev Köpekbalığı** | öneri |  |  |  |  |
| 819 | Giant Spider | **Dev Örümcek** | öneri |  |  |  |  |
| 820 | Giant Toad | **Dev Karakurbağası** | öneri |  |  |  |  |
| 821 | Giant Venomous Snake | **Dev Zehirli Yılan** | öneri |  |  |  |  |
| 822 | Giant Vulture | **Dev Akbaba** | öneri |  |  |  |  |
| 823 | Giant Wasp | **Dev Eşekarısı** | öneri |  |  |  |  |
| 824 | Giant Weasel | **Dev Gelincik** | öneri |  |  |  |  |
| 825 | Giant Wolf Spider | **Dev Kurt Örümceği** | öneri |  |  |  |  |
| 826 | Goat | **Keçi** | öneri |  |  |  |  |
| 827 | Hawk | **Şahin** | öneri |  |  |  |  |
| 828 | Hippopotamus | **Su Aygırı** | öneri |  |  |  |  |
| 829 | Hunter Shark | **Avcı Köpekbalığı** | öneri |  |  |  |  |
| 830 | Hyena | **Sırtlan** | öneri |  |  |  |  |
| 831 | Jackal | **Çakal** | öneri |  |  |  |  |
| 832 | Killer Whale | **Katil Balina** | öneri |  |  |  |  |
| 833 | Lion | **Aslan** | öneri |  |  |  |  |
| 834 | Lizard | **Kertenkele** | öneri |  |  |  |  |
| 835 | Mammoth | **Mamut** | öneri |  |  |  |  |
| 836 | Mastiff | **Mastif** | öneri |  |  |  |  |
| 837 | Mule | **Katır** | öneri |  |  |  |  |
| 838 | Octopus | **Ahtapot** | öneri |  |  |  |  |
| 839 | Owl | **Baykuş** | öneri |  |  |  |  |
| 840 | Panther | **Panter** | öneri |  |  |  |  |
| 841 | Piranha | **Pirana** | öneri |  |  |  |  |
| 842 | Plesiosaurus | **Plesiosaurus** | öneri |  |  |  |  |
| 843 | Polar Bear | **Kutup Ayısı** | öneri |  |  |  |  |
| 844 | Pony | **Midilli** | öneri |  |  |  |  |
| 845 | Pteranodon | **Pteranodon** | öneri |  |  |  |  |
| 846 | Rat | **Sıçan** | öneri |  |  |  |  |
| 847 | Raven | **Kuzgun** | öneri |  |  |  |  |
| 848 | Reef Shark | **Resif Köpekbalığı** | öneri |  |  |  |  |
| 849 | Rhinoceros | **Gergedan** | öneri |  |  |  |  |
| 850 | Riding Horse | **Binek Atı** | öneri |  |  |  |  |
| 851 | Saber-Toothed Tiger | **Kılıç Dişli Kaplan** | öneri |  |  |  |  |
| 852 | Scorpion | **Akrep** | öneri |  |  |  |  |
| 853 | Seahorse | **Denizatı** | öneri |  |  |  |  |
| 854 | Spider | **Örümcek** | öneri |  |  |  |  |
| 855 | Swarm of Bats | **Yarasa Sürüsü** | öneri |  |  |  |  |
| 856 | Swarm of Insects | **Böcek Sürüsü** | öneri |  |  |  |  |
| 857 | Swarm of Piranhas | **Pirana Sürüsü** | öneri |  |  |  |  |
| 858 | Swarm of Rats | **Sıçan Sürüsü** | öneri |  |  |  |  |
| 859 | Swarm of Ravens | **Kuzgun Sürüsü** | öneri |  |  |  |  |
| 860 | Swarm of Venomous Snakes | **Zehirli Yılan Sürüsü** | öneri |  |  |  |  |
| 861 | Tiger | **Kaplan** | öneri |  |  |  |  |
| 862 | Triceratops | **Triceratops** | öneri |  |  |  |  |
| 863 | Tyrannosaurus Rex | **Tyrannosaurus Rex** | öneri |  |  |  |  |
| 864 | Venomous Snake | **Zehirli Yılan** | öneri |  |  |  |  |
| 865 | Vulture | **Akbaba** | öneri |  |  |  |  |
| 866 | Warhorse | **Savaş Atı** | öneri |  |  |  |  |
| 867 | Weasel | **Gelincik** | öneri |  |  |  |  |
| 868 | Wolf | **Kurt** | öneri |  |  |  |  |

### Dil

| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |
|---|---|---|---|---|---|---|---|
| 869 | Common | **Ortak Dil** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 870 | Common Sign Language | **Ortak İşaret Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 871 | Draconic | **Ejderce** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 872 | Dwarvish | **Cücece** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 873 | Elvish | **Elfçe** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 874 | Giant | **Devce** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 875 | Gnomish | **Gnomca** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 876 | Goblin | **Goblince** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 877 | Halfling | **Buçuklukça** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 878 | Orc | **Orkça** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 879 | Abyssal | **Abis Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 880 | Celestial | **Göksel Dil** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 881 | Deep Speech | **Derin Dil** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 882 | Infernal | **Cehennem Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 883 | Primordial | **İlkel Dil** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 884 | Sylvan | **Sylvan Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 885 | Undercommon | **Yeraltı Ortak Dili** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 886 | Druidic | **Druidce** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |
| 887 | Thieves’ Cant | **Hırsız Argosu** | öneri |  |  | Dil adı; canavar kartlarındaki Diller satırı ve metin içi. |  |

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

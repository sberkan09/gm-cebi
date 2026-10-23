# Türkçe metin kuralları

Uygulamadaki her Türkçe metin bu kurallara uyar. Kod: `lib/core/turkish.dart`,
testler: `test/core/turkish_test.dart`.

## 1. Büyük/küçük harf

Dart'ın `toLowerCase()` / `toUpperCase()` işlevleri dilden bağımsızdır:
`'I'.toLowerCase()` → `i` verir, Türkçede doğrusu `ı`'dır. Bu yüzden:

| Yapma | Yap |
|---|---|
| `s.toLowerCase()` | `trLower(s)` — I → ı, İ → i |
| `s.toUpperCase()` | `trUpper(s)` — i → İ, ı → I |
| `s[0].toUpperCase() + …` | `trCapitalize(s)` — "istatistik" → "İstatistik" |

Kural terimleri kaynakta büyük harfle yazılmışsa Türkçede de büyük harfle
başlar (Avantaj, Can Puanı, Yerde); küçükse küçük kalır (kurtarma zarı). Bu,
veri hattının kalite denetimiyle de zorlanır.

## 2. Arama

Arama anahtarı `trFold()`: önce Türkçe küçük harf, sonra şapka ve
noktalar kaldırılır (ç→c, ğ→g, ı→i, ö→o, ş→s, ü→u, â→a, î→i, û→u). Böylece
"cuce", "CÜCE" ve "Cüce" aynı kaydı bulur; İngilizce "Initiative" da
"inisiyatif" gibi `i` ile katlanır. Sorguda hiçbir sonuç yoksa her kelimenin
sonundan 1–3 harf kırpılarak yeniden denenir ("körlük" → "kör"); bu sonuçlar
"yakın eşleşmeler" diye işaretlenir.

## 3. Sıralama (collation)

Listeler Türk alfabesine göre sıralanır (`trCompare`):

    a b c ç d e f g ğ h ı i j k l m n o ö p (q) r s ş t u ü v (w x) y z

- Önce büyük/küçük harf duyarsız karşılaştırılır, eşitlikte küçük harf önce gelir.
- â, î, û düz ünlüyle (a, i, u) birlikte sıralanır.
- Rakamlar harflerden önce gelir.
- Türk alfabesinde olmayan q, w, x en yakın harflerin arasına yerleşir.

## 4. Ekler

Türkçede ekler son hecedeki ünlüye ve son sese göre değişir. Basit kurallar
`withCase`, `plural`, `possessive3` içinde:

| Kural | Örnek |
|---|---|
| İki yönlü ünlü uyumu (a/e) | büyü**ler**, kural**lar** |
| Dört yönlü ünlü uyumu (ı/i/u/ü) | Goblin'**i**, Kurt'**u**, 100'**ü** |
| Ünlüyle biten köke kaynaştırma (y, n, s) | masa**ya**, kale**nin**, Zarı**sı** |
| Sert ünsüzden sonra d → t ("fıstıkçı şahap") | Ork'**ta**, 5'**ten** |
| Özel ad, sayı, kısaltmaya kesme işareti | Goblin'e, ZD 15'lik, ZS'si |
| Sayıya gelen ek okunuşa göre seçilir | 15'**e** (on beş), 40'**a** (kırk), 6'**da** (altı) |
| Sayıdan sonra çoğul yok | **3 goblin**, ~~3 goblinler~~ (`countNoun`) |
| Sıra sayısı noktayla | **3. tur**, 2. Seviye |
| Tamlama (3. tekil iyelik) | Oluşturma Cantrip'**i**, Kalkan**ı** |

Bilinçli sınırlar (gerekirse metni elle yaz):

- Ünsüz yumuşaması (kitap → kitab**ı**, ağaç → ağac**ı**) uygulanmaz. Kesme
  işaretli özel adlarda zaten yumuşama olmaz.
- Ünlü uyumuna uymayan kelimeler (saat → saat**e**, rol → rol**ü**) desteklenmez.
- Yabancı adlarda uyum yazılışa göre hesaplanır; okunuşu çok farklı olan
  adlarda (ör. sessiz harfle biten "Shield" /şild/) sonuç yazılışa göre çıkar.

## 5. Arayüz dili

- Hitap "sen"dir (kaynaktaki "you" gibi). Düğmeler kısa ve emir kipindedir: "Ekle", "AT", "Kaydet".
- Oyun terimleri yalnızca `pipeline/glossary.csv`'deki karşılıklarıyla yazılır (ZS, CP, ZD, TD, İnisiyatif…).
- Tarih: "21 Ekim 2026, 19:05" (ay adı Türkçe, 24 saat).
- Para: "50 altın", "1 gümüş"; uzunluk: "30 fit".
- Uygulama adında ve mağaza metinlerinde "D&D" / "Dungeons & Dragons" geçmez; "5e uyumlu" denir.

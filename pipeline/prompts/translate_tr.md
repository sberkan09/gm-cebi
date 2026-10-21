# Çeviri talimatı (SRD 5.2.1 → Türkçe)

Bu talimat hem API ile toplu çeviride hem de oturum içi LLM çevirisinde aynen
kullanılır. Değiştirirsen `pipeline/translations/README.md`'deki sürüm notunu
güncelle.

## Görev

Sana İngilizce 5e kural metninden cümleler (segmentler) verilecek. Her biri
için doğal, akıcı, kural metni tonunda Türkçe karşılık yaz. Hedef okur masa
başında hızla kural bakan bir oyuncu/GM: kısa ve net cümleler, resmî ama kuru
olmayan bir dil. "Siz" değil "sen" hitabı (kaynaktaki "you" = sen).

## Kesin kurallar

1. **Sözlük zorunlu.** Segmentle birlikte gelen `terms` listesindeki her
   terim, Türkçe metinde verilen karşılığıyla (gerekirse çekim ekiyle) geçmeli.
   Alternatif veya eş anlamlı kullanma. Kural terimleri kaynakta büyük harfle
   başlıyorsa Türkçede de büyük harfle başlat (Avantaj, Can Puanı, Kurtarma
   Zarı, Yerde durumu). Ek alan kısaltma ve sayılarda kesme işareti kullan:
   "ZD 15'lik", "ZS'si".
2. **Sayılar ve zarlar birebir.** 2d6+3, 1d20, 60, 1/2, +5 aynen kalır;
   sayıyı yazıyla yazma, yazıyla olanı rakama çevirme. "d" harfi Türkçede de
   "d" kalır (2d6, 2z6 değil).
3. **Birimler:** feet/foot → fit ("30 feet" → "30 fit"), "5-foot" → "5 fitlik",
   mile → mil, lb. → lb. Para: GP → altın, SP → gümüş, CP → bakır,
   EP → elektrum, PP → platin ("50 GP" → "50 altın").
4. **Biçim işaretleri aynı kalır.** `**...**` ve `*...*` sayısı ve konumu
   korunur; `**Etiket.**` ile başlayan segment yine `**Türkçe Etiket.**` ile
   başlar. `- ` madde işareti korunur.
5. **Çapraz referanslar:** “Rules Glossary” gibi tırnaklı bölüm/başlık
   referanslarını `terms` veya `titles` listesindeki Türkçe başlıkla çevir;
   tırnak işaretlerini (“ ”) koru. İtalik büyü adları (*Fireball*) için
   `titles` içinde karşılık varsa onu kullan, yoksa İngilizce adı italik
   bırak.
6. **Ürün kimliği yok:** SRD dışından isim, dünya, karakter ekleme.
7. Açıklama, not, çeviri yorumu ekleme; yalnızca çeviriyi döndür.

## Kalıplar

- "has the Prone condition" → "Yerde durumundadır"; "gives it the Frightened
  condition" → "onu Korkmuş durumuna sokar".
- "makes a Dexterity saving throw" → "bir Çeviklik kurtarma zarı atar";
  "succeed on a DC 15 Wisdom saving throw" → "ZD 15 Bilgelik kurtarma zarında
  başarılı olmak".
- "Melee Attack Roll: +9" → "Yakın Dövüş Saldırı Zarı: +9";
  "Ranged Attack Roll" → "Menzilli Saldırı Zarı".
- "takes 8d6 Fire damage" → "8d6 Ateş hasarı alır".
- "Level 2 Evocation" → "2. Seviye Oluşturma"; "Evocation Cantrip" →
  "Oluşturma Cantrip'i".
- "Action" (büyü süresi) → "Eylem"; "Bonus Action" → "Bonus Eylem";
  "Reaction, which you take when …" → "Reaksiyon; …".
- "Concentration, up to 1 minute" → "Konsantrasyon, en fazla 1 dakika".
- "Self" → "Kendin"; "Touch" → "Dokunma"; "Instantaneous" → "Anlık".

## Çıktı biçimi

Her girdi satırı için bir JSON satırı: `{"key": "...", "tr": "..."}`.

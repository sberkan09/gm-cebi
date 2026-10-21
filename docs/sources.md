# Kaynaklar

## Veri kaynağı (tek kaynak)

| | |
|---|---|
| Belge | System Reference Document 5.2.1 (SRD 5.2.1) |
| Yayımcı | Wizards of the Coast LLC |
| Lisans | Creative Commons Attribution 4.0 International (CC-BY-4.0) |
| Resmi dosya | https://media.dndbeyond.com/compendium-images/srd/5.2/SRD_CC_v5.2.1.pdf |
| SHA-256 | `8974902d109d6e63672d7c490bde9ccf052410503d9cfa768237154fbc5e3d87` |
| Boyut / sayfa | 6.031.375 bayt, 364 sayfa |
| İndirme tarihi | 2026-10-21 |

`pipeline/gmcebi_pipeline/fetch.py` dosyayı bu adresten indirir ve özeti doğrular;
özet tutmazsa hat durur. PDF depoya konmaz (`pipeline/raw/`, git dışı).

Lisans koşulu (PDF s. 1, "Legal Information"): eserde aşağıdaki atıf cümlesi
birebir yer almalı; Wizards'a başka bir atıf yapılmamalı; "5E compatible" ifadesi
kullanılabilir. Cümle README'de ve `assets/data/manifest.json`'da birebir duruyor;
Faz 1'de "Hakkında" ekranına da girecek.

> This work includes material from the System Reference Document 5.2.1 (“SRD 5.2.1”) by Wizards of the Coast LLC, available at https://www.dndbeyond.com/srd. The SRD 5.2.1 is licensed under the Creative Commons Attribution 4.0 International License, available at https://creativecommons.org/licenses/by/4.0/legalcode.

## Topluluk dönüşümleri (değerlendirildi, kullanılmadı)

Brief, mümkünse topluluğun CC-BY-4.0 markdown/JSON dönüşümlerini bulmayı istiyordu.
Bulunan adaylar ve neden kullanılmadıkları:

| Kaynak | Durum |
|---|---|
| github.com/downfallx/dnd-5e-srd-markdown | Erişilebilir (git). Sürümü ve lisansı doğrulanmadı; resmi PDF erişilebilir olduğu için gerek kalmadı. |
| github.com/acidRain-burns/OGL-SRD5 | Adından ve açıklamasından OGL/SRD 5.1 dönüşümü olduğu anlaşılıyor; SRD 5.2.1 değil. |
| EN World "editable 5.2.1 SRD" başlığı | Forum dosyası; resmi kaynak varken ara dönüşüme gerek yok. |
| mailbun.codeberg.page (SRD 5.5 mdbook) | Codeberg bu ortamdan erişilemedi (vekil 403). |

Karar: veri doğrudan resmi PDF'ten ayrıştırılıyor (bkz. `docs/decisions.md`). Böylece
her kaydın sayfa referansı resmi belgeye işaret ediyor ve üçüncü taraf dönüşüm
hatası ya da lisans belirsizliği taşınmıyor.

## Türkçe terim araştırması

Sözlük (`pipeline/glossary.csv`) için taranan topluluk kaynakları ve hangi terimin
nereden geldiği `docs/glossary-review.md` içindeki "Kaynaklar" tablosunda. Bu
kaynaklardan yalnızca tek tek terimler alındı; metin kopyalanmadı.

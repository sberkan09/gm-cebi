# Kararlar

Bir satır = bir karar. Biçim: `tarih — konu: karar (gerekçe)`. Geri alınamaz
kararlar (uygulama adı, paket adı, lisans metni) burada **ONAY BEKLİYOR**
olarak işaretlenir ve ürün sahibine sorulur.

## Faz 0 — veri

- 2026-10-21 — Veri kaynağı: resmi SRD 5.2.1 PDF'i doğrudan ayrıştırılır; topluluk markdown/JSON dönüşümleri kullanılmaz (resmi dosya erişilebilir, sayfa referansları doğrudan resmi belgeye işaret eder, ara dönüşümün hata ve lisans riski taşınmaz).
- 2026-10-21 — PDF depoya konmaz; `fetch.py` resmi adresten indirip SHA-256 ile doğrular (tekrarlanabilirlik, depo boyutu).
- 2026-10-21 — Ayrıştırma PyMuPDF ile yazı tipi/punto sınıflandırmasına dayanır (başlık düzeyleri, koşu başlıkları, tablolar); PDF'in içerik akışı okuma sırası olarak kullanılır, yanlış yere düşen başlıklı tablolar "X table" atfına göre sahibine taşınır.
- 2026-10-21 — Sayfa referansı PDF fiziksel sayfa numarasıdır (basılı numarayla aynı; PDF içindekiler tablosu bazı bölümlerde 1 sayfa geride, ona güvenilmez).
- 2026-10-21 — Kapsam: brief'teki 10 veri kümesi + `subclasses` ve `weapon_properties` ayrı dosyalar. Magic Items, Gameplay Toolbox ve "Playing the Game" bölümleri Faz 0'da ayrıştırılmadı (brief listesinde yok; Faz 1 öncesi eklenebilir).
- 2026-10-21 — Canavar aile başlıkları (ör. "Black Dragons") kayıt değil, `group` alanı; 330 istatistik bloğunun tamamı ayrı kayıt.
- 2026-10-21 — SRD 5.2.1'in kendi içinde geçen adlar (ör. Elf soyu "Drow") CC-BY kapsamındadır ve ürün kimliği sayılmaz; yasaklı liste (`license.py`) yalnızca SRD dışı adları içerir. "Sigil" (sıradan kelime olarak geçiyor) listeden çıkarıldı.
- 2026-10-21 — PDF'te işareti eksik basılmış tek değer (Young White Dragon, Int kurtarma "2") −2 olarak düzeltildi ve `_warnings.json`'a yazıldı.
- 2026-10-21 — Sözlük durumları: `topluluk` (topluluk kullanımı bulundu), `öneri` (bulunamadı, biz önerdik), `tartışmalı` (topluluk bölünmüş ya da seçimimiz en yaygın biçimden ayrılıyor).
- 2026-10-21 — Sözlük seçimleri: Strength = Güç (Force hasar türü Kuvvet olduğu için), DC = ZD (Zorluk Derecesi), CR = Tehlike Derecesi/TD (ZD ile çakışmasın), AC = ZS, HP = CP; Initiative = İnisiyatif (ürün sahibinin brief'indeki kullanım); Cantrip İngilizce kalır (topluluk alışkanlığı); Warlock = Sehhar (tartışmalı, tek yerleşik Türkçe biçim). Ayrıntı ve gerekçeler `docs/glossary-review.md`'de.
- 2026-10-21 — Para birimleri Türkçe metinde kısaltma yerine kelimeyle: 50 GP → 50 altın, 1 SP → 1 gümüş (İngilizce GP/SP kısaltmaları Türkçe okumada yanıltıcı). Uzunluk: feet → fit; sayılar asla dönüştürülmez.
- 2026-10-21 — Kural terimleri Türkçede de SRD gibi büyük harfle başlar (Avantaj, Can Puanı, Yerde) — oyuncu bir kelimenin kural terimi olduğunu görebilsin.
- 2026-10-21 — Sözlük eşleşmesi Türkçe çekim eklerine dayanıklı: çok kelimeli terimlerde son kelimenin tamlama eki düşürülür (Can Puanı → "can puan…"), sonda p/ç/t/k yumuşaması kabul edilir.
- 2026-10-21 — Çeviri birimi cümledir; çeviri belleği aynı İngilizce cümleyi bir kez çevirir. Kayıt adları veri kümesine göre ayrı anahtarlanır ("Shield" büyüsü ≠ "Shield" kalkanı).
- 2026-10-21 — Bu ortamda API anahtarı yok; pilot çeviri, hattın `queue → out → import` yolu üzerinden oturum içi Claude (claude-opus-5-5) alt ajanlarıyla yapıldı. Aynı talimat (`prompts/translate_tr.md`) API arka ucuyla (`translate api`) da kullanılır. Her segment `engine` alanında üreticisini taşır.
- 2026-10-21 — Pilot büyü adları (50) çeviriden önce sözlüğe "büyü adı" olarak eklendi; böylece paralel çevirmenler aynı adları kullanır ve italik büyü atıfları doğrulanabilir.
- 2026-10-21 — Asset biçimi: kayıt başına `en` ve tam `tr` kopyası + `tr_status`; çevrilmemiş alan İngilizce kalır (uygulama alan bazında geri düşer). Boyut bütçesi hat içinde denetlenir.
- 2026-10-21 — CI: `flutter` işinin adımları `pubspec.yaml` yokken atlanır (job düzeyinde `if` içinde hashFiles kullanılamıyor) (Faz 0'da uygulama yok). agentgate yalnızca gözlem modunda (`fail-on-conflict: false`, test eşlemesi yok, `runner = "command"`).
- 2026-10-21 — Python bağımlılıkları test edilen sürümlere sabitlendi (pymupdf 2.0, pydantic 2.13.5, pytest 9.1.1); CI Python 3.11.

## Onay bekleyenler

- **ONAY BEKLİYOR** — Atıf metni: SRD'nin zorunlu kıldığı İngilizce cümle README'ye ve `manifest.json`'a birebir kondu. Ek olarak Türkçe bir "değiştirilmiş eser" notu öneriliyor (CC-BY değişikliklerin belirtilmesini istiyor): "Türkçe metinler SRD 5.2.1'in çevirisidir ve orijinal metinden türetilmiş, değiştirilmiş bir çalışmadır." Mağaza ve "Hakkında" ekranına girmeden önce metnin onayı gerekiyor.
- **ONAY BEKLİYOR** — Uygulama adı "GM Cebi" ve paket adı Faz 1'de belirlenecek; henüz hiçbir yerde paket adı oluşturulmadı.

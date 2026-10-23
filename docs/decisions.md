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
- 2026-10-21 — Canavar aile başlıkları (ör. "Black Dragons") kayıt değil, `group` alanı; 330 istatistik bloğunun tamamı ayrı kayıt. Animals bölümündekilerin ailesi yok.
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

## Faz 0 inceleme düzeltmeleri (PR #2)

- 2026-10-21 — Sözlük eşleşmesi önek değil: kökten sonra yalnızca sıralı Türkçe çekim ekleri (çoğul → iyelik → hâl → -ki → şart+kişi → ek-fiil) kabul edilir. Anlam değiştiren türetmeler (-lı, -lık, -sız) dışarıda; doğal olanlar terim bazında `tr_pattern` ile açılır (Avantajlı/Dezavantajlı, 5 fitlik, Loş Işıklı).
- 2026-10-21 — Reddedilen alternatifler QC hatasıdır; başka bir terimin seçili karşılığı olan alternatif (Strength için "Kuvvet" = Force) ve terimin kendi parçası olan alternatif ("Can" ⊂ "Can Puanı") hariç. "Line" için "Hat", "feet" için "ayak" sıradan kelime olarak geçtiğinden alternatif listesinden çıkarıldı.
- 2026-10-21 — Büyük/küçük harf kaynağı izler (Advantage → Avantaj; saving throw → kurtarma zarı) ve QC'de denetlenir. Pilot belleğindeki 64 segment buna göre mekanik olarak düzeltildi (`engine = claude-opus-5-5+casefix`).
- 2026-10-21 — Türkçe binlik ayırıcı nokta (1.000); QC 1,000 ile 1.000'ı eşdeğer sayar.
- 2026-10-21 — Atıf eşlemesi ikiye ayrıldı: tırnaklı kural/bölüm atıfları ve italik büyü atıfları ayrı anahtarlı ("Shield" kalkanı ≠ *Shield* büyüsü).
- 2026-10-21 — Büyü adı çakışmaları giderildi: Prestidigitation = Hokkabazlık (El Çabukluğu becerisiyle çakışıyordu), Druidcraft = Druid Sanatı (Hüner = Feat ile çakışıyordu).
- 2026-10-21 — Sert QC bulgulu makine çevirileri asset'e girmez; Türkçe kayıt yalnızca adı çevrilmiş ve segmentlerinin en az %80'i çevrilmişse yayımlanır (kısmen İngilizce kayıtlar `none` kalır).
- 2026-10-21 — "Animals" bölümündeki 95 hayvan bir canavar ailesine bağlı değildir (`group = null`, başlık yolu `["Animals", ad]`).
- 2026-10-21 — Kural sözlüğündeki terim listeleri (alan şekilleri, eylemler, durumlar, yaratık türleri) madde işaretli bloklar olarak tutulur; soy özelliklerinin devam paragrafları ait oldukları özelliğe eklenir.
- 2026-10-21 — agentgate eylemi SHA'ya sabitlendi (`10b84ec`), Python 3.11; `pyproject.toml` bağımlılıkları `requirements.txt` ile aynı.

## Faz 1 — uygulama

- 2026-10-23 — Flutter 3.47.7 (Dart 3.13.5) stable; CI aynı sürüme sabit. Riverpod 3.4 (kod üretimsiz), drift 2.35 + drift_flutter; sqlite3 3.x yerel kütüphaneyi derleme kancasıyla getirir (sqlite3_flutter_libs artık gerekmiyor).
- 2026-10-23 — Referans verisi drift'e aktarılmaz: açılışta asset'lerden bir isolate içinde okunur ve bellekte arama dizini kurulur (önek ters dizini + ad içinde alt dize). Gerekçe: <100 ms arama, ilk açılışta içe aktarma yok, veri uygulama sürümüyle birlikte gelir. drift yalnızca kullanıcı verisi için: ayarlar, oturum notları, karşılaşmalar.
- 2026-10-23 — Arama tüm veri kümelerini (terimler dahil) tek kutuda, Türkçe ve İngilizce adlar + gövde metniyle tarar; sıralama ad eşleşmesine göre. Çevrilmemiş kayıtlar sözlükteki Türkçe adla da bulunur (Dagger ↔ Hançer). Sözlükte olup kaydı olmayan terimler "Terim" kartı olarak çıkar.
- 2026-10-23 — Arayüz tek dilli (Türkçe), metinler doğrudan widget'larda; gen-l10n kurulmadı. İçerik etiketleri (ZS, CP, Yapma Süresi…) gösterilen içeriğin diline uyar.
- 2026-10-23 — Tek elle kullanım: alt gezinme (Ara, Zar, İnisiyatif, Notlar), arama kutusu ekranın altında, ana eylem düğmeleri altta ve en az 56 dp.
- 2026-10-23 — Kayıt sayfasındaki TR/EN düğmesi yalnızca o sayfayı değiştirir; varsayılan dil Ayarlar'da.
- 2026-10-23 — Özellik bayrakları: `Feature` → `Entitlement` (ücretsiz / GM Paketi / ses aboneliği). Hak `--dart-define=GMCEBI_GM_PACK` ile gelir; `GMCEBI_INTERNAL` test sürümlerinde Ayarlar'a test anahtarı ekler. Satın alma kodu yok. NPC üretici ve ses özeti yalnızca bayrak olarak ayrıldı.
- 2026-10-23 — İnisiyatif: tek etkin karşılaşma; "Sonraki" ilk kez basılana kadar sıra imleci en üstte kalır (`started`), sonrasında yeni katılımcı eklense de aynı yaratıkta kalır. "Yeni karşılaşma" oyuncuları tam CP ile taşıyabilir.
- 2026-10-23 — Notlar 800 ms gecikmeyle ve ekrandan çıkarken kendiliğinden kaydedilir; boş not tutulmaz.
- 2026-10-23 — Zar dili: `NdM`, `kh/kl/dh/dl/k`, `+ - * /`, parantez, `d%`; Türk oyuncular için `z` de zar harfi (2z6). En çok 100 zar, 1000 yüz. `Random.secure()`.
- 2026-10-23 — İkon: kendi tasarımımız, mürekkep zemin üzerinde pirinç renkli genel bir yirmi yüzlü zar (`tool/make_icons.py`); bilinen bir markanın ikonografisi yok.
- 2026-10-23 — Android en az 8.0 (minSdk 26), iOS en az 15.0. Test APK'sı debug anahtarıyla imzalı; mağaza imzası ürün sahibinde.
- 2026-10-23 — Veri hattı yapısal değerleri (`type`: p/table) çevirmez; Türkçe kayıtların yapısı İngilizceyle aynı olmak zorunda (pytest). Uygulama `rows` taşıyan her bloğu tablo olarak çizer.
- 2026-10-23 — Yaklaşık arama (ek kırpma) yalnızca adlarda yapılır; gövde metninde kısa kökler gürültü üretiyordu.
- 2026-10-23 — Kısaltmalara gelen ekler harf okunuşuna göre (ZS'ye, NPC'ye); sıralamada boşluk ve noktalama harflerden önce (kelime kelime).
- 2026-10-23 — "Yeni karşılaşma" eskisini siler (katılımcılar zincirleme silinir); inisiyatif düzenleme yalnızca o sütunu yazar; mevcut yaratık sıranın sonundaysa ve çıkarılırsa sıra sonraki tura geçer.
- 2026-10-23 — Not editörü uygulama arka plana geçerken bekleyen metni hemen kaydeder.
- 2026-10-23 — Widget testleri drift'in sahte-zaman bölgesinde çalışır (`runAsync` drift bağlantı kilidinde kilitleniyor); testler uygulamanın tamamını bellek içi veritabanı ve gerçek asset'lerle açar.

## Onay bekleyenler

- **ONAY BEKLİYOR** — Atıf metni: SRD'nin zorunlu kıldığı İngilizce cümle README'ye, `manifest.json`'a ve Hakkında ekranına birebir kondu (onay gerektirmez, lisans şartı). Ek olarak Türkçe bir "değiştirilmiş eser" notu öneriliyor (CC-BY değişikliklerin belirtilmesini istiyor): "Türkçe metinler SRD 5.2.1'in çevirisidir ve orijinal metinden türetilmiş, değiştirilmiş bir çalışmadır. …" Test sürümünde Hakkında ekranında **öneri metni olarak** duruyor (`lib/app_info.dart`, `translationNotice`); mağaza sürümünden önce onaylanmalı ya da değiştirilmeli. SRD, Wizards'a bu atıf dışında başka bir atıf yapılmamasını istediği için "Wizards ile bağımız yoktur" gibi ek cümleler kullanılmıyor.
- **ONAY BEKLİYOR** — Uygulama adı: "GM Cebi" çalışma adı olarak kullanılıyor (`lib/app_info.dart`, Android etiketi, iOS `CFBundleDisplayName`).
- **ONAY BEKLİYOR** — Paket adı: şimdilik yer tutucu `com.example.gm_cebi` (Android) / `com.example.gmCebi` (iOS). Mağazaya ilk yüklemeden önce kesinleşmeli; değiştirilecek yerler `docs/ios-testflight.md`'de.

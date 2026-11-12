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
- 2026-10-23 — Özellik bayrakları: `Feature` → `Entitlement` (ücretsiz / GM Paketi / ses aboneliği). Hak `--dart-define=GMCEBI_GM_PACK` ile gelir; `GMCEBI_INTERNAL` test sürümlerinde Ayarlar'a test anahtarı ekler. Satın alma kodu yok. NPC üretici ve ses özeti yalnızca bayrak olarak ayrıldı (NPC üretici 2026-11-09'da yapıldı).
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

## Yayın hazırlığı (Play kapalı/açık test, TestFlight)

- 2026-11-06 — Sürüm `1.0.0+1`; `appVersion` ile pubspec'in uyumu testle denetlenir.
- 2026-11-06 — Mağaza derlemeleri (Play test kanalları, TestFlight): `GMCEBI_INTERNAL=false`, `GMCEBI_GM_PACK=true` (satın alma yok, test kullanıcıları GM Paketi'ni denemeli; test kanalındaki derleme üretime aynen terfi ettirilebildiği için test anahtarı hiçbir mağaza derlemesinde yok). Test APK'sı (GitHub ön-sürümü) değişmedi: ikisi de `true`.
- 2026-11-06 — Test anahtarının veritabanına yazdığı `gmPackOverride` yalnızca `GMCEBI_INTERNAL` derlemelerinde okunur (`resolveGmPack`). Önceden mağaza derlemesi de okuyordu; test derlemesinden güncellenen cihazda GM Paketi bedava açık kalabiliyordu.
- 2026-11-06 — Android imzası: Play App Signing + yükleme anahtarı. `android/key.properties` (git dışı) varsa release onunla, yoksa debug anahtarıyla imzalanır (yalnızca test APK'sı). CI keystore'u base64 secret'tan yazar ve iş sonunda siler.
- 2026-11-06 — `release-aab` iş akışı `v*` etiketinde (`v*-test*` hariç) test + imzalı AAB; imzalayanın yükleme anahtarı olduğu, test anahtarının derlemeden silindiği, İnternet izni ve `com.example` olmadığı `tool/check_store_build.sh` ile denetlenir. Play'e yükleme elle.
- 2026-11-06 — İkonlar için `flutter_launcher_icons` eklenmedi: `tool/make_icons.py` Android (legacy, adaptive, monochrome) ve iOS setinin tamamını zaten üretiyor. Play 512 px ikon ve öne çıkan görsel `tool/make_store_graphics.py` ile.
- 2026-11-06 — Mağaza ekran görüntüleri ayrı boyutlarda: Android 1080×1920 (Play en çok 2:1 oran kabul ediyor; mevcut 1290×2796 görüntüler 2,17), iOS 1320×2868 (6,9").
- 2026-11-06 — Mağaza metinleri çeviri kapsamını abartmaz (15 durum, 140 kural girdisi, 50 büyü); "D&D" geçmez, yalnızca "5e uyumlu"; SRD atıf cümlesi birebir (testle denetlenir).

## Savaş haritası ve kroki → sahne (2026-11-07)

- 2026-11-07 — Savaş haritası çevrimdışı ve GM Paketi'nde: inisiyatif ekranından açılır, karşılaşmaya aittir (yeni karşılaşma boş haritayla başlar). Çizgiler `map_strokes` tablosunda, jeton konumları `combatants.pos_x/pos_y`'de; koordinatlar 0–1 (telefon ve tablette aynı harita). Şema 2, geçiş testli.
- 2026-11-07 — Tek jest: jetonun üstünden başlayan sürükleme jetonu taşır, diğerleri çizer ya da siler; sürükleme parmağın değdiği yerden başlar (`DragStartBehavior.down`). Silgi hareketin tüm yolunu süpürür (hızlı hareket çizginin üstünden atlamasın).
- 2026-11-07 — Jetonlar inisiyatif sırasını, sıradakini, CP'yi ve düşenleri gösterir; sıra haritadan da ilerletilir. Palet anlamlıdır (mürekkep, su, bitki, tehlike); ileride prompt'a ipucu olabilir.
- 2026-11-07 — Kroki → sahne denemesi (`docs/spikes/sketch-to-scene/`): jetonlar modele gönderilmez, uygulama çizer; servise yalnızca arazi gider (`renderTerrainPng`, siyah mürekkep beyaz zemin, 512²). İki mod: düzeni koruyan "harita" (scribble + LCM) ve serbest "atmosfer" (20 adım). Servis tarafındaki iş: neuracraft-cloud #13 (alt issue'lar #14–#21).

- 2026-11-09 — İnceleme düzeltmeleri (PR #5): şema geçişi tek transaction içinde ve adım adım kontrollü (yarım kalan geçiş bir sonraki açılışta tamamlanır); geri al silgiyi ve "Çizimi temizle"yi de geri alır (ekran içi işlem yığını); çizgiler kimliğe göre bir kez ayrıştırılır; geniş ekranda harita solda tam yükseklik, kontroller sağda; araç çubuğu dar ekranda alt satıra kayar; renk düğmeleri 44 dp ve erişilebilirlik etiketli. Takipte: iOS kenar kaydırma hareketiyle çakışma, jeton boyutu / ızgaraya oturma, katmanlı çizim (RepaintBoundary).

## Çevrimiçi sahne (NeuraCraft Cloud, 2026-11-09)

- 2026-11-09 — Özellik isteğe bağlı ve derleme zamanında: yalnızca `NC_API_URL` verilen derlemelerde görünür (istemci kimliği 2026-11-10'dan beri kodda, aşağıda); verilmezse arayüzde iz yok ve Android manifestinde İnternet izni yok (`src/online/AndroidManifest.xml` yalnızca bu derlemelerde birleşir). Ayrıntı: `docs/online-scene.md`.
- 2026-11-09 — Onay verilmeden hiçbir istek gitmez (oturum bile açılmaz). Onay metni alt işleyiciyi (Anthropic, ABD) ve saklama sürelerini söyler.
- 2026-11-09 — Oturum harita açılınca açılır (GPU soğuksa ~75 sn, yedek veri merkezinde ~120 sn ısınır), heartbeat yalnızca ön planda; haritadan çıkınca 5 dk sonra kapanır (hemen geri dönen GM ısınmış GPU'yu kaybetmesin). `410`'da sessizce yenilenir; `401`'de özellik "güncelleme gerekiyor" ile kapanır.
- 2026-11-09 — Sonuç PNG'si drift'te karşılaşmaya bağlı saklanır (`map_scenes`, şema 3; sunucu 7 gün sonra siler). Bildirilen resim yerelde hemen gizlenir.
- 2026-11-09 — Resim indirmede 302 elle takip edilir: uygulama token'ı ve kurulum kimliği yalnızca NeuraCraft'a gider, depolama sağlayıcısına gitmez.
- 2026-11-09 — "Verilerimi sil" yerel verileri siler ve yeni kurulum kimliği üretir; sunucu tarafı silme `partner:manage` gerektirdiği ve GM Cebi'nin sunucusu olmadığı için "en geç 7 gün" açıklaması gösterilir.

## Çevrimiçi sahne: kullanıcı girişi (2026-11-10)

- 2026-11-10 — Uygulama token'ı (`nc_app_…`) ve `X-End-User` kurulum kimliği kaldırıldı; yerine e-postaya gelen 6 haneli kodla kullanıcı girişi geldi (neuracraft-cloud #48). Gerekçe: APK'deki token çıkarılabiliyordu, kurulum kimliği de istemcinin kendi beyanıydı. Her istek artık kullanıcının kısa ömürlü erişim token'ını (`nc_eu_…`, 1 saat) taşır. Ayrıntı: `docs/online-scene.md`, "Giriş".
- 2026-11-10 — İstemci kimliği (`nc_client_…`) herkese açıktır ve tek başına yetki vermez; GM Cebi'ninki (`nc_client_hZnpzu714IuIGtH2S5C26q8S`) kodda gömülüdür, `--dart-define=NC_CLIENT_ID` yalnızca başka bir sunucu için geçersiz kılar. Özellik `NC_API_URL` verilen derlemelerde görünür. `v*-test*` etiketleri ancak bu derlemeyle yeniden güvenli (APK'de token yok).
- 2026-11-10 — Token'lar `flutter_secure_storage` ile Keychain (`first_unlock_this_device`) / Android Keystore'da. Android yedeğinden ve cihaz aktarımından `sharedpref` alanı çıkarıldı (Keystore anahtarı taşınmadığı için geri yüklenen kayıt çözülemezdi); okunamayan kayıt "çıkış yapılmış" sayılır ve silinir. Kullanıcının yazdığı e-posta yalnızca Ayarlar'da göstermek için aynı kayıtta, cihazda kalır.
- 2026-11-10 — Yenileme tek uçuşlu: yenileme token'ı her kullanımda değişir ve iki kez kullanılırsa giriş biter. Aynı anda `401 auth.token_expired` alan istekler tek bir `POST /v1/auth/token`'ı bekler; istek bir kez tekrarlanır. Süresi dolmak üzere olan erişim token'ı istekten önce yenilenir. Ağ hatasında giriş korunur.
- 2026-11-10 — Giriş yalnızca özellik ilk kullanıldığında istenir ("Sahneyi canlandır" → onay → giriş → mod). Sunucu girişi bitirirse (`auth.refresh_invalid`, `auth.token_revoked`) oturum "kapalı" değil boşta kalır ve haritada "Oturumun sona erdi, tekrar giriş yap" çıkar; engellenen kullanıcı (`auth.end_user_blocked`) için özellik o çalıştırma boyunca kapalı. "Güncelleme gerekiyor" (`authInvalid`) artık yalnızca `auth.client_invalid`, `auth.end_user_token_required`, `auth.scope_missing`, `auth.required` için.
- 2026-11-10 — "Verilerimi sil" yerine "Hesabımı sil": `DELETE /v1/me` hesabı ve sunucudaki her şeyi hemen siler (mağazaların istediği uygulama içi hesap silme); ardından yerel resimler ve onay silinir. Çevrimdışıysa hesap kalır ve hata gösterilir. Giriş yapılmamışken yalnızca yerel "Uygulamadaki çevrimiçi resimleri sil" var. Bu, 2026-11-09'daki "en geç 7 gün" kararının yerini alır.

## Haritada alan katmanı (2026-11-10)

- 2026-11-10 — Alan katmanı (neuracraft-cloud #42): haritaya "Alan" fırçası eklendi; boyanan alanlar çizime karışmaz, harita modunda ikinci bir PNG (`inputs.regions`, 512×512, boyanmayan yer saydam, ≤ 512 KB) ve `params.ground` (grass varsayılan, stone, dirt, sand, snow) olarak gider. Scribble ControlNet yalnızca çizgi gördüğü için nehrin hangi tarafının su olduğunu bilemiyordu; img2img ile nehir mavi şerit oluyor (NeuraCraft denemesi, güç ~0,6).
- 2026-11-10 — Palet sözleşmedir, temaya göre değişmez: Su `#2060A0`, Yol `#8C6E48`, Orman `#285C28`, Taş zemin `#808080`, Duvar `#404040`, Kum `#D2B478`; dışa aktarımda opak, ekranda %45 saydam ve çizgilerin altında. Tür sırası veritabanında numara olarak saklanır, değişmez.
- 2026-11-10 — Katman yalnızca servis duyurduğunda gönderilir: `GET /v1/presets`'te `sketch_to_scene` şablonunun `inputs` listesinde `regions` (zemin için `params.ground`) varsa. Sunucu bilinmeyen girdiyi reddettiği ve tarafı henüz canlı olmadığı için; beklenmeyen biçim "desteklenmiyor" sayılır, cevap istemci başına saklanır (ağ hatası saklanmaz). Desteklenmiyorsa çizim bugünkü gibi tek başına gider, Zemin seçimi görünmez.
- 2026-11-10 — Saklama: yeni tablo yerine `map_strokes`'a boş olabilen `region` ve `width` sütunları (şema 5, geçiş testli; eski satırlar kalem çizgisi kalır). Geri al, silgi geri yükleme, temizleme ve karşılaşmayla silinme iki katmanda da aynı kodla çalışsın diye. "Sil" son seçilen aracın katmanını siler.

## Karşılaşma zorluğu (2026-11-09)

- 2026-11-09 — Zorluk SRD 5.2.1 "Combat Encounters" (s. 202) kuralıyla: karakter başına TP bütçesi (seviye × Düşük/Orta/Yüksek) karakterlerin toplamı; karşılaşma TP'si her canavarın normal TP'sinin toplamı (in lair değeri değil), çarpan yok. Karışık seviyeli grupta her karakter kendi satırından sayılır.
- 2026-11-09 — Bantlar: bütçe o zorlukta harcanabilecek en çok TP olduğu için Düşük bütçesine kadar "Düşük", Orta bütçesine kadar "Orta", Yüksek bütçesine kadar "Yüksek". SRD'de olmayan iki dış bant tablo dışı olduğunu belli eden adlarla: Yüksek bütçesini aşan "Yüksek üstü", Düşük bütçesinin yarısından az olan "Düşük altı" (yarı eşiği uygulamanın kendi kuralı, SRD'den değil). Çipte karşılaşma TP'si bandın üst bütçesine bölünmüş gösterilir.
- 2026-11-09 — Grup = karşılaşmadaki oyuncu karakterleri. Seviye `combatants.level`'da (boş olabilir; şema 4, geçiş testli); "Yeni karşılaşma" seviyeyi taşır. Seviyesi girilmemiş oyuncu ve oyuncusuz karşılaşma "Grup seviyesi" ayarını (varsayılan 1), oyuncusuz karşılaşma "Grup büyüklüğü" ayarını (varsayılan 4) kullanır; ikisi `settings` tablosunda. Ada göre ayarda saklamak kırılgan olduğu için sütun seçildi.
- 2026-11-09 — Canavar TP'si kayıttaki İngilizce `xp` metninden okunur (dilden bağımsız; adlara bakılmaz), eksikse TD'den. Elle eklenen ve canavar kaydı olmayan katılımcılar "TP bilinmiyor" olarak gösterilir, toplama katılmaz.

## NPC üretici (2026-11-09)

- 2026-11-09 — NPC tabloları (`lib/features/npc/npc_tables.dart`) tamamen özgün içeriktir: hiçbir yayımlanmış kitabın isim ya da özellik tablosu kopyalanmaz veya çevrilmez; ürün kimliği adları, dünya/mekân adları, tanrılar ve adı geçen karakterler kullanılmaz. Oyun içeriğinden yalnızca SRD 5.2.1 soy adları (sözlükteki Türkçeleriyle) ve Etkileme eyleminin tavırları (Dostça/Kayıtsız/Düşmanca) alınır. Yasaklı adlar ve en az liste boyları testle denetlenir.
- 2026-11-09 — NPC üretici GM Paketi'nde, Notlar ekranının üst çubuğundan açılır (yeni sekme yok; GM Paketi kilitliyken düğme görünmez). Üretim çevrimdışı ve zarla aynı `Random`'ı kullanır (testlerde tohumlu). Son 10 NPC, filtreler ve kilitler yalnızca oturum boyunca bellekte (ekrandan çıkıp dönünce durur); kalıcı olması istenen NPC "Nota kaydet" ile not olur, şema değişmez.
- 2026-11-09 — Kilitli ad soyu ve cinsiyeti de korur (ad soya uysun); bu sırada soy/cinsiyet filtreleri kapalıdır ve ekranda söylenir. Kilitli görünüş yeni soya uymuyorsa (Ejderdoğan'da saç, Elf'te kuyruk zili) yeniden üretilir; uyuyorsa korunur. Görünüş satırları her cinsiyete uyar; cüce sakal satırı da kadın cüceler için geçerlidir (bilinçli seçim).
- 2026-11-09 — Tutarlılık kuralları: iki karşıt özellik birlikte gelmez (`npcOppositeTraits`), lakap özellikle çelişmez ("Kurnaz" + "saf" yok, `npcEpithetClashes`), soyadı verilen adı tekrarlamaz ("Fındık Fındıkdibi" yok). Gerçek dinî topluluk çağrışımı yapan sözcükler ("tarikat") kullanılmaz.

## İnceleme düzeltmeleri (2026-11-12, #28–#30)

- 2026-11-12 — Tur sırası: sıra işareti katılımcıyı her yeniden sıralamada izler; o tur kimlerin oynadığı ayrıca tutulur (ayarlar tablosunda `initiativeActed`, şema değişmedi). "Sonraki" sıradaki henüz oynamamış ilk katılımcıya geçer, herkes oynadıysa yeni tur başlar; "Önceki" oynanan sıraları geri yürür. Sonuç: tur ortasında işaretin üstüne eklenen katılımcı o tur oynar. Eşit inisiyatifler `sortOrder` ile elle sıralanır.
- 2026-11-12 — "Yeni karşılaşma" neyin silineceğini söyler; "Haritayı tut" çizgileri, alanları ve en yeni bildirilmemiş resmi yeni karşılaşmaya taşır. Jetonlar sıfırlanır.
- 2026-11-12 — Telefonlar (kısa kenar < 600 dp) dikeye kilitli, tabletler serbest; iPhone `Info.plist`'te yalnızca dikey. Yatay telefon düzeni ayrıca tasarlanana kadar böyle kalır.
- 2026-11-12 — Arama: çekimli sorgular için ek soyma (`trStems`, üç eke kadar; yalnızca yazıldığı gibi adıyla eşleşen kayıt yoksa). Sözlük terimleri adıyla eşleşen kayıtların altında. Sonuç sınırı görünür ("892 sonuçtan ilk 60", "Daha fazla göster"). Arama süresi yalnızca dahili derlemede.
- 2026-11-12 — Çevrimiçi oturum: heartbeat'te `410` gelince oturum boşta kalır, bir sonraki gerekli kullanıcı eyleminde açılır (GPU boşuna sıcak tutulmaz). Her işe toplam 4 dakikalık tek süre sınırı. Çıkış ve hesap silme ekrandan bağımsız yürür. Bildirilen resmin baytları silinir; karşılaşma başına son 5 resim tutulur.
- 2026-11-12 — Kayıt, arama ve göz at listeleri tablette 720 dp'lik ortalanmış sütunda; iki bölmeli tablet düzeni ayrı bir iş.

## Yedekleme, yayın düzeni ve harita resmi (2026-11-12, #32–#34)

- 2026-11-12 — Yedek tek bir JSON dosyasıdır (`gm-cebi-yedek-YYYY-AA-GG.json`); tablolar şemadan okunur, yeni tablo ya da sütun teste eklenmezse bir test kırılır. Giriş anahtarları ve cihaza özel ayarlar (çevrimiçi onay ve anahtarı, test anahtarı, son yedek zamanı) yedeğe girmez. Geri yükleme birleştirmez, değiştirir: tek işlemde, kimlikler korunarak; hata olursa hiçbir şey değişmez. Daha yeni şemadan yedek reddedilir, eskisi kabul edilir. Dosya seçici tür süzmez; dosyanın yedek olup olmadığına içeriği karar verir.
- 2026-11-12 — `file_picker` en az iki haftalık bir sürüme kilitlenir (13.3.0); yeni çıkmış sürüme hemen geçilmez.
- 2026-11-12 — GM Paketi kilitliyken var olan notlar okunabilir (salt okunur); ekleme, düzenleme ve silme kilitli kalır.
- 2026-11-12 — Test APK'ları isteğe bağlı sabit bir test anahtarıyla imzalanır (`TEST_KEYSTORE_*` secret'ları; Play yükleme anahtarından ayrı). Yalnızca ARM, iki dosya (arm64, arm32). Her PR'da mağaza App Bundle'ı derlenip İnternet izni ve dahili test anahtarı içermediği denetlenir.
- 2026-11-12 — Kullanıcının yüklediği harita resmi ayrı tabloda durur (`map_images`, şema 6; çevrimiçi resimlerin budama ve bildirme kuralları ona dokunmaz), cihazdan hiç çıkmaz ve yedeğe girer. Harita kare kalır: resim "Sığdır" (varsayılan) ya da "Doldur" ile yerleşir. Çizimler yüklenen resmin üstünde görünür. Jeton boyutu (Küçük/Orta/Büyük) ve gösterilen arka plan karşılaşmaya kaydedilir. Izgarayı resme hizalama ve resmin en-boy oranını izleyen harita sonraki iş.

## Onay bekleyenler

- 2026-11-09 — Kalan içeriğin tamamı makine destekli çevrildi; mağaza metinleri ve Ayarlar notu bunu açıkça söyler, "kusursuz/resmî çeviri" denmez. İnsan incelemesi sonraki adım.
- 2026-11-09 — Kayıt adları (büyü, canavar, ekipman) sözlükte `öneri` olarak tutulur ve zorunlu değildir; metin içi adlar çevirmenlere ad listesiyle verilir. Dizi kuralları: Lesser/Greater = Küçük/Üstün, Conjure = Çağır, Summon = Celp Et, Devil = Şeytan, demon çevrilmez (Fiend = İblis dolu).
- 2026-11-09 — Stat bloğu üslubu: *Başarısızlık:* / *Başarı:* / *Tetikleyici:* / *Karşılık:* ("Tepki" Reaction'ın reddedilen alternatifi); "(Günde 3)", "**İstediği Zaman:**", "(Yenilenme 5–6)", "(İninde 4)". Hasar: sıfat türler yalın (Delici hasar), isim türler -ı ile (Ateş hasarı).
- 2026-11-09 — Bağlama bağlı segmentler ayrı ad alanında: sınıf büyü listesi hücreleri büyü adı, canavar dil satırı `lang`. Dil adları: Ortak Dil, Ejderce, Elfçe, Devce, Abis Dili, Cehennem Dili, Göksel Dil, Derin Dil, İlkel Dil, Sylvan Dili…
- 2026-11-09 — AI düzeltme turu (canavarlar, sınıflar, alt sınıflar; 74 segment). Çıkan kurallar `pipeline/prompts/translate_tr.md` sonuna eklendi (tur/sıra, ve/veya kapsamı, eylem adlarının başlıkla aynı olması, Restoration = Yenilenme, Evasion = Sıyrılma). İnsan incelemesi için öncelik ve açık kararlar: `docs/translation-review.md`.
- 2026-11-09 — Büyülü eşyalar (258) ve kural bölümleri (31) eklendi. SRD metnindeki ürün adları derlemede nötr ifadeye çevrilir (uygulama bu adları hiç göstermez). Magic Item = Büyülü Eşya; nadirlik: Yaygın / Az Bulunur / Nadir / Çok Nadir / Efsanevi / Artefakt; Wondrous Item = Harikulade Eşya.
- **ONAY BEKLİYOR** — Atıf metni: SRD'nin zorunlu kıldığı İngilizce cümle README'ye, `manifest.json`'a ve Hakkında ekranına birebir kondu (onay gerektirmez, lisans şartı). Ek olarak Türkçe bir "değiştirilmiş eser" notu öneriliyor (CC-BY değişikliklerin belirtilmesini istiyor): "Türkçe metinler SRD 5.2.1'in çevirisidir ve orijinal metinden türetilmiş, değiştirilmiş bir çalışmadır. …" Test sürümünde Hakkında ekranında **öneri metni olarak** duruyor (`lib/app_info.dart`, `translationNotice`); mağaza sürümünden önce onaylanmalı ya da değiştirilmeli. SRD, Wizards'a bu atıf dışında başka bir atıf yapılmamasını istediği için "Wizards ile bağımız yoktur" gibi ek cümleler kullanılmıyor.
- **ONAY BEKLİYOR** — Uygulama adı: "GM Cebi" çalışma adı olarak kullanılıyor (`lib/app_info.dart`, Android etiketi, iOS `CFBundleDisplayName`).
- **ONAY BEKLİYOR** — Paket adı: `io.github.sberkan09.gmcebi` (Android ve iOS aynı; `sberkan09.github.io` alanının tersi). Yer tutucu `com.example.*` Play'de reddedildiği için önerildi. İlk mağaza yüklemesinden sonra değiştirilemez; başka bir kimlik istenirse değiştirilecek yerler `docs/release.md`'de.
- **ONAY BEKLİYOR** — Üretime (herkese açık) çıkmadan önce: GM Paketi satın alma gelene kadar ücretsiz mi verilecek, yoksa üretim satın almayı mı bekleyecek? Test kanallarında açık (`docs/release.md`, "Bayraklar").

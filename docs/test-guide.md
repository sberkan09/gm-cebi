# GM Cebi — nasıl test edilir (test grubu için)

**Sürüm:** 1.0.0 test sürümü. Android'de iki yol var: GitHub'dan APK (aşağıda) ya da Play
Store test daveti. iOS için TestFlight daveti ayrıca gelecek.

Play Store ve TestFlight sürümlerinde test anahtarı yoktur; GM Paketi açık gelir. Aşağıdaki
"kilitli hâli görmek için" adımı yalnızca APK sürümünde çalışır.

GitHub'daki APK **"GM Cebi Test"** adıyla ayrı bir uygulama olarak kurulur; Play'den gelen
"GM Cebi" ile yan yana durabilir. İkisinin verileri (notlar, karşılaşmalar) ayrıdır, biri
diğerine aktarılmaz. Eski 0.1.0 test sürümü de ayrı bir uygulama olarak kalır; verilerin
oradadır, işin bitince kaldırabilirsin.

## Kurulum (Android 8 ve üstü)

1. GitHub'daki sürüm sayfasından **`gm-cebi-<sürüm>-arm64.apk`** dosyasını telefona indir (çoğu
   cihaz için). Telefon "uygulama yüklenmedi" ya da "uyumlu değil" derse aynı sayfadaki
   `gm-cebi-<sürüm>-arm32.apk`'yı dene (eski ya da 32 bit cihazlar).
2. Açınca "bilinmeyen kaynaklardan yükleme" izni istenirse bu dosya için izin ver.
3. Kur ve aç. İnternet gerekmez; her şey telefonda çalışır.

### Yeni test sürümü gelince

- Yeni APK'yı indirip aynı şekilde kur. Sürüm aynı imzayla geldiyse eski sürümün **üzerine kurulur**;
  notların, karşılaşmaların ve ayarların yerinde kalır. Her seferinde aynı dosyayı (arm64 ya da arm32)
  seç.
- Sürüm sayfasının en üstünde **"debug imzalı: önceki sürümün üzerine kurulamaz"** yazıyorsa ya da
  telefon "paket mevcut paketle çakışıyor" / "uygulama yüklenmedi" derse, yeni sürüm farklı bir imza
  taşıyor. O zaman:
  1. Eski uygulamada **Ayarlar → Yedekleme → "Yedek al"** ile yedeğini al ve yedek dosyasını
     telefonda (ya da kendine göndererek) sakla;
  2. eski "GM Cebi Test"i kaldır (kaldırınca verileri silinir);
  3. yeni APK'yı kur ve yedeği geri yükle.
- Bu durum yalnızca imza anahtarı değiştiğinde (ör. sabit test anahtarına ilk geçişte) bir kez olur.

Bu test sürümünde **GM Paketi açık** gelir. Kilitli hâlini görmek için:
Ara → sağ üstteki dişli → "Test: GM Paketi açık" anahtarını kapat.

### Yeni APK'dan önce yedek al

Yeni bir test APK'sı bazen eskisini kaldırmadan kurulmaz; kaldırınca notlar, karşılaşma ve harita da silinir.
Önce yedek al:

1. Ara → sağ üstteki dişli → **Yedekleme** → **Yedek al**.
2. **Dosyaya kaydet** (ör. İndirilenler) ya da **Paylaş** (kendine e-posta, Drive…). Dosyanın adı
   `gm-cebi-yedek-YYYY-AA-GG.json`. "Son yedek" satırı güncellenir.
3. Eski uygulamayı kaldır, yeni APK'yı kur.
4. Yeni uygulamada **Yedekleme** → **Yedekten geri yükle** → dosyayı seç → onayla. Buradaki veriler silinir,
   yedektekiler gelir (geri alınamaz).

Yedekte notlar, karşılaşma, savaş haritası, çevrimiçi resimler ve ayarlar (tema, içerik dili, grup seviyesi…)
vardır. Giriş bilgileri ve çevrimiçi sahne onayı yedeğe girmez; yeni kurulumda yeniden giriş yaparsın. Yedek
GM Paketi kilitliyken de alınır; kilitliyken notlar okunur ama düzenlenmez.

## Ne deneyelim (masada, gerçek oturumda)

1. **Ara** — Alttaki kutuya Türkçe ya da İngilizce yaz: "kör", "ateş topu",
   "saving throw", "cüce", "hançer", "goblin". Sonuç anında gelmeli (listenin
   üstünde süre yazar, 100 ms'nin altında olmalı). Boş kutuda kategorilere göz at.
2. **Kayıt sayfası** — Sağ üstteki **TR / EN** düğmesiyle dil tek dokunuşla
   değişmeli. Artık tüm büyüler, canavarlar, büyülü eşyalar, sınıflar, ekipman ve kural bölümleri Türkçe; canavar
   kartlarında ve sınıf özelliklerinde tuhaf ya da tutarsız terim görürsen not al.
3. **Zar** — `2d20kh1+5` (avantajlı +5), `4d6dl1` (en düşüğü at), `8d6`,
   `(1d8+3)*2` yaz ya da düğmelerle kur, **AT**'a bas. Avantaj/Dezavantaj
   düğmelerini ve geçmişe dokunup tekrar atmayı dene.
4. **İnisiyatif** — Oyuncuları "Ekle" ile, canavarları "Canavar listesinden
   ekle" ya da canavar sayfasındaki "İnisiyatife ekle" ile ekle. Zar
   simgesiyle canavarların inisiyatifini at, **Sonraki** ile sırayı ilerlet,
   can çubuğuna dokunup hasar/iyileştirme gir, kartın üstüne dokunup durum ekle.
   Uygulamayı kapatıp açınca karşılaşma yerinde durmalı. Listeden canavar
   eklenince üstte zorluk çipi çıkar (ör. "Orta · 1.050 / 1.500 TP"); dokununca
   bütçeler, canavarların TP'si ve grup açılır. Oyuncu seviyesini ekleme
   penceresinde, kart menüsündeki "Seviye"de ya da zorluk sayfasında değiştir;
   oyuncu yoksa grup büyüklüğü ve seviyesi orada ayarlanır.
5. **Harita** — İnisiyatif ekranında sağ üstteki harita simgesine dokun. Parmağınla çiz
   (renkler: mürekkep, su, bitki, tehlike), dokununca nokta bırakır; "Sil" ile sil; geri al
   düğmesi son işlemi (çizim, silme, temizleme) geri alır. Alttaki şeritten katılımcıya dokununca jetonu haritaya
   gelir; jetonu sürükleyerek taşı; jetona dokunup "Haritadan kaldır" ile kaldır. "Sonraki" sırayı haritadan ilerletir.
   Tablette de dene: harita ekrana göre büyür. İki parmakla kaydır ve yakınlaştır (yakınken köşedeki düğme haritayı
   sığdırır). Kalemle (S Pen, Apple Pencil) dokununca **kalem modu** kendiliğinden açılır: yalnızca kalem çizer,
   avuç içi ve parmak çizmez (tek parmak haritayı kaydırır, jetonlar parmakla taşınır); kalemin silgi ucu ya da yan
   tuşu o çizgi için siler; kalem ekranın üstünde gezinirken fırça/silgi imleci görünür. Kalem modunu haritadaki
   kalem düğmesinden ya da Ayarlar'dan kapat.
   **Alan fırçası:** araç çubuğunda "Alan"a dokun; renkler yerine altı alan türü (Su, Yol, Orman, Taş zemin, Duvar,
   Kum) ve üç fırça kalınlığı (ince, orta, kalın) çıkar. Bir nehri ya da odanın zeminini kabaca boya: boya yarı saydam,
   ızgara ve çizgiler üstünde okunur kalmalı, jetonlar boyanın üstünde durmalı. "Alan"dan sonra "Sil" yalnızca alanları,
   "Çiz"den sonra "Sil" yalnızca çizgileri siler; geri al ikisinde de çalışır. Kalemle de dene (kalem modu kuralları
   aynı, silgi ucu alanları siler). Uygulamayı kapatıp açınca boyalar yerinde durmalı.
   **Kendi harita resmin:** haritanın ⋮ menüsünden **Harita resmi yükle**'ye dokun ve hazır bir savaş haritası ya da
   elle çizdiğin haritanın fotoğrafını seç (izin sorulmamalı). Resim haritanın altına gelir; ızgarası olan bir resimse
   ilk seferde çıkan uyarıdaki "Izgarayı kapat"la ya da üstteki ızgara düğmesiyle uygulamanın ızgarasını kapat. Kare
   olmayan resimde menüden **Resim: Sığdır** (tamamı görünür, kenarlarda kâğıt rengi) ile **Resim: Doldur** (kare
   dolar, uzun kenar ortadan kırpılır) arasında geç. **Jeton boyutu: Küçük / Orta / Büyük** ile jetonları resmin
   karelerine uydur; dokunma alanı da jetonla büyüyüp küçülmeli. Resmin üstüne çiz ve boya: çizgiler ve yarı saydam
   alanlar resmin üstünde görünmeli. **Resmi değiştir** / **Resmi kaldır** menüde; telefonla çekilmiş dikey fotoğraf
   dik görünmeli. Çevrimiçi resim de varsa menüdeki **Arka plan** seçenekleriyle (Yok / Yüklediğim resim / Çevrimiçi
   resim) hangisinin görüneceğini seç; tablette bu seçimler sağdaki sütunda da var. "Yeni karşılaşma"da "Haritayı
   tut" işaretliyse resim, yerleşimi ve jeton boyutu yeni karşılaşmaya geçmeli. Resim cihazdan çıkmaz.
6. **Notlar** — Oturum notu al; yazdıkların kendiliğinden kaydedilir. Notun sağ üstündeki menüden **Notu paylaş**
   ile başlığı ve metni düz yazı olarak gönder.
7. **NPC üretici** — Notlar ekranında sağ üstteki maske simgesine dokun, **NPC üret**'e bas.
   Bir alana dokununca yalnızca o alan değişir; kilit simgesiyle alanı sabitle, sonra
   **Yeniden üret**. Filtrelerden soy, cinsiyet ve tavrı seç. **Nota kaydet** ve
   **İnisiyatife ekle**'yi dene. İsimler ve tablolar masada doğal okunuyor mu, söyle.
8. **Genel** — Tek elle kullanım, yazı büyüklüğü, koyu/açık tema (Ayarlar).
9. **Yedekleme** — Yedek al, birkaç not ekle, yedekten geri yükle: eklediğin notlar gitmeli, eskiler dönmeli;
   karşılaşma sırası (kimin sırası, tur) ve harita aynen gelmeli.

## Bilinen eksikler (bildirmene gerek yok)

- Çevirilerin tamamı makine destekli; insan incelemesi sürüyor. Terim önerilerin bu yüzden çok değerli.
- Satın alma yok.
- Yüklenen harita resminde: uygulamanın ızgarası resmin ızgarasına hizalanamaz (kare boyu, kaydırma); harita resmin
  en-boy oranını almaz, hep karedir; resim serbestçe kırpılamaz ya da yakınlaştırılamaz (yalnızca Sığdır / Doldur);
  savaş sisi (fog of war) yok.

## Geri bildirim

Her sorun için: **ne yaptın → ne bekledin → ne oldu**, mümkünse ekran
görüntüsü ve telefon modeli. Türkçe metinde tuhaf ya da yanlış bulduğun
terimleri de yaz (ör. "Güç mü Kuvvet mi olmalı?"). Bildirimleri ürün
sahibinin paylaştığı kanala gönder.

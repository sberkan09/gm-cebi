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

1. Sana gönderilen `gm-cebi-*.apk` dosyasını telefona indir.
2. Açınca "bilinmeyen kaynaklardan yükleme" izni istenirse bu dosya için izin ver.
3. Kur ve aç. İnternet gerekmez; her şey telefonda çalışır.

Bu test sürümünde **GM Paketi açık** gelir. Kilitli hâlini görmek için:
Ara → sağ üstteki dişli → "Test: GM Paketi açık" anahtarını kapat.

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
6. **Notlar** — Oturum notu al; yazdıkların kendiliğinden kaydedilir.
7. **NPC üretici** — Notlar ekranında sağ üstteki maske simgesine dokun, **NPC üret**'e bas.
   Bir alana dokununca yalnızca o alan değişir; kilit simgesiyle alanı sabitle, sonra
   **Yeniden üret**. Filtrelerden soy, cinsiyet ve tavrı seç. **Nota kaydet** ve
   **İnisiyatife ekle**'yi dene. İsimler ve tablolar masada doğal okunuyor mu, söyle.
8. **Genel** — Tek elle kullanım, yazı büyüklüğü, koyu/açık tema (Ayarlar).

## Bilinen eksikler (bildirmene gerek yok)

- Çevirilerin tamamı makine destekli; insan incelemesi sürüyor. Terim önerilerin bu yüzden çok değerli.
- Satın alma yok.

## Geri bildirim

Her sorun için: **ne yaptın → ne bekledin → ne oldu**, mümkünse ekran
görüntüsü ve telefon modeli. Türkçe metinde tuhaf ya da yanlış bulduğun
terimleri de yaz (ör. "Güç mü Kuvvet mi olmalı?"). Bildirimleri ürün
sahibinin paylaştığı kanala gönder.

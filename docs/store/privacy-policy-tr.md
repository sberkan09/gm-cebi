# GM Cebi — Gizlilik Politikası

<!-- YAYIMLAMADAN ÖNCE SAHİBİ DOLDURACAK (bu yorum yayımlanan sayfada görünmez; köşeli parantezli
her yer tutucu doldurulmadan politika yayımlanmaz):
  - <YAYIN TARİHİ>
  - <AD SOYAD ya da YAYINCI ADI>
  - <İLETİŞİM VE SİLME E-POSTASI — SAHİBİ DOLDURACAK>: sorular ve (çevrimiçi sahneli derlemede)
    uygulamaya erişemeyen kullanıcının hesap silme isteği bu adrese gelir. Uydurma adres yazma.
  - Çevrimiçi sahne bölümü: yalnızca çevrimiçi sahneli derleme mağazaya giderse yayımlanır; o zaman
    giriş paragrafı ve "Toplanan veriler" o bölümdeki hazır metinle değiştirilir. -->

Yürürlük tarihi: <YAYIN TARİHİ>
Geliştirici: <AD SOYAD ya da YAYINCI ADI> · İletişim: <İLETİŞİM VE SİLME E-POSTASI — SAHİBİ DOLDURACAK>

GM Cebi, 5e uyumlu masaüstü rol yapma oyunları için çevrimdışı çalışan bir yardımcı
uygulamadır. **Uygulama kişisel veri toplamaz, hiçbir veriyi bize ya da üçüncü
kişilere göndermez.**

## Toplanan veriler

Yok. Uygulamada:

- Ağ isteği yoktur. Mağaza derlemesi hiçbir sunucuya bağlanmaz; Android sürümü İnternet iznini
  (`android.permission.INTERNET`) bile istemez. İsteğe bağlı çevrimiçi özelliğin kodu uygulamada
  bulunur, ama bu derlemede derleme anında kapatılmıştır: sunucu adresi verilmemiştir, özellik
  görünmez ve çalışmaz.
- Reklam, analitik, çökme raporlama (crash reporting), izleme ya da kullanıcı hesabı yoktur.
- Konum, kamera, mikrofon, kişiler, fotoğraflar ya da başka bir cihaz izni istenmez.
- Uygulama içi satın alma ya da ödeme yoktur.

## Cihazında saklanan veriler

Aşağıdakiler yalnızca senin cihazında, uygulamanın kendi özel depolama alanında
saklanır (yedek dosyaları ise kaydetmeyi seçtiğin yerde). Bize ulaşmaz:

- **Ayarlar:** tema, varsayılan içerik dili.
- **Oturum notları:** senin yazdığın başlık ve metinler.
- **Karşılaşmalar (inisiyatif takibi):** girdiğin adlar, inisiyatif, can puanı,
  zırh sınıfı, seviye ve durum etiketleri.
- **Savaş haritası:** çizdiğin çizgiler, alan fırçasıyla boyadığın alanlar ve jetonların
  haritadaki yerleri. Karşılaşmaya bağlı saklanır.
- **Çevrimiçi resimler** (yalnızca çevrimiçi sahneli derlemede, özelliği kullanırsan): üretilen
  harita resimleri, yazdığın tarif ve resmin sunucudaki numarası, karşılaşmaya bağlı.
- **Yedek dosyaları:** Ayarlar → Yedekleme → "Yedek al" ile kendin oluşturduğun dosyalar. Uygulamadaki
  verilerinin bir kopyasını taşır. Sen paylaşmadıkça (ör. kendine e-postayla göndermedikçe) cihazında
  kalır; bize ulaşmaz. Yedek dosyası hiçbir zaman giriş anahtarı (token) içermez.
- **Zar geçmişi** yalnızca uygulama açıkken bellekte tutulur, kaydedilmez.

Bu verileri uygulama içinden silebilirsin (notu silme, "Yeni karşılaşma"; harita ve resimler
karşılaşmayla birlikte silinir). Uygulamayı kaldırınca hepsi silinir; kendi oluşturup başka bir yere
kopyaladığın yedek dosyalarını sen silersin.

**Cihaz yedekleri:** Cihazında Android yedeklemesi (Google hesabına yedekleme) ya da
iCloud/bilgisayar yedeklemesi açıksa, işletim sistemi bu verileri diğer uygulama
verileriyle birlikte yedekleyebilir. Bu yedekleme Google ya da Apple tarafından senin
hesabında yapılır. Geliştirici bu yedeklere erişemez.

## Çevrimiçi sahne (isteğe bağlı)

<!-- Yalnızca çevrimiçi sahne açık derlemeler için yayımlanır (docs/online-scene.md). Bu bölüm
yayımlanırsa giriş paragrafı ve "Toplanan veriler"in ilk maddesi aşağıdaki hazır metinle değiştirilir:

  Giriş paragrafı:
  GM Cebi, 5e uyumlu masaüstü rol yapma oyunları için çevrimdışı çalışan bir yardımcı uygulamadır.
  **İsteğe bağlı "Sahneyi canlandır" özelliği dışında uygulama hiçbir veriyi bize ya da üçüncü
  kişilere göndermez.** Bu özellik, yalnızca onay verip e-postana gelen kodla giriş yaptıktan sonra,
  savaş haritası çizimini ve yazdığın tarifi resim üretmek için bir sunucuya gönderir (aşağıda
  "Çevrimiçi sahne").

  "Toplanan veriler" başlığı ve ilk maddesi:
  ## Toplanan veriler
  Yalnızca isteğe bağlı çevrimiçi sahneyi kullanırsan, aşağıda "Çevrimiçi sahne"de yazanlar. Bunun
  dışında uygulamada:
  - Ağ isteği yoktur. Uygulama çevrimiçi sahne kullanılmadıkça hiçbir sunucuya bağlanmaz.
  (Diğer maddeler aynen kalır.) -->

Savaş haritasında "Sahneyi canlandır" özelliğini kullanırsan, çizdiğin arazi resme dönüştürülmek
üzere NeuraCraft Cloud sunucusuna gönderilir. Bu özellik isteğe bağlıdır; kullanmazsan hiçbir şey
gönderilmez ve uygulama çevrimdışı çalışmaya devam eder.

- **Giriş:** özellik yalnızca e-posta adresinle giriş yapınca çalışır (yalnızca bu özellik için).
  Adresin yalnızca 6 haneli giriş kodunu göndermek için kullanılır; kodu Brevo (AB) gönderir.
  NeuraCraft adresin kendisini saklamaz; yalnızca bir özetini (HMAC), sana verilen rastgele bir
  kullanıcı numarasını ve kayıt / son kullanım zamanlarını saklar. Ad ya da mağaza hesabı istenmez.
  Uygulama adresini yalnızca Ayarlar'da göstermek için cihazında tutar; giriş anahtarları cihazın
  güvenli deposunda (Keychain, Android Keystore) saklanır.
- **Gönderilenler ve saklama süreleri:** çizim (servis destekliyorsa alan fırçasıyla boyadığın
  alanlar da, ayrı bir resim olarak) 24 saat, üretilen resim 7 gün, yazdığın tarif iş bittikten 24
  saat sonrasına kadar saklanır. Jetonlar ve karşılaşma bilgileri gönderilmez.
- **Bir resmi bildirirsen:** resmin numarasıyla birlikte seçtiğin bildirim nedeni (ör. cinsel içerik,
  şiddet, nefret, çocuk güvenliği, diğer) ve yazdıysan en çok 500 karakterlik notun gönderilir. Resim
  inceleme için gizlenir; nota kişisel bilgi yazma.
- **Nerede:** işler Avrupa Birliği'ndeki sunucularda çalışır. Türkiye dışına (AB'ye) aktarım
  yapılmış olur.
- **Alt işleyiciler:** tarifin İngilizceye çevrilmesi için metin, hiçbir kimlik bilgisi olmadan
  Anthropic'e (ABD) gönderilebilir. Kod e-postalarını Brevo (AB) gönderir.
- **Reklam, analitik, izleme:** yok. Veriler satılmaz, reklam için paylaşılmaz.

### Hesabını silme

Ayarlar → Çevrimiçi sahne → **"Hesabımı sil"**. Hesabın ve sunucudaki tüm verilerin (çizimler,
resimler, tarifler, giriş anahtarları) hemen silinir; uygulamadaki çevrimiçi resimler de silinir.
"Çıkış yap" yalnızca bu cihazdaki girişi kapatır. Uygulamaya erişemiyorsan silme isteğini
<İLETİŞİM VE SİLME E-POSTASI — SAHİBİ DOLDURACAK> adresine gönderebilirsin.

## Üçüncü taraflar

Uygulamada veri gönderen üçüncü taraf kütüphane ya da hizmet (SDK) yoktur. Uygulamayı
indirdiğin mağaza (Google Play, App Store) kendi politikalarına göre kurulum ve çökme
istatistikleri toplayabilir. Bu veriler mağazanın kendi gizlilik politikasına tabidir.

## Çocuklar

Uygulama 13 yaşın altındaki çocuklara yönelik değildir ve kimseden kişisel veri toplamaz.

## Değişiklikler

İleride veri işleyen bir özellik eklenirse (ör. çevrimiçi yedekleme, satın alma) bu
politika güncellenir. Değişiklik uygulama güncellemesinden önce bu sayfada yayımlanır.
Yürürlük tarihi de güncellenir.

## İletişim

Sorular için: <İLETİŞİM VE SİLME E-POSTASI — SAHİBİ DOLDURACAK>

---

*Bu politika GM Cebi'nin kaynak kodu taranarak yazıldı: çalışma zamanı bağımlılıkları
`flutter_riverpod`, `drift`, `drift_flutter`, `sqlite3` ve `path_provider`; bunlar ağ bağlantısı
kurmaz. `http` ve `flutter_secure_storage` yalnızca isteğe bağlı çevrimiçi sahne içindir ve bu
özelliğin kapalı olduğu derlemede hiç çalışmaz (kodları derlenmiş durur, ama sunucu adresi verilmediği
için hiçbir istek yapılmaz). Mağaza derlemesi kontrol betiği
(`tool/check_store_build.sh`) Android derlemesinde İnternet izni olmadığını her sürümde
denetler.*

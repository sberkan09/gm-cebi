# GM Cebi — Gizlilik Politikası

Yürürlük tarihi: <YAYIN TARİHİ>
Geliştirici: <AD SOYAD ya da YAYINCI ADI> · İletişim: <E-POSTA>

GM Cebi, 5e uyumlu masaüstü rol yapma oyunları için çevrimdışı çalışan bir yardımcı
uygulamadır. **Uygulama kişisel veri toplamaz, hiçbir veriyi bize ya da üçüncü
kişilere göndermez.**

## Toplanan veriler

Yok. Uygulamada:

- İnternet bağlantısı yoktur. Android sürümü İnternet iznini (`android.permission.INTERNET`)
  bile istemez; iOS sürümünde de ağ isteği yapan kod yoktur.
- Reklam, analitik, çökme raporlama (crash reporting), izleme ya da kullanıcı hesabı yoktur.
- Konum, kamera, mikrofon, kişiler, fotoğraflar ya da başka bir cihaz izni istenmez.
- Uygulama içi satın alma ya da ödeme yoktur.

## Cihazında saklanan veriler

Aşağıdakiler yalnızca senin cihazında, uygulamanın kendi özel depolama alanında
saklanır. Bize ulaşmaz:

- **Ayarlar:** tema, varsayılan içerik dili.
- **Oturum notları:** senin yazdığın başlık ve metinler.
- **Karşılaşmalar (inisiyatif takibi):** girdiğin adlar, inisiyatif, can puanı,
  zırh sınıfı ve durum etiketleri.
- **Zar geçmişi** yalnızca uygulama açıkken bellekte tutulur, kaydedilmez.

Bu verileri uygulama içinden silebilirsin (notu silme, "Yeni karşılaşma"). Uygulamayı
kaldırınca hepsi silinir.

**Cihaz yedekleri:** Cihazında Android yedeklemesi (Google hesabına yedekleme) ya da
iCloud/bilgisayar yedeklemesi açıksa, işletim sistemi bu verileri diğer uygulama
verileriyle birlikte yedekleyebilir. Bu yedekleme Google ya da Apple tarafından senin
hesabında yapılır. Geliştirici bu yedeklere erişemez.

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

Sorular için: <E-POSTA>

---

*Bu politika GM Cebi'nin kaynak kodu taranarak yazıldı: çalışma zamanı bağımlılıkları
yalnızca `flutter_riverpod`, `drift`, `drift_flutter`, `sqlite3` ve `path_provider`;
hiçbiri ağ bağlantısı kurmaz. Mağaza derlemesi kontrol betiği
(`tool/check_store_build.sh`) Android derlemesinde İnternet izni olmadığını her sürümde
denetler.*

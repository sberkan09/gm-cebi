# Google Play — "Veri güvenliği" ve "Uygulama içeriği" cevap taslağı

Play Console → Politika → **Uygulama içeriği**. Cevaplar 1.0.0 sürümünün koduna göre
hazırlandı. Kanıtlar en altta. Bir SDK ya da ağ özelliği eklenirse bu belge ve gizlilik
politikası yeniden gözden geçirilmeli.

## Veri güvenliği (Data safety)

| Soru | Cevap |
|---|---|
| Uygulamanız gerekli kullanıcı verisi türlerinden herhangi birini topluyor ya da paylaşıyor mu? *(Does your app collect or share any of the required user data types?)* | **Hayır** |

"Hayır" seçilince veri türü, şifreleme ve silme soruları sorulmaz. Formun özeti şu
şekilde görünür: *"Üçüncü taraflarla veri paylaşılmaz · Veri toplanmaz"*.

Gerekçe (Play tanımlarına göre):

- **Toplama**, verinin cihazdan geliştiriciye ya da üçüncü bir tarafa gönderilmesidir.
  Uygulama hiçbir veriyi cihazdan dışarı göndermez. Mağaza derlemesinde İnternet izni yok.
- Notlar, karşılaşmalar ve ayarlar yalnızca cihazda işlenir. Play, yalnızca cihazda
  kalan veriyi "toplanan veri" saymaz.
- Android'in kendi yedekleme hizmeti (Google hesabına yedekleme) kullanıcının hesabında
  Google tarafından yapılır. Geliştirici bu yedeğe erişmez. Play bunu geliştiricinin
  veri toplaması olarak tanımlamaz. Gizlilik politikasında ayrıca belirtildi.
- Google Play'in kendi topladığı kurulum/çökme istatistikleri (Android vitals)
  uygulamanın beyanına girmez.

## Uygulama içeriği — diğer bölümler

| Bölüm | Cevap |
|---|---|
| Gizlilik politikası | `privacy-policy-tr.md` (ve/veya `-en.md`) yayımlandıktan sonra herkese açık URL'si. Play, URL'nin giriş gerektirmeden açılmasını ister. |
| Reklamlar | Uygulamada reklam **yok**. |
| Uygulama erişimi | **Tüm işlevler özel erişim gerektirmez.** Hesap yok. Mağaza test derlemesinde GM Paketi açık gelir. |
| İçerik derecelendirmesi (IARC anketi) | Kategori: **Referans, haber veya eğitim**. Şiddet: yalnızca fantastik oyun kurallarında metin olarak (büyü/canavar açıklamaları), görsel şiddet yok. Cinsellik, küfür, uyuşturucu, kumar: yok. Kullanıcılar arası etkileşim/paylaşım: **yok**. Konum paylaşımı: **yok**. Dijital ürün satın alma: **yok**. Beklenen sonuç: PEGI 3 / 7 ya da benzeri düşük derece. Kesin sonucu anket verir. |
| Hedef kitle ve içerik | Yaş grupları: **13–15, 16–17, 18 ve üzeri** (13 yaş altı seçilmez; seçilirse Aileler politikası ve ek şartlar devreye girer). "Uygulama çocukların ilgisini çekebilir mi?" → Hayır. |
| Haber uygulaması | Hayır |
| COVID-19 izleme/durum | Hayır |
| Veri güvenliği | Yukarıdaki gibi: veri toplanmıyor / paylaşılmıyor |
| Devlet uygulaması | Hayır |
| Finansal özellikler | Hiçbiri |
| Sağlık | Sağlık özelliği yok |
| Reklam kimliği (Advertising ID) | Kullanılmıyor. Manifestte `AD_ID` izni yok. |

## Kanıt (kod taraması, 1.0.0)

- Çalışma zamanı bağımlılıkları (`pubspec.yaml`): `flutter_riverpod`, `drift`,
  `drift_flutter`, `sqlite3`, `path_provider`. Ağ, analitik, reklam ya da çökme raporlama
  paketi yok (`firebase`, `sentry`, `http`, `dio`, `url_launcher` vb. yok).
- `lib/` içinde `HttpClient`, `Socket`, `WebSocket`, `Uri` isteği ya da platform kanalı
  yok. Koddaki tek URL'ler SRD atıf metnindeki düz metin adresler; tıklanabilir değil.
- Android `src/main/AndroidManifest.xml` hiçbir `uses-permission` içermiyor.
  `INTERNET` yalnızca `src/debug` ve `src/profile` manifestlerinde var. Bunlar Flutter
  geliştirme araçları içindir, release derlemesine girmez.
  `tool/check_store_build.sh` bunu her mağaza AAB'sinde denetler.
- iOS `Info.plist` hiçbir izin açıklaması (`NS…UsageDescription`) içermiyor.
- Kullanıcı verisi: `lib/db/database.dart` → `settings`, `notes`, `encounters`,
  `combatants` tabloları, uygulamanın belge klasöründe (`getApplicationDocumentsDirectory`)
  yerel SQLite dosyası.

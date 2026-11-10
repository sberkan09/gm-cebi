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

## Çevrimiçi sahne açık derleme (`NC_API_URL` + `NC_CLIENT_ID`)

Yukarıdaki "Hayır" yalnızca çevrimdışı mağaza derlemesi içindir. Çevrimiçi sahne açık bir derleme
Play'e giderse form şöyle doldurulur (`docs/online-scene.md`, "Gizlilik ve mağaza beyanları";
kaynak: neuracraft-cloud `docs/PRIVACY.md`):

| Soru | Cevap |
|---|---|
| Veri topluyor ya da paylaşıyor mu? | **Evet** |
| Aktarımda şifreli mi? | **Evet** (https) |
| Kullanıcı verisinin silinmesini isteyebilir mi? | **Evet**: uygulama içinde Ayarlar → Çevrimiçi sahne → "Hesabımı sil" (`DELETE /v1/me`, sunucudaki her şey hemen silinir). Play'in istediği hesap silme web adresi: gizlilik politikasındaki "Hesabını silme" bölümü. |
| Hesap oluşturma | Var, isteğe bağlı: yalnızca çevrimiçi sahne için e-posta + tek kullanımlık kod. Uygulamanın geri kalanı hesapsız çalışır. |

| Veri türü | Toplanıyor | Paylaşılıyor | Zorunlu mu | Amaç |
|---|---|---|---|---|
| Kişisel bilgiler → **E-posta adresi** | Evet (giriş kodu için; NeuraCraft adresi değil HMAC özetini saklar, kodu Brevo/AB gönderir) | Hayır (hizmet sağlayıcı / işleyici) | İsteğe bağlı | Uygulama işlevi, hesap yönetimi |
| Fotoğraflar ve videolar → **Diğer resimler** (arazi çizimi) | Evet (24 saat; sonuç resmi 7 gün) | Hayır | İsteğe bağlı | Uygulama işlevi |
| Uygulama etkinliği → **Diğer kullanıcı içeriği** (sahne tarifi) | Evet (iş bittikten 24 saat sonrasına kadar; kimliksiz olarak çeviri için Anthropic/ABD'ye gidebilir) | Hayır | İsteğe bağlı | Uygulama işlevi |

- Reklam ya da pazarlama için kullanım ve paylaşım **yok**; analitik **yok**.
- Hizmet sağlayıcıya (işleyici) aktarım Play'in tanımına göre "paylaşım" sayılmaz.
- Cihaz kimliği ya da kurulum kimliği **toplanmaz** (eski `X-End-User` kaldırıldı). Sunucu rastgele
  bir kullanıcı numarası (`eu_…`) üretir.
- "Uygulama erişimi" bölümü: inceleme için çevrimiçi sahneye giriş gerekir; test hesabı yerine
  inceleme ekibinin kendi e-postasıyla kod alabileceği yazılmalı (ya da özellik kapalı derleme).

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
  `drift_flutter`, `sqlite3`, `path_provider`; ayrıca yalnızca çevrimiçi sahnenin kullandığı
  `http` ve `flutter_secure_storage`. Analitik, reklam ya da çökme raporlama paketi yok
  (`firebase`, `sentry`, `dio`, `url_launcher` vb. yok).
- Ağ isteği yapan tek kod çevrimiçi sahnedir (`lib/data/neuracraft/`). `NC_API_URL` ve
  `NC_CLIENT_ID` verilmeyen mağaza derlemesinde hiç çalışmaz: arayüzde görünmez, güvenli depo
  okunmaz, manifestte İnternet izni yoktur. Koddaki diğer URL'ler SRD atıf metnindeki düz
  metin adresler; tıklanabilir değil.
- Android `src/main/AndroidManifest.xml` hiçbir `uses-permission` içermiyor.
  `INTERNET` yalnızca `src/debug` ve `src/profile` manifestlerinde var. Bunlar Flutter
  geliştirme araçları içindir, release derlemesine girmez.
  `tool/check_store_build.sh` bunu her mağaza AAB'sinde denetler.
- iOS `Info.plist` hiçbir izin açıklaması (`NS…UsageDescription`) içermiyor.
- Kullanıcı verisi: `lib/db/database.dart` → `settings`, `notes`, `encounters`,
  `combatants` tabloları, uygulamanın belge klasöründe (`getApplicationDocumentsDirectory`)
  yerel SQLite dosyası.

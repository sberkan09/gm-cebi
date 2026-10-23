# iOS / TestFlight hazırlığı

İmzalama ürün sahibinde. Depo, imzalama dışındaki her şeye hazır.

## Hazır olanlar

- Minimum iOS 15.0 (`ios/Runner.xcodeproj`, `IPHONEOS_DEPLOYMENT_TARGET`).
- Uygulama adı "GM Cebi" (`CFBundleDisplayName`), kendi ikon seti (`tool/make_icons.py`).
- `ITSAppUsesNonExemptEncryption = false` (Info.plist): uygulama şifreleme
  kullanmadığı için TestFlight'taki ihracat uyumluluğu sorusu çıkmaz.
- Ağ, konum, kamera vb. hiçbir izin istenmez; veri toplanmaz (App Store
  "App Privacy": *Data Not Collected*).
- CI: `.github/workflows/ios-build.yml`, macOS'ta imzasız `flutter build ios`
  ile projenin derlendiğini doğrular (elle tetiklenir ve sürüm etiketlerinde çalışır).

## Senin yapacakların

1. **Paket kimliği (bundle id)** — Şu an yer tutucu: `com.example.gmCebi`.
   Kesin kimliği seç (geri alınamaz). Değiştirilecek yerler:
   `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`, 3 yer
   + RunnerTests) ve Android için `android/app/build.gradle.kts`
   (`applicationId`, `namespace`) ile `MainActivity.kt` paket yolu.
2. Apple Developer hesabında aynı bundle id ile App ID oluştur, App Store
   Connect'te uygulama kaydını aç.
3. Mac'te: `open ios/Runner.xcworkspace` → Runner → Signing & Capabilities →
   Team seç, "Automatically manage signing".
4. Derle ve yükle:

   ```bash
   flutter build ipa --release \
     --dart-define=GMCEBI_INTERNAL=true --dart-define=GMCEBI_GM_PACK=true
   # build/ios/ipa/*.ipa dosyasını Transporter ile ya da:
   xcrun altool --upload-app -f build/ios/ipa/gm_cebi.ipa -t ios --apiKey … --apiIssuer …
   ```

   `GMCEBI_INTERNAL` test anahtarlarını, `GMCEBI_GM_PACK` GM Paketi'ni açar.
   Mağaza sürümünde ikisi de verilmez.
5. App Store Connect → TestFlight → "Internal Testing" grubuna test
   ekibini ekle. Test notu olarak `docs/test-guide.md`'yi kullanabilirsin.

## Android karşılığı

`flutter build apk --release --dart-define=GMCEBI_INTERNAL=true --dart-define=GMCEBI_GM_PACK=true`
CI'da her PR'da üretilir (iş çıktısı: `gm-cebi-internal-apk`). Test APK'sı
debug anahtarıyla imzalıdır; Play Store'a yüklemeden önce yükleme anahtarı
oluşturulmalı (`android/app/build.gradle.kts`, `signingConfigs`).

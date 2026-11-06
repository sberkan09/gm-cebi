# iOS / TestFlight

Depo, imzalama ve yükleme dışındaki her şeye hazır. Aşağıda adımlar **Mac
gerektirmeyenler** ve **Mac gerektirenler** diye ayrıldı. Android karşılığı ve
bayrakların anlamı: `docs/release.md`.

## Depoda hazır olanlar

- Bundle id: `io.github.sberkan09.gmcebi` (Android applicationId ile aynı; testler
  `io.github.sberkan09.gmcebi.RunnerTests`). İlk yüklemeden sonra değiştirilemez.
- Sürüm: `pubspec.yaml` → `version: 1.0.0+1` → `CFBundleShortVersionString 1.0.0`,
  `CFBundleVersion 1`. Her TestFlight yüklemesinde `+` sonrası sayı artmalı.
- Minimum iOS 15.0. Ad "GM Cebi" (`CFBundleDisplayName`). Kendi ikon seti, 1024 px
  ikon şeffaflık içermiyor (`tool/make_icons.py`).
- `ITSAppUsesNonExemptEncryption = false` (Info.plist): uygulama şifreleme
  kullanmadığı için TestFlight'taki ihracat uyumluluğu sorusu çıkmaz.
- Hiçbir izin istenmez (`NS…UsageDescription` yok), ağ kodu yok, veri toplanmaz.
- CI: `.github/workflows/ios-build.yml`, macOS'ta imzasız `flutter build ios` ile
  projenin derlendiğini doğrular (elle tetiklenir, `v*` etiketlerinde de çalışır).
- Mağaza materyalleri: `docs/store/` (metinler, gizlilik politikası, 6,9" iPhone ekran
  görüntüleri `docs/store/screenshots/ios/`, 1320×2868).

## Bayraklar: TestFlight = mağaza derlemesi

TestFlight'a yüklenen derleme, App Store incelemesine **aynen** gönderilebilir. Bu
yüzden TestFlight derlemesi de mağaza bayraklarıyla yapılır:

```bash
--dart-define=GMCEBI_INTERNAL=false --dart-define=GMCEBI_GM_PACK=true
```

`GMCEBI_INTERNAL=true` (test anahtarı) yalnızca GitHub'daki test APK'sında kullanılır.

## A. Mac gerektirmeyen adımlar (tarayıcıdan)

1. **Apple Developer Program** üyeliği (developer.apple.com/programs, yıllık ücretli).
   Bireysel ya da şirket hesabı. Şirket hesabı D-U-N-S numarası ister.
2. **App ID:** Certificates, Identifiers & Profiles → Identifiers → "+" → App IDs →
   Bundle ID (Explicit): `io.github.sberkan09.gmcebi`. Ek yetenek (capability) gerekmiyor.
3. **App Store Connect → Uygulamalar → "+" Yeni Uygulama:** platform iOS, ad "GM Cebi",
   birincil dil Türkçe, bundle id yukarıdaki, SKU (ör. `gmcebi-ios`).
4. **Uygulama Gizliliği (App Privacy):** "Veri toplamıyoruz" (*Data Not Collected*).
   Gizlilik politikası URL'si (`docs/store/privacy-policy-*.md` yayımlandıktan sonra).
5. **Yaş derecelendirmesi anketi:** şiddet yalnızca metin olarak, fantastik oyun
   kuralları içinde. En temkinli seçim "Seyrek/Hafif Fantastik Şiddet". Diğer her şey
   "Yok". Sınırsız web erişimi, kumar, kullanıcı içeriği paylaşımı yok.
6. **TestFlight grupları:**
   - *Dahili test* (App Store Connect kullanıcıları, en çok 100 kişi): inceleme gerekmez,
     derleme işlendikten hemen sonra açılır.
   - *Harici test* (e-posta ya da herkese açık bağlantı, en çok 10.000 kişi): ilk derleme
     için kısa bir **Beta App Review** gerekir. "Test Bilgileri"ne geri bildirim
     e-postası, açıklama ve "Neyi test etmeli" metni girilir (`docs/test-guide.md` ve
     `docs/store/listing-tr.md` uyarlanabilir). Giriş bilgisi gerekmez.
7. (İsteğe bağlı) **App Store Connect API anahtarı** (Users and Access → Integrations →
   App Store Connect API). Komut satırından yükleme ve ileride CI'dan TestFlight'a
   yükleme için. `.p8` dosyası gizlidir, depoya konmaz (`.gitignore` `*.p8`'i dışlar).

## B. Mac gerektiren adımlar (Xcode)

Gerekenler: macOS, güncel Xcode (App Store Connect'in istediği en düşük SDK sürümüyle),
Flutter 3.47.7, CocoaPods ya da Swift Package Manager (Flutter seçer).

1. Depoyu klonla, `flutter pub get`.
2. `open ios/Runner.xcworkspace` → Runner hedefi → **Signing & Capabilities** →
   Team: geliştirici hesabın, "Automatically manage signing" açık. Bundle id'nin
   `io.github.sberkan09.gmcebi` olduğunu kontrol et. Xcode dağıtım sertifikasını ve
   profili kendisi oluşturur.
   - Bu adım `project.pbxproj`'a `DEVELOPMENT_TEAM` yazar. Takım kimliği gizli değildir,
     commit'lenebilir.
3. Derle:

   ```bash
   flutter build ipa --release \
     --dart-define=GMCEBI_INTERNAL=false --dart-define=GMCEBI_GM_PACK=true
   ```

   Çıktı: `build/ios/archive/Runner.xcarchive` ve `build/ios/ipa/*.ipa`.
4. Yükle (biri yeter):
   - **Xcode → Window → Organizer →** arşivi seç → *Distribute App* → *App Store
     Connect* → *Upload*.
   - **Transporter** uygulaması (Mac App Store): `.ipa` dosyasını sürükle-bırak.
   - Komut satırı (API anahtarıyla):
     `xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>`
     (`.p8` dosyası `~/.appstoreconnect/private_keys/` altında olmalı).
5. Yükleme işlenince (10–30 dk) App Store Connect → TestFlight'ta derleme görünür.
   İhracat uyumluluğu sorusu `ITSAppUsesNonExemptEncryption` sayesinde sorulmaz.
6. Apple yüklemeden sonra **ITMS-91053 "Missing API declaration"** e-postası gönderirse
   Runner'a bir gizlilik bildirimi (`PrivacyInfo.xcprivacy`) eklenmeli: Xcode → File →
   New → File → *App Privacy*. `NSPrivacyTracking = false`, toplanan veri yok, e-postada
   adı geçen API kategorisi ve gerekçe kodu girilir. Flutter ve `path_provider` kendi
   bildirimlerini taşıdığı için bu e-postanın gelmesi beklenmiyor.
7. Ekran görüntüleri: App Store Connect → sürüm sayfası → 6,9" iPhone →
   `docs/store/screenshots/ios/*.png`. iPad desteği açık olduğu için iPad ekran görüntüsü
   de istenir (13" iPad, 2064×2752). Uygulama yalnızca iPhone'a yönelik çıkacaksa
   Xcode'da *Supported Destinations* listesinden iPad kaldırılabilir. Bu bir ürün kararı.

## Mac olmadan derleme (ileride)

Mac yoksa GitHub Actions'ın macOS çalıştırıcısı da imzalı `.ipa` üretip TestFlight'a
yükleyebilir. Bunun için App Store Connect API anahtarı (`.p8`, Key ID, Issuer ID) ve
dağıtım sertifikası ile profil (ya da `-allowProvisioningUpdates` ile otomatik imzalama)
repo secret'ı olarak verilir. Bu iş akışı henüz yazılmadı. İlk yükleme Mac'ten yapılırsa
imzalama ayarları da doğrulanmış olur.

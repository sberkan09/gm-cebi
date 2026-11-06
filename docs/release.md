# Mağaza sürümü (Google Play ve TestFlight)

Bu belge mağaza derlemesinin nasıl üretildiğini anlatır. Test grubuna giden APK
(GitHub ön-sürümü, `v*-test*` etiketi) için `docs/test-guide.md` geçerli.
iOS adımları `docs/ios-testflight.md`'de.

## Kimlik ve sürüm

| | Değer | Nerede |
|---|---|---|
| Uygulama adı | GM Cebi | `lib/app_info.dart`, `AndroidManifest.xml` (`android:label`), iOS `CFBundleDisplayName` |
| Android applicationId | `io.github.sberkan09.gmcebi` | `android/app/build.gradle.kts` (`applicationId`, `namespace`), `MainActivity.kt` paket yolu |
| iOS bundle id | `io.github.sberkan09.gmcebi` | `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`; testler `….RunnerTests`) |
| Sürüm | `1.0.0+1` | `pubspec.yaml` (`version`), `lib/app_info.dart` (`appVersion`) |

- Kimlik `sberkan09.github.io` alanının tersidir (sahibi olunan bir alan; `com.example`
  Play'de reddedilir). **İlk yüklemeden sonra değiştirilemez.** Başka bir kimlik
  istenirse ilk yüklemeden önce yukarıdaki dosyalarda değiştirilmeli.
- `version: 1.0.0+1` → Android `versionName 1.0.0`, `versionCode 1`; iOS
  `CFBundleShortVersionString 1.0.0`, `CFBundleVersion 1`.
- Her mağaza yüklemesinde `+` sonrası sayı (build numarası) artmalı; Play aynı
  `versionCode`'u ikinci kez kabul etmez. `appVersion` ile pubspec'in uyumu testle
  denetlenir (`test/core/app_info_test.dart`).
- İkonlar `tool/make_icons.py` ile üretilir (Android legacy + adaptive + monochrome,
  iOS AppIcon seti, 1024 px dahil). Ayrıca `flutter_launcher_icons` gerekmiyor.
  Play listesi için 512 px ikon ve 1024×500 öne çıkan görsel: `tool/make_store_graphics.py`
  → `docs/store/graphics/`.

## Bayraklar (`--dart-define`)

Kod: `lib/features/flags.dart`. İkisi de derleme anında sabittir (`bool.fromEnvironment`).

| Bayrak | Ne yapar | Test APK'sı (`v*-test*`) | Play kapalı/açık test, TestFlight | Üretim (satın alma geldikten sonra) |
|---|---|---|---|---|
| `GMCEBI_INTERNAL` | Ayarlar'da "Test: GM Paketi açık" anahtarı, kilit ekranında "Test için aç" düğmesi, Hakkında'da "test sürümü" etiketi | `true` | **`false`** | **`false`** |
| `GMCEBI_GM_PACK` | GM Paketi'ni (inisiyatif, notlar) herkese açar | `true` | `true` | `false` |

Gerekçe:

- `GMCEBI_INTERNAL=true` mağaza derlemesinde ücretli katmanı herkese bedavaya açan bir
  düğme demek. Mağaza derlemesinde `false` olunca bu dallar derleyicide tamamen
  silinir; `tool/check_store_build.sh` AAB'nin içinde test anahtarının izini arar.
- Kodda düzeltilen sızıntı: Test anahtarı tercihini veritabanına yazar
  (`gmPackOverride`). Önceden bu tercih mağaza derlemesinde de okunuyordu. Aynı
  cihazda önce test derlemesi kurulup sonra mağaza derlemesine güncellenince GM
  Paketi açık kalabiliyordu. Artık mağaza derlemesi yalnızca `GMCEBI_GM_PACK`'e
  bakıyor (`resolveGmPack`, testle denetleniyor).
- Satın alma kodu yok. `GMCEBI_GM_PACK=false` ile çıkan bir mağaza derlemesinde
  inisiyatif ve notlar açılamayan bir kilit ekranı olur. Bu yüzden test kanallarında
  GM Paketi açık. Test kullanıcıları da bu özellikleri denemeli. Satın alma eklenince
  üretim derlemesi `false` ile çıkar. **Üretime (herkese açık) çıkmadan önce bu karar
  yeniden verilmeli:** GM Paketi'ni ücretsiz vermek mi, satın almayı beklemek mi?
- Mağaza derlemesinde **İnternet izni yok.** `android.permission.INTERNET` yalnızca
  debug/profile manifestlerinde var (Flutter araçları için). Kontrol betiği bunu da
  denetler.

## Android imzalama

Play App Signing kullanılır: Google uygulamayı kendi **uygulama imzalama
anahtarıyla** imzalar, biz Play'e **yükleme anahtarıyla** (upload key) imzalı AAB
göndeririz. Yükleme anahtarı kaybolursa Play Console'dan sıfırlatılabilir;
yine de yedeklenmeli.

### 1. Yükleme anahtarını oluştur (bir kez, kendi bilgisayarında)

```bash
keytool -genkeypair -v \
  -keystore ~/gm-cebi-upload.jks \
  -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

- Komut bir **keystore şifresi** ve bir **anahtar şifresi** sorar, ad/kuruluş
  bilgilerini de ister (yalnızca sertifikada görünür). `-storetype JKS` iki ayrı şifreye izin verir.
  PKCS12 kullanırsan iki şifre aynı olmalı.
- `keytool` JDK ile gelir (Android Studio'nun JDK'sı:
  `"<Android Studio>/jbr/bin/keytool"`).
- Dosyayı ve şifreleri bir parola yöneticisinde yedekle. **Depoya koyma.**

### 2. Yerelde imzalı derleme (isteğe bağlı)

`android/key.properties` oluştur. Bu dosya git dışıdır (`android/.gitignore`,
kök `.gitignore`):

```properties
storeFile=/home/<sen>/gm-cebi-upload.jks
storePassword=<keystore şifresi>
keyAlias=upload
keyPassword=<anahtar şifresi>
```

`storeFile` göreli verilirse `android/app/` klasörüne göre çözülür. Sonra:

```bash
flutter build appbundle --release --dart-define=GMCEBI_INTERNAL=false --dart-define=GMCEBI_GM_PACK=true
tool/check_store_build.sh build/app/outputs/bundle/release/app-release.aab
```

`key.properties` yoksa release derlemesi debug anahtarıyla imzalanır. Bu yalnızca
test APK'sı içindir; Play debug imzalı AAB'yi reddeder.

### 3. GitHub Actions (`.github/workflows/release-aab.yml`)

Tetikleyici: `v1.0.0` gibi bir sürüm etiketi (`v*-test*` hariç; o test APK'sıdır) ya
da elle çalıştırma. Adımlar:

1. Etiket pubspec sürümüyle aynı mı (`v1.0.0` ↔ `version: 1.0.0+N`)?
2. `flutter analyze`, `flutter test`.
3. Keystore secret'tan çözülür, `android/key.properties` yazılır (çalıştırıcının
   geçici klasöründe).
4. `flutter build appbundle --release` (bayraklar: `INTERNAL=false`, `GM_PACK=true`).
5. Doğrulama: `jarsigner -verify`, imzalayan sertifika yükleme anahtarı mı,
   `tool/check_store_build.sh` (test anahtarı izi, İnternet izni, `com.example`).
6. İmza dosyaları silinir, AAB iş çıktısı olarak yüklenir: **`gm-cebi-release-aab`**
   (90 gün saklanır). Play'e yükleme elle yapılır.

Repo secret'ları (Settings → Secrets and variables → Actions → New repository secret):

| Secret | İçerik |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Keystore dosyasının base64 hâli (tek satır) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore şifresi |
| `ANDROID_KEY_ALIAS` | Anahtar adı (yukarıdaki komutta `upload`) |
| `ANDROID_KEY_PASSWORD` | Anahtar şifresi |

Base64'e çevirme:

```bash
# Linux
base64 -w0 ~/gm-cebi-upload.jks > gm-cebi-upload.jks.base64
# macOS
base64 -i ~/gm-cebi-upload.jks -o gm-cebi-upload.jks.base64
# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\gm-cebi-upload.jks")) | Set-Content gm-cebi-upload.jks.base64
```

Dosyanın içeriğini `ANDROID_KEYSTORE_BASE64` secret'ına yapıştır, sonra `.base64`
dosyasını sil. `gh` CLI ile: `gh secret set ANDROID_KEYSTORE_BASE64 < gm-cebi-upload.jks.base64`.

### Sürüm çıkarma

```bash
# pubspec.yaml: version: 1.0.0+1  (sonraki yükleme 1.0.1+2 vb.)
git tag v1.0.0
git push origin v1.0.0
```

İş bitince Actions → release-aab → çalıştırma → Artifacts → `gm-cebi-release-aab`
zip'ini indir, içindeki `app-release.aab`'yi Play Console'a yükle.

Aynı etiket `ios-build` iş akışını da tetikler (imzasız iOS derleme denetimi).
AAB, yerel kodun debug sembollerini kendi içinde taşır (`BUNDLE-METADATA/…/debugsymbols`).
Play'e ayrıca sembol dosyası yüklemek gerekmez.

## Mağaza materyalleri

`docs/store/`:

| Dosya | İçerik |
|---|---|
| `listing-tr.md`, `listing-en.md` | Kısa/uzun açıklama (Play), alt başlık/anahtar kelimeler (App Store), atıf |
| `privacy-policy-tr.md`, `privacy-policy-en.md` | Gizlilik politikası (kod taramasına dayalı) |
| `play-data-safety.md` | Play "Veri güvenliği" ve "Uygulama içeriği" formları için cevap taslağı |
| `graphics/` | 512 px ikon, 1024×500 öne çıkan görsel |
| `screenshots/android/` | 6 ekran görüntüsü, 1080×1920 |
| `screenshots/ios/` | 6 ekran görüntüsü, 1320×2868 (6,9" iPhone) |

Ekran görüntülerini yeniden üretmek için:

```bash
flutter test test/screenshots/store_screenshots_test.dart --update-goldens \
  --dart-define=FLUTTER_ROOT_FONTS=$(dirname $(which flutter))/cache/artifacts/material_fonts
python3 tool/make_store_graphics.py $(dirname $(which flutter))/cache/artifacts/material_fonts
```

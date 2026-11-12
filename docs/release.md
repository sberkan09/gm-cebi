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

`storeFile` göreli verilirse `android/app/` klasörüne göre çözülür. `key.properties`
Java properties biçimindedir: şifrede `\` varsa `\\` yaz (aksi hâlde kaçış karakteri sayılır).
Aynı değerler ortam değişkeniyle de verilebilir; dosyadan önce bunlara bakılır:
`ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
Sonra:

```bash
flutter build appbundle --release --dart-define=GMCEBI_INTERNAL=false --dart-define=GMCEBI_GM_PACK=true
tool/check_store_build.sh build/app/outputs/bundle/release/app-release.aab
```

Anahtar verilmezse release derlemesi debug anahtarıyla imzalanır. Bu yalnızca test APK'sı
içindir; Play debug imzalı AAB'yi reddeder ve `check_store_build.sh` bunu yakalar.

**Dahili test derlemeleri ayrı bir uygulamadır.** `GMCEBI_INTERNAL=true` ile derlenen APK
(GitHub'daki test APK'sı) `io.github.sberkan09.gmcebi.test` kimliğiyle ve "GM Cebi Test" adıyla
kurulur. Böylece Play'den gelen sürümle aynı telefonda yan yana durabilir; biri diğerinin üzerine
kurulmaya çalışılmaz ve kullanıcı verisi silinmez. Kontrol betiği `.test` kimliğini mağaza AAB'sinde
hata sayar.

### 3. GitHub Actions (`.github/workflows/release-aab.yml`)

Tetikleyici: `v1.0.0` gibi bir sürüm etiketi (`v*-test*` hariç; o test APK'sıdır) ya
da elle çalıştırma. Adımlar:

1. Etiket pubspec sürümüyle aynı mı? `version: 1.0.0+2` için `v1.0.0` ya da `v1.0.0+2`.
2. `flutter analyze`, `flutter test`.
3. Keystore secret'tan çözülür (çalıştırıcının geçici klasörüne). Şifreler Gradle'a ortam
   değişkeni olarak gider; dosya yazılmaz, şifrede her karakter kullanılabilir.
4. `flutter build appbundle --release` (bayraklar: `INTERNAL=false`, `GM_PACK=true`).
5. Doğrulama: `jarsigner -verify`, imzalayan sertifika yükleme anahtarı mı,
   `tool/check_store_build.sh` (test anahtarı izi, İnternet izni, debug imzası, `.test` kimliği,
   `com.example`).
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
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\gm-cebi-upload.jks")) | Set-Content -NoNewline gm-cebi-upload.jks.base64
```

Dosyanın içeriğini `ANDROID_KEYSTORE_BASE64` secret'ına yapıştır, sonra `.base64`
dosyasını sil. `gh` CLI ile: `gh secret set ANDROID_KEYSTORE_BASE64 < gm-cebi-upload.jks.base64`.
İş akışı satır sonlarını ve boşlukları yok sayar; yapıştırırken araya giren CRLF sorun olmaz.

**Önerilen koruma:** elle çalıştırma (`workflow_dispatch`) seçilen herhangi bir daldan imzalı AAB
üretebilir. Settings → Environments altında `release` adında, onay gerektiren bir ortam açıp bu
dört secret'ı oraya taşımak ve iş akışına `environment: release` eklemek, imzalamayı onaya bağlar.

### 4. Pull request denetimi (`.github/workflows/ci.yml`)

Her PR'da `flutter` işi, APK'dan sonra mağaza AAB'sini `release-aab` ile **aynı bayraklarla** iki kez
derler ve `tool/check_store_build.sh`'ı çalıştırır:

1. Çevrimdışı mağaza derlemesi → `check_store_build.sh --allow-debug-signature`: test anahtarı izi,
   İnternet izni **yok**, `.test` kimliği yok, `com.example` yok.
2. `--dart-define=NC_API_URL=https://example.invalid` ile → `--online --allow-debug-signature`:
   aynı denetimler, ama İnternet izni **olmalı**.

PR'lara secret verilmez; AAB debug anahtarıyla imzalanır. `--allow-debug-signature` yalnızca imza
denetimini atlar. Yükleme anahtarı denetimi etiketteki `release-aab` işinde yapılır. Gradle önbelleği
(`setup-java`, `cache: gradle`) ve APK derlemesinden kalan sıcak Gradle/Dart derleme durumu sayesinde
iki AAB işe yaklaşık iki dakika ekler (yerelde, APK'dan sonra: 56 sn ve 49 sn).

### Sürüm çıkarma

```bash
# pubspec.yaml: version: 1.0.0+1
git tag v1.0.0 && git push origin v1.0.0
# Aynı sürümün yeni bir yüklemesi: pubspec'i 1.0.0+2 yap, commit'le, sonra
git tag v1.0.0+2 && git push origin v1.0.0+2
```

İş bitince Actions → release-aab → çalıştırma → Artifacts → `gm-cebi-release-aab`
zip'ini indir, içindeki `app-release.aab`'yi Play Console'a yükle.

Aynı etiket `ios-build` iş akışını da tetikler (imzasız iOS derleme denetimi).
AAB, yerel kodun debug sembollerini kendi içinde taşır (`BUNDLE-METADATA/…/debugsymbols`).
Play'e ayrıca sembol dosyası yüklemek gerekmez.

## Test APK'sı (`.github/workflows/release-apk.yml`)

`v1.0.0-test.3` gibi bir etiket, test grubu için iki APK derleyip GitHub ön-sürümüne ekler:

| Dosya | Kime |
|---|---|
| `gm-cebi-<etiket>-arm64.apk` | Çoğu cihaz (64 bit ARM; son yıllarda çıkan telefon ve tabletlerin hemen hepsi) |
| `gm-cebi-<etiket>-arm32.apk` | Eski ya da 32 bit ARM cihazlar (arm64 kurulmazsa) |

`--split-per-abi --target-platform android-arm,android-arm64` ile derlenir. Eski tek dosyalı APK
x86_64'ü de taşıyordu (emülatörler, birkaç Chromebook) ve ~66 MB'tı. Bayraklar değişmedi:
`GMCEBI_INTERNAL=true`, `GMCEBI_GM_PACK=true`, depoda `NC_API_URL` değişkeni varsa çevrimiçi sahne
(`docs/online-scene.md`); günlükte `online scene: on/off` satırı yazar. Ön-sürüm notu
`docs/test-guide.md`'dir, başına hangi dosyanın indirileceği eklenir.

Split APK'larda Flutter `versionCode`'a ABI'ye göre bir sayı ekler (arm32: 1000+, arm64: 2000+).
Aynı cihaza hep aynı dosya kurulduğu sürece güncelleme sorunsuzdur.

### Test APK imza anahtarı

Android bir uygulamanın güncellemesini yalnızca **aynı anahtarla** imzalıysa kabul eder. Anahtar
verilmezse her etiket, çalıştırıcıda o an üretilen yeni bir debug anahtarıyla imzalanır. Test
kullanıcısı yeni sürümü kurmak için eskisini kaldırmak zorunda kalır ve notlarını, karşılaşmalarını
kaybeder. Bunu önlemek için sabit bir **test anahtarı** kullanılır.

**Neden Play yükleme anahtarı değil:** test APK'sı farklı bir uygulamadır (`….gmcebi.test`, "GM Cebi
Test"); Play anahtarıyla imzalanmasına gerek yok. Test APK'ları sık çıkar, GitHub'da herkese açık
dağıtılır ve `release` onay ortamı gibi bir korumaya bağlı değildir. Yükleme anahtarı yalnızca
mağaza derlemesi işinde görünürse, test yolundaki bir hata ya da sızıntı mağaza uygulamasının
imzasını tehlikeye atmaz. Test anahtarı kaybolur ya da sızarsa yalnızca test kullanıcıları bir kez
yeniden kurar.

**Oluşturma (bir kez, kendi bilgisayarında):**

```bash
keytool -genkeypair -v \
  -keystore ~/gm-cebi-test.jks \
  -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias gmcebi-test
```

- `-validity 10000` gün ≈ 27 yıl. Anahtarın süresi dolarsa güncelleme yine kırılır; 25 yıldan kısa
  verme.
- Keystore ve anahtar şifresini sorar (JKS'de ikisi farklı olabilir). Ad/kuruluş bilgisi yalnızca
  sertifikada görünür.
- Dosyayı ve şifreleri parola yöneticisinde yedekle. **Depoya koyma.**

**Base64 ve secret'lar** (Settings → Secrets and variables → Actions → New repository secret):

```bash
base64 -w0 ~/gm-cebi-test.jks > gm-cebi-test.jks.base64      # macOS: base64 -i ~/gm-cebi-test.jks -o gm-cebi-test.jks.base64
gh secret set TEST_KEYSTORE_BASE64 < gm-cebi-test.jks.base64
gh secret set TEST_KEYSTORE_PASSWORD    # şifreyi sorar, komut satırına yazma
gh secret set TEST_KEY_ALIAS            # gmcebi-test
gh secret set TEST_KEY_PASSWORD
rm gm-cebi-test.jks.base64
```

| Secret | İçerik |
|---|---|
| `TEST_KEYSTORE_BASE64` | Test keystore dosyasının base64 hâli |
| `TEST_KEYSTORE_PASSWORD` | Keystore şifresi |
| `TEST_KEY_ALIAS` | Anahtar adı (yukarıda `gmcebi-test`) |
| `TEST_KEY_PASSWORD` | Anahtar şifresi |

Dördü de varsa iş akışı keystore'u çalıştırıcının geçici klasörüne (çalışma alanının dışına) çözer,
Gradle'a `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
`ANDROID_KEY_PASSWORD` ortam değişkenleriyle verir (`android/app/build.gradle.kts`), APK'ların debug
anahtarıyla imzalanmadığını `apksigner` ile denetler ve iş sonunda dosyayı siler. Günlüğe yalnızca
sertifikanın adı ve SHA-256 parmak izi yazılır, hiçbir şifre yazılmaz.

Biri bile eksikse APK eskisi gibi debug anahtarıyla imzalanır. İş günlüğünde eksik secret adlarıyla
bir uyarı çıkar, ön-sürüm notunun en üstünde de "debug imzalı: önceki sürümün üzerine kurulamaz, önce
yedek al" yazar.

**Anahtar değişirse** (ilk kez eklendiğinde de) cihazdaki sürüm farklı imzalı olduğu için yeni APK
üzerine kurulmaz: her test kullanıcısı **bir kez** Ayarlar → Yedekleme → "Yedek al" ile yedek alır,
eski uygulamayı kaldırır, yenisini kurar ve yedeği geri yükler. Sonraki etiketler yerinde güncellenir.
Anahtarı bu yüzden değiştirme; ilk eklediğin sürümün notunda test grubuna bunu söyle.

### Üretime terfi etmeden önce

Play Console'daki "Sürümü yükselt" (promote) düğmesi test kanalındaki AAB'yi olduğu gibi üretime
taşır. Test AAB'sinde **GM Paketi ücretsiz açık** (`GMCEBI_GM_PACK=true`). Üretime çıkmadan önce:

- [ ] GM Paketi kararı verildi (ücretsiz mi, satın alma mı); gerekirse `GMCEBI_GM_PACK=false` ile
      yeni bir AAB derlendi;
- [ ] gizlilik politikası ve mağaza metinlerindeki yer tutucular (`<İLETİŞİM VE SİLME E-POSTASI — SAHİBİ
      DOLDURACAK>` / `<CONTACT AND DELETION EMAIL — OWNER TO FILL IN>`, `<YAYIN TARİHİ>`, geliştirici
      adı, telif, destek URL'si) dolduruldu, politika herkese açık bir adreste;
- [ ] derleme çevrimdışı mı, çevrimiçi sahneli mi (`NC_API_URL`) karar verildi ve mağaza metni,
      gizlilik politikası ve veri güvenliği formu ona göre seçildi: çevrimdışı derlemede bugünkü
      metinler; çevrimiçi sahneli derlemede `listing-*.md` sonundaki "değişen cümleler", politikadaki
      "Çevrimiçi sahne" bölümü (giriş paragrafı da değişir) ve `play-data-safety.md`'deki "Çevrimiçi
      sahne açık derleme" cevapları;
- [ ] iOS: IPA yükleme öncesi denetimi yapıldı (`docs/ios-testflight.md`, B.3).

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

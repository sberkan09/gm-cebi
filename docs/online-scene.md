# Çevrimiçi sahne: çizimden savaş haritası resmi (NeuraCraft Cloud)

GM savaş haritasına araziyi kabaca çizer, uygulama çizimi NeuraCraft Cloud'a gönderir ve gelen
resmi haritanın alt katmanı yapar. Jetonları, ızgarayı ve sırayı uygulama resmin üstüne kendisi
çizer. Servisin belgesi: neuracraft-cloud `docs/partners/gm-cebi.md` (servisin davranışı için esas
alınan kaynak).

**Özellik isteğe bağlıdır.** Uygulama çevrimdışı çalışmaya devam eder. Servis yoksa, hata verirse ya
da kota dolduysa harita çizim ve jetonlarla aynı şekilde sürer.

## Derleme

Özellik yalnızca iki değer verilen derlemelerde görünür:

```bash
flutter run \
  --dart-define=NC_API_URL=http://10.0.2.2:8080 \   # emülatörden geliştirici makinesi
  --dart-define=NC_CLIENT_ID=nc_client_…
```

- **Değerler verilmezse** (mağaza ve test APK'si bugün böyle): arayüzde hiçbir iz yok. Android
  manifestinde **İnternet izni de yok**. `android/app/build.gradle.kts`, `NC_API_URL` verildiğinde
  `src/online/AndroidManifest.xml`'i (yalnızca `INTERNET`) birleştirir. Yerelde iki release APK
  derlenip `aapt2 dump permissions` ile doğrulandı.
- **Test APK (GitHub):** `release-apk` iş akışı (`v*-test*` etiketi), depoda `NC_API_URL` ve
  `NC_CLIENT_ID` **değişkenleri** (Settings → Secrets and variables → Actions → Variables) varsa
  çevrimiçi sahneyi açar; yoksa APK eskisi gibi tamamen çevrimdışıdır. Play ve TestFlight derlemeleri
  gizlilik beyanları güncellenene kadar çevrimdışı kalır.
- **APK'de gizli bir şey yok.** İstemci kimliği (`nc_client_…`) herkese açıktır ve tek başına hiçbir
  yetki vermez: kullanıcı e-postasına gelen kodla giriş yapar, uygulama o kullanıcıya ait kısa ömürlü
  token'lar alır (aşağıda "Giriş"). Bu yüzden gizli değer (secret) değil, değişkendir. Eski uygulama
  token'ı (`nc_app_…`) ve `X-End-User` başlığı tamamen kaldırıldı. **`v*-test*` etiketleri ancak bu
  derlemeyle yeniden güvenli:** daha eski bir commit'ten etiketlenen APK'nin içinde uygulama token'ı
  olabilir. Servis tarafında `partner.js --require-end-user-tokens on` açılınca eski derlemeler
  "güncelleme gerekiyor" der ve eski token iptal edilebilir. `partner:manage` token'ı **asla**
  uygulamaya girmez.
- **Debug derlemeleri** düz `http` ile yerel API'ye bağlanabilir (`src/debug`: cleartext). Release
  derlemelerinde `NC_API_URL` `https` değilse özellik kapalı sayılır (`NcConfig.isConfigured`).
- **iOS:** `https` için ek ayar gerekmiyor. Simülatörde `http://localhost` denenirse ATS ayarı
  gerekebilir. Mağaza derlemesine istisna eklenmedi.

## Giriş (neuracraft-cloud #48)

Giriş yalnızca çevrimiçi özellik ilk kullanıldığında istenir: "Sahneyi canlandır" → onay → (giriş
yapılmamışsa) giriş sayfası → mod sayfası. Aynı sayfa Ayarlar → Çevrimiçi sahne → "Çevrimiçi sahne
hesabı"ndan da açılır.

1. **E-posta** → "Kod gönder": `POST /v1/auth/email/start {client_id, email, locale: "tr"}` →
   `202 {expiresIn: 600, resendAfter: 60}`. Uygulama adresi kabaca denetler (`a@b.c`), gerisini
   sunucu yapar (`auth.invalid_email`).
2. **6 haneli kod** → "Giriş yap": `POST /v1/auth/email/verify {client_id, email, code}` →
   `{accessToken: nc_eu_…, expiresIn: 3600, refreshToken: nc_rt_…, endUser: {id: eu_…}}`.
   "Kodu yeniden gönder" `resendAfter` saniye geri sayar. Hatalar sayfada satır içinde gösterilir.
3. **Her istek** `Authorization: Bearer nc_eu_…` taşır; `X-End-User` yok. Giriş çağrıları (dördü de)
   JSON gövdeli ve `Authorization` başlıksızdır.
4. **Yenileme:** erişim token'ı bir saat geçerli. Süresi dolmak üzereyse istekten önce, sunucu
   `401 auth.token_expired` derse istekten sonra `POST /v1/auth/token {client_id, grantType:
   "refresh_token", refreshToken}` ile yenilenir ve istek **bir kez** tekrarlanır (JSON uçları, SSE
   bağlantısı ve indirmenin ilk isteği). Yenileme token'ı her seferinde değişir ve iki kez
   kullanılırsa giriş biter; bu yüzden yenileme **tek uçuşludur**: aynı anda 401 alan istekler aynı
   yenilemeyi bekler, eski token'la dönen geç bir istek yeni token'ı hemen alır.
5. **Çıkış:** "Çıkış yap" önce süren işi iptal edip oturumu kapatır (token hâlâ geçerliyken), sonra
   token'ları siler ve `POST /v1/auth/revoke` dener (çevrimdışıysa yine çıkılır).
6. **Hesabı silme:** "Hesabımı sil" (onaylı) → `DELETE /v1/me`: sunucu kullanıcıyı, ona ait her şeyi
   ve tüm token'larını hemen siler. Sonra yerel token'lar, uygulamadaki çevrimiçi resimler ve onay
   silinir. Sunucuya ulaşılamazsa hata gösterilir, hesap ve resimler kalır. Giriş yapılmamışken
   yalnızca yerel "Uygulamadaki çevrimiçi resimleri sil" görünür.
7. **Kota:** Ayarlar'da `GET /v1/me` ile "Bugün: 3/20 harita" (çevrimdışıysa satır sessizce gizlenir).

**Saklama:** token'lar `flutter_secure_storage` ile Keychain (iOS, `first_unlock_this_device`: yedeğe
ve yeni cihaza gitmez) ve Android Keystore'da. Kullanıcının yazdığı e-posta yalnızca Ayarlar'da
göstermek için aynı kayıtta, cihazda kalır. Android otomatik yedeklemesi açık olduğu için
`sharedpref` alanı yedekten ve cihazdan cihaza aktarımdan çıkarıldı
(`res/xml/backup_rules.xml`, `data_extraction_rules.xml`): Keystore anahtarı cihazdan çıkmadığı için
geri yüklenen bir kopya çözülemezdi. Kayıt yine de okunamazsa (ör. geri yükleme sonrası) uygulama
çıkış yapılmış sayar ve kaydı siler.

**Kod:** `lib/data/neuracraft/auth.dart` (düz Dart: `NcAuthApi`, `NcTokens`, `NcTokenStore`,
`NcTokenManager`), `lib/features/online_scene/account.dart` (`SecureTokenStore`, `ncAccountProvider`,
çıkış ve hesap silme), `lib/ui/widgets/sign_in_sheet.dart`.

### Hata → tepki

| Kod | Uygulama |
|---|---|
| `401 auth.token_expired` | yenile, isteği bir kez tekrarla |
| `401 auth.refresh_invalid`, `auth.token_revoked` | çıkış yapılmış sayılır, token'lar silinir; oturum **boşta** (kapalı değil); haritada "Oturumun sona erdi, tekrar giriş yap" + "Giriş yap" |
| `403 auth.end_user_blocked` | özellik bu kullanıcı için kapalı (oturum "Kapalı"); uygulama yeniden başlayana kadar |
| `400 auth.client_invalid`, `401 auth.end_user_token_required`, `auth.scope_missing`, `auth.required` | özellik "güncelleme gerekiyor" ile kapanır (`authInvalid`) |
| `503 auth.sign_in_unavailable` | "Giriş şu an yapılamıyor; kod e-postası gönderilemiyor…" (e-posta sağlayıcısı henüz kurulmadıysa bugün böyle) |
| `400 auth.invalid_email` | "Bu e-posta adresi geçerli görünmüyor." |
| `400 auth.code_invalid` (`attemptsLeft`) | "Kod yanlış; N deneme hakkın kaldı." |
| `400 auth.code_expired` | "Kodun süresi doldu ya da çok kez yanlış girildi. Yeni kod iste." |
| `429 auth.code_rate_limited` (`retryAfter`) | "Çok fazla kod istendi; N saniye sonra tekrar dene." |
| `429 quota.partner_daily` | "GM Cebi'nin bugünkü harita hakkı doldu, yarın tekrar dene." |

Diğer kodlar eskisi gibi (`messages.dart`).

## Geliştirme sunucusu

neuracraft-cloud'da `docker compose` en kolay yol (`README.md`). Elle kurulum (Postgres, Node 22,
CMake) ve bu dalda kullanılan ayarlar:

```bash
# neuracraft-cloud içinde
npm ci && npm run build
cmake -S worker -B worker/build -DCMAKE_BUILD_TYPE=Release && cmake --build worker/build -j
export DATABASE_URL=postgres://nc@127.0.0.1:5433/neuracraft WORKER_TOKENS=dev-worker INTERACTIVE_ON_CPU=1
node apps/api/dist/src/main.js &                                  # CAPACITY_PROVIDER boş: hiç GPU kiralanmaz
curl -X POST -H 'content-type: application/json' -d '{"email":"gm-cebi@example.test","password":"…"}' localhost:8080/v1/auth/signup
node apps/api/dist/src/cli/partner-client.js --email gm-cebi@example.test --name "GM Cebi"   # nc_client_… yazar
node apps/api/dist/src/cli/partner.js --email gm-cebi@example.test --daily-jobs 20 --partner-daily-jobs 300 --timezone Europe/Istanbul
# küçük test modelleri (resim anlamsız, akış gerçek):
for m in "tests/assets/tiny/sd --kind sd --slug dreamshaper-8" "tests/assets/tiny/controlnet --kind controlnet --slug controlnet-scribble" \
         "tests/assets/tiny/lcm-lora.safetensors --kind lora --slug lcm-lora-sd15" "tests/assets/tiny/taesd --kind taesd --slug taesd" \
         "tests/assets/nsfw-tiny --kind onnx --entry nsfw.onnx --slug nsfw-classifier"; do
  node apps/api/dist/src/cli/add-model.js $m --license test; done
API_URL=http://127.0.0.1:8080 WORKER_TOKEN=dev-worker worker/build/neuracraft-worker &
```

Uygulamanın istemcisini gerçek sunucuya karşı deneyen betik:

```bash
# e-postaya gelen kodu betik stdin'den sorar
NC_API_URL=http://127.0.0.1:8080 NC_CLIENT_ID=nc_client_… NC_EMAIL=sen@example.com dart run tool/nc_smoke.dart path/to/sketch.png [out.png]
# e-posta yerine önceki çalıştırmanın yazdığı yenileme token'ı
NC_API_URL=… NC_CLIENT_ID=… NC_REFRESH_TOKEN=nc_rt_… dart run tool/nc_smoke.dart sketch.png
# canlı servis: kota adımını atlar (GPU harcamaz); sonda hesabı siler
NC_SMOKE_PRODUCTION=1 NC_SMOKE_DELETE_ACCOUNT=1 NC_API_URL=https://api.neuracraft.app NC_CLIENT_ID=… NC_EMAIL=… dart run tool/nc_smoke.dart sketch.png out.png
```

Betik şunları sırayla dener:
- giriş: bozuk e-posta (`auth.invalid_email`), kod gönderme, yanlış kod, stdin'den okunan kodla giriş
  (ya da `NC_REFRESH_TOKEN` ile yenileme);
- `GET /v1/me`; bozuk token → `auth.required`;
- şablon sürümü; oturum açma, heartbeat ve kapatma;
- Türkçe tarifle iş gönderme, SSE ile bekleme;
- 302 yönlendirmeli indirme (token depolamaya gitmez);
- bildirim ve iptal; `not_found`;
- yenileme (iki token da değişir); kota (`NC_SMOKE_PRODUCTION=1` değilse) ve `session.closed`;
- sonda: `NC_SMOKE_DELETE_ACCOUNT=1` ise `DELETE /v1/me` ve silinen hesabın yenileme token'ının
  reddi; değilse eski yenileme token'ının ikinci kullanımı (`auth.refresh_invalid`) ve bir sonraki
  çalıştırma için yeni yenileme token'ı.

2026-11-09'da (uygulama token'lı eski sürüm) yerel API + CPU işçisi + küçük modellerle tüm kontroller
geçti. Girişli sürüm henüz gerçek sunucuya karşı çalıştırılmadı: canlı servis bugün
`503 auth.sign_in_unavailable` dönüyor (e-posta sağlayıcısı kurulmadı).

## Mimari

| Katman | Dosya | Görev |
|---|---|---|
| Veri | `lib/data/neuracraft/client.dart` | HTTP istemcisi. Kimlik başlıkları, hata modeli, uçlar, SSE okuyucu ve yoklama yedeği, elle takip edilen yönlendirme. UI doğrudan HTTP çağırmaz. |
| | `auth.dart` | Giriş çağrıları, token modeli ve deposu, tek uçuşlu yenileme (`NcTokenManager`) |
| | `errors.dart`, `models.dart`, `config.dart` | `code` + `params` → `NcReaction`; yanıt tipleri; `--dart-define` |
| Özellik | `lib/features/online_scene/online_settings.dart` | Aç/kapa, onay (drift `settings`); sağlayıcılar |
| | `account.dart` | Güvenli token deposu, hesap durumu, çıkış, hesap silme, kota |
| | `session_controller.dart` | Oturum yaşam döngüsü (aşağıda) |
| | `scene_controller.dart` | Gönder, bekle, indir, kaydet; yeniden deneme kuralları; bildirim |
| | `messages.dart` | Türkçe mesajlar (her hata kodu için), durum etiketleri, onay metni |
| Arayüz | `lib/ui/widgets/online_scene.dart` | Oturum kapsamı, durum şeridi, "Sahneyi canlandır" sayfası, bildirim sayfası |
| | `lib/ui/widgets/sign_in_sheet.dart` | Giriş sayfası (e-posta → kod) |
| | `lib/ui/screens/map_screen.dart`, `settings_screen.dart` | Bağlantı noktaları |
| Veritabanı | `map_scenes` (şema 3) | Sonuç PNG'si karşılaşmaya bağlı saklanır (sunucu 7 gün sonra siler). Bildirilen resim `hidden`. |

### Oturum

- **Ne zaman açılır:** savaş haritası açılınca. GPU soğuksa ısınması ~75 sn (yedek veri merkezinde
  ~120 sn) sürüyor; çizim gönderilirken açmak geç kalır. Onay verilmeden ve giriş yapılmadan hiç
  açılmaz.
- **Heartbeat:** `heartbeatSeconds`'ta bir, yalnızca uygulama ön plandayken
  (`AppLifecycleState.resumed`). Arka planda durur, dönünce hemen bir heartbeat gider.
- **`410 session.closed`:** sessizce yeni oturum açılır (uygulama arka plandaysa ön plana dönünce).
  Sunucu bugün 410'u yalnızca heartbeat'te döndürüyor; iş gönderiminde gelirse diye istek bir kez
  tekrarlanacak şekilde de hazır.
- **Haritaya geri dönüş:** bekleme süresi içinde haritaya dönülürse aynı oturum sürer; hemen bir
  heartbeat gider ve heartbeat'ler yeniden başlar.
- **Kapanış:** haritadan çıkıldıktan **5 dakika sonra** `DELETE`. GM haritayı kapatıp hemen geri
  açarsa ısınmış GPU boşa gitmesin diye. Özellik kapatılınca, çıkış yapılınca ya da hesap silinince
  oturum hemen kapanır.
- **Giriş biterse** (sunucu çıkış yaptırırsa) oturum boşta kalır, yeniden denenmez; yeniden giriş
  yapılınca açılır. **Engellenen kullanıcı** ve **eski derleme** (`authInvalid`) için oturum kapalıdır
  ("Kapalı" / "Güncelleme gerekiyor").

### İş

- Gönderilen PNG, `renderTerrainPng` ile **jetonsuz katmandan** üretilir: siyah mürekkep, beyaz
  zemin, 512×512.
- Varsayılan mod `map`. Tarif boşsa genel bir İngilizce prompt gider (servis `narrative` ya da
  `prompt` istiyor). İstemci her işte bildiği şablon sürümünü (`version: 1`) gönderir.
- **Bekleme:** SSE ile. Akış açılamazsa, erken koparsa ya da 45 sn boyunca hiç satır gelmezse
  (sunucu 15 sn'de bir ping atar) saniyede bir yoklamaya düşülür. Yoklama ağ hatalarında geri
  çekilerek 5 kez yeniden dener. Sunucu ilk olayı gönderip sonra abone olduğu için, arada biten bir
  işin son olayı kaçabilir; bu da sessizlik süresiyle yakalanır.
- **İptal:** gönderim sürerken iptal edilirse, dönen iş sunucuda da hemen iptal edilir (koşmaz,
  kotadan düşmez). Ayarlar'dan kapatma, çıkış ve hesap silme de süren işi iptal eder.
- **Karşılaşma:** resim, çizimin ait olduğu karşılaşmaya kaydedilir. İş sürerken yeni karşılaşma
  başlarsa resim yeni karşılaşmaya eklenmez.
- **Yeniden deneme:**
  - `limit.concurrent_jobs` / `rate_limited`: 3 sn bekleyip en çok 2 kez;
  - beklenmeyen iş hatası: yeni seed ile 1 kez, sonra sessizce vazgeç;
  - `content.flagged` / `content.unchecked`: kullanıcıya söylenir, ücret alınmaz.
- **Görünüm:** resim alt katman; ızgara ve jetonlar üstte. Resim üstündeyken çizime başlanırsa
  görünüm kendiliğinden çizime döner. "Resim" düğmesiyle ikisi arasında geçilir.

## Gizlilik ve mağaza beyanları

Bu özellik **açık bir derleme** mağazaya gittiği gün aşağıdakiler değişmeli. Bugünkü mağaza
hazırlığı (PR #4) çevrimdışı derleme içindir. Hazır metinler: `docs/store/privacy-policy-*.md`
("Çevrimiçi sahne" bölümü), `docs/store/play-data-safety.md` ("Çevrimiçi sahne açık derleme"),
`docs/ios-testflight.md` (App Privacy).

Kaynak: neuracraft-cloud `docs/PRIVACY.md` ve `docs/partners/gm-cebi.md` ("Privacy").

- **Ne gider:** çizim ve tarif; giriş için e-posta adresi.
- **E-posta:** yalnızca giriş kodunu göndermek için kullanılır; kodu Brevo (AB) gönderir (adres, kod
  ve "GM Cebi"). NeuraCraft adresi saklamaz, yalnızca HMAC özetini, rastgele kullanıcı numarasını
  (`eu_…`) ve kayıt / son görülme zamanlarını saklar. Ad ve mağaza hesabı yok. Uygulama adresi yalnızca
  cihazda, göstermek için tutar.
- **Saklama süreleri:** çizim 24 saat, resim 7 gün, tarif iş bittikten 24 saat sonrasına kadar.
- **Nerede:** işler AB'deki GPU'larda çalışır.
- **Alt işleyiciler:** tarif metni, hiçbir kimlik olmadan, İngilizce prompt yazmak için Anthropic'e
  (ABD) gidebilir; Brevo (AB) kod e-postalarını gönderir.
- **KVKK:** AB de yurt dışı sayılır; yurt dışına aktarım belirtilmeli.
- **Silme:** "Hesabımı sil" (Ayarlar) `DELETE /v1/me` ile hesabı ve sunucudaki her şeyi **hemen**
  siler; GM Cebi'nin sunucusu gerekmez. Google Play ve App Store'un istediği uygulama içi hesap silme
  budur.
- **Play "Veri güvenliği":** Kişisel bilgiler → **E-posta adresi** (hesap yönetimi, uygulama işlevi;
  zorunlu değil, yalnızca çevrimiçi sahne için), **Fotoğraflar ve videolar → diğer resimler**
  (çizim), **Uygulama etkinliği → diğer kullanıcı içeriği** (tarif). Kurulum kimliği artık yok.
  Reklam ya da pazarlama için paylaşım yok; hizmet sağlayıcıya (işleyici) aktarım Play'e göre
  "paylaşım" sayılmaz. Aktarımda şifreli: evet. Silme: uygulama içinden, hemen. Hesap silme bağlantısı
  (Play'in istediği web adresi) için gizlilik politikasındaki "Hesabını silme" bölümü kullanılabilir.
- **Apple App Privacy:** "Data Not Collected" artık doğru değil. Contact Info → **Email Address**
  (App Functionality; kimliğe bağlı: evet, hesap için), User Content → Photos or Videos / Other User
  Content (App Functionality); "Used to Track You": hayır. Uygulama içi hesap silme var (App Store
  5.1.1(v)).
- **Google Play yapay zeka içerik politikası:** uygulama içi "Bildir" düğmesi var (resim menüsü).
- **Mağaza kontrol betiği:** `tool/check_store_build.sh` İnternet iznini hata sayar. Çevrimiçi
  derleme için `tool/check_store_build.sh --online <aab>` kullanılır; bu seçenekle izin *beklenir*.
  `release-aab` iş akışı bugün çevrimdışı derlediği için seçeneksiz çalışır.

## Bilinen sınırlar

- **Şablon sürümü kontrolü:** istemci her işte `version: 1` gönderiyor; sunucu bir gün sürüm 1'i
  desteklemeyi bırakırsa işler genel hata mesajıyla reddedilir. `supportsSketchToScene()` hazır,
  ama henüz uygulama açılışında çağrılmıyor.

- **Bildirim ve gizleme:** neuracraft-cloud #40'tan beri bildirilen resim sahibinden de gizleniyor
  (`GET /v1/assets/{id}/content` → 404, işin `outputs` listesinden ve `GET /v1/assets`'ten düşüyor;
  inceleme temiz çıkarsa geri geliyor). Uygulama yerel kopyayı yine her durumda gizliyor.
- **Canlı servis (2026-11-09, `https://api.neuracraft.app`):** `tool/nc_smoke.dart`
  (`NC_SMOKE_PRODUCTION=1`) tüm adımları geçti.
  - Kapasite: oturum açılınca `warming` (eta 90 sn), 96 sn'de `ready`. Servisin güncel tahmini
    (#43): model önbelleğiyle ~75 sn, yedek veri merkezinde (`gpu.modelCache: false`) ~120 sn.
    Hangi GPU'nun çalıştığı `capacity.gpu` ve `job.gpu`'da (yalnızca günlük için; uygulama okumuyor).
  - İş: map modu, Türkçe tarif, 7,2 sn'de bitti (6 adım); 512×512 PNG yönlendirmeyle indi.
  - Bildirim sonrası resim 404; iptal `cancelled`; hata kodları beklendiği gibi.
  - Stok yokken kapasite `unavailable: no GPU available at the provider` ve iş
    `503 job.no_gpu_worker` döndü. Servis artık GPU türlerini sırayla deniyor (neuracraft-cloud #41).
- **Kalite (2026-11-10, neuracraft-cloud #42 sonrası):** harita modu artık kuşbakışı, aydınlık,
  düz bir savaş haritası çiziyor; daireler ağaç tepesi oluyor, düzen birebir korunuyor. Ama iki
  çizgi arasındaki nehir şeridi hâlâ su olmuyor (yürüme yolu ya da hendek oluyor, su yanındaki boş
  alana taşıyor); içini taramak, doldurmak ya da açıklamada belirtmek değiştirmedi. Ayrıntı ve
  resimler: [`online-scene/2026-11-10-map-mode.md`](online-scene/2026-11-10-map-mode.md).
  Uygulama harita modunda kısa bir çizim ipucu gösteriyor (ağaçlar daire; nehir, su ve küçük
  eşyalar açıklamada).
- **Cihaz:** gerçek telefon ya da tablette denenmedi.

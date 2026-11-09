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
  --dart-define=NC_APP_TOKEN=nc_app_…
```

- **Değerler verilmezse** (mağaza ve test APK'si bugün böyle): arayüzde hiçbir iz yok. Android
  manifestinde **İnternet izni de yok**. `android/app/build.gradle.kts`, `NC_API_URL` verildiğinde
  `src/online/AndroidManifest.xml`'i (yalnızca `INTERNET`) birleştirir. Yerelde iki release APK
  derlenip `aapt2 dump permissions` ile doğrulandı.
- **Token'ı depoya koyma.** Uygulama token'ı (`nc_app_…`) uygulamanın içinde gider ve APK'den
  çıkarılabilir. Bu yüzden yetkisi dar tutulur (`jobs:submit, jobs:read, assets:read`). Servis
  kurulum başına günlük kota ve dakikada 240 istek sınırı uygular. `partner:manage` token'ı **asla**
  uygulamaya girmez.
- **Debug derlemeleri** düz `http` ile yerel API'ye bağlanabilir (`src/debug`: cleartext). Release
  derlemeleri `https` ister.
- **iOS:** `https` için ek ayar gerekmiyor. Simülatörde `http://localhost` denenirse ATS ayarı
  gerekebilir. Mağaza derlemesine istisna eklenmedi.

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
node apps/api/dist/src/cli/create-token.js --email gm-cebi@example.test --kind app --name "GM Cebi dev"
node apps/api/dist/src/cli/partner.js --email gm-cebi@example.test --daily-jobs 20 --timezone Europe/Istanbul
# küçük test modelleri (resim anlamsız, akış gerçek):
for m in "tests/assets/tiny/sd --kind sd --slug dreamshaper-8" "tests/assets/tiny/controlnet --kind controlnet --slug controlnet-scribble" \
         "tests/assets/tiny/lcm-lora.safetensors --kind lora --slug lcm-lora-sd15" "tests/assets/tiny/taesd --kind taesd --slug taesd" \
         "tests/assets/nsfw-tiny --kind onnx --entry nsfw.onnx --slug nsfw-classifier"; do
  node apps/api/dist/src/cli/add-model.js $m --license test; done
API_URL=http://127.0.0.1:8080 WORKER_TOKEN=dev-worker worker/build/neuracraft-worker &
```

Uygulamanın istemcisini gerçek sunucuya karşı deneyen betik:

```bash
NC_API_URL=http://127.0.0.1:8080 NC_APP_TOKEN=nc_app_… dart run tool/nc_smoke.dart path/to/sketch.png [out.png]
```

Betik şunları sırayla dener:
- şablon sürümü;
- oturum açma, heartbeat ve kapatma;
- Türkçe tarifle iş gönderme, SSE ile bekleme;
- 302 yönlendirmeli indirme (token depolamaya gitmez);
- bildirim ve iptal;
- `not_found`, `partner.end_user_required`, `auth.required`, `quota.end_user_daily` ve
  `session.closed`.

2026-11-09'da yerel API + CPU işçisi + küçük modellerle tüm kontroller geçti.

## Mimari

| Katman | Dosya | Görev |
|---|---|---|
| Veri | `lib/data/neuracraft/client.dart` | HTTP istemcisi. Kimlik başlıkları, hata modeli, uçlar, SSE okuyucu ve yoklama yedeği, elle takip edilen yönlendirme. UI doğrudan HTTP çağırmaz. |
| | `errors.dart`, `models.dart`, `config.dart`, `install_id.dart` | `code` + `params` → `NcReaction`; yanıt tipleri; `--dart-define`; kurulum kimliği (UUID v4) |
| Özellik | `lib/features/online_scene/online_settings.dart` | Aç/kapa, onay, kurulum kimliği (drift `settings`); sağlayıcılar |
| | `session_controller.dart` | Oturum yaşam döngüsü (aşağıda) |
| | `scene_controller.dart` | Gönder, bekle, indir, kaydet; yeniden deneme kuralları; bildirim |
| | `messages.dart` | Türkçe mesajlar (her hata kodu için), durum etiketleri, onay metni |
| Arayüz | `lib/ui/widgets/online_scene.dart` | Oturum kapsamı, durum şeridi, "Sahneyi canlandır" sayfası, bildirim sayfası |
| | `lib/ui/screens/map_screen.dart`, `settings_screen.dart` | Bağlantı noktaları |
| Veritabanı | `map_scenes` (şema 3) | Sonuç PNG'si karşılaşmaya bağlı saklanır (sunucu 7 gün sonra siler). Bildirilen resim `hidden`. |

### Oturum

- **Ne zaman açılır:** savaş haritası açılınca. GPU'nun ısınması ~40 sn sürüyor; çizim gönderilirken
  açmak geç kalır. Onay verilmeden hiç açılmaz, yani kurulum kimliği bile gönderilmez.
- **Heartbeat:** `heartbeatSeconds`'ta bir, yalnızca uygulama ön plandayken
  (`AppLifecycleState.resumed`). Arka planda durur, dönünce hemen bir heartbeat gider.
- **`410 session.closed`:** sessizce yeni oturum açılır. İş gönderirken gelirse istek bir kez
  tekrarlanır.
- **Kapanış:** haritadan çıkıldıktan **5 dakika sonra** `DELETE`. GM haritayı kapatıp hemen geri
  açarsa ısınmış GPU boşa gitmesin diye. Özellik kapatılınca ya da "Verilerimi sil" denince oturum
  hemen kapanır.
- **`401`:** özellik "Güncelleme gerekiyor" ile kapanır, yeniden denenmez.

### İş

- Gönderilen PNG, `renderTerrainPng` ile **jetonsuz katmandan** üretilir: siyah mürekkep, beyaz
  zemin, 512×512.
- Varsayılan mod `map`. Tarif boşsa genel bir İngilizce prompt gider (servis `narrative` ya da
  `prompt` istiyor). İstemci her işte bildiği şablon sürümünü (`version: 1`) gönderir.
- **Bekleme:** SSE ile. Akış açılamazsa ya da erken koparsa saniyede bir yoklamaya düşülür.
- **Yeniden deneme:**
  - `limit.concurrent_jobs` / `rate_limited`: 3 sn bekleyip en çok 2 kez;
  - beklenmeyen iş hatası: yeni seed ile 1 kez, sonra sessizce vazgeç;
  - `content.flagged` / `content.unchecked`: kullanıcıya söylenir, ücret alınmaz.
- **Görünüm:** resim alt katman; ızgara ve jetonlar üstte. Resim üstündeyken çizime başlanırsa
  görünüm kendiliğinden çizime döner. "Resim" düğmesiyle ikisi arasında geçilir.

## Gizlilik ve mağaza beyanları

Bu özellik **açık bir derleme** mağazaya gittiği gün aşağıdakiler değişmeli. Bugünkü mağaza
hazırlığı (PR #4) çevrimdışı derleme içindir.

- **Gizlilik politikası** (`docs/store/privacy-policy-*.md`, PR #4): "veri toplamıyoruz" yerine şu
  bölüm eklenmeli:
  - çizim ve tarif sunucuya gider;
  - hesap yok, yalnızca rastgele kurulum kimliği;
  - saklama süreleri: çizim 24 saat, resim 7 gün, tarif iş bittikten 24 saat sonrasına kadar;
  - işler AB'de çalışır;
  - tarif kimliksiz olarak Anthropic'e (ABD) gidebilir;
  - KVKK'ya göre yurt dışına aktarım: AB de yurt dışı sayılıyor.
  - Kaynak: neuracraft-cloud `docs/PRIVACY.md`.
- **Play "Veri güvenliği":**
  - Toplanan veri: **Fotoğraflar ve videolar → diğer resimler** (çizim), **Uygulama
    etkinliği → diğer kullanıcı içeriği** (tarif), **Cihaz kimlikleri → diğer** (kurulum kimliği).
  - Amaç: uygulama işlevi.
  - Paylaşım: hizmet sağlayıcı (işleyici). Play'in tanımına göre bu "paylaşım" sayılmaz.
  - Aktarımda şifreli: evet (https).
  - Silme: uygulama içinde yerel silme; sunucuda en geç 7 gün.
- **Apple App Privacy:** "Data Not Collected" artık doğru değil. User Content (Photos, Other) ve
  Identifiers (Device ID) beyan edilmeli; "Used to Track You": hayır.
- **Google Play yapay zeka içerik politikası:** uygulama içi "Bildir" düğmesi var (resim menüsü).
- **Mağaza kontrol betiği:** PR #4'teki `tool/check_store_build.sh` İnternet iznini hata sayar.
  Çevrimiçi derleme için betiğe bir istisna (`--online`) eklenmeli. İki PR birleşince yapılacak.

### "Verilerimi sil"

- **Yerel:** çevrimiçi resimler silinir, yeni kurulum kimliği üretilir, onay yeniden istenir, oturum
  kapanır.
- **Sunucu:** `DELETE /v1/partner/end-users/{id}` yalnızca `partner:manage` token'ıyla yapılabilir;
  GM Cebi'nin sunucusu yok. Bu yüzden uygulama "sunucudaki veriler en geç 7 gün içinde kendiliğinden
  silinir" diye açıklar. Eski kimlik artık bu kuruluma bağlanamaz.

## Bilinen sınırlar

- **Bildirim ve gizleme:** servis belgesi "bildirilen resim herkes için gizlenir" diyor. Bugünkü
  neuracraft-cloud kodu (`5bb960e`) bildirimi kaydediyor (`reported_at`), ama
  `GET /v1/assets/{id}/content` sahibine resmi vermeye devam ediyor (`tool/nc_smoke.dart` bunu
  gösteriyor). Uygulama yerel kopyayı her durumda gizliyor. Servis tarafında düzeltilmeli.
- **Kalite:** gerçek GPU ve gerçek modellerle bu dalda deneme yapılmadı; yerel deneme küçük test
  modelleriyle. Kalite ve süre için neuracraft-cloud `docs/reports/sketch-to-scene.md`.
- **Cihaz:** gerçek telefon ya da tablette denenmedi.

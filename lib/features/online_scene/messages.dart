/// Turkish texts of the online scene feature: one message per service
/// reaction (docs/partners/gm-cebi.md, "Errors"), capacity labels and the
/// consent / privacy text.
library;

import '../../data/neuracraft/errors.dart';
import '../../data/neuracraft/models.dart';
import 'session_controller.dart';

String _hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// The message shown for a failed request or job.
String messageFor(NcException e) {
  if (e is NcJobFailed) {
    if (e.flagged) return 'Bu çizim ya da tarif için resim üretilemedi; başka bir çizim ya da tarif dene.';
    if (e.unchecked) return 'İçerik kontrolü yapılamadı, tekrar dene.';
    return 'Resim üretilemedi.';
  }
  if (e is NcApiException) {
    switch (e.reaction) {
      case NcReaction.dailyQuota:
        final at = e.resetsAt;
        return at == null ? 'Bugünkü harita hakkın doldu, yarın yenilenir.' : 'Bugünkü harita hakkın doldu, ${_hhmm(at)} saatinde yenilenir.';
      case NcReaction.signInRequired when e.code == NcApiException.signInRequired:
        return 'Çevrimiçi sahne için giriş yap.';
      case NcReaction.codeInvalid when e.attemptsLeft != null:
        return e.attemptsLeft! > 0 ? 'Kod yanlış; ${e.attemptsLeft} deneme hakkın kaldı.' : 'Kod yanlış. Yeni kod iste.';
      case NcReaction.codeRateLimited when e.retryAfter != null:
        return 'Çok fazla kod istendi; ${_wait(e.retryAfter!)} sonra tekrar dene.';
      default:
        break;
    }
  }
  return messageForReaction(e.reaction);
}

String _wait(int seconds) => seconds < 120 ? '$seconds saniye' : '${(seconds / 60).ceil()} dakika';

String messageForReaction(NcReaction r) => switch (r) {
      NcReaction.bug => 'Bir hata oluştu, resim üretilemedi.',
      NcReaction.textRefused => 'Bu tarif kabul edilmedi, farklı anlatmayı dene.',
      NcReaction.authInvalid => 'Çevrimiçi resim için uygulamanın güncellenmesi gerekiyor.',
      NcReaction.signInRequired => 'Oturumun sona erdi, tekrar giriş yap.',
      NcReaction.blocked => 'Çevrimiçi sahne bu hesap için kapatıldı.',
      NcReaction.signInUnavailable => 'Giriş şu an yapılamıyor; kod e-postası gönderilemiyor. Biraz sonra tekrar dene.',
      NcReaction.invalidEmail => 'Bu e-posta adresi geçerli görünmüyor.',
      NcReaction.codeInvalid => 'Kod yanlış.',
      NcReaction.codeExpired => 'Kodun süresi doldu ya da çok kez yanlış girildi. Yeni kod iste.',
      NcReaction.codeRateLimited => 'Çok fazla kod istendi; biraz bekleyip tekrar dene.',
      NcReaction.allowanceExhausted => 'Bu kullanıcı için hak kalmadı.',
      NcReaction.serviceOutOfCredits => 'Çevrimiçi resim geçici olarak kullanılamıyor.',
      NcReaction.notFound => 'Resim bulunamadı; 7 günden eski olabilir.',
      NcReaction.sessionClosed => 'Bağlantı yenilendi, tekrar dene.',
      NcReaction.dailyQuota => 'Bugünkü harita hakkın doldu.',
      NcReaction.partnerDailyQuota => "GM Cebi'nin bugünkü harita hakkı doldu, yarın tekrar dene.",
      NcReaction.busy => 'Şu an çok yoğun, biraz sonra dene.',
      NcReaction.retrySoon => 'Şu an çok yoğun, birkaç saniye sonra tekrar dene.',
      NcReaction.noGpu => 'Çevrimiçi resim şu an kullanılamıyor. Harita çevrimdışı çalışmaya devam ediyor.',
      NcReaction.serviceSettingUp => 'Servis hazırlanıyor, biraz sonra dene.',
      NcReaction.offline => 'Sunucuya ulaşılamadı. Harita çevrimdışı çalışmaya devam ediyor.',
      NcReaction.unknown => 'Resim üretilemedi.',
    };

/// The small status label on the map.
String capacityLabel(OnlineSessionState s) {
  switch (s.phase) {
    case SessionPhase.idle:
      return 'Bağlı değil';
    case SessionPhase.opening:
      return 'Bağlanıyor…';
    case SessionPhase.disabled:
      return s.error == NcReaction.blocked ? 'Kapalı' : 'Güncelleme gerekiyor';
    case SessionPhase.failed:
      return s.error == NcReaction.offline ? 'Çevrimdışı' : 'Şu an kullanılamıyor';
    case SessionPhase.open:
      if (s.error == NcReaction.offline) return 'Bağlantı sorunlu';
      return switch (s.capacity) {
        NcCapacityReady() => 'Hazır',
        NcCapacityWarming(:final etaSeconds?) => 'Hazırlanıyor (~$etaSeconds sn)',
        NcCapacityWarming() => 'Hazırlanıyor',
        NcCapacityUnavailable() || null => 'Şu an kullanılamıyor',
      };
  }
}

/// Shown under the send button when the picture may not come.
String? capacityWarning(OnlineSessionState s) => switch ((s.phase, s.capacity)) {
      (SessionPhase.open, NcCapacityWarming(:final etaSeconds)) =>
        'Sunucu hazırlanıyor${etaSeconds == null ? '' : ' (~$etaSeconds sn)'}. Çizimin sırada bekler.',
      (SessionPhase.open, NcCapacityUnavailable()) || (SessionPhase.failed, _) =>
        'Şu an kullanılamıyor; gönderebilirsin ama resim gelmeyebilir.',
      _ => null,
    };

/// Nothing is drawn on the map yet.
const drawFirstMessage = 'Önce haritaya araziyi çiz.';

/// Only painted areas, and the service does not take the region layer.
const linesNeededMessage = 'Çizgiyle de çiz: sunucu henüz alanları desteklemiyor.';

/// Only painted areas, in atmosphere mode (the region layer is for map mode).
const linesNeededForAtmosphereMessage = 'Çizgiyle de çiz: boyanan alanlar yalnızca Harita modunda gönderilir.';

const reportReasonLabels = {
  ReportReason.sexual: 'Cinsel içerik',
  ReportReason.violenceGore: 'Şiddet ya da kan',
  ReportReason.hate: 'Nefret içeriği',
  ReportReason.minorSafety: 'Çocukların güvenliği',
  ReportReason.other: 'Diğer',
};

const consentTitle = 'Çevrimiçi sahne';

/// First-use consent and the privacy summary in Settings
/// (docs/partners/gm-cebi.md, "Privacy"; neuracraft-cloud docs/PRIVACY.md).
const consentText = '''Çizdiğin arazi ve yazdığın tarif, resme dönüştürülmek için NeuraCraft Cloud sunucusuna gönderilir. Jetonlar gönderilmez; onları uygulama resmin üstüne çizer.

• Çevrimiçi sahne için (yalnızca bu özellik için) e-posta adresinle giriş yaparsın. Adres yalnızca giriş kodunu göndermek için kullanılır; kodu Brevo (AB) gönderir.
• NeuraCraft adresin kendisini saklamaz, yalnızca bir özetini (HMAC) ve sana verilen rastgele bir kullanıcı numarasını saklar.
• Sunucu çizimi 24 saat, resmi 7 gün, tarifi iş bittikten sonra 24 saat saklar.
• İşler AB'deki sunucularda çalışır. Tarifin İngilizceye çevrilmesi için metin, hiçbir kimlik bilgisi olmadan Anthropic'e (ABD) gönderilebilir.
• Hesabını Ayarlar'dan istediğin zaman silebilirsin; sunucudaki her şey hemen silinir. Özelliği de Ayarlar'dan kapatabilirsin.''';

/// The sign-in sheet's explanation.
const signInInfo = 'Çevrimiçi sahne için e-posta adresinle giriş yap. Adresine 6 haneli bir kod gelir; adres yalnızca bu kodu göndermek için kullanılır.';

/// "Hesabımı sil" confirmation.
const deleteAccountInfo =
    'Hesabın ve sunucudaki tüm çizimlerin, resimlerin ve tariflerin hemen silinir. Uygulamadaki çevrimiçi resimler de silinir. Bu işlem geri alınamaz.';

/// "Uygulamadaki çevrimiçi resimleri sil" (signed out: local only).
const deleteLocalInfo =
    'Bu cihazdaki çevrimiçi resimler silinir. Sunucudaki verilerin için giriş yapıp "Hesabımı sil"i kullan.';

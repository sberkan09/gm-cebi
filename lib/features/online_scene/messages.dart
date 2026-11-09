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
  if (e is NcApiException && e.reaction == NcReaction.dailyQuota) {
    final at = e.resetsAt;
    return at == null ? 'Bugünkü harita hakkın doldu, yarın yenilenir.' : 'Bugünkü harita hakkın doldu, ${_hhmm(at)} saatinde yenilenir.';
  }
  return messageForReaction(e.reaction);
}

String messageForReaction(NcReaction r) => switch (r) {
      NcReaction.bug => 'Bir hata oluştu, resim üretilemedi.',
      NcReaction.textRefused => 'Bu tarif kabul edilmedi, farklı anlatmayı dene.',
      NcReaction.authInvalid => 'Çevrimiçi resim için uygulamanın güncellenmesi gerekiyor.',
      NcReaction.allowanceExhausted => 'Bu kullanıcı için hak kalmadı.',
      NcReaction.serviceOutOfCredits => 'Çevrimiçi resim geçici olarak kullanılamıyor.',
      NcReaction.notFound => 'Resim bulunamadı; 7 günden eski olabilir.',
      NcReaction.sessionClosed => 'Bağlantı yenilendi, tekrar dene.',
      NcReaction.dailyQuota => 'Bugünkü harita hakkın doldu.',
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
      return 'Güncelleme gerekiyor';
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

• Hesap yok; ad ya da e-posta toplanmaz. Tek kimlik, bu kurulum için üretilen rastgele bir numaradır.
• Sunucu çizimi 24 saat, resmi 7 gün, tarifi iş bittikten sonra 24 saat saklar.
• İşler AB'deki sunucularda çalışır. Tarifin İngilizceye çevrilmesi için metin, kimlik bilgisi olmadan Anthropic'e (ABD) gönderilebilir.
• Bu özelliği Ayarlar'dan istediğin zaman kapatabilirsin.''';

const deleteDataInfo =
    'Uygulamadaki çevrimiçi resimler silinir ve yeni bir kurulum kimliği üretilir. Sunucudaki çizimler ve resimler en geç 7 gün içinde kendiliğinden silinir.';

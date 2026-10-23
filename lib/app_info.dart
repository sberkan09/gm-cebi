/// App identity and license texts.
///
/// The app name and package name are not final (docs/decisions.md, "Onay
/// bekleyenler"); change them only here, in pubspec.yaml and in the platform
/// projects.
library;

/// Working name. Never "D&D" / "Dungeons & Dragons" (brief: say "5e uyumlu").
const appName = 'GM Cebi';

/// Keep in sync with `version:` in pubspec.yaml.
const appVersion = '0.1.0';

const appTagline = '5e uyumlu Türkçe FRP yardımcısı';

/// Required by the SRD 5.2.1 license (PDF p. 1). Must stay verbatim.
const srdAttribution =
    'This work includes material from the System Reference Document 5.2.1 (“SRD 5.2.1”) by '
    'Wizards of the Coast LLC, available at https://www.dndbeyond.com/srd. The SRD 5.2.1 is '
    'licensed under the Creative Commons Attribution 4.0 International License, available at '
    'https://creativecommons.org/licenses/by/4.0/legalcode.';

/// CC-BY 4.0 asks to indicate changes. Wording awaits the product owner's
/// approval (docs/decisions.md).
const translationNotice =
    'Türkçe metinler SRD 5.2.1\'in çevirisidir ve orijinal metinden türetilmiş, değiştirilmiş bir '
    'çalışmadır. Çeviriler henüz tamamlanmamıştır; çevrilmemiş kayıtlar İngilizce gösterilir.';

const compatibilityNotice = 'GM Cebi 5e uyumludur (“5E compatible”).';

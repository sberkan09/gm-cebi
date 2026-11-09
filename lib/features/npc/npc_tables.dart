/// Tables for the NPC generator. Everything here is ORIGINAL content written
/// for GM Cebi (docs/decisions.md): no name or table is copied or translated
/// from a published book, and no setting, deity or character name appears.
/// Species names are the SRD 5.2.1 species in the app glossary's Turkish.
///
/// Edit freely: `test/features/npc_generator_test.dart` checks minimum sizes,
/// duplicates and a list of forbidden names.
library;

/// SRD 5.2.1 species, glossary Turkish (pipeline/glossary.csv, category "soy").
enum NpcSpecies {
  insan('İnsan'),
  elf('Elf'),
  cuce('Cüce'),
  bucukluk('Buçukluk'),
  gnom('Gnom'),
  ork('Ork'),
  ejderdogan('Ejderdoğan'),
  tiefling('Tiefling'),
  goliat('Goliat');

  const NpcSpecies(this.label);
  final String label;
}

/// Given names of one species. Neutral names are used for either gender.
class NameSet {
  const NameSet({required this.female, required this.male, required this.neutral, required this.family});

  final List<String> female;
  final List<String> male;
  final List<String> neutral;

  /// Family names, clan names or house compounds.
  final List<String> family;
}

const npcNames = <NpcSpecies, NameSet>{
  // Turkic / Anatolian-sounding, mostly invented.
  NpcSpecies.insan: NameSet(
    female: [
      'Ayçil', 'Selvin', 'Gülbike', 'Yeldem', 'Ilgın', 'Suyla', 'Altınay', 'Akça', //
      'Çiçekay', 'Sevra', 'Aysın', 'Kumru', 'Narsel', 'Ezgin', 'Tolunay', 'Alkım',
    ],
    male: [
      'Tolun', 'Batuk', 'Erkut', 'Ilbay', 'Kortan', 'Sungur', 'Alpkan', 'Kayalp', //
      'Arıkan', 'Tunçer', 'Serhun', 'Baytal', 'Ilgar', 'Okyay', 'Yalvaç', 'Börkan',
    ],
    neutral: ['Ekin', 'Evren', 'Derin', 'Kayra', 'Erinç', 'Yansı'],
    family: [
      'Demirocaklı', 'Kırçiçek', 'Taşyürek', 'Gökbilek', 'Yeldeğirmen', 'Çamdibi', 'Kuzgunoğlu', 'Bakırtaş', //
      'Tuzlakaya', 'Akkavak', 'Dumanlı', 'Sarıbaşak', 'Kayaköklü', 'Ayazoğlu', 'Gümüşdere', 'Çakmaktaşı',
      'Ocaklı', 'Yamaçlı', 'Değirmentaşı', 'Söğütlü', 'Karabaşak', 'Kartaloğlu', 'Ballıdere', 'Göktaşlı',
      'Kırlangıçlı', 'Ardıçlı', 'Pusatlı', 'Kordemir', 'Yalazoğlu', 'Taşkapılı',
    ],
  ),
  // Flowing vowels; family names are poetic Turkish compounds.
  NpcSpecies.elf: NameSet(
    female: [
      'Aelira', 'Siviel', 'Lunaye', 'Nalaen', 'Ysolei', 'Evaniel', 'Saeryn', 'Thalira', //
      'Meliassa', 'Orivaine', 'Vaelora', 'Ilaeve', 'Soraviel', 'Elunei', 'Naiaris',
    ],
    male: [
      'Ilvaren', 'Saelorin', 'Oreleth', 'Lirandel', 'Vaelion', 'Emrion', 'Ithavar', 'Nolaris', //
      'Seravian', 'Aluvien', 'Caelivar', 'Yrilian', 'Daeravel', 'Eolindar', 'Miraeth',
    ],
    neutral: ['Aeli', 'Lirien', 'Sylvae', 'Iniel', 'Orae', 'Venaril'],
    family: [
      'Gümüşkavak', 'Çiyçiçeği', 'Aysüzen', 'Yeldalı', 'Sabahsisi', 'Kuğugölü', 'Rüzgârsesi', 'Akasyagölge', //
      'Ilıkpınar', 'Yıldızkökü', 'Söğütsesi', 'Mehtapdalı', 'Kamışezgi', 'Sisvadisi', 'Şebnemli', 'Yaprakdansı',
      'Ormanışığı', 'Ilgınkökü', 'Kırağıçiçeği', 'Serinçağlayan',
    ],
  ),
  // Hard consonants; family names are craft and stone compounds.
  NpcSpecies.cuce: NameSet(
    female: [
      'Kadrun', 'Bretta', 'Gorma', 'Hekra', 'Brekka', 'Dorgit', 'Ketra', 'Brudda', //
      'Morgra', 'Halvra', 'Ingrud', 'Skadda', 'Tusgrid', 'Durka', 'Gritta',
    ],
    male: [
      'Tokdur', 'Gürbak', 'Karduk', 'Dökmer', 'Kozbak', 'Torgut', 'Bükdar', 'Gortak', //
      'Dragmur', 'Brakdur', 'Durgan', 'Hakmur', 'Kragdin', 'Borduk', 'Grumdal',
    ],
    neutral: ['Krag', 'Dorn', 'Bukra', 'Tobrek', 'Gand'],
    family: [
      'Örsdöven', 'Taşkıran', 'Demirsakal', 'Kayabilek', 'Bakırçekiç', 'Kömürgöz', 'Madenkazan', 'Çekiçdil', //
      'Kalkanbaş', 'Tunçbilek', 'Dağkökü', 'Ocakbekçisi', 'Cevherbulan', 'Kazmasap', 'Mermerdiş', 'Pasbıyık',
      'Taşkulak', 'Kızılörs', 'Granitkol', 'Körükçü',
    ],
  ),
  // Short and round; neutral names are cosy Turkish nicknames.
  NpcSpecies.bucukluk: NameSet(
    female: [
      'Dimi', 'Lupa', 'Pemma', 'Mirri', 'Tilla', 'Totta', 'Hanni', 'Lenna', //
      'Tuli', 'Fenni', 'Lisi', 'Bonna', 'Cimi', 'Melle', 'Ninni',
    ],
    male: [
      'Tobin', 'Pimbo', 'Lorti', 'Bunto', 'Fesko', 'Madro', 'Tummo', 'Dalmo', //
      'Fendu', 'Gullo', 'Vilmo', 'Juppo', 'Nesko', 'Ruffo', 'Pakko',
    ],
    neutral: ['Fındık', 'Çörek', 'Pıtır', 'Kekik', 'Lokum'],
    family: [
      'Ballıkaşık', 'Tatlıçörek', 'Kekikli', 'Fındıkdibi', 'Yumuşakçayır', 'Demlikçi', 'Elmadalı', 'Kestanekabuğu', //
      'Bostanlı', 'Tereyağlı', 'Sıcakfırın', 'Bezelyeli', 'Pekmezci', 'Mantardere', 'Çimenayak', 'Yorganlı',
    ],
  ),
  // Quick, clicky syllables; family names are tinker compounds.
  NpcSpecies.gnom: NameSet(
    female: [
      'Zelli', 'Pinzi', 'Tikka', 'Nobli', 'Fipsa', 'Killa', 'Zarra', 'Mibbet', //
      'Tazzi', 'Linnik', 'Biksi', 'Dorni', 'Ozzla', 'Fenzi', 'Klikka',
    ],
    male: [
      'Bimbol', 'Tokkel', 'Nizzo', 'Zarbin', 'Dimbur', 'Fennik', 'Gimbek', 'Pazzik', //
      'Korbin', 'Orvik', 'Zappo', 'Ribbik', 'Tumzel', 'Vobbik', 'Kizbert',
    ],
    neutral: ['Pim', 'Zuzu', 'Tok', 'Nib', 'Fiz', 'Çıtır'],
    family: [
      'Çarkçevir', 'Pirinçburun', 'Dişlidüğme', 'Zemberekli', 'Yaylıkurgu', 'Vidasöken', 'Mercekgöz', 'Pervaneci', //
      'Kıvılcımcı', 'Çıngıraklı', 'Pusulabaz', 'Bobinli', 'Saatkurdu', 'Tıkırtılı', 'Kaldıraçlı', 'Mantarşapka',
    ],
  ),
  // Guttural; family names are deed names.
  NpcSpecies.ork: NameSet(
    female: [
      'Gorza', 'Brakka', 'Vorsha', 'Kazhra', 'Ozga', 'Durra', 'Yarga', 'Ruhka', //
      'Ragza', 'Ashka', 'Morva', 'Zugra', 'Baska', 'Urgana', 'Kelga',
    ],
    male: [
      'Karrok', 'Durzag', 'Morgut', 'Urtak', 'Gazrul', 'Hrokk', 'Vorgan', 'Tuzgar', //
      'Okkar', 'Zarguk', 'Rakmor', 'Yagrun', 'Draknak', 'Grushum', 'Bakzul',
    ],
    neutral: ['Ruk', 'Zag', 'Orra', 'Krell', 'Grath'],
    family: [
      'Demirdiş', 'Kırıkmızrak', 'Kurtyele', 'Taşyumruk', 'Kemikkıran', 'Közgözlü', 'Dağyaran', 'Yaralıkalkan', //
      'Kartalpençe', 'Kalınboyun', 'Tunçgırtlak', 'Kırkyara', 'Buzdişi', 'Kurtkardeş', 'Demirtırnak', 'Tozkoşan',
    ],
  ),
  // Hissing, regal; family names are clan compounds.
  NpcSpecies.ejderdogan: NameSet(
    female: [
      'Zovra', 'Kethrin', 'Vyrsa', 'Arzhel', 'Velthra', 'Ziraya', 'Teshara', 'Ozhira', //
      'Varisha', 'Ithrae', 'Kalzira', 'Rezhna', 'Suvrah', 'Myrkesh', 'Belsari',
    ],
    male: [
      'Varzhul', 'Korvesh', 'Thrazar', 'Mezhrik', 'Azhvan', 'Kelthrax', 'Raskar', 'Turvesh', //
      'Zharokh', 'Ozrin', 'Brevax', 'Saldrak', 'Vorimar', 'Hezkar', 'Draekon',
    ],
    neutral: ['Azh', 'Kesh', 'Vor', 'Rhyx', 'Zul'],
    family: [
      'Közkanat',
      'Alevpul',
      'Bakırpençe',
      'Şimşekgırtlak',
      'Kızıldumanlı',
      'Altınpul',
      'Tunçkuyruk',
      'Yıldırımdişli', //
      'Zehirsis', 'Buzsoluk', 'Közyürek', 'Ateşkalkan', 'Pulzırh', 'Gökgürleyen', 'Ejdersancak', 'Kayapençe',
    ],
  ),
  // Smoky, sharp; family names are dusk-and-ember compounds or invented houses.
  NpcSpecies.tiefling: NameSet(
    female: [
      'Azrava', 'Selmeth', 'Zevira', 'Velkis', 'Kalvira', 'Ravessa', 'Sevrine', 'Malveth', //
      'Tezrin', 'Ilvexa', 'Vorena', 'Zelith', 'Ashveth', 'Kerissa', 'Moravi',
    ],
    male: [
      'Malrik', 'Vexan', 'Draveth', 'Soreth', 'Azkan', 'Teshvan', 'Orzhel', 'Vashko', //
      'Ishkar', 'Zorvan', 'Kelmoth', 'Hadrex', 'Nerith', 'Valzar', 'Morgeth',
    ],
    neutral: ['Vesh', 'Kor', 'Nyr', 'Azel', 'Rhen', 'Ixa'],
    family: [
      'Közgölge', 'Kıvılcımkuyruk', 'Dumanlıyol', 'Kızılgece', 'Külkapı', 'Gecekuzgunu', 'Kükürtlü', 'Sisçizgi', //
      'Karayemin', 'Alazoğlu', 'Yanıkmühür', 'Mumalevi', 'Zifirdere', 'Vaskarel', 'Morezzan', 'Draventis',
    ],
  ),
  // Broad, open syllables; family names are mountain deed names.
  NpcSpecies.goliat: NameSet(
    female: [
      'Tayra', 'Kelmi', 'Ardana', 'Sarpa', 'Yurla', 'Menkea', 'Olvai', 'Tessaka', //
      'Ulmara', 'Kaveya', 'Silvai', 'Narka', 'Ebrai', 'Oruna', 'Vekta',
    ],
    male: [
      'Tagrun', 'Kolbar', 'Udrak', 'Harmuk', 'Oskan', 'Baykor', 'Kayrak', 'Burgan', //
      'Otrak', 'Semrek', 'Akdur', 'Tavkan', 'Gorvai', 'Ilkar', 'Mavrak', 'Bora', 'Ayaz', 'Sarp', 'Yamaç',
    ],
    neutral: ['Tuna', 'Orun', 'Tarvi', 'Ekai', 'Ulun'],
    family: [
      'Kayaomuz', 'Buzbilek', 'Zirveyürüyen', 'Taşkucak', 'Çığsesi', 'Kartalyuva', 'Doruksoylu', 'Yamaçkoşan', //
      'Fırtınasırtı', 'Uçurumbekçisi', 'Göğekuzanan', 'Granityürek', 'Bulutdelen', 'Sarpadım', 'Karkıran',
    ],
  ),
};

/// Nicknames that replace the family name, written before the given name
/// ("Kara Tolun", "Tek Göz Brekka").
const npcEpithets = [
  'Kara', 'Deli', 'Koca', 'Çakır', 'Sarı', 'Kızıl', 'Uzun', 'Sessiz', 'Tek Göz', 'Yaşlı', //
  'Tilki', 'Gümüş', 'Yalın', 'Gezgin', 'Çevik', 'Bilge', 'Ak', 'Kurnaz', 'Gölge', 'Demir',
];

const npcOccupations = [
  'Değirmenci', 'Kervan muhafızı', 'Han sahibi', 'Demirci', 'Balıkçı', 'Şifacı', 'Mezarcı', 'Kâtip', //
  'Tapınak bekçisi', 'Çoban', 'Kunduracı', 'Sokak çalgıcısı', 'Hamal', 'Seyyar satıcı', 'Arıcı', 'Ebe',
  'Tabakçı', 'Çömlekçi', 'Haritacı', 'Ok yapımcısı', 'Kayıkçı', 'Fırıncı', 'Gece bekçisi', 'Köy muhtarı',
  'Mumcu', 'Halı dokumacısı', 'Kuyumcu', 'Tefeci', 'Avcı', 'Tuzakçı', 'Simyacı çırağı', 'Kütüphaneci',
  'Falcı', 'Meddah', 'Köprü bekçisi', 'Gümrükçü', 'Seyis', 'Atlı haberci', 'Gemi aşçısı', 'Kömürcü',
  'Madenci', 'Taş ustası', 'Marangoz', 'Paralı asker', 'Emekli asker', 'Kaçakçı', 'Süngerci', 'Bahçıvan',
  'Konak kâhyası', 'Bağcı', 'Baharatçı', 'Terzi', 'Berber', 'Tellal', 'Hamam işletmecisi', 'Kervanbaşı',
  'Sınır nöbetçisi', 'Ödül avcısı', 'Tapınak rahibi', 'Dilenci',
];

/// One striking detail, for any gender. Details that do not fit a species
/// (hair on an Ejderdoğan) are listed in [npcAppearancesNotFor].
const npcAppearances = [
  'Sol kaşını ikiye bölen eski bir yara izi var.',
  'Gözleri farklı renkte: biri ela, biri gri.',
  'Parmaklarının hepsinde mürekkep lekesi var.',
  'Boynunda iplikle asılı paslı bir anahtar taşıyor.',
  'Saçlarına küçük kemik boncuklar örmüş.',
  'Hep fazla büyük bir paltonun içinde kayboluyor.',
  'Kolunda soluk bir harita dövmesi var.',
  'Avucunun içinde eski bir mühür izi var.',
  'Yüzü çillerle kaplı, burnu güneşten soyulmuş.',
  'Her zaman tek eldiven takıyor.',
  'Kulağında kocaman, uyumsuz bir küpe sallanıyor.',
  'Üzerinden hafif bir tarçın kokusu eksik olmuyor.',
  'Sırtında kendisinden büyük bir sepet taşıyor.',
  'Bir gözü sürekli kısık, sanki nişan alıyor.',
  'Elleri yaşından çok daha yaşlı görünüyor; nasırlı ve yaralı.',
  'Kıyafeti yamalı ve her yama başka renk.',
  'Şapkasına parlak yeşil bir kuş tüyü takmış.',
  'Kemerinde irili ufaklı bir düzine kese sallanıyor.',
  'İri yarı ama sesi beklenmedik kadar ince.',
  'Saçının bir tutamı bembeyaz, geri kalanı simsiyah.',
  'Hiç kırpmadan bakan soluk mavi gözleri var.',
  'Yürürken hafifçe aksıyor ve oymalı bir bastona dayanıyor.',
  'Burnu bir zamanlar kırılmış, yamuk kaynamış.',
  'Bileklerinde bakır bilezikler şıngırdıyor.',
  'Tırnaklarının altı hep toprak.',
  'Gülümseyince yanaklarında derin gamzeler beliriyor.',
  'Boynuna sardığı kırmızı atkıyı hiç çıkarmıyor.',
  'Kaşları o kadar gür ki gözlerini gölgeliyor.',
  'Çizmeleri ayna gibi parlak; geri kalan her şeyi pejmürde.',
  'Omzunda evcil bir kertenkele taşıyor.',
  'Yüzünün yarısını soluk bir doğum lekesi kaplıyor.',
  'Saçını topuz yapmış, içine iki kalem sokmuş.',
  'Bir parmağı eksik; kalan parmaklarının hepsinde yüzük var.',
  'Gözlerinin altında uykusuzluktan mor halkalar var.',
  'Cüppesinin eteği çamur ve kurumuş yosun içinde.',
  'Hep bir şey çiğniyor: kuru üzüm, kök, ot.',
  'Kollarında eski yanık izleri var; ocak başında büyüdüğü belli.',
  'Kıyafetleri pahalı ama modası çoktan geçmiş.',
  'Belinde süslü ama kını boş bir kılıç kemeri var.',
  'Teni denizcilerinki gibi tuzdan ve güneşten sertleşmiş.',
  'Saçlarına minik ziller takmış; yürüdükçe çınlıyor.',
  'Kalın, yuvarlak camlı gözlüğünü durmadan burnunun üstüne itiyor.',
  'Bir kulağının ucu kesik.',
  'Üstü başı at ahırı kokuyor.',
  'Dudağının kenarında yeni dikilmiş küçük bir yara var.',
];

/// General details that do not fit a species: Ejderdoğanlar have scales, no
/// hair, eyebrows or outer ears. Every entry must be in [npcAppearances].
const npcAppearancesNotFor = <NpcSpecies, Set<String>>{
  NpcSpecies.ejderdogan: {
    'Saçlarına küçük kemik boncuklar örmüş.',
    'Yüzü çillerle kaplı, burnu güneşten soyulmuş.',
    'Saçının bir tutamı bembeyaz, geri kalanı simsiyah.',
    'Kaşları o kadar gür ki gözlerini gölgeliyor.',
    'Sol kaşını ikiye bölen eski bir yara izi var.',
    'Saçını topuz yapmış, içine iki kalem sokmuş.',
    'Saçlarına minik ziller takmış; yürüdükçe çınlıyor.',
    'Gülümseyince yanaklarında derin gamzeler beliriyor.',
    'Teni denizcilerinki gibi tuzdan ve güneşten sertleşmiş.',
    'Bir kulağının ucu kesik.',
  },
};

/// Extra appearance details that only make sense for one species. The dwarf
/// beard line is for any gender (docs/decisions.md).
const npcSpeciesAppearances = <NpcSpecies, List<String>>{
  NpcSpecies.insan: [
    'Elinde yıpranmış bir boncuk dizisini durmadan çeviriyor.',
    'Saçlarını kınayla kızıla boyamış.',
    'Yanağında küçük, mavi bir dövme noktası var.',
  ],
  NpcSpecies.elf: [
    'Kulaklarının ucuna ince gümüş halkalar takmış.',
    'Saçlarına örülmüş yapraklar hiç solmuyor gibi.',
    'Yaşını kestirmek imkânsız; bakışları çok eski.',
  ],
  NpcSpecies.cuce: [
    'Sakalını üç kalın örgüye ayırmış, uçlarına demir halkalar takmış.',
    'Tenine işlemiş demir tozu hiç çıkmıyor.',
    'Bir kaşı ocak ateşinde yanmış, yarım kalmış.',
  ],
  NpcSpecies.bucukluk: [
    'Ceplerinden durmadan ekmek kırıntısı dökülüyor.',
    'Kafasına fazla büyük gelen bir hasır şapka giyiyor.',
    'Yanakları hep elma gibi kırmızı.',
  ],
  NpcSpecies.gnom: [
    'Alnında kocaman bir büyüteç gözlük duruyor.',
    'Saçları her yöne dikilmiş, sanki az önce yıldırım çarpmış.',
    'Kemerinde minik aletlerle dolu bir şerit taşıyor.',
  ],
  NpcSpecies.ork: [
    'Alt dişlerinden birini altınla kaplatmış.',
    'Omzunda eski, derin bir pençe izi var.',
    'Kollarındaki dövmeler bir aile hikâyesi anlatıyor.',
  ],
  NpcSpecies.ejderdogan: [
    'Pulları yer yer bakır rengine dönmüş.',
    'Burun deliklerinden ara sıra ince bir duman süzülüyor.',
    'Boynundaki birkaç pul kopmuş; yerinde pembe bir yara dokusu var.',
  ],
  NpcSpecies.tiefling: [
    'Boynuzlarından biri kırık; ucuna gümüş bir kapak taktırmış.',
    'Kuyruğunun ucuna küçük bir zil bağlamış.',
    'Gözleri baştan sona altın rengi.',
  ],
  NpcSpecies.goliat: [
    'Tenindeki koyu desenler bir dağ silsilesini andırıyor.',
    'Kapılardan geçerken hep eğiliyor; alnında bunun izleri var.',
    'Kollarında kırağı rengi damarlar seçiliyor.',
  ],
};

/// Lowercase predicates; one or two are joined ("Meraklı, kolay güler.").
/// Pairs in [npcOppositeTraits] never appear together.
const npcTraits = [
  'meraklı', 'kuşkucu', 'aşırı kibar', 'kolay güler', 'alıngan', 'sabırsız', 'cömert', 'cimri', //
  'dedikoduya bayılır', 'sözünün eri', 'övülmeyi sever', 'utangaç', 'gösterişçi', 'iyimser', 'karamsar',
  'herkese lakap takar', 'sessiz ama dikkatli', 'aceleci', 'titiz', 'dağınık', 'batıl inançlı',
  'kahramanlara hayran', 'otoriteye güvenmez', 'hayvanlara herkesten çok güvenir', 'pazarlıkçı', 'romantik',
  'ukala', 'yardımsever', 'kindar', 'affedici', 'korkak ama dürüst', 'inatçı', 'maceraperest', 'evine düşkün',
  'çabuk sıkılır', 'aşırı temkinli', 'neşeli', 'asık suratlı', 'fırsatçı', 'sadık', 'kurnaz', 'saf',
  'kibirli', 'alçakgönüllü', 'hırslı', 'tembel', 'çalışkan', 'hesapçı', 'sözünü esirgemez', 'dalgın',
  'lafı dolandırır', 'kural düşkünü', 'yemeğe düşkün', 'yabancılara mesafeli', 'çocuklarla arası iyi',
  'sırlara bayılır', 'eski günleri özler', 'her şeyden bir hikâye çıkarır', 'rakamlara takıntılı',
  'şakacı', 'vicdanlı', 'kıskanç', 'gururlu',
];

/// Traits that contradict each other.
const npcOppositeTraits = [
  ('kindar', 'affedici'),
  ('cömert', 'cimri'),
  ('titiz', 'dağınık'),
  ('tembel', 'çalışkan'),
  ('kibirli', 'alçakgönüllü'),
  ('neşeli', 'asık suratlı'),
  ('kolay güler', 'asık suratlı'),
  ('şakacı', 'asık suratlı'),
  ('iyimser', 'karamsar'),
  ('kurnaz', 'saf'),
  ('kuşkucu', 'saf'),
  ('utangaç', 'gösterişçi'),
  ('aceleci', 'aşırı temkinli'),
  ('maceraperest', 'evine düşkün'),
  ('sözünü esirgemez', 'lafı dolandırır'),
  ('aşırı kibar', 'sözünü esirgemez'),
  ('sadık', 'fırsatçı'),
];

/// Epithets that contradict a trait ("Kurnaz" who is "saf").
const npcEpithetClashes = <String, Set<String>>{
  'Kurnaz': {'saf'},
  'Bilge': {'saf'},
  'Sessiz': {'dedikoduya bayılır', 'gösterişçi', 'sözünü esirgemez'},
  'Çevik': {'tembel'},
  'Deli': {'aşırı temkinli'},
  'Tilki': {'saf'},
};

const npcMotivations = [
  'Borcunu ödeyip ailesinin tarlasını geri almak istiyor.',
  'Yıllar önce kaybolan kardeşini arıyor.',
  'Adının bir şarkıda anılmasını istiyor.',
  'Ustasının yarım bıraktığı eseri tamamlamak istiyor.',
  'Köyünü yağmalayanlardan hesap sormak istiyor.',
  'Sakin, sıradan bir hayattan başka bir şey istemiyor.',
  'Lonca başkanlığına seçilmek için her şeyi yapar.',
  'Yıllar önce verdiği bir sözü tutmak zorunda olduğuna inanıyor.',
  'Dünyanın her köşesinde en az bir gece uyumak istiyor.',
  'Hastalanan çocuğu için şifa arıyor.',
  'Kasabadaki herkesin kendisine borçlu olmasını istiyor; iyilikle ya da parayla.',
  'Gördüğü tekrar eden bir rüyanın anlamını çözmek istiyor.',
  'Yıkılmaya yüz tutmuş tapınağın onarımı için para topluyor.',
  'Rakibinden daha iyi bir usta olduğunu kanıtlamak istiyor.',
  'Eski bir haritada işaretlenmiş yeri bulmak istiyor.',
  'Ailesinin lekelenen adını temize çıkarmak istiyor.',
  'Yeterince altın biriktirip denizin ötesine gitmek istiyor.',
  'Bildiği her şeyi yazıya geçirmeden ölmek istemiyor.',
  'Bölgedeki haydutların kökünü kazımak istiyor.',
  'Kendi hanını açmayı hayal ediyor.',
  'Bir zamanlar ihanet ettiği dostunun affını kazanmak istiyor.',
  'Doğanın dengesinin bozulduğuna inanıyor ve onu korumak istiyor.',
  'Gerçek ailesinin kim olduğunu öğrenmek istiyor.',
  'Güç istiyor; kim verirse versin, bedeli ne olursa olsun.',
  'Çırağını kendisinden daha iyi bir usta yapmak istiyor.',
  'Bu yılki hasat şenliğini kusursuz düzenlemek istiyor.',
  'Efsanelerdeki bir yaratığı kendi gözleriyle görmek istiyor.',
  'Kaybettiği şöhretini geri kazanmak istiyor.',
  'Kimseye muhtaç olmadan yaşamak istiyor.',
  'Eski yol arkadaşlarını son bir kez bir araya toplamak istiyor.',
  'Bilgiye ulaşmak istiyor; yasak olanına bile.',
  'Yetimhaneyi kapanmaktan kurtarmak istiyor.',
  'Herkesin kurallara uymasını istiyor; çünkü kurallar onu bir kez kurtarmış.',
  'Ölmeden önce doğduğu köye dönmek istiyor.',
  'Sevdiği kişinin ailesine layık görünmek istiyor.',
];

const npcFlawsAndSecrets = [
  'Kumar borcu yüzünden tehlikeli birilerine borçlu.',
  'Kendini tanıttığı kişi değil; adı da mesleği de uydurma.',
  'Kasabanın bekçibaşısına gizlice bilgi taşıyor.',
  'Bir cinayete tanık oldu ama sustu.',
  'Altın görünce sağduyusunu kaybediyor.',
  'Yalan söylerken kulakları kızarıyor.',
  'Yükseklikten ödü kopuyor.',
  'Gençliğinde bir haydut çetesinin üyesiydi.',
  'Mahzeninde bir şey saklıyor ve oraya kimseyi sokmuyor.',
  'Lanetli olduğuna inanıyor; belki de haklı.',
  'Gururu yüzünden asla yardım istemiyor.',
  'İçkiye karşı koyamıyor.',
  'Çaldığı bir yüzüğü hâlâ parmağında taşıyor.',
  'Rakip loncadan gizlice para alıyor.',
  'Kendi soyundan olmayanlara karşı önyargılı ve bunu zor saklıyor.',
  'Bir soylunun, kimsenin bilmediği çocuğu.',
  'Kötü haber getireni cezalandırıyor.',
  'Ölmüş sanılan biriyle hâlâ mektuplaşıyor.',
  'Herkesin önünde eleştirilmeye dayanamıyor.',
  'Büyü yeteneği olduğunu herkesten saklıyor.',
  'Gizemli bir yabancıyla yaptığı anlaşmanın bedelini henüz ödemedi.',
  'Verdiği sözleri hep son anda unutuyor.',
  'Tehlike anında önce kendini kurtarıyor.',
  'Köydeki salgını yanlışlıkla kendisinin başlattığını düşünüyor.',
  'Kendinden güçlü olana hemen boyun eğiyor.',
  'Başka bir kentte aranıyor; yüzü bir afişte.',
  'Bildiği gizli bir geçidi kimseye söylemiyor.',
  'Eskiden sahte ilaç satıyordu; biri bundan öldü.',
  'Hep en kolay yolu seçiyor, bedelini başkası ödese bile.',
  'Kıskançlık yüzünden en iyi dostunu ele verdi.',
  'Rüyalarında ona fısıldayan bir ses var.',
  'Parasını saymadan uyuyamıyor.',
  'Kimsenin bilmediği gizli bir cemiyete bağlı.',
  'Yıllar önce ödünç aldığı kitabı geri vermedi; sahibi bir büyücü.',
  'Her gece gizlice mezarlığa gidiyor.',
  'Kayıp bir mirasın tek vârisi olduğunu biliyor ama söylemiyor.',
];

const npcSpeechQuirks = [
  'Her cümleyi bir soruyla bitirir, değil mi?',
  'Kendinden üçüncü şahıs olarak bahseder.',
  'Atasözlerini hep yanlış söyler.',
  'Konuşurken durmadan boğazını temizler.',
  'Fısıltıyla konuşur; dinleyenler eğilmek zorunda kalır.',
  'Her şeyi yemek benzetmeleriyle anlatır.',
  'Sözcükleri uzatarak, şarkı söyler gibi konuşur.',
  'Lafın ortasında düşüncelere dalıp susar.',
  'Herkese "evlat" diye hitap eder.',
  'Eski, ağdalı bir dille konuşur: "Zât-ı âliniz ne arzu ederler?"',
  'Çok hızlı, nefes almadan konuşur.',
  'Her cümlesine bir sayı ya da tarih sıkıştırır.',
  'Kafiyeli konuşmaya çalışır; bazen başarır.',
  'Gülerken burnundan ses çıkarır.',
  'Her sözünü bir el hareketiyle vurgular.',
  'Bir lafı iki kez tekrarlar, iki kez tekrarlar.',
  'Koyu bir taşra ağzıyla konuşur.',
  'Tek kelimelik cevaplar verir.',
  'Her söze "Şimdi bak…" diye başlar.',
  'Yabancı sözcükler karıştırır; çoğunu yanlış yerde kullanır.',
  'Kötü haberi bile neşeyle verir.',
  'Sık sık derin derin iç çeker.',
  'Herkesin adını yanlış hatırlar, her seferinde başka türlü söyler.',
  'Ses tonu hiç değişmez; şaka mı yaptığı anlaşılmaz.',
  'Konuşurken gözlerini karşısındakinden hiç ayırmaz.',
  'Cümlelerini "…demek istediğim o" diye bağlar.',
  'Önemli bir şey söylemeden önce etrafı kolaçan eder.',
  'Her cümlesine "yemin ederim" ekler.',
  'Sözünü kesenlere parmak sallar.',
  'Sesli düşünür; aklından geçen her şeyi söyler.',
];

const npcHooks = [
  'Grubun aradığı haritanın yarısı onda; öbür yarısı rakibinde.',
  'Dün gece kasabanın dışında gördüğü ışıkları kimseye anlatamıyor; gruba anlatabilir.',
  'Kayıp bir kervanın tek kurtulanı.',
  'Gruptan, açılmamış bir mektubu uzak bir kente götürmelerini istiyor.',
  'Grubun peşindekilerin kim olduğunu biliyor; bu bilginin bir bedeli var.',
  'Mahzeninden geceleri tıkırtılar geliyor; aşağı inecek cesur birini arıyor.',
  'Çırağı üç gündür eve dönmedi.',
  'Karakterlerden birinin geçmişinden birini tanıyor ve ondan selam getirdi.',
  'Kuyunun suyu bir haftadır tuzlu; nedenini bulana ödül vaat ediyor.',
  'Alacağını tahsil etmek için yanında yürüyecek koruma arıyor.',
  'Eski bir mezarlıkta bulduğu tuhaf bir sikkeyi satmak istiyor.',
  'Yarın geceki düğünün bozulacağını biliyor; nasıl olacağını söylemiyor.',
  'Köprü yıkıldı; karşı kıyıya geçmenin başka bir yolunu biliyor.',
  'Gruba bedava yemek ve yatak teklif ediyor; karşılığını sonra isteyecek.',
  'Ormandaki eski kulenin anahtarı onda ama oraya gitmeye korkuyor.',
  'Kasabada salgın başladı; ilaç için gereken bitki dağın tepesinde.',
  'Bir soylunun düzenlediği yarışma için gizlice ortak arıyor.',
  'Karakterlerden birini, yıllar önce kaybettiği bir yakınına benzetiyor.',
  'Pazarda sattığı bir eşya lanetli çıktı; geri almak istiyor.',
  'Bekçiler onu haksız yere suçluyor; olayı gören bir tanık arıyor.',
  'Çalınan aile yadigârının nerede olduğunu biliyor ama oraya tek başına gidemez.',
  'Bir canavarın inini bulduğunu söylüyor; kanıtı da yanında.',
  'Kendi düğününden kaçmak için yardım istiyor.',
  'Elinde, karakterlerden birinin adının yazılı olduğu eski bir belge var.',
  'Gece yarısı kapısını çalan bir yabancıya kapıyı açtı; o günden beri tuhaf davranıyor.',
  'Göl kıyısında bulduğu yaralı bir yaratığı ahırında saklıyor.',
  'Lonca seçimlerinden önce rakibini gözden düşürecek bir kanıt arıyor.',
  'Bir sonraki dolunayda ne olacağını bildiğini söylüyor; kimse ona inanmıyor.',
  'Kayıp bir çocuğun izini sürüyor; izler kasabanın altındaki tünellere çıkıyor.',
  'Grubun taşıdığı bir eşyayı tanıyor ve onu almak için her şeyi teklif ediyor.',
  'Yola çıkacak bir elçiye eşlik edecek güvenilir birileri lazım; yollar haydut dolu.',
  'Han odasında unutulmuş bir sandığın sahibini arıyor.',
  'Yüz yıldır kapalı maden yeniden açıldı; ilk inenler geri dönmedi.',
];

/// NPC attitudes: the SRD "Influence" action's Friendly / Indifferent /
/// Hostile, glossary Turkish.
enum NpcAttitude {
  dostca('Dostça'),
  kayitsiz('Kayıtsız'),
  dusmanca('Düşmanca');

  const NpcAttitude(this.label);
  final String label;
}

/// How the attitude shows at the table.
const npcAttitudeNotes = <NpcAttitude, List<String>>{
  NpcAttitude.dostca: [
    'Grubu sıcak karşılıyor; ilk iyiliği kendisi yapar.',
    'Yardım etmeye hevesli; belki fazla hevesli.',
    'Grupla ortak bir düşmanları olduğunu düşünüyor.',
    'Karşılık beklemeden bildiklerini anlatır.',
    'Grubun adını duymuş ve onlara hayran.',
    'İlk sohbette çay ikram eder, ikincisinde sır verir.',
  ],
  NpcAttitude.kayitsiz: [
    'Kendi işine bakıyor; ikna edilmesi gerek.',
    'Bir iyiliğin karşılığını görmeden kılını kıpırdatmaz.',
    'Grubu ne seviyor ne sevmiyor; çok soru sorulunca sıkılıyor.',
    'Yardım eder ama işler sarpa sararsa ilk o kaçar.',
    'Önce grubun kimin tarafında olduğunu anlamak istiyor.',
    'Parası ödenirse dinler, ödenmezse duymaz.',
  ],
  NpcAttitude.dusmanca: [
    'Gruba güvenmiyor; her adımlarını izliyor.',
    'Grubun gelişini kendi çıkarlarına bir tehdit olarak görüyor.',
    'Kaba ve ters; ama kavgayı başkalarına bırakır.',
    'Karakterlerden birine karşı eski bir kin besliyor.',
    'Grubu başka birileriyle karıştırıyor ve inatla vazgeçmiyor.',
    'Gruptan kurtulmak için yetkililere şikâyet etmeye hazır.',
  ],
};

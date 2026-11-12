# Veri modeli

Şema `pipeline/gmcebi_pipeline/models.py` içinde pydantic ile tanımlı; bu belge
onun özetidir. Değişiklikte önce kodu, sonra bu belgeyi güncelle.

## Katmanlar

```
SRD PDF ──extract/parse──▶ data/source/<dataset>.json      (İngilizce, pydantic şeması)
                              │
                              ├──segments──▶ çeviri kuyruğu ──LLM──▶ translations/tm.jsonl
                              │                                     (cümle düzeyinde EN ↔ TR)
                              ▼
                  build_assets ──▶ assets/data/<dataset>.json  (EN + TR, uygulama okur)
```

## Ortak alanlar

Her kayıt:

| Alan | Tür | Açıklama |
|---|---|---|
| `id` | str | İngilizce addan slug (`fireball`). Veri kümesi içinde benzersiz. |
| `name` | str | Kayıt adı |
| `kind` | str | Kayıt türü (`spell`, `monster`, …) |
| `source.document` | str | Her zaman `SRD 5.2.1` |
| `source.page` / `page_end` | int | PDF sayfa numarası (basılı sayfa numarasıyla aynı) |
| `source.heading` | list[str] | Başlık yolu, dıştan içe (`["Spells", "Spell Descriptions", "Fireball"]`) |

Zengin metin `blocks` listesinde durur:

| Alan | Açıklama |
|---|---|
| `type` | `p` (paragraf) veya `table` |
| `text` | Hafif markdown: `**kalın**`, `*italik*`, `- ` madde, `### başlık` |
| `title`, `header`, `rows` | Tablolar için başlık, sütun adları ve hücreler (düz metin) |

`NamedText` = `{name, text}`: başlıklı paragraf (canavar özelliği, soy özelliği, durum etkisi).

## Veri kümeleri

| Dosya | Kayıt | Önemli alanlar |
|---|---|---|
| `rules_glossary` | `RuleEntry` | `tags` (`Action`, `Hazard`, `Area of Effect`, `Attitude`), `blocks`, `see_also` |
| `conditions` | `Condition` | `RuleEntry` + `effects: NamedText[]` (blocks'tan türetilir) |
| `spells` | `Spell` | `level` (0 = cantrip), `school`, `classes`, `casting_time`, `ritual`, `range`, `components{verbal,somatic,material,material_text}`, `duration`, `concentration`, `blocks`, `higher_levels`, `cantrip_upgrade` |
| `monsters` | `Monster` | `group` (aile başlığı), `size`, `creature_type`, `alignment`, `ac`, `ac_note`, `initiative`, `hp`, `hp_formula`, `speed`, `abilities{str..cha: {score, mod, save}}`, `details` (Skills, Resistances, Immunities, Senses, Languages, Gear…), `cr`, `xp`, `proficiency_bonus`, `traits`, `actions`, `bonus_actions`, `reactions`, `legendary_actions`, `section_intros` |
| `classes` | `CharacterClass` | `core_traits` (anahtar → değer), `blocks` (gelişim tablosu, büyü listeleri, seçenekler), `features: Feature[]`, `subclasses` (id listesi) |
| `subclasses` | `Subclass` | `class_id`, `blocks`, `features` |
| `species` | `Species` | `creature_type`, `size`, `speed`, `traits`, `blocks` (tablolar) |
| `backgrounds` | `Background` | `ability_scores`, `feat`, `skill_proficiencies`, `tool_proficiency`, `equipment` |
| `feats` | `Feat` | `category` (Origin / General / Fighting Style / Epic Boon), `prerequisite`, `repeatable`, `blocks` |
| `equipment` | `EquipmentItem` | `category` (weapon, armor, tool, gear, mount, vehicle), `subcategory`, `fields` (tablo sütunları: Damage, Properties, Mastery, Weight, Cost…), `blocks` |
| `weapon_properties` | `WeaponProperty` | `text` |
| `weapon_mastery` | `WeaponMastery` | `text` |

`Feature` = `{level, name, blocks}`.

## Çeviri belleği (`pipeline/translations/tm.jsonl`)

Her satır benzersiz bir İngilizce segment:

| Alan | Açıklama |
|---|---|
| `key` | `sha1(en)[:16]`; kayıt adları için `sha1("<dataset>\|<en>")` (ör. büyü "Shield" ≠ zırh "Shield") |
| `en` | İngilizce kaynak cümle |
| `tr` | Türkçe çeviri |
| `status` | `machine` / `reviewed` / `rejected` |
| `engine` | Üreten: model kimliği, `glossary` veya `human:<ad>` |
| `qc` | İçe aktarımda bulunan kalite bulguları (boş = temiz) |
| `refs` | Segmentin geçtiği en çok 3 yer (`dataset/id:path#n`) |

Segmentleme: `text`, `higher_levels`, `cantrip_upgrade`, `material_text` cümlelere
bölünür; diğer metin alanları (ad, süre, menzil, tablo hücresi) tek segmenttir.
Aynı İngilizce cümle bir kez çevrilir ve her yerde yeniden kullanılır.
`school`, `classes`, `tags` LLM'e gitmez, sözlükten eşlenir. `effects` ve
`see_also` çevrilmiş bloklardan ve başlık eşlemesinden yeniden üretilir.

## Uygulama asset'leri (`assets/data/`)

```json
{"dataset": "spells", "schema": 1, "count": 339, "tr_complete": 50, "tr_partial": 0,
 "records": [{"id": "fireball", "en": { … }, "tr": { … } | null,
              "tr_status": "complete" | "partial" | "none"}]}
```

`tr`, kaydın tam bir kopyasıdır; çevrilmemiş alanlar İngilizce kalır. `partial`
durumunda uygulama alan bazında "çeviri bekliyor" işareti gösterebilir.
Ayrıca `glossary.json` (arama ve terim ipuçları için) ve `manifest.json`
(sayımlar, boyutlar, lisans ve atıf metni) üretilir. Boyut bütçesi 10 MB; hat
aşımda durur.

## Yedek dosyası (uygulama verisi)

Kullanıcı verisi (drift/SQLite, `lib/db/database.dart`) Ayarlar → Yedekleme ile tek bir UTF-8 JSON dosyasına
alınır: `gm-cebi-yedek-YYYY-AA-GG.json` (`lib/features/backup/backup.dart`).

```json
{"format": "gm-cebi-backup", "version": 1, "schemaVersion": 5,
 "createdAt": "2026-11-12T11:05:00.000Z", "app": "1.0.0",
 "tables": {"notes": [{"id": 3, "title": "…", "pinned": false, "created_at": "2026-10-01T16:05:00.000Z", …}],
            "settings": […], "encounters": […], "combatants": […], "map_strokes": […], "map_scenes": […]}}
```

- Tablolar ve sütunlar drift'in tablo bilgisinden yazılır: yeni bir tablo ya da sütun kendiliğinden yedeğe girer.
  Bilerek dışarıda bırakılan tablo `backupExcludedTables` listesindedir (bugün boş); bir test, ikisinde de
  olmayan yeni tabloda ya da sütunda kırılır.
- Sütun adları SQL şemasındaki gibidir. Tarihler ISO-8601 UTC metin, blob'lar (resim PNG'si) base64, mantıksal
  değerler `true`/`false`; id'ler korunur (yabancı anahtarlar ve `initiativeActed` onlara bakar).
- Girmeyenler: cihaza bağlı ayarlar (`ncConsent`, `ncEnabled`, `gmPackOverride`, `lastBackupAt`), bildirilmiş ya da
  baytı olmayan resimler. Giriş bilgileri zaten veritabanında değil, güvenli depodadır.
- Geri yükleme her şeyi değiştirir: dosya önce baştan sona denetlenir, sonra tek işlemde tablolar silinip yedek
  satırları yazılır; bir hata olursa hiçbir şey değişmez. Bu cihazın cihaza bağlı ayarları kalır.
- `schemaVersion` uygulamanınkinden büyükse (ya da `version` > 1) reddedilir. Eski şema kabul edilir: dosyada
  olmayan tablolar boş, sütunlar varsayılan değerle gelir; bilinmeyen sütunlar yok sayılır. 50 MB üstü reddedilir.

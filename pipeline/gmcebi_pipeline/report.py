"""Generate review documents for the product owner.

  docs/glossary-review.md   the core glossary terms, grouped, with status and evidence
  docs/pilot-samples.md     pilot translation samples side by side + QC statistics
"""

from __future__ import annotations

import json
import random
from collections import Counter
from pathlib import Path

from .glossary import Glossary
from .tm import TM

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT.parent / "docs"

SOURCES = [
    ("A", "FRP-SRD v0.1 — SRD 5.1 Türkçe hayran çevirisi (Barış Can Kaştaş, GM Binder)",
     "https://www.gmbinder.com/share/-NLKXk7KDdEM4yxpBCaC"),
    ("B", "5eTürkçe (Tumblr) — 5e kurallarını Türkçe anlatan blog", "https://www.tumblr.com/5eturkce"),
    ("C", "FRPNET — DM Dersleri 3", "https://frpnet.net/rehber/dm-dersleri-3"),
    ("D", "FRPNET — DM Dersleri 7 (3.x dönemi)", "https://frpnet.net/rehber/dm-dersleri-7"),
    ("E", "FRPNET — D&D 2024 Başlangıç Rehberi: Temel Sistem",
     "https://frpnet.net/rehber/dungeons-and-dragons-2024-baslangic-rehberi-temel-sistem"),
    ("F", "FRPNET — 5e'de Büyü ve Büyücüler",
     "https://frpnet.net/incelemeler/dungeons-dragons-5th-editionda-buyu-ve-buyuculer"),
    ("G", "FRPNET — 5th Edition Sınıfları", "https://frpnet.net/incelemeler/dungeons-dragons-5th-edition-siniflari"),
    ("H", "RoleplayTürk — Cüce Rahip Rehberi", "https://roleplayturk.net/dd-5e-cuce-rahip-rehberi/"),
    ("I", "Zar ve Kalem (frprehberi.com) — başlangıç rehberi ve sözlük", "https://frprehberi.com/"),
    ("J", "Steam rehberi — Baldur's Gate 3 resmî Türkçe arayüz terimleri",
     "https://steamcommunity.com/sharedfiles/filedetails/?id=3565603051"),
    ("K", "Baldur's Gate: EE Türkçe terim belgesi (hayran yerelleştirmesi, AD&D terimleri)",
     "https://forums.beamdog.com/uploads/FileUpload/d1/c344a2a0afa6470d7c6ea3d18545ef.pdf"),
    ("L", "FRPNET — BG3 Türkçe yerelleştirme röportajı",
     "https://frpnet.net/makaleler/baldurs-gate-3un-turkce-yerellestirme-sureci-ve-en-cok-merak-edilen-sorular"),
    ("N", "DungeonLib TR — makine çevirisi izlenimi veriyor, zayıf kanıt",
     "https://www.dungeonlib.com/tr/2024/conditions"),
    ("O", "trfrp.blogspot — Karakter Oluşturma", "https://trfrp.blogspot.com/2020/04/d-karakter-olusturma.html"),
    ("P", "Ekşi Sözlük — dragonborn", "https://eksisozluk.com/dragonborn--3139766"),
    ("R", "games.gg TR — Solasta 2 / 5e kuralları",
     "https://games.gg/tr/solasta-ii/guides/solasta-2-rehberi-dd-5e-kurallarını-hızlıca-öğrenin/"),
    ("S", "draconism.com — Büyü", "https://draconism.com/dnd-ve-buyu/"),
    ("T", "DonanımHaber — Pathfinder: Kingmaker Türkçe yama başlığı",
     "https://forum.donanimhaber.com/pathfinder-kingmaker-turkce-dil-yamasi-terminolojiye-sadik-duzeltilmis-surum-2025--162515112"),
    ("U", "Steam rehberi — BG3 25 ipucu", "https://steamcommunity.com/sharedfiles/filedetails/?l=turkish&id=3023579472"),
    ("V", "Ekşi Sözlük — dungeons and dragons fifth edition",
     "https://eksisozluk.com/dungeons-and-dragons-fifth-edition--3215290"),
]

CATEGORY_ORDER = ["kural", "kısaltma", "yetenek", "beceri", "durum", "eylem", "hasar", "hasar türü", "duyu",
                  "alan", "büyü", "büyü okulu", "sınıf", "alt sınıf", "soy", "köken", "geçmiş", "hüner",
                  "yönelim", "boyut", "yaratık türü", "canavar", "silah", "silah özelliği", "silah ustalığı",
                  "zırh", "ekipman", "eşya", "para", "birim"]


def glossary_review(path: Path = DOCS / "glossary-review.md") -> None:
    g = Glossary.load()
    core = [t for t in g.terms if t.category not in ("büyü adı", "bölüm")]
    st = Counter(t.status for t in core)
    lines = [
        "# Sözlük incelemesi",
        "",
        "> Üretildi: `python -m gmcebi_pipeline.report` — elle düzenleme; değişiklikleri "
        "`pipeline/glossary.csv`'ye yap.",
        "",
        f"Çekirdek terim: **{len(core)}** — topluluk: {st['topluluk']}, öneri: {st['öneri']}, "
        f"tartışmalı: {st['tartışmalı']}. Ayrıca {sum(t.category == 'büyü adı' for t in g.terms)} pilot "
        f"büyü adı ve {sum(t.category == 'bölüm' for t in g.terms)} bölüm adı (en altta).",
        "",
        "## Nasıl incelenir",
        "",
        "- **tartışmalı** satırlarla başla (aşağıda ilk bölüm). Her biri için ya seçimi onayla ya da "
        "alternatiflerden birini seç.",
        "- **öneri** satırları için topluluk kullanımı bulunamadı; dil duygusuna göre onayla veya düzelt.",
        "- **topluluk** satırları kanıtlı; yalnızca göze batanlara bak.",
        "- Bir terimi değiştirmek için `pipeline/glossary.csv`'de `tr` sütununu düzelt (ya da bana liste "
        "halinde ilet). Hat, eski biçimle çevrilmiş tüm segmentleri yeniden inceleme kuyruğuna alır.",
        "- **Zorunlu** sütunu: ✔ olan terim, kaynakta geçtiğinde çeviride de geçmek zorundadır.",
        "",
        "## Tartışmalı terimler (öncelikli)",
        "",
        "| İngilizce | Seçim | Alternatifler | Gerekçe | Kanıt |",
        "|---|---|---|---|---|",
    ]
    for t in core:
        if t.status == "tartışmalı":
            lines.append(f"| {t.en} | **{t.tr}** | {', '.join(t.alternatives) or '—'} | {t.note or '—'} | "
                         f"{t.evidence or '—'} |")
    by_cat: dict[str, list] = {}
    for t in core:
        by_cat.setdefault(t.category, []).append(t)
    cats = [c for c in CATEGORY_ORDER if c in by_cat] + [c for c in by_cat if c not in CATEGORY_ORDER]
    lines += ["", "## Tüm çekirdek terimler", ""]
    n = 0
    for c in cats:
        lines += [f"### {c.capitalize()}", "", "| # | İngilizce | Türkçe | Durum | Zorunlu | Alternatifler | Not | Kanıt |",
                  "|---|---|---|---|---|---|---|---|"]
        for t in by_cat[c]:
            n += 1
            lines.append(f"| {n} | {t.en} | **{t.tr}** | {t.status} | {'✔' if t.enforce else ''} | "
                         f"{', '.join(t.alternatives)} | {t.note} | {t.evidence} |")
        lines.append("")
    lines += ["## Pilot büyü adları ve bölüm adları", "", "| İngilizce | Türkçe | Tür |", "|---|---|---|"]
    for t in g.terms:
        if t.category in ("büyü adı", "bölüm"):
            lines.append(f"| {t.en} | {t.tr} | {t.category} |")
    lines += ["", "## Kaynaklar", "",
              "Kanıt sütunundaki harfler. Yalnızca tek tek terimler alındı; metin kopyalanmadı. "
              "Erişilemeyen kaynaklar: Zindan Efendisi blogu, araklon.com, Scribd/anyflip hayran "
              "çevirileri. duruNdragons, Gordion Game Fate Core çevirisi, Türkçe Discord wiki'leri için "
              "dizinlenmiş sayfa bulunamadı; Fate için yalnızca d12Macera'nın Fate Condensed çevirisi "
              "podcast sayfası bulundu (Aspekt, Stres, Sonuç).", "",
              "| Anahtar | Kaynak |", "|---|---|"]
    for k, name, url in SOURCES:
        lines.append(f"| {k} | [{name}]({url}) |")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def pilot_samples(path: Path = DOCS / "pilot-samples.md", n: int = 20, seed: int = 7) -> None:
    tm = TM()
    llm = [e for e in tm.entries.values() if e.engine not in ("glossary",) and e.tr]
    by_ds = Counter((e.refs[0].split("/")[0] if e.refs else "?") for e in llm)
    clean = [e for e in llm if not e.qc]
    flagged = [e for e in llm if e.qc]
    rnd = random.Random(seed)
    # A spread: long sentences from each pilot dataset, plus run-in labels and spell-card fields.
    pick = []
    for ds, k in (("conditions", 5), ("rules_glossary", 7), ("spells", 8)):
        pool = [e for e in clean if e.refs and e.refs[0].startswith(ds + "/") and len(e.en) > 50]
        rnd.shuffle(pool)
        pick += pool[:k]
    pick = pick[:n]
    lines = [
        "# Pilot çeviri örnekleri",
        "",
        "> Üretildi: `python -m gmcebi_pipeline.report`. Kaynak: `pipeline/translations/tm.jsonl`.",
        "",
        "## Özet",
        "",
        f"- Çevrilen benzersiz segment: **{len(llm)}** (sözlükten doğrudan dolanlar hariç: "
        f"{sum(e.engine == 'glossary' for e in tm.entries.values())})",
        f"- Veri kümesine göre (ilk geçtiği yer): " + ", ".join(f"{k} {v}" for k, v in by_ds.most_common()),
        f"- QC bulgusu olmayan: **{len(clean)}**, bulgulu: **{len(flagged)}** (inceleme kuyruğunda öne alınır)",
        f"- Üretici: " + ", ".join(f"`{k}` {v}" for k, v in Counter(e.engine for e in llm).most_common()),
        "",
        f"## {len(pick)} rastgele örnek (tohum {seed})",
        "",
    ]
    for i, e in enumerate(pick, 1):
        lines += [f"### {i}. `{e.refs[0] if e.refs else e.key}`", "", f"- **EN:** {e.en}", f"- **TR:** {e.tr}", ""]
    if flagged:
        lines += ["## QC bulgusu kalan segmentler", "", "| Yer | EN | TR | Bulgu |", "|---|---|---|---|"]
        for e in flagged:
            esc = lambda s: s.replace("|", "\\|")  # noqa: E731
            lines.append(f"| `{e.refs[0] if e.refs else ''}` | {esc(e.en)} | {esc(e.tr)} | {esc('; '.join(e.qc))} |")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    glossary_review()
    pilot_samples()
    print("docs/glossary-review.md, docs/pilot-samples.md written")


if __name__ == "__main__":
    main()


__all__ = ["glossary_review", "pilot_samples", "json"]

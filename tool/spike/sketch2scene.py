"""Sketch → scene quality spike (GM Cebi × NeuraCraft).

Runs on a GPU pod with diffusers. Draws six synthetic tablet-style battle sketches
(top-down, wobbly strokes), then renders each with SD 1.5 (DreamShaper 8) +
ControlNet 1.1 under several settings, timing every image.

  python sketch2scene.py OUT_DIR            # on the pod (GPU)
  python sketch2scene.py OUT_DIR --sketches # sketches only (no GPU, no diffusers)

Outputs: OUT_DIR/sketches/*.png, OUT_DIR/results/<scene>/<variant>_s<seed>.png,
OUT_DIR/timings.json. The Turkish narratives are turned into English prompts by
hand here; in the product that is an LLM step (see the neuracraft-cloud issues).
"""
import json
import math
import random
import sys
import time
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps

W = H = 512

# ---------------------------------------------------------------- sketches


class Pen:
    """Wobbly, slightly uneven strokes like a finger or stylus on a tablet."""

    def __init__(self, seed):
        self.r = random.Random(seed)
        self.terrain = Image.new("L", (W, H), 255)
        self.tokens = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        self.dt = ImageDraw.Draw(self.terrain)
        self.dk = ImageDraw.Draw(self.tokens)

    def _wobble(self, pts, amp=2.5, step=6):
        out = []
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = max(1, int(math.hypot(x1 - x0, y1 - y0) / step))
            for i in range(n):
                t = i / n
                out.append((x0 + (x1 - x0) * t + self.r.uniform(-amp, amp),
                            y0 + (y1 - y0) * t + self.r.uniform(-amp, amp)))
        out.append(pts[-1])
        return out

    def line(self, pts, w=4):
        self.dt.line(self._wobble(pts), fill=0, width=w, joint="curve")

    def rect(self, x0, y0, x1, y1, w=4):
        self.line([(x0, y0), (x1, y0), (x1, y1), (x0, y1), (x0, y0 + 2)], w)

    def circle(self, cx, cy, rad, w=4, n=24):
        pts = [(cx + rad * math.cos(2 * math.pi * i / n), cy + rad * math.sin(2 * math.pi * i / n)) for i in range(n + 1)]
        self.line(pts, w)

    def tree(self, cx, cy, rad=18):
        n = 14
        pts = []
        for i in range(n + 1):
            a = 2 * math.pi * i / n
            rr = rad * (0.8 + 0.25 * (i % 2))
            pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
        self.line(pts, 3)

    def hatch(self, x0, y0, x1, y1, gap=12):
        for k in range(int(x0), int(x1), gap):
            self.line([(k, y0), (min(x1, k + (y1 - y0)), y1)], 2)

    def wave(self, x0, y0, x1, y1, amp=10, w=4):
        n = 12
        pts = [(x0 + (x1 - x0) * i / n + amp * math.sin(i * 1.3), y0 + (y1 - y0) * i / n) for i in range(n + 1)]
        self.line(pts, w)

    # tokens: kept on their own layer (the product draws them, not the model)
    def hero(self, cx, cy, label):
        self.dk.ellipse([cx - 13, cy - 13, cx + 13, cy + 13], outline=(20, 90, 200, 255), width=4)
        self.dk.text((cx - 4, cy - 6), label, fill=(20, 90, 200, 255))

    def foe(self, cx, cy):
        c = (200, 30, 30, 255)
        self.dk.line([cx - 11, cy - 11, cx + 11, cy + 11], fill=c, width=4)
        self.dk.line([cx - 11, cy + 11, cx + 11, cy - 11], fill=c, width=4)

    def with_tokens(self):
        """Sketch as the GM draws it: terrain and tokens in one black-ink picture."""
        img = self.terrain.convert("RGBA")
        ink = Image.new("RGBA", (W, H), (0, 0, 0, 255))
        img.paste(ink, mask=self.tokens.split()[3])
        return img.convert("L")


def scene_bridge():
    p = Pen(1)
    p.wave(250, 0, 240, 512)
    p.wave(320, 0, 310, 512)
    p.rect(200, 220, 370, 280)
    for x in range(215, 370, 22):
        p.line([(x, 222), (x, 278)], 2)
    for cx, cy in [(80, 80), (130, 140), (60, 330), (110, 420), (430, 90), (460, 380), (400, 450)]:
        p.tree(cx, cy)
    for i, (cx, cy) in enumerate([(150, 240), (160, 275), (120, 260)]):
        p.hero(cx, cy, str(i + 1))
    for cx, cy in [(410, 230), (430, 270), (395, 300)]:
        p.foe(cx, cy)
    return p, ("Kurt sürüsü nehrin karşı yakasında, ahşap köprünün başında pusu kurmuş. Akşam, sisli bir orman.",
               "top-down fantasy battle map, a wooden plank bridge over a misty forest river, pine trees on both banks, "
               "evening light, tabletop RPG map, detailed painted texture")


def scene_tavern():
    p = Pen(2)
    p.rect(30, 30, 482, 482)
    p.line([(30, 230), (30, 290)], 8)  # (door gap drawn as thick mark)
    p.rect(60, 50, 300, 95)  # bar counter
    for cx, cy in [(150, 220), (300, 230), (200, 360), (360, 380), (420, 160)]:
        p.circle(cx, cy, 30)
    p.rect(400, 400, 470, 470)
    p.hatch(400, 400, 470, 470, 10)  # stairs
    for i, (cx, cy) in enumerate([(90, 260), (120, 300)]):
        p.hero(cx, cy, str(i + 1))
    for cx, cy in [(250, 300), (330, 310), (180, 130)]:
        p.foe(cx, cy)
    return p, ("Kalabalık bir handa kavga çıkıyor. Tezgâhın önünde üç haydut, masalar devrilmiş, merdiven yukarı çıkıyor.",
               "top-down fantasy battle map, interior of a medieval tavern, wooden floor, round tables, long bar counter, "
               "staircase in the corner, warm candle light, tabletop RPG map, detailed painted texture")


def scene_dungeon():
    p = Pen(3)
    p.line([(60, 40), (60, 470), (470, 470)], 5)
    p.line([(140, 40), (140, 390), (470, 390)], 5)
    p.rect(70, 200, 130, 260)
    p.hatch(72, 202, 130, 260, 9)  # pit
    p.line([(140, 300), (140, 340)], 9)  # door
    p.line([(300, 390), (300, 470)], 3)
    p.hero(100, 90, "1")
    p.hero(100, 130, "2")
    p.foe(380, 430)
    return p, ("Dar bir zindan koridoru köşeyi dönüyor. Ortada bir çukur tuzak, köşenin ardında bir iskelet bekliyor.",
               "top-down fantasy battle map, narrow stone dungeon corridor turning a corner, a pit trap in the floor, "
               "wooden door in the wall, torch light, tabletop RPG map, detailed painted texture")


def scene_road():
    p = Pen(4)
    p.line([(0, 380), (120, 340), (260, 300), (380, 200), (512, 160)], 4)
    p.line([(0, 450), (130, 410), (280, 370), (410, 270), (512, 240)], 4)
    p.rect(200, 320, 280, 360)  # wagon
    p.circle(210, 365, 9, 3)
    p.circle(270, 365, 9, 3)
    for cx, cy in [(60, 90), (150, 60), (90, 200), (420, 420), (470, 360), (330, 80), (460, 60)]:
        p.tree(cx, cy, 22)
    for cx, cy in [(330, 330), (360, 300)]:
        p.circle(cx, cy, 10, 3)  # rocks
    for i, (cx, cy) in enumerate([(230, 300), (290, 335)]):
        p.hero(cx, cy, str(i + 1))
    for cx, cy in [(120, 150), (200, 120), (400, 100)]:
        p.foe(cx, cy)
    return p, ("Orman yolunda bir at arabası. Ağaçların arasından haydutlar oklarla saldırıyor.",
               "top-down fantasy battle map, a dirt road through a dense forest, a wooden wagon on the road, rocks, "
               "daylight, tabletop RPG map, detailed painted texture")


def scene_cave():
    p = Pen(5)
    p.line([(0, 120), (100, 100), (200, 130), (320, 90), (512, 110)], 5)  # cliff edge
    p.line([(180, 125), (200, 60), (260, 50), (300, 95)], 5)  # cave mouth
    for cx, cy in [(120, 260), (340, 300), (260, 400), (420, 220)]:
        p.circle(cx, cy, 24, 4)  # boulders
    p.wave(0, 470, 512, 440, 8, 3)  # stream
    for i, (cx, cy) in enumerate([(200, 330), (240, 350), (180, 380)]):
        p.hero(cx, cy, str(i + 1))
    p.foe(250, 110)
    return p, ("Kayalık bir yamaçta mağara girişi. Önünde büyük kayalar, aşağıda bir dere. Mağaradan bir ogre çıkıyor.",
               "top-down fantasy battle map, a cave entrance in a rocky cliff, large boulders, a small stream at the "
               "bottom, overcast, tabletop RPG map, detailed painted texture")


def scene_wall():
    p = Pen(6)
    p.line([(0, 200), (512, 200)], 6)
    p.line([(0, 250), (512, 250)], 6)
    p.rect(60, 170, 130, 280)  # tower
    p.rect(380, 170, 450, 280)
    p.circle(95, 225, 20)
    p.circle(415, 225, 20)
    p.rect(230, 195, 290, 255)  # gate
    p.hatch(232, 197, 290, 255, 8)
    p.line([(260, 255), (260, 512)], 3)  # path
    for i, (cx, cy) in enumerate([(240, 380), (280, 400), (260, 440)]):
        p.hero(cx, cy, str(i + 1))
    for cx, cy in [(95, 225), (415, 225), (260, 150)]:
        p.foe(cx, cy)
    return p, ("Kale surları ve kapı. İki kulede okçular, kahramanlar yoldan kapıya yaklaşıyor.",
               "top-down fantasy battle map, a stone castle wall with two round towers and a wooden gate with a "
               "portcullis, a dirt path leading to the gate, grass outside, tabletop RPG map, detailed painted texture")


SCENES = {
    "kopru": scene_bridge,
    "han": scene_tavern,
    "zindan": scene_dungeon,
    "orman-yolu": scene_road,
    "magara": scene_cave,
    "sur": scene_wall,
}

NEGATIVE = ("text, letters, watermark, signature, blurry, lowres, deformed, people, characters, "
            "perspective view, isometric, frame, border, ugly")


def write_sketches(out: Path):
    d = out / "sketches"
    d.mkdir(parents=True, exist_ok=True)
    meta = {}
    for name, fn in SCENES.items():
        p, (tr, en) = fn()
        p.terrain.save(d / f"{name}_arazi.png")
        p.with_tokens().save(d / f"{name}_jetonlu.png")
        p.tokens.save(d / f"{name}_jetonlar.png")
        meta[name] = {"anlati_tr": tr, "prompt_en": en}
    (out / "scenes.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2))
    return meta


# ---------------------------------------------------------------- generation


def control_image(gray: Image.Image) -> Image.Image:
    # scribble/lineart ControlNets were trained on white lines on black
    return ImageOps.invert(gray).convert("RGB")


def main():
    out = Path(sys.argv[1])
    meta = write_sketches(out)
    if "--sketches" in sys.argv:
        return

    import torch
    from diffusers import (ControlNetModel, EulerAncestralDiscreteScheduler, LCMScheduler,
                           StableDiffusionControlNetPipeline)

    dev, dt = "cuda", torch.float16
    log = lambda *a: print(time.strftime("%H:%M:%S"), *a, flush=True)  # noqa: E731
    t0 = time.time()
    nets = {k: ControlNetModel.from_pretrained(f"lllyasviel/control_v11p_sd15_{k}", torch_dtype=dt) for k in ("scribble", "lineart")}
    pipe = StableDiffusionControlNetPipeline.from_pretrained(
        "Lykon/dreamshaper-8", controlnet=nets["scribble"], torch_dtype=dt, safety_checker=None,
        requires_safety_checker=False).to(dev)
    for n in nets.values():
        n.to(dev)
    euler = EulerAncestralDiscreteScheduler.from_config(pipe.scheduler.config)
    lcm = LCMScheduler.from_config(pipe.scheduler.config)
    pipe.load_lora_weights("latent-consistency/lcm-lora-sdv1-5", adapter_name="lcm")
    log("models loaded in", round(time.time() - t0, 1), "s")

    variants = [
        # name, controlnet, sketch layer, LCM?, steps, guidance, control scale
        ("scribble_lcm4", "scribble", "arazi", True, 4, 1.5, 0.9),
        ("lineart_lcm4", "lineart", "arazi", True, 4, 1.5, 0.9),
        ("scribble_lcm4_jetonlu", "scribble", "jetonlu", True, 4, 1.5, 0.9),
        ("scribble_euler20", "scribble", "arazi", False, 20, 7.0, 0.9),
    ]
    seeds = [7, 42]
    timings = []
    for name in SCENES:
        d = out / "results" / name
        d.mkdir(parents=True, exist_ok=True)
        for vname, net, layer, use_lcm, steps, cfg, cscale in variants:
            pipe.controlnet = nets[net]
            pipe.scheduler = lcm if use_lcm else euler
            if use_lcm:
                pipe.set_adapters(["lcm"], adapter_weights=[1.0])
                pipe.enable_lora()
            else:
                pipe.disable_lora()
            ctrl = control_image(Image.open(out / "sketches" / f"{name}_{layer}.png"))
            for seed in seeds:
                torch.cuda.synchronize()
                t = time.time()
                img = pipe(meta[name]["prompt_en"], negative_prompt=NEGATIVE, image=ctrl,
                           num_inference_steps=steps, guidance_scale=cfg, controlnet_conditioning_scale=cscale,
                           generator=torch.Generator(dev).manual_seed(seed), width=W, height=H).images[0]
                torch.cuda.synchronize()
                sec = round(time.time() - t, 2)
                img.save(d / f"{vname}_s{seed}.png")
                timings.append({"scene": name, "variant": vname, "seed": seed, "seconds": sec})
                log(name, vname, seed, sec, "s")
    (out / "timings.json").write_text(json.dumps({
        "gpu": torch.cuda.get_device_name(0),
        "peak_vram_gb": round(torch.cuda.max_memory_allocated() / 1e9, 2),
        "images": timings,
    }, indent=2))
    log("done")


if __name__ == "__main__":
    main()

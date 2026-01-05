import os
from PIL import Image

SCRIPT_DIR = os.path.dirname(__file__)
SEEDLING_PATH = os.path.join(SCRIPT_DIR, "seedling.png")
CROPS_DIR = os.path.join(SCRIPT_DIR, "crops")
OUT_DIR = os.path.join(SCRIPT_DIR, "seeds_generated")

def overlay_crop_on_seedling(crop_path, seedling_path, out_path):
    with Image.open(seedling_path) as base_im:
        base = base_im.convert("RGBA")
        with Image.open(crop_path) as crop_im:
            crop = crop_im.convert("RGBA")
            # scale down
            scale_factor = 0.5
            new_size = (int(crop.width * scale_factor), int(crop.height * scale_factor))
            crop = crop.resize(new_size, Image.Resampling.LANCZOS)
            
            # bottom-right position
            x = base.width - crop.width
            y = base.height - crop.height
            out = base.copy()
            out.paste(crop, (x, y), crop)
            out.save(out_path, format="PNG")

def main():
    if not os.path.isfile(SEEDLING_PATH):
        print("seedling.png not found at:", SEEDLING_PATH)
        return
    if not os.path.isdir(CROPS_DIR):
        print("crops/ directory not found at:", CROPS_DIR)
        return
    os.makedirs(OUT_DIR, exist_ok=True)
    for fname in sorted(os.listdir(CROPS_DIR)):
        if not fname.lower().endswith(".png"):
            continue
        crop_path = os.path.join(CROPS_DIR, fname)
        out_path = os.path.join(OUT_DIR, fname)
        overlay_crop_on_seedling(crop_path, SEEDLING_PATH, out_path)
        print("Saved:", out_path)

if __name__ == "__main__":
    main()

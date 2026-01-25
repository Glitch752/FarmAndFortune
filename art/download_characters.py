# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "cairosvg",
# ]
# ///
character_categories = [
    "Farmer",
    "Office worker",
    "Factory worker",
    "Health worker",
    "Construction worker",
    "Student",
    "Artist",
]

character_variants = [
    "Default",
    "Light",
    "Medium-Light",
    "Medium",
    "Medium-Dark",
    "Dark"
]

style = "Flat" # 3D, Flat, or Color
extension = "png" if style == "3D" else "svg"

# Asset paths are e.g. https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Farmer/Default/3D/farmer_3d_default.png
base_url = "https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets"
def get_url(category: str, variant: str) -> str:
    return f"{base_url}/{category}/{variant}/{style}/{category.lower().replace(' ', '_')}_{style.lower()}_{variant.lower()}.{extension}"

import os
import urllib.request
output_dir = "art/characters"
os.makedirs(output_dir, exist_ok=True)

# clear the directory first
for f in os.listdir(output_dir):
    os.remove(os.path.join(output_dir, f))

for category in character_categories:
    for (i, variant) in enumerate(character_variants):
        url = get_url(category, variant).replace(" ", "%20")
        filename = f"{category.lower().replace(' ', '_')}_{i}.{extension}"
        output_path = os.path.join(output_dir, filename)
        print(f"Downloading {url} to {output_path}...")
        urllib.request.urlretrieve(url, output_path)
        
        # Convert SVG to PNG if needed
        if extension == "svg":
            from cairosvg import svg2png
            with open(output_path, "rb") as svg_file:
                svg_data = svg_file.read()
            png_output_path = output_path.replace(".svg", ".png")
            svg2png(bytestring=svg_data, write_to=png_output_path, output_width=256, output_height=256)
            os.remove(output_path)
            print(f"Converted {output_path} to {png_output_path}.")
print("Download complete.")
from PIL import Image, ImageDraw, ImageFilter
import os
import sys

def add_corners_and_shadow(img_path, radius, shadow_offset, shadow_blur, shadow_opacity=0.35, padding=120):
    img = Image.open(img_path).convert("RGBA")
    
    # Create corner mask
    mask = Image.new('L', img.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0) + img.size, radius, fill=255)
    
    rounded_img = img.copy()
    rounded_img.putalpha(mask)
    
    canvas_width = img.width + padding * 2
    canvas_height = img.height + padding * 2
    
    shadow = Image.new('RGBA', (canvas_width, canvas_height), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    
    shadow_box = (
        padding + shadow_offset[0], 
        padding + shadow_offset[1], 
        padding + img.width + shadow_offset[0], 
        padding + img.height + shadow_offset[1]
    )
    
    shadow_color = int(255 * shadow_opacity)
    shadow_draw.rounded_rectangle(shadow_box, radius, fill=(0, 0, 0, shadow_color))
    
    shadow = shadow.filter(ImageFilter.GaussianBlur(shadow_blur))
    final = Image.new('RGBA', (canvas_width, canvas_height), (0, 0, 0, 0))
    final.alpha_composite(shadow)
    final.paste(rounded_img, (padding, padding), rounded_img)
    return final

def make_composite_image(center_path, left_path, right_path, out_path):
    print(f"Compositing {os.path.basename(out_path)}...")
    img_c = add_corners_and_shadow(center_path, radius=80, shadow_offset=(0, 30), shadow_blur=40)
    img_l = add_corners_and_shadow(left_path, radius=80, shadow_offset=(0, 30), shadow_blur=40)
    img_r = add_corners_and_shadow(right_path, radius=80, shadow_offset=(0, 30), shadow_blur=40)

    # Scale down side images slightly to emphasize center image
    scale_factor = 0.85
    new_size_l = (int(img_l.width * scale_factor), int(img_l.height * scale_factor))
    img_l = img_l.resize(new_size_l, Image.Resampling.LANCZOS)
    
    new_size_r = (int(img_r.width * scale_factor), int(img_r.height * scale_factor))
    img_r = img_r.resize(new_size_r, Image.Resampling.LANCZOS)

    rot_angle = 35 
    img_l_rot = img_l.rotate(rot_angle, expand=True, resample=Image.Resampling.BICUBIC)
    img_r_rot = img_r.rotate(-rot_angle, expand=True, resample=Image.Resampling.BICUBIC)

    canvas_w = img_c.width + int(img_c.width * 1.8)
    canvas_h = img_c.height + int(img_c.height * 0.2)
    
    c_x = (canvas_w - img_c.width) // 2
    c_y = (canvas_h - img_c.height) // 2

    canvas = Image.new('RGBA', (canvas_w, canvas_h), (0, 0, 0, 0))

    l_x = c_x - int(img_c.width * 0.65)
    l_y = c_y + int(img_c.height * 0.08)
    
    r_x = c_x + int(img_c.width * 0.65) - (img_r_rot.width - img_c.width)
    r_y = c_y + int(img_c.height * 0.08)

    canvas.paste(img_l_rot, (l_x, l_y), img_l_rot)
    canvas.paste(img_r_rot, (r_x, r_y), img_r_rot)
    canvas.paste(img_c, (c_x, c_y), img_c)

    bbox = canvas.getbbox()
    if bbox:
        canvas = canvas.crop(bbox)

    canvas.save(out_path)
    print(f"Composite saved to {out_path}!")

if __name__ == "__main__":
    assets_dir = sys.argv[1]

    # Process Screen1 (Home)
    s1_center = os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/media__1772692005697.png")
    s1_left = os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/media__1772695909866.png")
    s1_right = os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/media__1772695915032.png")
    s1_out = os.path.join(assets_dir, "Screen1.imageset", "Screen1.png")
    make_composite_image(s1_center, s1_left, s1_right, s1_out)

    # Process Screen3 (Community)
    s3_center = os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/media__1772692029854.png")
    s3_left = os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/media__1772698263237.png")
    s3_right = os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/media__1772698261816.png")
    s3_out = os.path.join(assets_dir, "Screen3.imageset", "Screen3.png")
    make_composite_image(s3_center, s3_left, s3_right, s3_out)

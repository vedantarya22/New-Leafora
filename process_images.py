from PIL import Image, ImageDraw, ImageFilter
import os
import sys

def round_corners_and_add_shadow(input_path, output_path, radius, shadow_offset, shadow_blur, shadow_opacity=0.6, padding=150):
    try:
        # Load image
        img = Image.open(input_path).convert("RGBA")
        
        # Create corner mask
        mask = Image.new('L', img.size, 0)
        draw = ImageDraw.Draw(mask)
        draw.rounded_rectangle((0, 0) + img.size, radius, fill=255)
        
        # Apply corner mask to image
        rounded_img = img.copy()
        rounded_img.putalpha(mask)
        
        # Determine canvas size
        canvas_width = img.width + padding * 2
        canvas_height = img.height + padding * 2
        
        # Create shadow layer
        shadow = Image.new('RGBA', (canvas_width, canvas_height), (0, 0, 0, 0))
        shadow_draw = ImageDraw.Draw(shadow)
        
        # The shadow rectangle is the same size as the image, but shifted
        shadow_box = (
            padding + shadow_offset[0], 
            padding + shadow_offset[1], 
            padding + img.width + shadow_offset[0], 
            padding + img.height + shadow_offset[1]
        )
        
        # Fill the shadow rectangle with the desired opacity (black)
        shadow_color = int(255 * shadow_opacity)
        shadow_draw.rounded_rectangle(shadow_box, radius, fill=(0, 0, 0, shadow_color))
        
        # Blur the shadow drastically to make it look soft and premium
        shadow = shadow.filter(ImageFilter.GaussianBlur(shadow_blur))
        
        # Create final composite canvas
        final = Image.new('RGBA', (canvas_width, canvas_height), (0, 0, 0, 0))
        
        # Paste shadow
        final.alpha_composite(shadow)
        
        # Paste rounded image in the center
        final.paste(rounded_img, (padding, padding), rounded_img)
        
        # Save output
        final.save(output_path)
        print(f"Processed: {os.path.basename(output_path)}")
        
    except Exception as e:
        print(f"Error processing {input_path}: {e}")

if __name__ == "__main__":
    assets_dir = sys.argv[1]
    
    # Process Screen1 (Home Garden)
    s1 = os.path.join(assets_dir, "Screen1.imageset", "Screen1.png")
    round_corners_and_add_shadow(os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/media__1772692005697.png"), s1, radius=80, shadow_offset=(0, 40), shadow_blur=60, shadow_opacity=0.35, padding=200)

    # Process Screen2 (Visualize / AR Image)
    s2 = os.path.join(assets_dir, "Screen2.imageset", "Screen2.png")
    round_corners_and_add_shadow(os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/visualize_raw.png"), s2, radius=80, shadow_offset=(0, 40), shadow_blur=60, shadow_opacity=0.35, padding=200)

    # Process Screen3 (Community Image)
    s3 = os.path.join(assets_dir, "Screen3.imageset", "Screen3.png")
    round_corners_and_add_shadow(os.path.expanduser("~/.gemini/antigravity/brain/17e8a3e6-10dd-4451-994c-ec06db14fae2/media__1772692029854.png"), s3, radius=80, shadow_offset=(0, 40), shadow_blur=60, shadow_opacity=0.35, padding=200)

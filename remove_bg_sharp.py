import os
import numpy as np
from PIL import Image, ImageFilter, ImageOps

ASSETS = '/Users/firozmohammad/DigiEmperor/transport_management_system/assets/images'

def refine_background_removal(img_path):
    print(f'Refining {os.path.basename(img_path)}...', flush=True)
    img = Image.open(img_path).convert("RGBA")
    
    # Get data as numpy array for faster processing
    data = np.array(img)
    r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]
    
    # Create mask: True where pixel is NOT white
    # Using a slightly lower threshold to catch the "soft" white edges
    mask = (r < 250) | (g < 250) | (b < 250)
    
    # Convert mask to Image for morphological operations
    mask_img = Image.fromarray((mask * 255).astype(np.uint8))
    
    # Erode the mask slightly (1-2 pixels) to remove the white fringe
    # This is the "secret sauce" for sharpness on colored backgrounds
    refined_mask = mask_img.filter(ImageFilter.MaxFilter(3)) # Slight dilation of black/contraction of white
    refined_mask = refined_mask.filter(ImageFilter.MinFilter(3)) # Erosion
    
    # Soften the edges just a tiny bit for a professional look (anti-aliased)
    refined_mask = refined_mask.filter(ImageFilter.GaussianBlur(radius=0.5))
    
    # Update alpha channel
    new_a = np.array(refined_mask)
    data[:,:,3] = new_a
    
    # Save back
    result = Image.fromarray(data)
    result.save(img_path, "PNG")
    print(f'Done ✓ sharp edges preserved.', flush=True)

for i in ['1', '2', '3', '4']:
    path = f'{ASSETS}/intro_{i}.png'
    if os.path.exists(path):
        refine_background_removal(path)

print('ALL DONE')

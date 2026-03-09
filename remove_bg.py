import sys
import os
from PIL import Image

ASSETS = '/Users/firozmohammad/DigiEmperor/transport_management_system/assets/images'

def make_white_transparent(img_path):
    print(f'Processing {os.path.basename(img_path)}...', flush=True)
    img = Image.open(img_path).convert("RGBA")
    datas = img.getdata()

    newData = []
    for item in datas:
        # If pixel is very close to white (R,G,B all > 252)
        if item[0] > 252 and item[1] > 252 and item[2] > 252:
            # Make it transparent
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)

    img.putdata(newData)
    img.save(img_path, "PNG")
    print(f'Done ✓', flush=True)

for i in ['1', '2', '3', '4']:
    path = f'{ASSETS}/intro_{i}.png'
    if os.path.exists(path):
        make_white_transparent(path)

print('ALL DONE')

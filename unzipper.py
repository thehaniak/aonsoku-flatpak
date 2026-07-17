import os
import zipfile

cache = '/run/build/aonsoku/flatpak-node/cache/electron'
arch = os.environ.get('ARCH', 'x64')

if arch == 'arm64':
    zip_name = 'electron-v42.6.1-linux-arm64.zip'
    extract_dir = '.'
else:
    zip_name = 'electron-v42.6.1-linux-x64.zip'
    extract_dir = '.'

zip_path = os.path.join(cache, zip_name)
extract_to = os.path.join(cache, extract_dir)

os.makedirs(extract_to, exist_ok=True)

if not os.path.exists(os.path.join(extract_to, 'electron')):
    with zipfile.ZipFile(zip_path) as z:
        z.extractall(extract_to)
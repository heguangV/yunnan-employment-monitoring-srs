"""Package the offline prototype source files and usage documentation."""

from pathlib import Path
import json
import zipfile

root = Path(__file__).resolve().parent.parent
prototype = root / '项目交互原型'
names = [
    'index.html', 'prototype.css', 'prototype.js', 'prototype-v11.js',
    '原型使用说明.md', '页面清单与需求映射.md',
]
files = [(prototype / name, Path('项目交互原型') / name) for name in names]
output = root / 'dist'
output.mkdir(exist_ok=True)
target = output / '云南企业就业监测_交互原型_V1.1.zip'
with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED) as archive:
    for file, destination in files:
        archive.write(file, destination.as_posix())
with zipfile.ZipFile(target) as archive:
    if archive.testzip() is not None:
        raise ValueError('Archive integrity check failed')
    for file, destination in files:
        if archive.read(destination.as_posix()) != file.read_bytes():
            raise ValueError(f'Archive file differs: {file}')
print(json.dumps({
    'zip': str(target), 'files': len(files), 'bytes': target.stat().st_size,
    'archive_verified': True,
}, ensure_ascii=False))

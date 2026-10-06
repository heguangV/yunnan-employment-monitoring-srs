"""Package the offline prototype; append current QA evidence if available."""

from pathlib import Path
import json
import zipfile

root = Path(__file__).resolve().parent.parent
prototype = root / '项目交互原型'
evidence = root / 'artifacts' / 'prototype-v11'
names = [
    'index.html', 'prototype.css', 'prototype.js', 'prototype-v11.js',
    '原型使用说明.md', '页面清单与需求映射.md',
]
files = [(prototype / name, Path('项目交互原型') / name) for name in names]
report_path = evidence / '交互检查结果.json'
if report_path.exists():
    report = json.loads(report_path.read_text(encoding='utf-8'))
    if report.get('version') != 'V1.1' or not report.get('results') or not all(
        item.get('status') == 'PASS' for item in report['results']
    ):
        raise ValueError('QA evidence is incomplete or contains failures; rerun pnpm test')
    files.append((report_path, Path('项目交互原型/artifacts/prototype-v11/交互检查结果.json')))
    files.extend(
        (file, Path('项目交互原型/artifacts/prototype-v11/screenshots') / file.name)
        for file in sorted((evidence / 'screenshots').glob('*.png'))
    )

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
    'qa_evidence_included': report_path.exists(), 'archive_verified': True,
}, ensure_ascii=False))

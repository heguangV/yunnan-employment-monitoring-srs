"""Reject generated outputs and local dependencies from this project's index."""

from pathlib import Path, PurePosixPath
import subprocess
import sys

project = Path(__file__).resolve().parent.parent
repo = Path(subprocess.check_output(
    ['git', '-C', str(project), 'rev-parse', '--show-toplevel'],
    text=True, encoding='utf-8',
).strip())
relative_project = project.relative_to(repo).as_posix()
prefix = '' if relative_project == '.' else relative_project + '/'
tracked = subprocess.check_output(
    ['git', '-C', str(repo), 'ls-files', '--cached', '-z', '--', prefix or '.'],
).decode('utf-8').split('\0')
allowed_extensions = {
    '.md', '.typ', '.html', '.css', '.js', '.cjs', '.mjs', '.py', '.json',
    '.yaml', '.yml', '.toml', '.lock', '.sh',
}
allowed_names = {'.gitignore', '.gitattributes', '.editorconfig', 'pre-commit'}
violations = []
count = 0
for name in filter(None, tracked):
    count += 1
    local_name = name.removeprefix(prefix)
    file_path = PurePosixPath(local_name)
    if file_path.suffix not in allowed_extensions and file_path.name not in allowed_names:
        violations.append(name + ': unsupported source-file type')
    ignored = subprocess.run(
        ['git', '-C', str(repo), 'check-ignore', '--no-index', '-q', '--', name],
        check=False,
    )
    if ignored.returncode == 0:
        violations.append(name + ': matched .gitignore (possibly forced into index)')
    elif ignored.returncode != 1:
        raise RuntimeError('git check-ignore failed: ' + name)
    file_on_disk = repo / name
    if file_on_disk.is_file() and file_on_disk.stat().st_size > 1024 * 1024:
        violations.append(name + ': source file larger than 1 MiB; inspect before tracking')

if violations:
    print('Project source policy failed:\n' + '\n'.join(violations), file=sys.stderr)
    sys.exit(1)
print(f'Project source policy passed: {count} tracked source files')

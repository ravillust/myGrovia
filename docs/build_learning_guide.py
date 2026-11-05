from pathlib import Path
from html import escape
import re

root = Path(__file__).resolve().parents[1]
source = root / 'docs/Panduan_Kode_Sederhana_myGrovia.md'
output = root / 'docs/Panduan_Kode_Sederhana_myGrovia.html'
body, toc = [], []
code, paragraph = None, []
section = 0

def flush():
    if paragraph:
        body.append('<p>' + escape(' '.join(paragraph)) + '</p>')
        paragraph.clear()

for line in source.read_text(encoding='utf-8').splitlines():
    if line.startswith('```'):
        flush()
        if code is None:
            code = []
        else:
            body.append('<pre><code>' + escape('\n'.join(code)) + '</code></pre>')
            code = None
        continue
    if code is not None:
        code.append(line)
        continue
    if line.startswith('# '):
        flush()
        body.append('<h1>' + escape(line[2:]) + '</h1>')
    elif line.startswith('## '):
        flush()
        section += 1
        ident = f'bab-{section}'
        title = escape(line[3:])
        toc.append(f'<a href="#{ident}">{title}</a>')
        body.append(f'<h2 id="{ident}">{title}</h2>')
    elif line.startswith('### '):
        flush()
        body.append('<h3>' + escape(line[4:]) + '</h3>')
    elif line.startswith('- '):
        flush()
        body.append('<p class="term">' + escape(line[2:]) + '</p>')
    elif not line.strip():
        flush()
    else:
        paragraph.append(line)
flush()
assert code is None, 'Unclosed code block'

body.append('<h2 id="kode-lengkap">Lampiran: kode lengkap proyek</h2><p>Klik nama file untuk membuka. Angka di kiri adalah nomor baris. Gunakan tombol di bawah untuk membuka semua kode sebelum mencari dengan Ctrl+F atau mencetak lampiran.</p><button type="button" id="expand">Buka semua kode</button> <button type="button" id="collapse">Tutup semua kode</button>')
toc.append('<a href="#kode-lengkap">Lampiran kode lengkap</a>')
files = sorted((root / 'lib').rglob('*.dart')) + [root / 'pubspec.yaml'] + sorted((root / 'test').glob('*.dart'))
for path in files:
    name = path.relative_to(root).as_posix()
    text = path.read_text(encoding='utf-8-sig')
    if text.strip():
        lines = ''.join(f'<span class="source-line"><span class="line-no" aria-hidden="true">{i}</span>{escape(line)}</span>' for i, line in enumerate(text.splitlines(), 1))
        content = '<pre class="source"><code>' + lines + '</code></pre>'
    else:
        content = '<p>File ini kosong saat panduan dibuat.</p>'
    body.append(f'<details><summary>{escape(name)}</summary>{content}</details>')

html = '''<!doctype html>
<html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Panduan Belajar Kode myGrovia</title>
<style>
:root{--size:18px;color-scheme:light}*{box-sizing:border-box}html{scroll-padding-top:25px}body{margin:0;background:#faf9f6;color:#242b27;font-family:Segoe UI,Arial,sans-serif;font-size:var(--size);line-height:1.8}nav{position:fixed;inset:0 auto 0 0;width:285px;overflow:auto;padding:26px 20px;background:#f0f2ed;border-right:1px solid #d8ded6;font-size:14px}nav strong{display:block;font-size:19px;margin-bottom:14px}nav a{display:block;padding:7px 0;text-decoration:none;color:#28583f;line-height:1.5}a:hover{text-decoration:underline}a:focus-visible,button:focus-visible,summary:focus-visible{outline:3px solid #367751;outline-offset:3px}.tools{display:flex;flex-wrap:wrap;gap:6px;margin:15px 0}button{font:inherit;font-size:14px;background:white;color:#244f37;border:1px solid #abbcab;padding:8px 12px;border-radius:5px;cursor:pointer}main{max-width:1120px;margin-left:285px;padding:44px 55px 100px}h1{font-size:2.1em;line-height:1.25;margin-top:0}h2{font-size:1.55em;line-height:1.4;margin-top:70px;padding-top:22px;border-top:2px solid #ccd8c9}h3{font-size:1.13em;line-height:1.5;margin-top:35px}p{margin:15px 0}pre{background:#eef1eb;border:1px solid #d9dfd5;border-left:4px solid #3c7551;border-radius:3px;padding:18px;overflow:auto;font-size:.84em;line-height:1.65;tab-size:2}code{font-family:Consolas,monospace}.term{margin:9px 0;padding-left:14px;border-left:2px solid #cbd5c6}details{margin:16px 0;border:1px solid #cbd5c6;padding:12px}summary{cursor:pointer;font-size:.9em;color:#28583f;overflow-wrap:anywhere}.source-line{display:block;min-height:1.65em}.line-no{display:inline-block;width:3.5em;color:#657062;user-select:none}.source{padding:12px 8px}.skip{position:absolute;left:-9999px}.skip:focus{position:fixed;left:10px;top:10px;background:white;z-index:10;padding:10px}.hint{font-size:13px;color:#4b584c}footer{margin-top:45px;font-size:14px;color:#586356}
@media(max-width:850px){nav{position:static;width:auto;max-height:340px;border-right:0;border-bottom:1px solid #ccd8c9}main{margin:0;padding:28px 22px 70px}h1{font-size:1.8em}}
@media print{nav,.tools,button,.skip{display:none}body{background:white;font-size:11pt;line-height:1.6}main{margin:0;padding:0;max-width:none}h2{break-before:page;margin-top:0}h2,h3,summary{break-after:avoid}pre{white-space:pre-wrap;overflow-wrap:anywhere;font-size:9pt}details{border:0;padding:0}.source-line{white-space:pre-wrap}a{color:inherit;text-decoration:none}}
</style></head><body>
<a class="skip" href="#isi">Langsung ke isi</a>
<nav aria-label="Daftar isi"><strong>Belajar myGrovia</strong><div class="tools"><button id="smaller" type="button" aria-label="Kecilkan tulisan">A−</button><button id="larger" type="button" aria-label="Besarkan tulisan">A+</button><button id="print" type="button">Cetak / PDF</button></div><p class="hint">Klik bab untuk berpindah. Ctrl+F untuk mencari. Dokumen ini bisa dibuka tanpa internet.</p>'''
html += '\n'.join(toc) + '</nav><main id="isi">' + '\n'.join(body)
html += '''<footer>Salinan pembelajaran • 21 Oktober 2026 • Versi kode yang disederhanakan.</footer></main>
<script>
let size=18;
function changeSize(delta){size=Math.max(15,Math.min(26,size+delta));document.documentElement.style.setProperty('--size',size+'px');}
document.getElementById('smaller').onclick=()=>changeSize(-1);
document.getElementById('larger').onclick=()=>changeSize(1);
document.getElementById('print').onclick=()=>window.print();
document.getElementById('expand').onclick=()=>document.querySelectorAll('details').forEach(d=>d.open=true);
document.getElementById('collapse').onclick=()=>document.querySelectorAll('details').forEach(d=>d.open=false);
</script></body></html>'''
output.write_text(html, encoding='utf-8')
anchors = re.findall(r'href="#([^"]+)"', html)
ids = set(re.findall(r'id="([^"]+)"', html))
assert all(anchor in ids for anchor in anchors), 'Broken internal link'
assert len(files) == len(re.findall('<details>', html)), 'Missing source appendix'
print(f'Generated {output.name}: {section} chapters, {len(files)} source files, {len(html):,} characters. Internal links verified.')

"""Build the public policy page from the same text bundled in the APK."""
import html
import json
from pathlib import Path

root = Path(__file__).resolve().parent.parent
policy = json.loads((root / 'assets/data/privacy_policy.json').read_text(encoding='utf-8'))
email = html.escape(policy['contact_email'], quote=True)
sections = []
for section in policy['sections']:
    text = html.escape(section['text'])
    for url in (
        'https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement',
        'https://policies.google.com/privacy',
    ):
        text = text.replace(url, f'<a href="{url}">{url}</a>')
    text = text.replace(email, f'<a href="mailto:{email}">{email}</a>')
    sections.append(f'<section><h2>{html.escape(section["title"])}</h2><p>{text}</p></section>')

page = f'''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Privacy policy and support contact for the myGrovia Android app.">
  <title>{html.escape(policy['title'])}</title>
  <style>
    * {{ box-sizing: border-box; }}
    body {{ margin: 0; background: #faf9f6; color: #202723; font-family: system-ui, sans-serif; line-height: 1.65; }}
    main {{ max-width: 760px; margin: 0 auto; padding: 48px 24px; }}
    h1 {{ margin: 0 0 16px; font-size: clamp(1.75rem, 5vw, 2.25rem); line-height: 1.25; }}
    h2 {{ margin: 32px 0 8px; font-size: 1.2rem; line-height: 1.4; }}
    p {{ margin: 0 0 16px; }}
    a {{ color: #2f7255; text-decoration: underline; overflow-wrap: anywhere; }}
    a:focus-visible {{ outline: 3px solid #2f7255; outline-offset: 3px; }}
  </style>
</head>
<body>
  <main>
    <h1>{html.escape(policy['title'])}</h1>
    <p>Effective date: {html.escape(policy['effective_date'])}<br>
      Contact: <a href="mailto:{email}">{email}</a></p>
    {''.join(sections)}
  </main>
</body>
</html>
'''
folder = root / 'privacy'
folder.mkdir(exist_ok=True)
(folder / 'index.html').write_text(page, encoding='utf-8')
print('Generated privacy/index.html from assets/data/privacy_policy.json')

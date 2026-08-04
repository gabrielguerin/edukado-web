/**
 * Generates docs/screenshots/GALLERY.md and the README showcase block from
 * manifest.json, so every caption has exactly one source of truth (capture.js).
 */
const fs = require('fs');
const path = require('path');

const TMP = process.env.EDUKADO_WORK || path.join(__dirname, '.work');
const REPO = path.resolve(__dirname, '..', '..', '..');
const OUT = path.join(REPO, 'docs/screenshots');

const manifest = JSON.parse(fs.readFileSync(path.join(TMP, 'manifest.json'), 'utf8'));

const ORDER = [
  'Landing & discovery',
  'Authentication',
  'Documents & contribution',
  'Reciprocity gate',
  'Reputation',
  'Social layer',
  'Admin back office',
  'Role-based access',
  'Responsive',
  'Known rough edges',
];

const annotatedFor = (file) => {
  const base = file.replace(/\.png$/, '');
  return fs.existsSync(path.join(OUT, 'annotated', `${base}-annotated.png`))
    ? `annotated/${base}-annotated.png`
    : null;
};

/**
 * One captioned entry: bold name, em-dash caption, then the image.
 * `mode` decides how an annotated variant is handled:
 *   'both'      — clean image followed by the annotated one (the gallery)
 *   'annotated' — the annotated image only, so a screen is not shown twice
 *   'clean'     — the clean image only
 */
function entry(m, prefix = '', mode = 'both') {
  const ann = annotatedFor(m.file);
  if (ann && mode === 'annotated') {
    return `**${m.name}** — ${m.caption}\n\n![${m.name}, annotated](${prefix}${ann})\n`;
  }
  let out = `**${m.name}** — ${m.caption}\n\n![${m.name}](${prefix}${m.file})\n`;
  if (ann && mode === 'both') {
    out += `\n**${m.name} (annotated)** — The same screen with the mechanism called out.\n\n`;
    out += `![${m.name}, annotated](${prefix}${ann})\n`;
  }
  return out;
}

// ---------------------------------------------------------------------------
// GALLERY.md
// ---------------------------------------------------------------------------
const roleNote = {
  'Role-based access': 'Captured across all three roles, because the point is that the same URL renders differently.',
};

let g = `# Edukado — screenshot gallery

Every screen captured from a running instance of the 2020 application, in the order a
visitor would meet them. The curated subset lives in the
[main README's showcase section](../../README.md#showcase); this page is the complete set.

**How these were captured.** The app was booted exactly as the README's
[Running it locally](../../README.md#running-it-locally) section describes — Ruby 2.6.4,
Rails 6.0.4.4, PostgreSQL 12 and Elasticsearch 7.13.4 in containers — then driven with
Playwright at a 1440×900 viewport and \`deviceScaleFactor: 2\`, so every PNG is a
retina-resolution capture of real rendered pages. Nothing is a mockup.

**About the content.** The interface is in French, which is what the platform was built
for; the captions here are in English. The data is generated demo content seeded into a
local database — plausible coursework, not real student uploads or real traffic.

**Annotated variants.** A handful of screens carry logic that a static image cannot show:
the reciprocity gate, and the way admin access narrows by institution. Those have a second
\`-annotated\` version with the mechanism called out. The clean original is always kept
alongside it.

---

`;

let n = 1;
for (const section of ORDER) {
  const items = manifest.filter((m) => m.section === section);
  if (!items.length) continue;
  g += `## ${n}) ${section}\n\n`;
  if (roleNote[section]) g += `${roleNote[section]}\n\n`;
  for (const m of items) {
    g += entry(m) + '\n';
  }
  g += '---\n\n';
  n += 1;
}

g += `## Reusing these

The PNGs in this folder are the originals, unscaled and uncompressed beyond PNG itself.
They are named \`<area>-<NN>.png\` so they can be referenced individually.

## Regenerating

This page is generated. Captions live beside each shot in
[\`tooling/capture.js\`](tooling/capture.js), so they cannot drift between here and the
README. See [\`tooling/README.md\`](tooling/README.md) for how to re-run the capture.

---

*Edukado was built in 2019–2020 to teach myself Ruby and Rails. The code is preserved as
written; see the [README](../../README.md) for what has aged and why none of it was
repaired.*
`;

fs.writeFileSync(path.join(OUT, 'GALLERY.md'), g);
console.log(`GALLERY.md: ${manifest.length} entries across ${n - 1} sections`);

// ---------------------------------------------------------------------------
// README showcase block
// ---------------------------------------------------------------------------
const pick = (file) => manifest.find((m) => m.file === file);
const P = 'docs/screenshots/';

// Screens whose mechanism is the whole point: the README carries the annotated
// version instead of the plain one. The clean original stays in the gallery.
const ANNOTATED_IN_README = new Set(['gate-01.png', 'scope-02.png']);

const HERO = [
  ['The student experience', [
    'home-01.png', 'feed-01.png', 'search-02.png', 'post-01.png', 'upload-01.png',
  ]],
  ['The give-and-take rule', ['gate-01.png']],
  ['Reputation: points, badges, leaderboards', [
    'dashboard-01.png', 'rankings-01.png', 'badges-01.png',
  ]],
  ['Back office and permissions', ['admin-users-01.png', 'scope-02.png']],
  ['Responsive', ['mobile-01.png']],
];

let r = `## Showcase

Running this yourself takes about half an hour (Ruby 2.6.4, Elasticsearch 7, a seed pass —
see [Running it locally](#running-it-locally)). These are captures of the real thing so you
do not have to.

The interface is in French. The data is generated demo content in a local database. Every
image below is a retina-resolution capture of a live page, not a mockup.

**→ [Full annotated gallery — ${manifest.length} screens](${P}GALLERY.md)**

`;

for (const [group, files] of HERO) {
  const items = files.map(pick).filter(Boolean);
  if (!items.length) continue;
  r += `### ${group}\n\n`;
  for (const m of items) {
    r += entry(m, P, ANNOTATED_IN_README.has(m.file) ? 'annotated' : 'clean') + '\n';
  }
}

r += `**→ [Full annotated gallery — ${manifest.length} screens](${P}GALLERY.md)**, including the
complete Administrate back office, the discovery taxonomy, the authentication flows and the
known rough edges.

Both this section and the gallery are generated from the capture scripts in
[\`${P}tooling/\`](${P}tooling/), which also document how to reproduce the whole set.
`;

fs.writeFileSync(path.join(TMP, 'readme_showcase.md'), r);
console.log(`readme_showcase.md: ${HERO.reduce((a, [, f]) => a + f.length, 0)} hero images`);

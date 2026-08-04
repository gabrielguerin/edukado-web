/**
 * Captures the Edukado screenshot set with Playwright against the container's
 * published http://localhost:3000.
 *
 * Writes PNGs into docs/screenshots/ plus a manifest.json that is the single
 * source of truth for the generated GALLERY.md and README section: a caption is
 * written once, here, next to the shot it belongs to.
 */
const { chromium, devices } = require('playwright');
const fs = require('fs');
const path = require('path');

const TMP = process.env.EDUKADO_WORK || path.join(__dirname, '.work');
const REPO = path.resolve(__dirname, '..', '..', '..');
const OUT = path.join(REPO, 'docs/screenshots');
const ANN = path.join(OUT, 'annotated');

const facts = JSON.parse(fs.readFileSync(path.join(TMP, 'facts.json'), 'utf8'));
const BASE = facts.base;
const PW = 'password';

fs.mkdirSync(TMP, { recursive: true });
fs.mkdirSync(OUT, { recursive: true });
fs.mkdirSync(ANN, { recursive: true });

const manifest = [];
const problems = [];

/** Record a capture so GALLERY.md/README can be generated from one source. */
function rec(file, section, name, caption, role) {
  manifest.push({ file, section, name, caption, role });
}

/** Navigate and let Turbolinks/Stimulus settle before capturing. */
async function go(page, url) {
  const res = await page.goto(url, { waitUntil: 'networkidle', timeout: 90000 });
  await page.waitForTimeout(900);
  return res ? res.status() : 0;
}

/**
 * Capture to docs/screenshots/<file>.png and record its caption.
 * `expect` guards against silently shipping an error page.
 */
async function shot(page, file, section, name, caption, role, opts = {}) {
  const { full = true, expect = 200, status = null, dir = OUT } = opts;
  if (status !== null && expect !== null && status !== expect) {
    problems.push(`${file}: HTTP ${status} (expected ${expect})`);
  }

  const shotOpts = { path: path.join(dir, `${file}.png`), fullPage: full };
  if (full) {
    // Index pages run to tens of thousands of pixels (the blog index is 22,000
    // tall), which is unreadable as an image and needlessly heavy. Cap the
    // captured height: enough to show the page's structure and a good stretch of
    // its content, without the whole tail.
    const { h, vw, vh } = await page.evaluate(() => ({
      h: document.documentElement.scrollHeight,
      vw: document.documentElement.clientWidth,
      vh: window.innerHeight,
    }));
    const max = Math.max(vh, Math.min(2600, Math.round(vw * 1.9)));
    if (h > max) shotOpts.clip = { x: 0, y: 0, width: vw, height: max };
  }
  await page.screenshot(shotOpts);
  if (dir === OUT) rec(`${file}.png`, section, name, caption, role);
  process.stdout.write(`  ✓ ${file}\n`);
}

/** Sign in through the real Devise form; returns a page in that session. */
async function signIn(ctx, email) {
  const page = await ctx.newPage();
  await go(page, `${BASE}/users/sign_in`);
  await page.fill('input[name="user[email]"]', email);
  await page.fill('input[name="user[password]"]', PW);
  // The navbar's search form contributes a hidden submit input that appears
  // first in the DOM, so submit by pressing Enter inside the password field.
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle', timeout: 90000 }),
    page.press('input[name="user[password]"]', 'Enter'),
  ]);
  await page.waitForTimeout(700);
  const signedIn = !(await page.url()).includes('sign_in');
  if (!signedIn) problems.push(`sign-in failed for ${email}`);
  return page;
}

/**
 * Draw numbered callouts over live DOM elements, then capture.
 * Done as an injected overlay rather than by editing pixels so the annotated
 * variant stays crisp at 2x and the clean original remains a separate file.
 */
async function annotate(page, file, callouts, title) {
  await page.evaluate(
    ({ callouts, title }) => {
      document.querySelectorAll('.__ann').forEach((n) => n.remove());
      const layer = document.createElement('div');
      layer.className = '__ann';
      layer.style.cssText =
        'position:absolute;inset:0;z-index:2147483647;pointer-events:none;';
      // Resolve either a CSS selector or `text=<substring>`, which Playwright
      // understands but querySelector does not.
      const resolve = (sel) => {
        if (!sel.startsWith('text=')) return document.querySelector(sel);
        const needle = sel.slice(5);
        const all = Array.from(document.querySelectorAll('body *')).filter(
          (e) => e.children.length === 0 && e.textContent.includes(needle),
        );
        return all[0] ? all[0].closest('div, li, p, section') || all[0] : null;
      };

      const items = [];
      callouts.forEach((c, i) => {
        const el = resolve(c.selector);
        if (!el) return;
        const r = el.getBoundingClientRect();
        const top = r.top + window.scrollY;
        const left = r.left + window.scrollX;
        const box = document.createElement('div');
        box.style.cssText = `position:absolute;top:${top - 4}px;left:${left - 4}px;width:${
          r.width + 8
        }px;height:${r.height + 8}px;border:3px solid #e8590c;border-radius:8px;
          box-shadow:0 0 0 3px rgba(232,89,12,.18);`;
        const badge = document.createElement('div');
        badge.textContent = String(i + 1);
        badge.style.cssText = `position:absolute;top:${top - 18}px;left:${left - 18}px;
          width:34px;height:34px;border-radius:50%;background:#e8590c;color:#fff;
          font:700 18px/34px -apple-system,Segoe UI,Roboto,sans-serif;text-align:center;
          box-shadow:0 2px 6px rgba(0,0,0,.35);`;
        layer.appendChild(box);
        layer.appendChild(badge);
        items.push(`<li>${c.text}</li>`);
      });
      // Legend, pinned to the top of the document so it lands in a full-page shot.
      const legend = document.createElement('div');
      legend.style.cssText = `position:absolute;top:16px;right:16px;width:380px;
        background:rgba(17,17,17,.94);color:#fff;padding:16px 18px;border-radius:12px;
        font:14px/1.5 -apple-system,Segoe UI,Roboto,sans-serif;
        box-shadow:0 8px 24px rgba(0,0,0,.35);`;
      legend.innerHTML =
        `<div style="font-weight:700;margin-bottom:8px;font-size:15px">${title}</div>` +
        `<ol style="margin:0;padding-left:20px">${items.join('')}</ol>`;
      layer.appendChild(legend);
      document.body.appendChild(layer);
    },
    { callouts, title },
  );
  await page.waitForTimeout(250);
  // Same height cap as clean captures, so annotated variants stay readable.
  const dims = await page.evaluate(() => ({
    h: document.documentElement.scrollHeight,
    vw: document.documentElement.clientWidth,
    vh: window.innerHeight,
  }));
  const annOpts = { path: path.join(ANN, `${file}-annotated.png`), fullPage: true };
  const annMax = Math.max(dims.vh, Math.min(2600, Math.round(dims.vw * 1.9)));
  if (dims.h > annMax) annOpts.clip = { x: 0, y: 0, width: dims.vw, height: annMax };
  await page.screenshot(annOpts);
  await page.evaluate(() => document.querySelectorAll('.__ann').forEach((n) => n.remove()));
  process.stdout.write(`  ✎ ${file}-annotated\n`);
}

(async () => {
  const browser = await chromium.launch();
  const mk = () =>
    browser.newContext({
      viewport: { width: 1440, height: 900 },
      deviceScaleFactor: 2,
      locale: 'fr-FR',
      acceptDownloads: true,
    });

  // ======================================================================
  // 1) Landing, discovery and authentication as an anonymous visitor
  // ======================================================================
  console.log('\n== anonymous ==');
  const anon = await mk();
  const a = await anon.newPage();

  let st = await go(a, `${BASE}/`);
  await shot(a, 'home-01', 'Landing & discovery', 'Landing page (signed out)',
    'Public entry point built from the theme\'s reusable partials, leading with the platform\'s premise: pooled coursework in exchange for your own.',
    'anonymous', { status: st });

  st = await go(a, `${BASE}/about`);
  await shot(a, 'about-01', 'Landing & discovery', 'About page',
    'Static page rendered through the same `statics#show` catch-all route that serves the home page, driven by content-block partials.',
    'anonymous', { status: st });

  st = await go(a, `${BASE}/posts`);
  await shot(a, 'feed-02', 'Landing & discovery', 'Document feed (signed out)',
    'The document index as an anonymous visitor sees it — browsable and searchable, but every file is locked behind authentication.',
    'anonymous', { status: st });

  // The signed-out state of the file card: same partial, lock branch.
  if (facts.rich_post_slugs && facts.rich_post_slugs[0]) {
    st = await go(a, `${BASE}/posts/${facts.rich_post_slugs[0]}`);
    await shot(a, 'auth-wall-01', 'Authentication', 'File locked for visitors',
      'A single partial renders three different states of the same file card; this is the anonymous branch, inviting the visitor to sign in or register.',
      'anonymous', { status: st });
  }

  st = await go(a, `${BASE}/users/sign_in`);
  await shot(a, 'sign-in-01', 'Authentication', 'Sign in',
    'Devise session form. The deployment ran eight Devise modules, including confirmable and invitable.',
    'anonymous', { status: st });

  st = await go(a, `${BASE}/users/sign_up`);
  await shot(a, 'sign-up-01', 'Authentication', 'Registration',
    'Registration through a custom `Users::RegistrationsController`, collecting the institution that scopes everything the account later sees.',
    'anonymous', { status: st });

  st = await go(a, `${BASE}/users/password/new`);
  await shot(a, 'password-reset-01', 'Authentication', 'Password reset',
    'Devise recoverable flow. In development the resulting mail is captured by letter_opener rather than sent.',
    'anonymous', { status: st });

  st = await go(a, `${BASE}/users/confirmation/new`);
  await shot(a, 'confirmation-01', 'Authentication', 'Resend confirmation',
    'Confirmable flow: accounts stay inactive until the emailed confirmation link is followed.',
    'anonymous', { status: st });

  // ======================================================================
  // 2) Discovery and the social layer as an ordinary student
  // ======================================================================
  console.log('\n== student ==');
  const studentCtx = await mk();
  const s = await signIn(studentCtx, facts.accounts.student);

  st = await go(s, `${BASE}/`);
  await shot(s, 'home-02', 'Landing & discovery', 'Landing page (signed in)',
    'The same landing page for an authenticated student: the navigation gains the upload action, notifications and the account menu.',
    'student', { status: st });

  st = await go(s, `${BASE}/posts`);
  await shot(s, 'feed-01', 'Landing & discovery', 'Document feed',
    'The heart of the platform: every shared document, filterable by institution, course, category, study level and academic year, with vote counts and comment counts inline.',
    'student', { status: st });

  // Elasticsearch-backed autocomplete, driven interactively.
  try {
    await s.click('#search');
    await s.type('#search', 'analyse', { delay: 110 });
    await s.waitForSelector('.tt-menu .tt-suggestion', { timeout: 15000 });
    await s.waitForTimeout(500);
    await shot(s, 'search-02', 'Landing & discovery', 'Search autocomplete',
      'Typeahead suggestions served by a dedicated `posts#autocomplete` endpoint querying Elasticsearch through searchkick, which indexes titles with `word_start` matching.',
      'student', { full: false });
  } catch (e) {
    problems.push(`autocomplete: ${e.message}`);
  }

  st = await go(s, `${BASE}/posts?search=analyse`);
  await shot(s, 'search-01', 'Landing & discovery', 'Search results',
    'Full-text search results. Queries go to Elasticsearch 7 via searchkick; the same index powers the autocomplete above.',
    'student', { status: st });

  // Taxonomy indexes and one populated detail page for each.
  const tax = [
    ['courses', facts.course, 'Courses', 'Every course across the ten institutions, each a container for the documents shared under it.'],
    ['subjects', facts.subject, 'Subjects', 'Subjects group courses one level up, giving a second axis for browsing.'],
    ['categories', facts.category, 'Categories', 'The eight document types students actually exchange: lecture notes, past papers, practicals, summaries, homework, tutorials, essays and other.'],
    ['groups', facts.group, 'Institutions', 'The ten seeded French institutions. An account belongs to one, and this membership is what scopes a supervisor\'s admin access.'],
    ['tags', facts.tag, 'Tags', 'Free-form tags, applied to both documents and blog articles through separate join tables.'],
    // Index only: `levels#show` is an empty action whose view still passes @posts
    // to kaminari, so every level detail page raises. Captured as a known issue.
    ['levels', null, 'Study levels', 'Study levels one through ten, attached to documents many-to-many so a single file can serve several years.'],
  ];
  let ti = 1;
  for (const [route, entity, label, blurb] of tax) {
    st = await go(s, `${BASE}/${route}`);
    await shot(s, `${route}-01`, 'Landing & discovery', `${label} index`, blurb, 'student', { status: st });
    if (entity && (entity.slug || entity.id)) {
      st = await go(s, `${BASE}/${route}/${entity.slug || entity.id}`);
      await shot(s, `${route}-02`, 'Landing & discovery', `${label} detail`,
        `A single ${label.toLowerCase().replace(/s$/, '')} page, listing the documents filed under it.`,
        'student', { status: st });
    }
    ti += 1;
  }

  // Document detail — the richest page in the app.
  const rich = facts.rich_post_slugs[0];
  st = await go(s, `${BASE}/posts/${rich}`);
  await shot(s, 'post-01', 'Documents & contribution', 'Document detail',
    'A shared document: description, tags, course and level metadata, upvote and downvote controls, the attached file, and the comment thread beneath.',
    'student', { status: st });

  await annotate(s, 'post-01', [
    { selector: 'a.file', text: 'The attachment itself — an Active Storage blob. Following it POSTs to <code>DownloadsController</code>, which meters the download before redirecting to the file.' },
    { selector: '.list-group, .comments, #comments', text: 'Comments, each independently votable through acts_as_votable and rendered by <code>.js.erb</code> partial responses rather than a full page reload.' },
  ], 'Document detail — how it works');

  st = await go(s, `${BASE}/posts/new`);
  await shot(s, 'upload-01', 'Documents & contribution', 'Upload a document',
    'The contribution form: a Stimulus-driven Dropzone for the file, plus the taxonomy that makes it findable — institution, course, category, level and year.',
    'student', { status: st });

  // Reputation.
  st = await go(s, `${BASE}/rankings`);
  await shot(s, 'rankings-01', 'Reputation', 'Leaderboards',
    'Weekly, monthly and all-time rankings, computed by hand-written SQL over merit\'s score tables in `config/initializers/score.rb`.',
    'student', { status: st });

  st = await go(s, `${BASE}/badges`);
  await shot(s, 'badges-01', 'Reputation', 'Badge catalogue',
    'All 43 badges, created at boot from declarative rules in `config/initializers/merit.rb` across bronze, silver and gold tiers.',
    'student', { status: st });

  if (facts.badge_ids && facts.badge_ids.length) {
    st = await go(s, `${BASE}/badges/${facts.badge_ids[0]}`);
    await shot(s, 'badges-02', 'Reputation', 'Badge detail',
      'A single badge, its tier, and what earns it.',
      'student', { status: st });
    st = await go(s, `${BASE}/badges/${facts.badge_ids[0]}/user`);
    await shot(s, 'badges-03', 'Reputation', 'Badge holders',
      'Who has earned a given badge — merit stores awards on a per-user "sash".',
      'student', { status: st });
  }

  // The dashboard belongs to the signed-in account.
  if (facts.student_ref) {
    const me = facts.student_ref.slug || facts.student_ref.id;
    st = await go(s, `${BASE}/users/${me}/dashboard`);
    await shot(s, 'dashboard-01', 'Reputation', 'Student dashboard',
      'The signed-in student\'s own view: accumulated points, badges earned, and the documents they have contributed.',
      'student', { status: st });
  }

  // The public profile of another member, seen as a signed-in student.
  const pu = facts.profile_user || facts.student_ref;
  if (pu) {
    const uref = pu.slug || pu.id;
    st = await go(s, `${BASE}/users/${uref}`);
    await shot(s, 'profile-01', 'Social layer', 'Public profile',
      'Another member\'s public profile: their institution, reputation, badges and shared documents.',
      'student', { status: st });

    st = await go(s, `${BASE}/users/${uref}/posts`);
    await shot(s, 'profile-02', 'Social layer', 'A member\'s documents',
      'Everything one account has contributed, paginated with kaminari.',
      'student', { status: st });
  }

  st = await go(s, `${BASE}/users`);
  await shot(s, 'users-01', 'Social layer', 'Member directory',
    'The member directory across all institutions, searchable through the same Elasticsearch index.',
    'student', { status: st });

  st = await go(s, `${BASE}/notifications`);
  await shot(s, 'notifications-01', 'Social layer', 'Notifications',
    'In-app notifications raised when someone comments on or votes for your document.',
    'student', { status: st });

  st = await go(s, `${BASE}/blog`);
  await shot(s, 'blog-01', 'Social layer', 'Blog index',
    'An editorial section separate from user uploads, with its own tags and cover images.',
    'student', { status: st });

  if (facts.blog) {
    st = await go(s, `${BASE}/blog/${facts.blog.slug || facts.blog.id}`);
    await shot(s, 'blog-02', 'Social layer', 'Blog article',
      'A single article; the body is Action Text rich content, edited through the back office.',
      'student', { status: st });
  }

  // ======================================================================
  // 3) The reciprocity gate — the product's central mechanic
  // ======================================================================
  console.log('\n== reciprocity gate ==');
  if (facts.freeloader && facts.safe_post_slugs.length >= 4) {
    const gateCtx = await mk();
    const g = await signIn(gateCtx, facts.freeloader.email);

    // Perform three real downloads so the gate is triggered by the app's own
    // metering, not by editing the counter.
    for (let i = 0; i < 3; i++) {
      const slug = facts.safe_post_slugs[i];
      await go(g, `${BASE}/posts/${slug}`);
      const link = await g.$('a.file');
      if (!link) { problems.push(`gate: no download link on ${slug}`); continue; }
      // The link is a rails-ujs POST to DownloadsController, which increments the
      // counter and then redirects to the blob. Whether Chromium raises a
      // download event depends on how it handles that redirect, so don't wait on
      // one — what matters is that the POST happened, which the gate below proves.
      await link.click();
      await g.waitForTimeout(1800);
    }

    // Fourth visit: three downloads, zero uploads -> the gate replaces the card.
    const gslug = facts.safe_post_slugs[3];
    st = await go(g, `${BASE}/posts/${gslug}`);
    const gated = await g.$('text=Veuillez contribuer');
    if (!gated) problems.push('gate: prompt did not appear after 3 downloads');
    await shot(g, 'gate-01', 'Reciprocity gate', 'Contribution required',
      'After three downloads with no upload, the same partial swaps the download card for a contribution prompt. The rule is enforced in the view, and the download counter is incremented server-side by `DownloadsController`.',
      'student with 0 uploads', { status: st });

    await annotate(g, 'gate-01', [
      { selector: 'text=Veuillez contribuer', text: 'The gate. <code>download_count &gt;= 3 &amp;&amp; posts.count &lt; 1</code> replaces the file card with this prompt, which links to the upload form.' },
    ], 'The give-and-take rule');
    await gateCtx.close();
  } else {
    problems.push('gate: preconditions not met (no zero-upload user or too few comment-free posts)');
  }

  // ======================================================================
  // 4) Admin back office, and how it is scoped by role
  // ======================================================================
  console.log('\n== superadmin ==');
  const suCtx = await mk();
  const su = await signIn(suCtx, facts.accounts.superadmin);

  const adminShots = {
    users: ['Admin — users', 'The Administrate back office. A superadmin sees every account across all ten institutions.'],
    posts: ['Admin — documents', 'Every uploaded document, with its attachment, taxonomy and owner.'],
    comments: ['Admin — comments', 'Comment moderation across the whole platform.'],
    groups: ['Admin — institutions', 'The institutions that scope both browsing and admin access.'],
    courses: ['Admin — courses', 'Course records, each belonging to an institution and a subject.'],
    subjects: ['Admin — subjects', 'The subject taxonomy sitting above courses.'],
    categories: ['Admin — categories', 'The eight document categories.'],
    tags: ['Admin — tags', 'Tags, shared between documents and blog articles.'],
    // Routed as `resources :blogs, path: 'blog'`, so the admin path is singular.
    blog: ['Admin — blog articles', 'Editorial content, with Action Text bodies edited in place.'],
    years: ['Admin — academic years', 'Academic years, used to date documents by cohort.'],
    levels: ['Admin — study levels', 'Study levels one through ten.'],
  };
  let ai = 1;
  for (const [res, [name, caption]] of Object.entries(adminShots)) {
    st = await go(su, `${BASE}/admin/${res}`);
    await shot(su, `admin-${res}-01`, 'Admin back office', name, caption, 'superadmin', { status: st });
    ai += 1;
  }

  // The merit and acts_as_votable tables are routed and have Administrate
  // dashboards, but no Pundit policies were ever written for those gem models.
  // Because the admin controllers mix in Administrate::Punditize, all four raise
  // Pundit::NotDefinedError. Captured once, as a known issue, rather than four
  // times as if they worked.

  // A record detail page. The matching edit form is refused for every role:
  // ApplicationPolicy#update? returns false, edit? delegates to it, and
  // UserPolicy overrides neither — so the back office is read-only in practice.
  st = await go(su, `${BASE}/admin/users`);
  const href = await su.$eval('a[href^="/admin/users/"]', (el) => el.getAttribute('href')).catch(() => null);
  if (href) {
    st = await go(su, BASE + href);
    await shot(su, 'admin-users-02', 'Admin back office', 'Admin — user detail',
      'A single account with its associations, laid out from an Administrate dashboard class rather than hand-written markup.',
      'superadmin', { status: st });
  }

  // Role scoping: the same route, two different answers.
  st = await go(su, `${BASE}/admin/users`);
  await shot(su, 'scope-01', 'Role-based access', 'All institutions (superadmin)',
    'A superadmin querying `/admin/users` sees every account on the platform.',
    'superadmin', { status: st });
  const suPages = await su.$$eval('a[href*="page="]', (els) =>
    Math.max(0, ...els.map((e) => parseInt((e.href.match(/page=(\d+)/) || [0, 0])[1], 10) || 0)));

  console.log('\n== supervisor ==');
  const svCtx = await mk();
  const sv = await signIn(svCtx, facts.accounts.supervisor);
  st = await go(sv, `${BASE}/admin/users`);
  await shot(sv, 'scope-02', 'Role-based access', 'One institution (supervisor)',
    'The identical route for a supervisor returns only their own institution\'s members. Administrate\'s `Punditize` prefers the policy\'s `resolve_admin` scope over `resolve`, so the narrowing happens in the Pundit policy rather than the controller.',
    'supervisor', { status: st });
  const svPages = await sv.$$eval('a[href*="page="]', (els) =>
    Math.max(0, ...els.map((e) => parseInt((e.href.match(/page=(\d+)/) || [0, 0])[1], 10) || 0)));

  await annotate(sv, 'scope-02', [
    { selector: 'table', text: `Same URL, same code path, narrower result set: ${svPages} page(s) here versus ${suPages} for a superadmin. The scope comes from the Pundit policy.` },
  ], 'Per-institution admin scoping');
  console.log(`  pagination: superadmin=${suPages} pages, supervisor=${svPages} pages`);

  // A student is refused entirely.
  st = await go(s, `${BASE}/admin`);
  await shot(s, 'scope-03', 'Role-based access', 'Refused (student)',
    'A student following the same link is redirected out with a flash message; the back office is guarded by Pundit, not merely hidden from the navigation.',
    'student', { status: null, expect: null });

  // ======================================================================
  // 5) Responsive
  // ======================================================================
  console.log('\n== responsive ==');
  const mob = await browser.newContext({ ...devices['iPhone 13'], locale: 'fr-FR' });
  const m = await signIn(mob, facts.accounts.student);
  st = await go(m, `${BASE}/posts`);
  await shot(m, 'mobile-01', 'Responsive', 'Document feed (mobile)',
    'The feed at 390 px. The 2020 theme was responsive throughout — no separate mobile templates.',
    'student', { status: st });
  st = await go(m, `${BASE}/posts/${rich}`);
  await shot(m, 'mobile-02', 'Responsive', 'Document detail (mobile)',
    'The document page on a phone, comment thread included.',
    'student', { status: st });
  st = await go(m, `${BASE}/rankings`);
  await shot(m, 'mobile-03', 'Responsive', 'Leaderboards (mobile)',
    'Rankings on a phone.',
    'student', { status: st });

  // ======================================================================
  // 6) Development tooling and known rough edges
  // ======================================================================
  console.log('\n== dev tooling / rough edges ==');
  // letter_opener writes the captured mail to tmp/letter_opener as HTML.
  const lo = path.join(REPO, 'tmp/letter_opener');
  if (fs.existsSync(lo)) {
    const dirs = fs.readdirSync(lo).filter((d) => fs.statSync(path.join(lo, d)).isDirectory());
    if (dirs.length) {
      const latest = dirs.sort().reverse()[0];
      const rich2 = path.join(lo, latest, 'rich.html');
      if (fs.existsSync(rich2)) {
        await a.goto('file://' + rich2, { waitUntil: 'load' });
        await a.waitForTimeout(400);
        await shot(a, 'mail-01', 'Authentication', 'Transactional email',
          'Devise mail rendered through the app\'s own mailer layout and captured locally by letter_opener instead of being delivered.',
          'anonymous', { status: null, expect: null });
      }
    }
  }

  // Three unconditional failures, found while producing this gallery and left
  // exactly as they were written in 2020. Each is a different class of mistake.
  st = await go(a, `${BASE}/faq`);
  await shot(a, 'known-issue-01', 'Known rough edges', 'FAQ raises — a route that was never finished',
    'The FAQ is routed `only: [:index]`, but its view calls `new_faq_path`. A helper for a route that does not exist, so the page raises on every request.',
    'any', { status: null, expect: null });

  st = await go(s, `${BASE}/levels/${(facts.level && facts.level.slug) || 1}`);
  await shot(s, 'known-issue-02', 'Known rough edges', 'Level detail raises — an unassigned variable',
    '`LevelsController#show` is an empty action, but `levels/show.html.erb` still hands `@posts` to the kaminari partial. `@posts` is nil, so pagination calls `total_pages` on nothing.',
    'student', { status: null, expect: null });

  st = await go(su, `${BASE}/admin/merit/scores`);
  await shot(su, 'known-issue-03', 'Known rough edges', 'Admin raises — a missing Pundit policy',
    'Four admin sections exist for the merit and acts_as_votable gem tables, complete with dashboards and routes, but no policy classes were ever written for them. Because every admin controller mixes in `Administrate::Punditize`, all four raise `Pundit::NotDefinedError`. The same default is why editing is refused everywhere in the back office: `ApplicationPolicy#update?` returns false and no policy overrides it.',
    'superadmin', { status: null, expect: null });

  // ======================================================================
  fs.writeFileSync(path.join(TMP, 'manifest.json'), JSON.stringify(manifest, null, 2));
  fs.writeFileSync(path.join(TMP, 'problems.json'), JSON.stringify(problems, null, 2));
  console.log(`\ncaptured ${manifest.length} screenshots`);
  if (problems.length) {
    console.log(`\n!! ${problems.length} problem(s):`);
    problems.forEach((p) => console.log(`   - ${p}`));
  }
  await browser.close();
})().catch((e) => {
  console.error('FATAL', e);
  process.exit(1);
});

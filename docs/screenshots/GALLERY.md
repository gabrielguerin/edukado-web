# Edukado — screenshot gallery

Every screen captured from a running instance of the 2020 application, in the order a
visitor would meet them. The curated subset lives in the
[main README's showcase section](../../README.md#showcase); this page is the complete set.

**How these were captured.** The app was booted exactly as the README's
[Running it locally](../../README.md#running-it-locally) section describes — Ruby 2.6.4,
Rails 6.0.4.4, PostgreSQL 12 and Elasticsearch 7.13.4 in containers — then driven with
Playwright at a 1440×900 viewport and `deviceScaleFactor: 2`, so every PNG is a
retina-resolution capture of real rendered pages. Nothing is a mockup.

**About the content.** The interface is in French, which is what the platform was built
for; the captions here are in English. The data is generated demo content seeded into a
local database — plausible coursework, not real student uploads or real traffic.

**Annotated variants.** A handful of screens carry logic that a static image cannot show:
the reciprocity gate, and the way admin access narrows by institution. Those have a second
`-annotated` version with the mechanism called out. The clean original is always kept
alongside it.

---

## 1) Landing & discovery

**Landing page (signed out)** — Public entry point built from the theme's reusable partials, leading with the platform's premise: pooled coursework in exchange for your own.

![Landing page (signed out)](home-01.png)

**About page** — Static page rendered through the same `statics#show` catch-all route that serves the home page, driven by content-block partials.

![About page](about-01.png)

**Document feed (signed out)** — The document index as an anonymous visitor sees it — browsable and searchable, but every file is locked behind authentication.

![Document feed (signed out)](feed-02.png)

**Landing page (signed in)** — The same landing page for an authenticated student: the navigation gains the upload action, notifications and the account menu.

![Landing page (signed in)](home-02.png)

**Document feed** — The heart of the platform: every shared document, filterable by institution, course, category, study level and academic year, with vote counts and comment counts inline.

![Document feed](feed-01.png)

**Search autocomplete** — Typeahead suggestions served by a dedicated `posts#autocomplete` endpoint querying Elasticsearch through searchkick, which indexes titles with `word_start` matching.

![Search autocomplete](search-02.png)

**Search results** — Full-text search results. Queries go to Elasticsearch 7 via searchkick; the same index powers the autocomplete above.

![Search results](search-01.png)

**Courses index** — Every course across the ten institutions, each a container for the documents shared under it.

![Courses index](courses-01.png)

**Courses detail** — A single course page, listing the documents filed under it.

![Courses detail](courses-02.png)

**Subjects index** — Subjects group courses one level up, giving a second axis for browsing.

![Subjects index](subjects-01.png)

**Subjects detail** — A single subject page, listing the documents filed under it.

![Subjects detail](subjects-02.png)

**Categories index** — The eight document types students actually exchange: lecture notes, past papers, practicals, summaries, homework, tutorials, essays and other.

![Categories index](categories-01.png)

**Categories detail** — A single categorie page, listing the documents filed under it.

![Categories detail](categories-02.png)

**Institutions index** — The ten seeded French institutions. An account belongs to one, and this membership is what scopes a supervisor's admin access.

![Institutions index](groups-01.png)

**Institutions detail** — A single institution page, listing the documents filed under it.

![Institutions detail](groups-02.png)

**Tags index** — Free-form tags, applied to both documents and blog articles through separate join tables.

![Tags index](tags-01.png)

**Tags detail** — A single tag page, listing the documents filed under it.

![Tags detail](tags-02.png)

**Study levels index** — Study levels one through ten, attached to documents many-to-many so a single file can serve several years.

![Study levels index](levels-01.png)

---

## 2) Authentication

**File locked for visitors** — A single partial renders three different states of the same file card; this is the anonymous branch, inviting the visitor to sign in or register.

![File locked for visitors](auth-wall-01.png)

**Sign in** — Devise session form. The deployment ran eight Devise modules, including confirmable and invitable.

![Sign in](sign-in-01.png)

**Registration** — Registration through a custom `Users::RegistrationsController`, collecting the institution that scopes everything the account later sees.

![Registration](sign-up-01.png)

**Password reset** — Devise recoverable flow. In development the resulting mail is captured by letter_opener rather than sent.

![Password reset](password-reset-01.png)

**Resend confirmation** — Confirmable flow: accounts stay inactive until the emailed confirmation link is followed.

![Resend confirmation](confirmation-01.png)

**Transactional email** — Devise mail rendered through the app's own mailer layout and captured locally by letter_opener instead of being delivered.

![Transactional email](mail-01.png)

---

## 3) Documents & contribution

**Document detail** — A shared document: description, tags, course and level metadata, upvote and downvote controls, the attached file, and the comment thread beneath.

![Document detail](post-01.png)

**Document detail (annotated)** — The same screen with the mechanism called out.

![Document detail, annotated](annotated/post-01-annotated.png)

**Upload a document** — The contribution form: a Stimulus-driven Dropzone for the file, plus the taxonomy that makes it findable — institution, course, category, level and year.

![Upload a document](upload-01.png)

---

## 4) Reciprocity gate

**Contribution required** — After three downloads with no upload, the same partial swaps the download card for a contribution prompt. The rule is enforced in the view, and the download counter is incremented server-side by `DownloadsController`.

![Contribution required](gate-01.png)

**Contribution required (annotated)** — The same screen with the mechanism called out.

![Contribution required, annotated](annotated/gate-01-annotated.png)

---

## 5) Reputation

**Leaderboards** — Weekly, monthly and all-time rankings, computed by hand-written SQL over merit's score tables in `config/initializers/score.rb`.

![Leaderboards](rankings-01.png)

**Badge catalogue** — All 43 badges, created at boot from declarative rules in `config/initializers/merit.rb` across bronze, silver and gold tiers.

![Badge catalogue](badges-01.png)

**Badge detail** — A single badge, its tier, and what earns it.

![Badge detail](badges-02.png)

**Badge holders** — Who has earned a given badge — merit stores awards on a per-user "sash".

![Badge holders](badges-03.png)

**Student dashboard** — The signed-in student's own view: accumulated points, badges earned, and the documents they have contributed.

![Student dashboard](dashboard-01.png)

---

## 6) Social layer

**Public profile** — Another member's public profile: their institution, reputation, badges and shared documents.

![Public profile](profile-01.png)

**A member's documents** — Everything one account has contributed, paginated with kaminari.

![A member's documents](profile-02.png)

**Member directory** — The member directory across all institutions, searchable through the same Elasticsearch index.

![Member directory](users-01.png)

**Notifications** — In-app notifications raised when someone comments on or votes for your document.

![Notifications](notifications-01.png)

**Blog index** — An editorial section separate from user uploads, with its own tags and cover images.

![Blog index](blog-01.png)

**Blog article** — A single article; the body is Action Text rich content, edited through the back office.

![Blog article](blog-02.png)

---

## 7) Admin back office

**Admin — users** — The Administrate back office. A superadmin sees every account across all ten institutions.

![Admin — users](admin-users-01.png)

**Admin — documents** — Every uploaded document, with its attachment, taxonomy and owner.

![Admin — documents](admin-posts-01.png)

**Admin — comments** — Comment moderation across the whole platform.

![Admin — comments](admin-comments-01.png)

**Admin — institutions** — The institutions that scope both browsing and admin access.

![Admin — institutions](admin-groups-01.png)

**Admin — courses** — Course records, each belonging to an institution and a subject.

![Admin — courses](admin-courses-01.png)

**Admin — subjects** — The subject taxonomy sitting above courses.

![Admin — subjects](admin-subjects-01.png)

**Admin — categories** — The eight document categories.

![Admin — categories](admin-categories-01.png)

**Admin — tags** — Tags, shared between documents and blog articles.

![Admin — tags](admin-tags-01.png)

**Admin — blog articles** — Editorial content, with Action Text bodies edited in place.

![Admin — blog articles](admin-blog-01.png)

**Admin — academic years** — Academic years, used to date documents by cohort.

![Admin — academic years](admin-years-01.png)

**Admin — study levels** — Study levels one through ten.

![Admin — study levels](admin-levels-01.png)

**Admin — user detail** — A single account with its associations, laid out from an Administrate dashboard class rather than hand-written markup.

![Admin — user detail](admin-users-02.png)

---

## 8) Role-based access

Captured across all three roles, because the point is that the same URL renders differently.

**All institutions (superadmin)** — A superadmin querying `/admin/users` sees every account on the platform.

![All institutions (superadmin)](scope-01.png)

**One institution (supervisor)** — The identical route for a supervisor returns only their own institution's members. Administrate's `Punditize` prefers the policy's `resolve_admin` scope over `resolve`, so the narrowing happens in the Pundit policy rather than the controller.

![One institution (supervisor)](scope-02.png)

**One institution (supervisor) (annotated)** — The same screen with the mechanism called out.

![One institution (supervisor), annotated](annotated/scope-02-annotated.png)

**Refused (student)** — A student following the same link is redirected out with a flash message; the back office is guarded by Pundit, not merely hidden from the navigation.

![Refused (student)](scope-03.png)

---

## 9) Responsive

**Document feed (mobile)** — The feed at 390 px. The 2020 theme was responsive throughout — no separate mobile templates.

![Document feed (mobile)](mobile-01.png)

**Document detail (mobile)** — The document page on a phone, comment thread included.

![Document detail (mobile)](mobile-02.png)

**Leaderboards (mobile)** — Rankings on a phone.

![Leaderboards (mobile)](mobile-03.png)

---

## 10) Known rough edges

**FAQ raises — a route that was never finished** — The FAQ is routed `only: [:index]`, but its view calls `new_faq_path`. A helper for a route that does not exist, so the page raises on every request.

![FAQ raises — a route that was never finished](known-issue-01.png)

**Level detail raises — an unassigned variable** — `LevelsController#show` is an empty action, but `levels/show.html.erb` still hands `@posts` to the kaminari partial. `@posts` is nil, so pagination calls `total_pages` on nothing.

![Level detail raises — an unassigned variable](known-issue-02.png)

**Admin raises — a missing Pundit policy** — Four admin sections exist for the merit and acts_as_votable gem tables, complete with dashboards and routes, but no policy classes were ever written for them. Because every admin controller mixes in `Administrate::Punditize`, all four raise `Pundit::NotDefinedError`. The same default is why editing is refused everywhere in the back office: `ApplicationPolicy#update?` returns false and no policy overrides it.

![Admin raises — a missing Pundit policy](known-issue-03.png)

---

## Reusing these

The PNGs in this folder are the originals, unscaled and uncompressed beyond PNG itself.
They are named `<area>-<NN>.png` so they can be referenced individually.

## Regenerating

This page is generated. Captions live beside each shot in
[`tooling/capture.js`](tooling/capture.js), so they cannot drift between here and the
README. See [`tooling/README.md`](tooling/README.md) for how to re-run the capture.

---

*Edukado was built in 2019–2020 to teach myself Ruby and Rails. The code is preserved as
written; see the [README](../../README.md) for what has aged and why none of it was
repaired.*

# Build plan

Launch: **Friday 9 October 2026**, Margate Electronics #13 at Margate Arts Club.

**Status (1 Oct 2026): phase 1 is done and live** at
https://margate-electronics.org (switched on 1 Oct, see `docs/cutover.md`),
with stock read from Bandcamp. Next: the phase 2 cart below. The milestones
are kept as the record of how it was built; where a detail changed later
(e.g. previews now 45 seconds, the newsletter a page), `CLAUDE.md` has the
current state.

Phase 1 is a static catalogue site on Cloudflare Pages. Tickets link out to
the event's ticket platform (OutSavvy for ME#13), tapes link out to Bandcamp. See `CLAUDE.md` for the architecture
and the static build rules.

## How to use this file

One milestone is roughly one working session, sometimes two. Start each in plan
mode, get the plan approved, build it, run the tests, commit. Tick items off
here as they land, so a later session can see where things stand.

Dates are targets. Thursday 8 October is deliberately empty.

---

## M0. Foundations and the deploy pipeline (by Sun 27 Sep)

- [x] `rails new`, Vite set up, TypeScript strict (25 Sep)
- [x] Switch the database from PostgreSQL to SQLite (27 Sep)
- [x] `storage/content.sqlite3` un-ignored and committed
- [x] `tokens.css` exported from Figma variables
- [x] Fonts rendering: IBM Plex Mono self-hosted, Noto Sans JP from Google
- [x] Base layout: header, footer, container, type styles
- [x] Parklife configured, `bin/static-build` with the forbidden-string checks
- [x] `bin/publish` with the SQLite checkpoint
- [x] GitHub repo (private, `tomasjef/margate-electronics-app`), CI on push
- [x] Actions workflow deploying to Cloudflare Pages on push and daily
- [x] Deployed to Cloudflare Pages (27 Sep): https://margate-electronics.pages.dev
- [x] `staging.margate-electronics.org` serving the site (confirmed by Tomas,
  28 Sep)
- [x] Remove what the static site can't use: the Dockerfile and its CI step,
  the production environment's server settings, the server-side newsletter
  sync (see Newsletter below)
- [x] Filters at real paths (`/events/` and so on), pulled forward from M2

**Done when:** editing something locally, running `bin/publish`, and seeing it
on staging a couple of minutes later works end to end.

## Design sign-off (25 to 27 Sep)

- [x] All Figma pages built as a front-end prototype, local at `/prototype`
  (removed 29 Sep, once built for real)
- [x] Rounds 2 and 3: hovers, colour images with stroke, lightbox and
  thumbnails, spacing system, optional headings, logo, mobile menu, Ledger
  audio player, newsletter dialog
- [x] Signed off by Tomas (27 Sep)
- [x] Missing images exported from Figma (ME004, ME003, T-shirt) (real photos uploaded in the admin instead)

## Newsletter

- [x] MailerLite groups: Website (triggers the welcome email) and Events Promo
  (the main list). No double opt-in.
- [x] Server-side sync built (27 Sep), then superseded the same day by the
  static architecture; removed in M0
- [x] Our form posts to MailerLite's existing embedded form, "Sign up"
  (wired in M0, tested with a faked reply)
- [x] Tomas: the "Sign up" form adds to Events Promo and Website; welcome
  email automation on the Website group (27 Sep)
- [x] Live test from the deployed site (27 Sep): MailerLite answered success,
  [address removed] joined both groups
- [x] Tomas: the welcome email arrived (confirmed 28 Sep)

## Waiting on Tomas

- [x] Bandcamp API access requested (26 Sep 2026, via Bandcamp's contact form)
- [x] Bandcamp approves: client ID and secret appear under Settings → API
  Access. Tomas puts them in `.env` as `BANDCAMP_CLIENT_ID` and
  `BANDCAMP_CLIENT_SECRET` (never in chat or the repo)
- [x] ~~Tomas gives each merch option a SKU~~: not needed, matched by album
  title, size name and each colour's Bandcamp item (1 Oct)
- [x] ~~Cloudinary~~: replaced by R2 on 28 Sep
- [x] Cloudflare: the domain is already there; API token and account ID in
  GitHub secrets (27 Sep)
- [x] Backblaze key in the Rails credentials, for the read-only copy to R2.
  Backblaze stays as it is, permanently (videos included).
- [x] Cloudflare R2: buckets `margate-electronics-media` (public, custom
  domain `media.margate-electronics.org`, CORS) and
  `margate-electronics-masters` (private); Images > Transformations on for
  the zone; API token in `.env` as `R2_*` (checked 28 Sep)
- [x] `brew install ffmpeg`
- [x] Admin login: one account (the spare one removed 28 Sep)
- [x] ME003 release date (10 Aug 2026) and the Waffle price (£20)

## M1. Content models and admin (by Tue 29 Sep)

- [x] Event, Release, Track, Product (colours, sizes and stock) and Image
      models; statuses from dates at build time (28 Sep)
- [x] Avo resources, with image upload to R2 and `audio_path` fields
- [x] Media on Cloudflare R2 instead of Cloudinary and Backblaze (28 Sep)
- [x] Audio URL helper with per-segment percent-encoding, tested against the
      awkward existing filenames (`#`, spaces, `&`, brackets, apostrophes)
- [x] Preview generation job: full MP3 or existing `master_path` in, 90-second
      clip out to `previews/<folder>/`, `preview_start` editable
- [x] Tomas: R2 buckets, custom domain, Image Transformations, CORS, API
      token in `.env`, `brew install ffmpeg` (28 Sep)
- [x] `bin/r2-setup`: 29 audio files copied (28 Sep). Systems EP and Tactile
      Machines belong to tomasjef.com: kept on R2, not on this site
- [x] Seed the content with photos on R2 (`bin/rails db:seed`), merge `m1`
      (28 Sep, live on staging)
- [x] Previews for ME003 and ME004 (Tomas uploads the full files in Avo)
- [x] Seeds for ME#13, ME#12, ME003, ME004, the T-shirt and the Waffle print
- [x] Model tests for statuses and date-derived states
- [x] Stock from Bandcamp (1 Oct): `bin/publish` and every deploy (daily
  too) read it, feeding the existing `Inventory` notes and, for cassettes,
  Tape Sold Out

**Done when:** an event and a release can be created in Avo and appear
correctly on staging with images and audio served from the CDNs.

## M2. Home page (by Thu 1 Oct)

- [x] Mixed feed, tiles, category tags, action links (labels On Sale /
      Pre-order / Sold Out / Archived, 28 Sep)
- [x] Margin key with counts (filter pages at `/events/`, `/releases/`,
      `/prints/`, `/apparel/` already exist, since M0)
- [x] Responsive from 1440 down to 390: checked at 1440, 1240, 1024, 800 and
      390 (28 Sep)
- [x] System test for filtering: filter, clear with ×, a tile's tag as a
      filter (28 Sep)

**Done when:** it matches the signed-off design at 1440 and 390 and every
filter page exists in the static build.

## M3. Event pages (by Sat 3 Oct)

- [x] Upcoming template with Book Tickets pointing at the ticket platform
      (OutSavvy for ME#13)
- [x] Archived template with the recordings list
- [x] Real copy and images for ME#13 and ME#12
- [x] Open Graph image and meta tags on every page (28 Sep): heading, the
      description's opening, the poster cropped 1200x630 from the top
- [x] Tomas: artist links in the ME#13 and ME#12 descriptions (admin)
- [x] Tomas: check the ME#13 link preview in WhatsApp or iMessage (30 Sep)

**Done when:** the ME#13 page is good enough to be the link on every poster,
email and social post. If anything slips, it is not this.

## M4. Audio (by Mon 5 Oct)

- [x] Shared transport, marked `data-turbo-permanent`, with the page players
      as remote controls (Stimulus, not React; 28 Sep)
- [x] Play, pause, scrub, elapsed time, one track at a time
- [x] Playback survives navigation, with a now-playing bar and [ STOP ]
- [x] Tomas signs off the bar (desktop and phone): option E (28 Sep)
- [x] Checked on Tomas's iPhone (iOS Safari): plays locked, lock screen
      play, pause and seeking work (28 Sep)

**Done when:** a track keeps playing while browsing, tested on desktop Chrome,
desktop Safari and iOS Safari. Test iOS early.

## M5. Releases, prints and apparel (by Tue 6 Oct)

- [x] Release page with tracklist, players and outbound buy link: "Previews",
      0:00 / 1:30, only tracks with a clip; preview pipeline checked on the
      real R2 (28 Sep)
- [x] Product pages with prices, no cart
- [x] Sold out states: Sold Out tile label, a Sold Out tag in place of Buy /
      Book Tickets, and on apparel in place of the chips (28 Sep)
- [x] Pre-order states: the button follows the release date
      (`pre_order_label` / `buy_label`), checked for ME004 on 8, 9, 10 Oct
- [x] ME004 and ME003 complete with real copy

**Done when:** every item in the feed leads to a finished page.

## M6. Launch readiness and cutover (by Wed 7 Oct)

- [x] Newsletter form posting to MailerLite, tested end to end (27 Sep)
- [x] Analytics: Tomas enables Cloudflare Web Analytics on the Pages project
      (steps in `docs/cutover.md`)
- [x] Favicon, sitemap, robots, 404 page (29 Sep)
- [x] Open Graph images checked in a real link preview (Tomas, WhatsApp or
      iMessage; 30 Sep)
- [x] Accessibility pass: contrast, keyboard, focus, reduced motion (29 Sep)
- [x] Cross-browser and mobile pass (29 Sep)
- [x] `bin/publish` waits for the deploy and says when it's live (29 Sep)
- [x] Cutover plan written: `docs/cutover.md` (29 Sep)
- [x] **Cutover:** `SITE_URL` in `.github/workflows/deploy.yml` changed to
      `https://margate-electronics.org` (canonical and preview links use it)
- [x] **Cutover:** apex and www moved from GitHub Pages to Cloudflare Pages
      (Thu 1 Oct 2026, checked live: every page, www and http redirects,
      robots, audio, newsletter). Old GitHub Pages site still untouched:
      disable it once the new one has run for a few days

**Done when:** margate-electronics.org serves the new site and you would send
the link to someone you want to impress.

## Thu 8 Oct

Buffer. Nothing scheduled.

## Fri 9 Oct

Event. Do not deploy.

---

## Cutlines

If time runs short, drop in this order. Each is safe to ship later.

1. Prints and apparel pages, replaced by a line saying available at events
2. Audio previews on release pages, replaced by the Bandcamp link
3. The ME#12 archive page
4. Filter pages, if the feed is short enough to scan without them

Never cut: the ME#13 event page, the ticket link, the home page, mobile.

---

## Phase 2: cart (built from about 2 Oct on the `cart` branch, in Stripe test mode; merged after 9 Oct, live for ME004 shipping)

Estimate: 5 to 6 sessions. Needs from Tomas: a verified Stripe account, test
keys in `.env`, shipping countries and prices, VAT status, returns policy and
terms of sale, and Bandcamp API access for writing sales back.

- [ ] Stripe products and prices created, IDs stored on Product records
- [ ] Releases sold on the site too (Tomas, 29 Sep: tapes like ME004): a
      Stripe price ID and stock on Release, and a per-release choice of where
      it sells. Sold on the site, the button adds to the cart ("Pre-order" /
      "Buy", switching on the release date as now); sold on Bandcamp, it stays
      the outbound link (`Release#button_label`, words from the link).
- [ ] `worker/` with `wrangler.toml`, TypeScript, D1 binding for stock
- [ ] Worker endpoint: validate cart, check stock, create an Embedded Checkout
      session. Prices come from Stripe, never from the browser.
- [ ] Worker endpoint: webhook with signature verification, idempotent,
      decrements stock
- [ ] Cart island: localStorage state, header count, add and remove
- [ ] Checkout page mounting Stripe Embedded Checkout
- [ ] Shipping options and address collection in the Checkout session
- [ ] Stripe test mode end to end, then one real purchase and refund in live
      mode

Open question: items are also sold on Bandcamp, so stock in D1 and on Bandcamp
can drift apart. Decide before phase 2 which one is the single count, and
whether the Worker writes each site sale back to Bandcamp. (Since 1 Oct the
site reads Bandcamp's stock on every publish and daily: `BandcampStock`.)

## Phase 3: native ticketing (November onwards)

Same Worker pattern: ticket types, capacity in D1, QR codes, confirmation
emails, door check-in page, printable guest list.

## After launch

**Newsletter on the site's own list:** the list exported from MailerLite,
sending through Amazon SES (domain verification, DKIM, SPF, DMARC, production
access), unsubscribe links and bounce handling, then MailerLite retired.

## Backlog

Full event archive, artist pages, releases index filtered by format, RSS,
structured data for events.

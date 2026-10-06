# Margate Electronics

Website for Margate Electronics, an experimental electronic music event series
and label based in Margate, UK. Run by one person, who is also the only editor.
Design-led, text-first, monospace ledger aesthetic.

**Live at https://margate-electronics.org since 1 October 2026**; the launch
event is Margate Electronics #13 at Margate Arts Club on 9 October.

The build plan is in `docs/build-plan.md`. Decisions already made are in
`docs/decisions.md`. Read both before starting a milestone.

## Architecture in one paragraph

A Rails app that runs only on Tomas's Mac. Content is edited locally in Avo and
stored in SQLite, committed to the repo. Parklife crawls the app and writes a
static site, which GitHub Actions deploys to Cloudflare Pages. There is no
production Rails server. From phase 2, a Cloudflare Worker (TypeScript) handles
the cart's server side: Stripe Checkout sessions, the webhook, and stock in D1.

## Phases

**Phase 1 (live): static catalogue.**

- No cart, orders, line items, checkout or Stripe code on `main` until after
  launch (phase 2 is built on its own branch, see below). Do not add the
  `stripe` gem.
- No ticketing, QR codes or scanning.
- Links to other sites open in a new tab (`target="_blank" rel="noopener"`):
  in templates through `external_link_to`, in typed text through `copy`.
  The site's own links and e-mail links don't.
- Buy and book actions are outbound links (each event's ticket platform, OutSavvy for ME#13; Bandcamp
  for tapes), never a button that posts to this app.
- Product data (price, stock, variants) is still modelled properly, because the
  cart arrives in phase 2 and the data is real either way.

**Phase 2 (cart): built from about 2 October on the `cart` branch, live after
launch, in time for ME004 shipping (late October).** A React and TypeScript
cart island on the static site, cart state in localStorage, checkout through a
Cloudflare Worker using Stripe Embedded Checkout. Stock in Cloudflare D1.
Orders managed in the Stripe Dashboard. The branch uses Stripe test mode only
and is merged into `main` after 9 October, never before (Tomas, 28 Sep). The
phase 1 features come first.

**Phase 3 (November onwards): native ticketing** on the same Worker pattern.

If a phase 1 task seems to need anything dynamic, stop and ask rather than
building it.

## Stack

- Ruby 3.3.5 on Rails 8.1, Hotwire (Turbo + Stimulus, via npm). Runs locally
  only.
- Node 24 (pinned in `.nvmrc`; run `nvm use`)
- SQLite. Solid Queue for background jobs and ffmpeg for audio previews, both
  local only. No Redis.
- Avo Community for the admin, local only, never deployed
- Parklife for the static export (`parklife-rails`; `Parkfile`, `bin/static-build`)
- Vite (`vite_rails`) builds all JS and CSS. Entrypoints are
  `app/javascript/entrypoints/application.ts` and
  `app/javascript/entrypoints/application.css` (linked in the head, so pages
  never paint unstyled). Propshaft only serves images.
- TypeScript strict mode. React only for the phase 2 cart island, added on
  the `cart` branch (see Frontend conventions)
- Plain CSS with custom properties. No Tailwind, no CSS framework.
- Media on Cloudflare R2 (S3-compatible, `aws-sdk-s3`): images uploaded
  through Active Storage from Avo, resized by Cloudflare Image
  Transformations; audio referenced by path (see Audio). Served at
  `media.margate-electronics.org`. Backblaze B2 keeps the old site's files,
  including the videos, permanently: never delete or change anything there.
- Hosting on Cloudflare Pages, deployed by GitHub Actions
- Newsletter: our own form, posting directly to MailerLite from the static page
- Phase 2 only: Cloudflare Workers, D1, Stripe, all in `worker/` with its own
  `wrangler.toml`

## Commands

```
nvm use              # Node 24
bin/setup            # install gems and npm packages, prepare the database, start bin/dev
bin/dev              # Rails server and Vite dev server (foreman, Procfile.dev); admin at /admin
bin/ci               # all the checks: rubocop, typecheck, vite build, audits, tests, static build (never migrates the content database)
bin/rails test       # unit and integration
bin/rails test:system
bin/rubocop
npm run typecheck    # tsc --noEmit
bin/vite build       # production asset build
bin/lan              # with bin/dev running: serve on port 3001 to the local network, to check on a phone
ADMIN_EMAIL=… ADMIN_PASSWORD=… bin/rails db:seed   # create the admin user
bin/static-build     # Parklife export into build/, then the checks below (also a bin/ci step)
bin/publish          # stock from Bandcamp, checkpoint SQLite, commit only the content database, push main, wait for the deploy, print "Live: …"
bin/rails bandcamp:stock  # copy stock from Bandcamp onto the content (needs .env loaded; bin/publish does it)
bin/rails images:dither   # make the dithered loading stand-ins for photos without one (needs .env loaded)
bin/public-snapshot  # publish main's code to the public repo tomasjef/margate-electronics-site, admin user and sessions removed from the database
```

Keep this section accurate. Update it whenever a command changes.

The pages read the content database. `db/seeds/content.rb` holds a small
set of content (ME#13, ME#12, ME004, ME003, the T-shirt, the Waffle print,
the About page), loaded into an empty database by `bin/rails db:seed` and
used as the tests' data. The real content is only ever edited in the admin.

## Content database

- `storage/content.sqlite3` is the source of truth for all content and is
  committed to the repo. Un-ignore it in `.gitignore`. The test database stays
  ignored.
- Rails runs SQLite in WAL mode, so recent writes can sit in the `-wal` file.
  `bin/publish` must run `PRAGMA wal_checkpoint(TRUNCATE)` before committing,
  otherwise the committed database is missing the latest edits.
- Never commit the `-wal` or `-shm` files.
- A migration reaches the content database only through `bin/rails
  db:migrate`, run in the same command as the commit of its code: a
  publish in between would ship a database the committed code doesn't
  match. `bin/ci` never migrates it (`bin/setup --skip-content` prepares
  only the test database; `bin/ci-static-build` builds from a migrated
  copy).

## Static build rules

These exist because the published site has no Rails behind it.

- **Only CDN URLs in output.** Every image and audio link is built by
  `MediaUrls` from the file's key or path on R2's public address. Never
  `url_for(blob)`, `rails_blob_path`, `variant` or any Active Storage route:
  they need Rails, and the published site has none.
- **No Active Storage variants.** Cloudflare resizes images through the URL
  (`/cdn-cgi/image/width=…,quality=auto,format=auto/<key>`) at a fixed set of
  widths (`MediaUrls::WIDTHS`; free up to 5,000 unique transformations a
  month). Pages use a 1x and 2x `srcset`.
- **Filters are real paths**, not query parameters: `/events/`, `/releases/`,
  `/prints/`, `/apparel/`, each pre-rendered.
- **Links end in `/`** (`ApplicationController#default_url_options`), matching
  the `path/index.html` files the build writes, so Cloudflare Pages serves
  them without a redirect.
- **Content images come from R2**; site images (logo, icons) from
  `public/assets`, copied one by one as the pages reference them. The rest of
  `public/assets` holds the admin's files and is never deployed.
- **Every page must be reachable by a link** so Parklife finds it, or be listed
  explicitly in the Parklife config.
- **Date-based states are computed at build time.** A scheduled daily rebuild
  keeps Next Event, Archived, New Release and the pre-order / Buy switch
  current, and reads Bandcamp's stock.
- **Nothing posts to Rails.** Forms on the public site post elsewhere (the
  newsletter to MailerLite) or not at all.
- `bin/static-build` fails the build if any output file contains
  `/rails/active_storage`, `localhost` or `127.0.0.1`, or if `404.html`,
  `sitemap.xml`, `robots.txt`, `feed.xml`, `_headers` or the icons are missing.
- **Built from routes, listed in the `Parkfile`:** `404.html` (Cloudflare
  Pages serves it for missing addresses; it answers 200 when built, since
  Parklife stops on a 404), `sitemap.xml` (every public page at `SITE_URL`),
  `robots.txt` (indexing allowed only on margate-electronics.org) and
  `feed.xml` (Atom, every entry newest first, `PagesController#atom`; each
  page's head links to it, with no visible link).
- `public/_headers` marks the staging and pages.dev addresses
  `X-Robots-Tag: noindex`, before and after the cutover.
- Icons: `public/icon.svg`, `favicon.ico` and `apple-touch-icon.png`, made
  from `me-logo.svg` (the commands are in the layout).
- The build needs no media keys at all: it only reads files' keys from the
  content database (production mode falls back to a local `without_keys`
  service).

## Domain model

- **Event**: title (its "#13" gives the bar's "M.E.#13", as on the posters), slug, date, doors_at, music_at, venue,
  `tickets` (prices), lineup fields `live`, `dj`, `screening`, `workshop`,
  description (free text), poster image, `external_ticket_url`, `sold_out`,
  status (`upcoming` / `archived`, derived from the date at build time).
  The text under the poster is written from these (`event_text` helper):
  before the night Book Tickets; the title and lineup; after a blank line,
  in italic, the venue, and before the night "Date: Fri 9 Oct 2026",
  "Time: Doors 7PM / Music 8PM" and "Tickets: …" (Tomas, 3 Oct: the prices
  under the time, no longer beside Book Tickets); then the description.
  Before the night, Add to Calendar (a white button after Book Tickets or
  Sold Out) links to `/events/<slug>/calendar.ics` (`EventCalendar`): the
  title, from the doors time in UK time for four hours (all day when the
  time can't be read), the venue, the lineup and the page's address.
- **Release**: catalogue number (ME004), artist, title, format, edition size,
  price, release date, status (`pre_order` / `available` / `sold_out`),
  description, credits (shown as typed, usually italic), cover
  image, `external_buy_url`. Written from the fields, never typed twice:
  the heading ("Artist – Title", unless one is typed; `headline`), the
  first two info lines ("Artist – Title (ME004)", "Cassette + digital,
  edition of 25"; `info_html`, then any typed lines), the credits' closing
  "© <year> Margate Electronics" (`credits_html`), and the button's words
  from the link ("Pre-order on Bandcamp" until the release date, then "Buy
  on Bandcamp"; elsewhere "Pre-order" / "Buy"; `Release#button_label`).
  Event buttons always say "Book Tickets", product buttons "Buy".
- **Track**: belongs to a Release (album tracks) or an Event (recordings from the
  night), title, duration, position, `audio_path`, and for releases
  `master_path` and `preview_start`
- **Product**: prints and apparel, with variants (size, colour), price, stock,
  `external_buy_url`, `sold_out` (apparel is also sold out when every size and
  colour is at 0), and a `stripe_price_id` column left empty until phase 2.
  Stock is per size and colour combination; the `Inventory` class (sold-out
  sizes, "N remaining" at `LOW_STOCK` or fewer) is the logic to keep when this
  becomes a model.
- **Stock from Bandcamp** (`BandcampStock`, `BandcampApi`, read only on
  Bandcamp): `bin/rails bandcamp:stock` runs in `bin/publish` (so the content
  database holds it) and in every deploy, the daily one included (on the
  build's copy). Each T-shirt colour links to its Bandcamp item by
  `ProductColour#bandcamp_package_id` (the items are named by emoji: ⚪️🔵
  Natural, ⚫️⚪️ Black; never shown on the site), sizes by the option's name.
  Cassettes match their release by album title into `Release#tape_stock`;
  under the price the page says "9 of 25 tapes remaining" (`tape_note`, in
  the stock-note style); at 0 it shows Tape Sold Out with "Buy Digital on Bandcamp" and no
  tape price (`tape_sold_out?`; `sold_out` still means everything gone).
  Without keys, or with Bandcamp out of reach, the stock last saved stays.
- **Image**: on an event, release or product; placement `gallery` (the first
  is the main photo; with more than one they show as thumbnails) or
  `scatter`; alt text (required), optional caption (lightbox and scattered
  photos; under scattered photos its credit, "Photo © …", "Design © …" or
  "Courtesy of …", starts its own line, `Image#caption_lines`; the
  lightbox keeps it on one), position, a colour for apparel photo sets, and an optional crop
  (`display_ratio`). Items also have an optional `tile_ratio` for the home tile.
- **Home tile text** is written from each item's fields (`TileText`), never
  typed: events their heading (or title) and lineup (no date, venue or
  time, before or after the night); releases their info lines and "Out on …"
  while a pre-order; products their heading (or title) and info lines. Each
  item's "Text on the home tile" switch (`show_tile_text`) hides it.
- **AboutPage**: one record, edited in the admin ("About" in the sidebar):
  `heading` (optional large heading, "Margate Electronics" to start),
  `body` (the page's text), `credit` (an optional line under the artists)
  and `artists` (one name per line; the page
  lists them A to Z, each once, `artist_names`). "About" in the sidebar
  opens it for editing; it can't be deleted or duplicated.
- **Stockist**: the record shops that stock the tapes, edited in the admin
  ("Stockists"): city, name, url, position. `Stockist.by_city` groups them,
  cities in the order of their first shop. Shown on `/stockists/`
  (`shared/_stockists`: centred in the window like the newsletter page, no
  Back; one column read like the About text, links white on hover; linked
  from the menu), and as a
  plain line under a release's price (`shared/_stockist_line`): "Also in
  select record shops: see stockists", or once sold out on Bandcamp "Sold out
  on Bandcamp. A few copies may still be in shops, see stockists."; nothing
  before the release date. The About page links to `/stockists/`.
- **StockistsPage**: an optional large `heading` (empty to start), and the
  lines above and under the list on `/stockists/`
  ("Our tapes are stocked in these shops:", "Interested in stocking our
  releases? Get in touch." linked to the e-mail), one record edited in the
  admin ("Stockists page", like About); empty leaves either out.
- **IndexPage**, **NewsletterPage**: one record each, edited in the admin
  ("Index page", "Newsletter page"), each with an optional `top_line` and
  `heading` (the Index's a large heading, empty to start; the Newsletter
  page's an optional title above the field, empty to start, as its top
  line names it; on phones, without one, "Newsletter" shows above the
  field instead of the top line). AboutPage,
  StockistsPage and Product have a `top_line` too.
- **Index** (called Index on the site, address `/archive/`, `PagesController#archive`;
  Cloudflare Pages treats addresses with "index" in them as folder pages): the full width of
  the window, every row ruled with a hairline (`--stroke` in the ink). From
  768 up its header and footer aren't pinned: they stay at the top and the
  end of the page (no grey name bar), as its rows run under where they're
  pinned elsewhere; the logo stays pinned, turning. Phones keep theirs. First
  a Recordings section (the audio chip) with `[ PLAY ALL ]`; then every
  published event and release as a ledger (a table; rows stacked into short
  blocks where the columns don't fit: releases below 1024, events below
  768),
  newest first, each row opening its page, all plain text (no chips):
  events their date and series title under "Event" ("Margate Electronics
  #10", no theme; `Event#series_title`),
  lineup and how many recordings; releases their Cat #, artist, title,
  format, date and label (`Feed.release_label`). From 1240 the tables sit
  on the artist index's four columns: Event and Artist line up after a
  date-wide first column, Lineup and Title start at column 2, Format at 3,
  the releases' Date at 4; Recordings and Status share a column at the
  right edge. The last columns
  (Recordings, Status) share a width and line up. Then the artist
  index (`ArtistIndex`) in four ruled columns (two on tablets, one on
  phones): the About page's names (each on one line; when a name and its
  links don't fit, the links move whole to a line of their own), each with the events
  ("M.E.#3", comma-separated, with releases' catalogue numbers) whose lineup names it (whole words, any case) and the releases that are theirs.
  Linked from the menu, first.
- **Feed** (`app/models/feed.rb`): items pinned with `home_position` first
  (lowest number first), then upcoming events, then newest first (events by
  date, releases by release date, products by `listed_on`), undated last; tags Next Event / Event / New Release / Release / Apparel /
  Print and labels On Sale / Pre-order / Sold Out / Tape Sold Out / Archived
  with the year ("Archived 2023"; events past their date, sold out or not).

The home page is a mixed feed of Events, Releases and Products ordered by
recency. Build it as a query object or presenter that merges the three, not as a
single polymorphic table.

## Filtering

- Types: Event, Release, Print, Apparel. Recordings live inside event pages and
  are not a type.
- Each filter is a real, pre-rendered path (`/events/` and so on), so views are
  shareable and the back button works.
- Single select; no filter shows everything (there is no "All" tab). Counts
  shown next to each type. Hide a type when its count is zero.
- Home page only. The key sits in the left margin on desktop; phones show no
  key, only the active filter with its × on a filtered page (see Design
  system).

## Design system

Signed off by Tomas on 27 Sep 2026. The Figma file ("ME-new", file key
`rPsWfum4UgU7YIjxr4rmGM`) is the source of truth for layout, as refined in the
design rounds recorded in `docs/decisions.md`. Tokens live in
`app/assets/stylesheets/tokens.css`, exported from Figma variables.

**Never hardcode a colour, spacing value, font size or line height in a
component. Use a token. If a token is missing, ask before inventing one.**

- Background `#cccccc`, text and links `#0000ff`
- Category tags: Event `#ffe500`, Release `#7cff4f`, Print `#3de8ff`,
  Apparel `#ffa3e6`, audio (Recordings, Previews) `#ffb347`. Action tags (On
  Sale, Pre-order, Archived, Book Tickets, Buy) are white. Tag text is the
  blue, except Sold Out and Tape Sold Out: red on a pale red tint.
- **Match Figma exactly.** Spacing, sizes and positions come from the frames,
  including off-grid values (3, 6, 9, 10, 50...). Every value is a named token
  in `tokens.css`; add a token rather than a raw value.
- Type: Heading/H1 24px Plex Mono Medium (500), Body 14px (16px on phones,
  matching form fields so iPhones don't zoom), Small and Credits 12px
  (credits italic), photo captions 11px (12px on phones), italic. Line height is Plex's own 1.3.
- Text is measured from cap height to baseline, like Figma: text blocks use
  the `.trim` class (`text-box: trim-both cap alphabetic`).
- Typefaces: IBM Plex Mono (self-hosted via `@fontsource/ibm-plex-mono`, weights
  400 and 500 plus 400 italic) with Noto Sans JP from Google Fonts for kana and
  kanji (weights 400 and 500 only, loaded without holding up the page:
  `media="print"` switched on load, with a `<noscript>` copy). Stack is `"IBM Plex Mono", "Noto Sans JP", ui-monospace, monospace`, in
  that order, so Latin and Lithuanian never fall through. Do not substitute or
  add typefaces.
- While a photo loads it shows its dithered stand-in: a 64px-wide
  two-colour version in the site's blue and grey (`Dither`, a data URI in
  `images.dither`), drawn blown up into square blocks (`lib/dither` marks
  photos still loading). The lightbox shows it too, at the photo's size
  with its caption, while a photo it opens on loads (`lightbox_image`
  gives the original's height; the dialog controller sizes it), and a
  gallery thumbnail's swap carries its own. Made by `MakeDitherJob` after each upload; `bin/rails
  images:dither` makes any missing (needs `.env` loaded). Without
  JavaScript, photos load as before.
- Images are full colour. On hover or focus they show a 3px stroke inside the
  image in the category colour (event yellow, release green, apparel pink,
  print cyan), set by `--category` on `.tile--*` / `.detail--*`. Selected
  text takes the same colour (yellow outside a category).
- Hover: category tags and filters turn white; buy, book and subscribe
  buttons and the filter's × turn blue with white text; links in body text
  turn white and stay underlined; so do the Index's rows and artist links,
  not underlined at rest (Tomas, 3 Oct). The home tiles' captions only
  underline, staying blue (Tomas, 5 Oct). The audio controls
  (`[ PLAY ]`, `[ STOP ]`, `[ PLAY ALL ]`, `[ NEXT ]`, `[ CLOSE ]`) turn
  white on hover, not underlined; the bar's title, a link, white and
  underlined. Only body text links are ever underlined at rest; navigation (site name, menu, footer, Back / Next, tile
  captions) underlines on hover only with a real pointer (`@media (hover:
  hover)`), since a tap on a phone leaves a link "hovered". The menu's
  links never underline: they turn white. On home tiles, On Sale / Pre-order / Sold Out / Archived are
  descriptive labels, not links (the tile opens the page).
- Sold out: on the item's page a red Sold Out tag (red on a pale red tint,
  `tag--sold-out`, also the home tile's label) replaces Book Tickets or
  Buy (`shared/_sold_out`); on apparel it also replaces the size and colour
  chips and the stock notes.
- Filters are on the home page only (`shared/_filter_key`): no "All" tab;
  the active filter shows a square × beside it that clears it.
- **Brackets mean "press this":** controls drawn as text use spaced
  brackets, `[ PLAY ]`, `[ STOP ]`, `[ CLOSE ]` (non-breaking spaces,
  hidden from screen readers where added in CSS). The menu is the
  exception (Tomas, 5 Oct): "Menu", "Close" and its links are plain words;
  so is the lightbox's "Close", "← Prev", "Next →" at every size (6 Oct). Never bracket anything that
  can't be pressed. Keep bracketed labels to one short word.
- **The menu** (Tomas, 5 Oct; `shared/_menu`, `menu` controller on
  `<body>`): every link is in it. "Menu" sits top right at every size
  (pinned from 1240; in the grey bar too), where Cart will go beside it.
  It drops a block over the top of the window, the page's grey with blue
  text in the body type (on phones blue with white text, Tomas, 5 Oct): the
  name and Close where the name and Menu are, then Events · Releases ·
  Apparel · Prints (the home page's filters, each only with entries:
  phones have no filters otherwise), Index · About · Stockists,
  Newsletter · E-mail, ↑ Bandcamp · ↑ Instagram; from 768 the name, the
  four groups and Close side by side,
  equally spaced across the window (one column on phones).
  The page you're on has a dot before it (not colour alone); links turn
  white on hover. Over the page, the rest of the page is inert while it's
  open, so Tab and screen readers stay in the menu. After the last
  link two blank lines of solid grey, then its last 80 feathers away into
  the page behind, which is blurred and doesn't scroll.
  On phones its link groups are a section gap (40) apart, like the name
  and the links. On phones there's no fade and no blur; a 1px blue line
  marks its bottom edge, 40 under the last link and, at the top of the
  page, 40 above what follows
  (costly on older phones); at the top of the page it sits in the page in
  the header's place and pushes the page down (`menu-flow`), mid-page (from
  the grey bar) it rolls down over the page where you are. Esc, Close or a click on the page closes
  it, and focus goes back to Menu.
- Phones (below 768px): no filter tabs, except that a filtered page
  (reached from a tile's chip) shows its active filter with the ×; Back
  sits at the end of the page, level with the logo.
- Event, release and product pages have "← Back" instead (`shared/_back_link`, `back` controller; About and Stockists have none):
  back to the previous page when it was on this site, otherwise to the
  section on the home page. Fixed: left margin, vertically centred, at 1240px
  and up; bottom left (opposite the logo) below that.
- "Next →" beside it on event, release and product pages (`Feed#next_path`):
  the next entry in the home page's order, wrapping round from the last to
  the first. Right margin, vertically centred, at 1240px and up; just after
  Back below that (phones: side by side at the end of the page).
- Keyboard (`shortcuts` controller on `<body>`): Space plays or pauses
  what's in the transport (scrolls as usual when nothing is), ← clicks
  Back, → clicks Next. Not while typing, on a focused button or player (its
  arrows skip 10 seconds), with a modifier key, or with the lightbox or
  phone menu open. Not shown anywhere on the site.
- Apparel: size and colour as chips (radio buttons); chosen pink, sold-out
  options faded and disabled. No native dropdowns (unstylable in Safari).
- **Spacing system:** only three gaps between elements. `--gap-group` 10
  (within a group), `--gap-related` 20 (related things), `--gap-section` 40
  (between sections). Page top and bottom are 80 on wide screens, 40 on phones.
  Page margin 20, 15 on phones. Paragraphs are one blank line apart.
- Page headings are optional: one large centred heading (24px Medium) that
  holds the whole title, e.g. "Kodama こだま · ME004 / koke no ne こけのね".
  Its line breaks show on phones too. In tab and link-preview titles
  (`heading_text`) the lines join with " – " after a capitalised word
  ("Ambient Garden – Kodama…"), otherwise a space.
  No small line above it. The header status line (the "top line") is
  automatic on events and releases, never typed there: events "Upcoming –
  9 Oct 2026", then "Archived – 9 Oct 2026"; releases their catalogue
  number, "ME004 – Pre-order, out on 9 Oct 2026" until the release date.
  Every other page (About, Stockists, apparel and prints, the Index, the
  Newsletter page) can have one typed in the admin ("Top line", the
  `top_line` helper), and a large heading (Tomas, 5 Oct). About,
  Stockists, the Index and Newsletter have no section chip beside the name
  (chips are for categories): their top line names them, "About" and so
  on, unless one is typed. Dates on the site read "9 Oct 2026" (`to_fs(:site)`,
  unambiguous in the UK and US; Tomas, 1 Oct); the admin's date fields
  stay DD.MM.YYYY.
- Images on detail pages open in the lightbox (`dialog` controller on `<body>`,
  one `<dialog>` in the layout); thumbnails swap the main image (`gallery`).
  In the lightbox, Prev/Next (and arrow keys) step through all the page's
  images and wrap round.
- Photos on detail pages: an optional main photo with thumbnails
  (`shared/_main_media`; every photo in its own shape, its crop from the
  admin or its proportions: the main photo changes shape with the thumbnail
  chosen, and thumbnails are 80 wide at their own heights) and optional scattered photos (`shared/_scatter`:
  two masonry columns; at 1240px and up each photo shifts to a seeded random
  grid position across the 8-column width, its own half or the middle,
  never touching a photo level with it, and drops 0 to 3 section gaps, the
  right column starting lower, so same-size photos don't form rows;
  `Scatter.places`, seeded by the slug, or with the item's "Reshuffle
  photos" number set, the slug and that number: `scatter_seed`).
- Audio player ("Ledger"): `[ PLAY ]` / `[ STOP ]`, title, time, then a rule
  drawn in characters, `[|||.......]`, sized to the column from the real
  character width. The first bar appears the moment sound starts.
  `[ PLAY ]`, title and time are always one line: a title too long for it
  ends in … and moves across while its track plays, like the phone's bar
  (`lib/scroll_across`; still for reduced motion).
- The ME logo is 50px and turns clockwise with scroll, a whole number of
  turns over the page, so it is upright at the very top and the very bottom.
  It turns for reduced motion too (Tomas's choice; see Accessibility). Only
  scroll turns it: nothing moves it while music plays.
- The site name stays in place while scrolling. At 1240px and up the header
  is pinned in the margins (name and category chip; on home the description
  shortens once scrolled). Below that, a grey bar (`.sticky-name`,
  `scroll-state` controller) shows just "Margate Electronics" and Menu;
  the category chip scrolls away with the page.
- The logo is fixed in the bottom-right corner at every screen size.
- Footer: just the logo (and Back / Next on entry pages); every link is in
  the menu (Tomas, 6 Oct: Newsletter Sign Up removed from it).
- Space above and below the content is even: 80 on wide screens, 40 on
  phones.
- Layout: single column scroll, two column tiling on wide screens, 1440 reference
  width with content in a centred container (two 440 columns, 40 gap).
- Use the Figma MCP for variables, measurements and structure. Never paste its
  generated code into the project. Build markup by hand from the tokens.

## Frontend conventions

Hotwire by default. Server-rendered HTML exported as static files, Turbo Drive
for navigation, Stimulus for small behaviours. Stimulus controllers live in
`app/javascript/controllers` as `*_controller.ts` and register themselves by
file name. Remember that nothing can post to the Rails app once deployed.

React is allowed in exactly one place: the phase 2 cart island. It isn't
installed on `main` (removed 29 Sep, unused); the `cart` branch adds it. The
home filter and the shared audio transport were built without it (server
pages and Stimulus).

Anything else that seems to want React should be a Stimulus controller or a
Turbo Frame. Ask before adding another island.

React code is TypeScript with strict mode, no `any`, and props typed explicitly.

## Admin

- Avo (Community edition) mounted at `/admin`, local only, never deployed.
  Config in `config/initializers/avo.rb`, resources in `app/avo/resources`.
- Login is Rails 8's built-in authentication (`User`, `Session`, `Current`,
  the `Authentication` concern). No Devise, no sign-up and no password reset
  (there is no email sending; change the password with `bin/rails runner`). Every controller
  requires login unless it calls `allow_unauthenticated_access`, so public
  controllers must call it.
- `app/controllers/avo/application_controller.rb` includes `Authentication`, so
  `/admin` redirects to `/session/new` when signed out.
- The single admin user is created by `db/seeds.rb` from `ADMIN_EMAIL` and
  `ADMIN_PASSWORD`. Never commit credentials.
- Each content model gets an Avo resource. Keep resources plain: fields,
  no custom Avo components unless asked.
- Every text field is the admin's text editor, never a plain box, and no
  field needs `<br>` typed. Its toolbar shows only Italic, White and Link,
  what the site shows (`copy`); bold, strikethrough and lists are hidden. Headings, info and tile text: each Enter is a
  new line (`lines` helper). Descriptions and credits: Enter is a new
  paragraph, Shift+Enter a new line. A cleared editor field is stored as
  nothing (`EditorText`).
- Prices are stored in pence (`price_pence`, as Stripe wants them) but
  edited in pounds: the admin's "Price (£)" field is `price_pounds`
  (`Priced`), taking 12, 12.50 or £12.
- Events, releases and products are addressed by slug in the admin too
  (`Slugged`, and `find_record_method` on their Avo resources).

## Audio

**Buckets (Cloudflare R2):**

- `margate-electronics-media` (public, at `media.margate-electronics.org`):
  images, live event recordings under `recordings/<event slug>/`, and
  release preview clips under `previews/<folder>/`, where the folder is the
  catalogue number, or the slug without one. Two of Tomas's own live
  recordings (Tactile Machines, Other Echoes) and the Systems EP and Tactile
  Machines previews are kept at the top level for tomasjef.com.
- `margate-electronics-masters` (private): full release files under
  `<folder>/`. Never linked from the site, never public.
- A one-off script (since removed) copied the audio from Backblaze's
  `archivalrecs` on 28 Sep: recordings to the public bucket, the full Systems
  EP and Tactile Machines tracks to the private one. Those two (TM002, TM001)
  are Tomas's own releases for tomasjef.com, not Margate Electronics, so they
  are kept on R2 but not on this site. Videos stay on Backblaze. Backblaze is
  only ever read. The public bucket's CORS rule (GET and HEAD from any
  origin) is set in the dashboard.

**Rules:**

- Tracks play from `audio_path` in the public bucket. Tomas never types it:
  he uploads the MP3 in the admin ("Audio file (upload)", the same box for
  both). An event recording is published in full (`PublishRecordingJob`:
  private bucket → `recordings/<event slug>/<file name>`, then its duration
  is read); a release track stays private and gets a preview (below). Every
  recording was re-uploaded this way by 30 Sep and the old top-level copies
  removed from R2; Backblaze keeps the originals.
- `MediaUrls.audio_url` builds every public audio URL: the media host plus the
  path, with each segment percent-encoded (spaces as `%20`). Existing file
  names contain spaces, `#`, `&`, brackets and apostrophes, and an unencoded
  `#` silently truncates the URL. Tested against those exact names.
- **Releases are never streamed in full.** A release Track stores
  `master_path` (private bucket) and `audio_path` (its preview clip).

**Preview generation (runs locally, in the admin):**

- In Avo, a release Track takes an uploaded full file ("Audio file
  (upload)", stored straight in the private bucket); its `master_path` is
  then shown, not typed.
- `GeneratePreviewJob` (Solid Queue; `bin/dev` runs the worker) then moves an
  upload to `<folder>/<file name>`, cuts a preview with ffmpeg
  (`preview_start` seconds in, default 60, 45 seconds long, 2-second fades in
  and out, 128kbps MP3), uploads it to `previews/<folder>/` in the public
  bucket, and saves both paths. A new file or start point makes a new clip.
  Clip names end in a fingerprint of the sound
  (`01-title-3f9a1c2e.mp3`): media is cached for 4 hours, so a remade clip
  needs a new address; the old one is deleted.
- On the release page only tracks with a clip are listed, under "Previews",
  each showing `0:45` at rest (`Track#shown_duration`; recordings their
  length), "0:12 / 0:45" once playing.
- Checked end to end on the real R2 on 28 Sep (upload, job, public clip,
  cleanup; clips were 90 seconds then, 45 since 29 Sep). `bin/rails runner` needs `.env` loaded
  (`set -a; . ./.env; set +a`); `bin/dev` loads it itself.
- `R2Storage` does the direct bucket work through `aws-sdk-s3`. The R2 key
  lives only in `.env` (`R2_*`, see `.env.example`), scoped to the two
  buckets, and never goes to GitHub.
- ffmpeg is a local dependency. `bin/setup` says if it's missing.

**Player:**

- One shared `<audio preload="none">` in the layout (`shared/_transport`,
  `transport` Stimulus controller, `data-turbo-permanent`), so playback
  carries on while browsing. No autoplay. Long sets stream via range requests.
- While something plays or is paused, a full-width strip shows at the very
  bottom of the window (`--color-bar-bg`), but not on the page whose own
  player is playing (no doubling). The footer and logo lift by its height
  (`--transport-height`). Desktop: `[ STOP ]` / `[ PLAY ]`, "title ·
  source" (a link back to its page), the progress rule (click to seek), the
  time, `[ CLOSE ]`. Phones, one line: `[ STOP ]`, title, elapsed time;
  paused, `[ PLAY ]`, title, `[ CLOSE ]`. A title too long for the phone
  line scrolls across while playing (still for reduced motion).
- `[ PLAY ALL ]` on the Index page (`play-all` controller) sends every
  recording to the transport as a queue (`{ action: "queue" }`), shuffled,
  played one after another. It's drawn as a page player for the whole set:
  the full width of the window; at rest "15 recordings, shuffled" and
  their total time; playing, it's the player of the recording that's on:
  `[ STOP ]`, its title, its own time ("14:48 / 29:36") and rule (click to
  jump along it; ← → on the button skip 10 seconds), `[ PREV ]` once
  there's one before (back to the start of the recording, or in its first
  3 seconds to the one before) and `[ NEXT ]`, which loads the next, while
  more are to come. A title too long for its line
  moves across while it plays (`lib/scroll_across`, as page players); on
  phones `[ PLAY ALL ]` / `[ STOP ]`, `[ PREV ]` and `[ NEXT ]` share the first line,
  the title and its time the second. Like any page player, the bottom bar stays
  hidden on its page (the Index) and shows once you leave it, with its
  own `[ NEXT ]` (wider screens). Its button says `[ PLAY ALL ]` only to
  start; then `[ STOP ]` / `[ PLAY ]` like any player. On the lock screen
  the set gets next and previous (in place of the 10-second skips):
  previous goes back to the start of the recording, or in its first 3
  seconds to the one before; the lock screen's progress resets with each
  recording. Playing a single track, or `[ CLOSE ]`, ends the queue.
  Preview clips are never queued.
- `[ STOP ]` pauses and the bar stays; `[ CLOSE ]` stops and removes it. The
  phone's lock screen can pause and play it, move along its progress bar
  and skip 10 seconds (Media Session; the position is sent on each change).
- Page players (`shared/_player`, `player` controller, the Ledger design:
  the only one; the rule draws bars) are remote controls: they send
  `transport:command` events and draw the `transport:state` it reports for
  their track.
- A recording saved without a duration gets it read from the file
  (`ReadDurationJob`, `DurationProbe`: ffprobe fetches only the header).
- The public bucket's CORS rules allow all origins (GET, HEAD). Anything
  reading audio data (waveforms, Web Audio) will not work over plain http
  locally.

## Newsletter

- Our own form on the `/newsletter/` page (every Newsletter link opens it;
  its address is the one to share; the pop-up dialog was removed 1 Oct),
  posting directly to
  MailerLite's form endpoint from the static page. The site stores nothing.
- Sign-ups join the Website group (it triggers the welcome email, a MailerLite
  automation) and Events Promo (the main list). No double opt-in.
- After launch the list moves to the site's own sending through Amazon SES,
  exported from MailerLite.

## Content and copy

- Real content comes from Tomas. Never invent event details, release copy,
  artist names, dates or prices. Use obvious placeholders and flag them.
- British English.
- House punctuation is applied as text is shown (`typography`, in `copy`,
  `words` and tab titles): curly apostrophes and quotes, and a spaced en
  dash for a spaced hyphen or an em dash. Whatever is typed in the admin.
- No em dashes anywhere in UI copy or content. Use commas, full stops or a
  restructured sentence.
- Japanese and Lithuanian characters appear in titles (Kodama こだま,
  (Ne)Žmogus). Never strip or transliterate them. Lithuanian renders in Plex,
  kana and kanji fall through to Noto Sans JP, which is 1em wide against Plex's
  0.6em, so mixed lines will not sit on the character grid. That is expected.
  Lines break only at spaces (`word-break: keep-all`), so a Japanese word
  is never split across lines.

## Accessibility

- Text must reach 4.5:1 against `#cccccc`. Exception, chosen by Tomas: a
  white text style (`.text-white`) is available on any text, a paragraph or
  a phrase. In the admin it's the text editor's "White" button, on any
  selected text in any field (the editor's underline, relabelled in
  `app/assets/stylesheets/avo-overrides.css`; `copy` turns `<u>` into
  `.text-white`).
  Second exception: stock notes (apparel sizes, tapes remaining) are pure
  red (`--color-alert`). The Sold Out chips use a deeper red that passes
  (4.63:1 on their tint). Third:
  the now-playing strip's darker grey (`--color-bar-bg`), blue on it about
  4:1. Bright
  colours only work as tag fills with blue text on top, never as text on the
  grey.
- Colour never carries meaning alone. Tags always have a text label.
- Everything reachable and operable by keyboard, with visible focus states.
- One `<h1>` per page: the page heading, or a visually hidden one from the
  page title where the design shows none (`shared/_page_heading`).
- Checked on 29 Sep with axe-core (every page, 1440 and 390, dialogs, menu,
  the bar) and keyboard walk-throughs, again in the 30 Sep review (tap
  targets too) and on 5 Oct (the Index, the new menu open and closed);
  only the chosen exceptions remain.
- The Index's tables carry explicit table roles: on phones their rows
  stack (`display: block`), and Safari's VoiceOver then stops reading
  them as tables without.
- Respect `prefers-reduced-motion`. One exception, chosen by Tomas: the
  logo still turns with scroll (it moves only as you scroll).

## Testing

- Model and request tests for anything with logic. System tests for the
  filter, the audio transport, the newsletter page and the admin's forms.
  Admin clicks go through `click_until`, which retries from script: headless
  Chrome sometimes stops passing mouse input to Avo's edit pages.
- A test that runs the static build and checks the forbidden-string rules.
- Browser tests also cover the lock-screen controls (Media Session), the
  player's keyboard, reduced motion, the lightbox's size limits, and the
  admin's photos (add, replace, delete, no sideways scroll). The test
  server's stand-in audio supports byte ranges, like R2, so seeking works.
- `bin/publish`'s wait for the deploy is tested with a stand-in `gh`
  (`test/bin/publish_test.rb`).
- No tests for static markup.
- Tests must pass before a commit is proposed.

## Deployment

- GitHub Actions builds and deploys to Cloudflare Pages on push to `main` and
  once a day on a schedule (`deploy.yml`, the only workflow). There is no
  test run on GitHub (removed by Tomas, 29 Sep): the tests run locally,
  `bin/ci` and `bin/rails test:system`, before every commit.
- Repository secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, and
  `BANDCAMP_CLIENT_ID`, `BANDCAMP_CLIENT_SECRET` (stock; a build without them
  keeps the stock last published).
- **Live at https://margate-electronics.org since Thu 1 Oct 2026** (Cloudflare
  Pages custom domains; www 301s to the apex by a Cloudflare redirect rule;
  `SITE_URL` in `deploy.yml` is the real address). Staging,
  `staging.margate-electronics.org`, serves the same build, noindex. The old
  GitHub Pages site (repo `tomasjef/margate-electronics`) is untouched; the
  way back is in `docs/cutover.md`.
- Locally, uploading from Avo needs the R2 settings in `.env` (`R2_*`, see
  `.env.example`). The Backblaze key left in the Rails credentials was only
  for the one-off copy; nothing uses it now. Neither is needed by the build.
- Phase 2 Worker secrets (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`) are set
  with `wrangler secret put` and never committed.

## Working agreements

- Start non-trivial work in plan mode. Propose the plan, wait for approval.
- One vertical slice per session. Commit at the end of each.
- Ask before adding any gem or npm package, and say what it replaces.
- Prefer deleting code to adding options. This is a small site with one editor.
- When something in this file turns out to be wrong or missing, say so and
  suggest the edit rather than working around it.
- Decisions that come up during a session go in `docs/decisions.md` so later
  sessions do not reopen them.

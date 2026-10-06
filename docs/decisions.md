# Decisions

Settled decisions, as a dated log. Add to this during a session so later
sessions do not reopen them. A later decision overrides an earlier one on the
same subject; `CLAUDE.md` describes the current state.

## 6 Oct 2026, logo

- **The logo no longer drifts while music plays** (Tomas, 6 Oct). Only
  scroll turns it, so it is upright at the very top and the very bottom of
  every page. The drift (3 Oct, below) left it at an angle once the music
  stopped. Overrides that decision.

## 3 Oct 2026, small effects

- **Tried seven effects, kept two** (Tomas, after trying each with a switch
  on a local branch). Kept: selected text in the category colour, and the
  logo drifting round (one turn a minute) while music plays, stopping where
  it is when it stops; not for reduced motion. Not wanted: photos moving
  into place between pages, blue duotone on archived events, a blinking
  cursor, links scrambling on hover, the audio bar title typing out. Also
  not wanted: waveforms on the players.
- **Add to Calendar** (Tomas, 3 Oct): a white button beside Book Tickets on
  upcoming events, sold out too (people with tickets want it). A calendar
  file built with the site, titled with the event's title, starting at the
  doors time and lasting four hours, as there's no end time in the admin.
- **The Archive's header and footer scroll away** (Tomas, 3 Oct): from 768
  up its header and footer stay at the top and end of the page rather than
  pinned, as its full-width rows would run under them; the logo stays
  pinned and turning. Other pages keep pinned corners.
- **Archive events as "Margate Electronics #13"** (Tomas, 3 Oct): no themes,
  under the heading "Event". The player bar keeps "M.E.#12".
- **The Archive is called Index** (Tomas, 5 Oct): it lists everything,
  upcoming and on sale too, which "Archive" suggests it doesn't (and the
  tiles already say "Archived 2025"). The footer and menu link, its chip
  and title say Index; the address stays `/archive/`, as Cloudflare Pages
  treats addresses with "index" in them as folder pages. Its releases'
  columns: Cat #, Artist, Title, Format, Date, Status.
- **The Index on one grid** (Tomas, 5 Oct): from 1240 both tables use the
  artist index's four columns (widths from the page body's width, in
  container units). Event lines up with Artist, Lineup and Title with
  column 2, Format with 3, the releases' Date with 4. Recordings and Status
  stay in a shared column at the right edge (tried lined up with column 4's
  date-wide slot; Tomas preferred the edge), only as wide as its longest
  entry ("Tape Sold Out", "12 recordings": 13 characters), so it sits as
  close to the edge as it can. Narrower screens keep their own widths.
- **Index columns never break mid-name** (Tomas, 5 Oct): releases' six
  columns stack into blocks below 1024 (they split titles and "Cassette +
  digital" at 768–900); events stay a table to 768 (only lineups wrap). An
  artist's links move whole to their own line rather than splitting.
- **Play All on phones: two lines** (Tomas, 5 Oct): [ PLAY ALL ] /
  [ STOP ] and [ NEXT ] on the first, what's on and its time on the second;
  a title too long for it moves across while playing, like page players'
  titles (at every width).
- **Two blank lines before the menu fades** (Tomas, 5 Oct): solid grey
  under the last link, then the 80 of fade.
- **The menu keeps its columns on tablets** (Tomas, 5 Oct): from 768, not
  only 1240, as they fit. One column on phones only.
- **Lightbox captions back under their photos** (Tomas, 6 Oct): stepping on
  before a photo had loaded left its dither's fixed size on the image, so
  later photos showed in the wrong box (captions far below, or off to the
  left); each photo now starts clear of any size before it.
- **No flash of the menu** (Tomas, 6 Oct): leaving a page through the menu
  left Turbo's copy of it with the menu open, shown for a moment on the
  way back; the menu now closes before Turbo keeps its copy.
- **Phone and footer tidy-up** (Tomas, 6 Oct): Newsletter Sign Up removed
  from the footer everywhere (the newsletter is in the menu); the phone
  lightbox says "Close", "← Prev", "Next →" like desktop (no brackets or
  capitals); Stockists on phones starts where About's text does; the menu's
  current-page dot sits in the line of text (it was placed by the link's
  tap area); on phones the newsletter page shows "Newsletter" above the
  field instead of the top line.
- **Section chips for categories only** (Tomas, 5 Oct): About, Stockists,
  the Index and Newsletter lose the white chip beside the name; their top
  line names them instead ("About" and so on, unless typed in the admin).
  The Newsletter page's title above the field, the same word, now starts
  empty. Events, releases, apparel and prints keep their coloured chip.
- **Top lines and headings on every page** (Tomas, 5 Oct): the pages
  without an automatic top line (About, Stockists, apparel and prints, the
  Index, the Newsletter page) can have one typed in the admin, and a
  heading; the Index and Newsletter get one-record admin pages for them.
  Events and releases keep their automatic top lines (29 Sep). The
  Newsletter page's title stays in its own body-size style.
- **About and Stockists headings** (Tomas, 5 Oct): an optional large
  heading on each, edited in the admin like an event's; About starts with
  "Margate Electronics" (the label's name, rather than repeating the
  "About" chip), Stockists empty.
- **Review, 5 Oct** (Tomas agreed all): the page behind the desktop menu
  is inert while it's open (Tab used to wander into it); the page you're
  on in the menu has a dot before it, not colour alone (white on grey was
  1.6:1); "Newsletter Sign Up" in every page's footer, bottom left, at the
  end of the page at every size (first a sentence at the end of the home
  feed, then pinned in the corner; the footer is no longer pinned on wide
  screens, only the logo); Noto Sans JP asked for at
  400 and 500 only (700 was never used) without holding up the page; the
  Index's tables carry table roles for VoiceOver when they stack. axe:
  only the chosen exceptions remain.
- **The types in the menu, no Home item** (Tomas, 5 Oct): the name (top
  left), the logo and Back already lead home, the web's convention, so no
  "Home" or "Feed" link. The menu's first group is Events · Releases ·
  Apparel · Prints, the home page's filter pages, each only when it has
  entries: phones have no filters, so this is their way to browse by type.
- **Menu columns equally spaced** (Tomas, 5 Oct): the name, Index · About ·
  Stockists, Newsletter · E-mail, ↑ Bandcamp · ↑ Instagram and Close
  spread across the window with equal gaps (rather than on the Index's
  grid, which left uneven space); names and links never wrap.
- **About's and Stockists' text where it was** (Tomas, 5 Oct): tried
  starting it on the top line, level with the name and Menu; back to
  About 80 down and Stockists centred in the window.
- **The phone menu in blue with white text** (Tomas, 5 Oct, phones only;
  wider screens keep grey with blue): the page you're on in the site's
  grey; the line under it is then blue on blue (spacing kept).
- **Play All has [ PREV ]** (Tomas, 5 Oct): beside [ NEXT ], doing what
  the lock screen's previous does; each shows only when there's somewhere
  to go ([ PREV ] not on the first recording, [ NEXT ] not on the last).
- **Play All: [ PLAY ALL ] only to start** (Tomas, 5 Oct): then [ STOP ] /
  [ PLAY ] like any player, as it plays one recording at a time. On the
  lock screen the set has next and previous (iPhones show them instead of
  the 10-second skips; previous was missing, so ⏮ did nothing): previous
  restarts the recording, or in its first 3 seconds goes to the one before.
  The lock screen's progress resets with each new recording.
- **The phone menu pushes the page down** (Tomas, 5 Oct): at the top of the
  page it takes the header's place in the page, as the first phone menu
  did; mid-page it rolls down where you are. No fade, no blur; the page's
  grey (the audio bar's darker grey tried and dropped); a 1px blue line
  along its bottom, 40 under the last link (as between its groups) and,
  at the top of the page, 40 above what follows. Below 1240 its link groups are
  40 apart, the section gap. Wider screens unchanged.
- **No blur behind the phone menu** (Tomas, 5 Oct): below 768 the block
  drops down and feathers away as on wider screens, the page behind left
  sharp (blurring costs older phones). Tried filling the whole screen:
  not needed.
- **The dither in the lightbox too** (Tomas, 5 Oct, rather than removing
  it): opening a photo not loaded yet shows its dither at the photo's size,
  caption and all, instead of an empty lightbox; Prev / Next still load the
  next photo before showing it.
- **One menu for every link, at every size** (Tomas, 5 Oct, after trying
  it on a branch; like wildwuchs.ch and centrephotogeneve.ch): the header
  is the name and "Menu" (top right, Cart to go beside it), the footer just
  the logo. Menu drops a block over the top of the window, grey with blue
  body text (tried blue with grey 24px headings, and with a hairline under
  it: plainer won), its bottom 80 feathered into the page, which is blurred
  behind; the links on the Index's four columns. Replaces the phone push-down menu and its two copies, the header
  links (Bandcamp, Instagram, Newsletter) and the footer row (Index, About,
  Stockists, E-mail). Menu, Close and the links are plain words, not
  bracketed.
- **Home tile captions stay blue on hover** (Tomas, 5 Oct): underlined
  only, not white (white from 3 Oct reverted for the home page).
- **E-mail beside the logo** (Tomas, 3 Oct): out of the bottom-left row,
  pinned just left of the logo from 1240 (at the right of the footer row
  below that). The shorter row no longer runs over the content at 1440.
- **Audio controls white on hover** (Tomas, 3 Oct): [ PLAY ], [ STOP ],
  [ PLAY ALL ], [ NEXT ], [ CLOSE ] on page players, Play All and the
  bottom bar; not underlined (a tap on a phone leaves them "hovered"). The
  bar's title links to its page: white and underlined.
- **All linked body text white and underlined on hover** (Tomas, 3 Oct):
  the home tiles' captions and the Archive's links too, not only underlined
  links in running text. Header, footer and menu links are navigation and
  keep their own hover.
- **[ PLAY ALL ] the full width of the window** (Tomas, 3 Oct), like the
  Archive's tables (two columns wide before that). While the set plays it's
  the player of the recording that's on (its own time and rule, click to
  jump), not of the whole set; [ NEXT ] loads the next.
- **Artist index links read "M.E.#3, M.E.#13, ME004"** (Tomas, 3 Oct).
- **No grey bands behind the pinned corners** (Tomas, 3 Oct): from 1240 to
  about 1600 the header links and the footer row are wider than the side
  margins, so content passes under them while scrolling. Bands behind them
  (tried as tall as the logo, then thin) were too heavy; the corners float
  over the content as before.
- **Archive redesign** (Tomas, 3 Oct): full window width, a hairline
  between rows, four ruled artist columns.
- **Archive page** (Tomas, 3 Oct): `/archive/`, events and releases only
  (not apparel or prints) as a ledger, then an artist index made from the
  About page's list, so there is one list of names to keep. Linked as
  "About · Stockists · Archive · E-mail" in the footer, and in the phone menu.
- **[ PLAY ALL ] shuffles** (Tomas, 3 Oct): the event recordings only (not
  release previews), in a new random order each press. The Play All
  player has its own [ NEXT ]; the bottom bar only shows once you leave the
  Archive, as for any page player (Tomas, 3 Oct; it first stayed on
  every page).
- **A feed for feed readers** (3 Oct): Atom at `/feed.xml`, every event,
  release and product newest first, with the tile's photo and text. Found
  through the link in each page's head; nothing visible on the site.
- **Keyboard shortcuts** (3 Oct): Space, ← and → (play/pause, Back, Next),
  a quiet extra with no key list on the site.
- **Dithered loading stand-ins** (3 Oct): 64 across, an 8×8 ordered
  dither with the contrast raised (at 48 across, or without the contrast,
  mid-tones all became one checkerboard), strictly two colours. Shown only
  while a photo loads and only with JavaScript, so a real photo is never
  drawn pixelated.
- **Ticket prices under the time** (Tomas, 3 Oct): "Tickets: …" is the
  last line of an upcoming event's italic details, after "Time: …"; the
  row under the poster keeps only Book Tickets (or Sold Out) and Add to
  Calendar.
- **Recordings 40 below the event text** at every width, the same as
  Previews on releases (Tomas, 3 Oct); was 20 on wider screens.

## 27 Sep 2026, static architecture

- **The site is static.** Rails runs only on Tomas's Mac; content is edited
  in Avo, stored in SQLite committed to the repo, exported by Parklife and
  deployed to Cloudflare Pages by GitHub Actions (on push and daily). No
  production Rails server, so no Hetzner, Coolify or Neon. Phase 2's cart
  server side is a Cloudflare Worker with D1 and Stripe Embedded Checkout.
  Decided by Tomas outside this repo; CLAUDE.md and the build plan were merged
  from his versions on 27 Sep.
- **The signed-off design stays.** Tomas's pasted CLAUDE.md carried the
  pre-sign-off design rules (greyscale images, a 4/8/16 spacing scale, Plex
  700); he chose the signed-off design instead.
- **Newsletter: our form posts straight to MailerLite** from the static page;
  the site stores nothing. This supersedes the same morning's decision to keep
  our own copy (`Subscriber`, `SyncSubscriberJob`), which a static site can't
  run; that code is removed in M0. The list is exported from MailerLite when
  sending moves to SES.
- **Cloudinary uploads go to one content folder**, not a development and a
  production folder: Rails only ever runs locally, in development.
- **Stock from Bandcamp is pulled by `bin/publish`** into the local database
  (once API access is approved), because the build has no secrets but the
  Cloudinary cloud name. Phase 2 must still decide between D1 and Bandcamp as
  the single stock count.

## 29 Sep 2026, M6: launch readiness

- **Icons from the ME logo** (`me-logo.svg`, already in the repo): SVG tab
  icon, favicon.ico (16, 32) and a 180px home-screen icon on the site grey.
  At 16px the "ME." reads, roughly; Tomas didn't need to supply anything.
- **404 page in the site's design**, built as `/404.html`; Cloudflare Pages
  serves it with status 404.
- **Search:** `sitemap.xml` lists every public page; `robots.txt` allows
  indexing only on margate-electronics.org; `_headers` keeps staging and
  pages.dev noindex even after the cutover.
- **Analytics:** Cloudflare Web Analytics, turned on by Tomas in the Pages
  project (no code, no cookie banner).
- **`bin/publish` waits for the deploy** and prints "Live: …" (Tomas looked
  once before a deploy had finished).
- **Accessibility pass:** axe-core on every page and state, keyboard and
  focus walk-throughs. Fixed: pages without a main heading (a hidden `<h1>`
  now). Kept, as Tomas chose: red stock notes (2.5:1), the bar's grey
  (about 4:1), white text.
- **Browser pass:** Chromium, WebKit, Firefox at 1440, 1024 and 390, and an
  Android size: no overflow, broken images or script errors. Fixed: phone
  headings ran words together at a line break ("GardenKodama"), a bug from
  the 28 Sep editor change; Chrome split "T-shirt" at its hyphen (hyphenated
  words now stay whole).
- **Tidy-up:** one player design (Ledger) and one progress style (bars); the
  others, kept from the design rounds, are removed.
- **Recording durations are read from the file** when left empty.
- **Cutover plan:** `docs/cutover.md`, for 7 Oct, with the way back.
- **Admin entries show everything, photos and audio first** (Tomas): on an
  event, release or product, Show and Edit both have Images, then Recordings
  / Audio (products: colours and sizes), then the details, the text and the
  home tile. Adding a photo or track from Edit leaves the form, so save
  text changes first.
- **Photos are numbered from 1** (Tomas); existing ones moved up by one.
- **Lightbox never enlarges past the original**, and gets a 3520px version
  for sharp screens when the original has the pixels.
- **Event text spacing** (Tomas): the venue, date and time sit a blank line
  below the lineup (changed from the same block, 29 Sep); the audio section sits a related gap
  (20) below the text, its chip a group gap (10) above the players.
- **Event tiles: heading and lineup only** (Tomas, 29 Sep), the next event's
  too; the date, venue and time are on the event's page.
- **Next → on inner pages** (Tomas, 29 Sep): the next entry in the home
  page's order (all entries, not the filter you came from), wrapping round.
  Right margin on wide screens, beside Back on phones.
- **No test run on GitHub** (Tomas, 29 Sep): its CI workflow kept failing
  on timing in the admin's browser tests while the site deployed fine. The
  tests run locally before every commit; GitHub only deploys.
- **Release text written from its fields** (Tomas, 29 Sep): heading, the
  first two info lines, the © line and the button words, so nothing is
  typed twice. A one-off task removed the typed copies (and fixed ME002's
  info, which said ME001).
- **Stockists on a page of their own** (Tomas, 1 Oct): `/stockists/`, the
  conventional place (labels list "Stockists" / "Where to buy" by city,
  linked from the footer), rather than a section on `/releases/`, which is
  the home feed filtered and shares its template. One list in the admin
  feeds the page, the release line and the About link. Bandcamp's tape
  counts are Bandcamp's own inventory and don't include shop copies.
- **Dates read "9 Oct 2026"** on the whole site (Tomas, 1 Oct): release
  out-on dates and event dates ("Fri 9 Oct 2026", "Archived – 24 Apr 2026"),
  unambiguous in the UK and the US; replaces DD.MM.YYYY (29 Sep). The
  admin's date fields keep DD.MM.YYYY.
- **Stock from Bandcamp** (Tomas, 1 Oct): read on every publish and every
  deploy, daily included (keys in `.env` and GitHub secrets). No SKUs typed:
  cassettes by album title, T-shirt colours by their Bandcamp item (⚪️🔵
  Natural, ⚫️⚪️ Black, linked once), sizes by name. Tapes gone: a red Tape
  Sold Out chip and "Buy Digital on Bandcamp", no tape price; the tile says
  Tape Sold Out. Release pages always say how many are left, "9 of 25
  tapes remaining" (Tomas), under the price in the stock-note style.
- **Sold Out chips are red** (Tomas, 1 Oct): text `--color-sold-out`
  (#cc0000) on `--color-sold-out-bg` (#ffdcdc), 4.63:1, on tiles and pages.
  Pure red can't reach 4.5:1 even on white, so the chip uses a deeper red;
  the stock notes keep pure red (Tomas's exception).
- **Newsletter is a page, not a pop-up** (Tomas, 1 Oct): every Newsletter
  link opens `/newsletter/`, with its own address; the dialog (chosen 27
  Sep) is removed. The page centres the sign-up as the dialog did, with
  "Newsletter" in body text, left-aligned, 20 above the field (Tomas, the
  related gap).
- **Light only** (Tomas, 1 Oct): the site looks the same in dark mode;
  `color-scheme: only light` (meta and CSS) keeps browsers that darken
  pages themselves from recolouring it.
- **About credit line** (Tomas, 1 Oct): an optional `credit` field, shown
  under the artists list (e.g. the website's design and build credit).
- **Newsletter page heading** (Tomas, 1 Oct): `/newsletter/`, the link to
  share for sign-ups, has the large page heading "Newsletter", 40 above the
  field; the desktop dialog has none.
- **About is 560 wide** from 768px up (Tomas, 30 Sep): `--column-text`, 5
  grid columns, about 66 characters a line (680 was too wide); artists in
  two columns (three tried). Phones unchanged.
- **About page in the admin** (Tomas, 30 Sep): its text and the artists
  list moved from the code (`About`) into one `AboutPage` record, starting
  with what the page said.
- **Thumbnails span the main photo** (Tomas, 29 Sep): a grid of 80-wide
  columns, as many as fit, the spare room shared out between them, so a
  full row meets both edges of the photo (4 across on an iPhone, 3 on an
  SE; 5 at 440, as before).
- **Previews 40 below the buying block** on release pages at every width
  (Tomas, 1 Oct), now that it has the tapes-remaining line; events keep 20
  above Recordings on wider screens.
- **Audio section on phones: a section gap (40) above** the Recordings or
  Previews chip, not the related gap (20) wider screens keep (Tomas, 29 Sep).
- **Review, part 2 (Tomas, 29 Sep):** heading breaks kept on phones; players
  show just the length at rest; the bar says "M.E.#12" like the posters;
  filtered pages show their filter on phones; house punctuation applied
  automatically; no line above the newsletter field (a
  "Newsletter Sign Up" line was tried and removed); "E-mail" throughout; pages without a photo preview with the
  next event's poster. Kept: the release page order, the ↑ (the font has
  no ↗).
- **Review fixes, 29 Sep:** tab titles escape "&" once (layout `safe_join`,
  `heading_text` decodes entities) and filter pages have their own title;
  on phones [ PLAY ] and the site name get finger-sized tap areas (41 and
  45px, nothing moves); About's wrapped artist names continue indented.
- **Underlines: body text links only** (Tomas, 29 Sep): nothing else is
  underlined at rest; navigation's hover underline needs a real pointer, so
  taps on phones leave none; the phone menu has none at all.
- **Clean-up** (Tomas, 29 Sep: "remove everything that isn't being used"):
  editors show only Italic, White and Link (the site shows nothing else;
  a typed list becomes lines); removed React (the cart branch adds it
  back), password reset (no email sending here), the phone debug log, the
  finished one-off scripts (event details move, Backblaze → R2 copy), the
  /prototype and /styleguide pages, and unused styles.
- **Fields removed** (Tomas, 29 Sep: "remove all not needed fields"): the
  event number (from the title now), the button words on events, releases
  and products (fixed, or from the link), and the sizes' unused SKU. A
  track's duration and master path are shown, not typed (both fill in
  after an upload).
- **Gallery photos keep their own shape** (Tomas, 29 Sep): the main photo
  takes the shape of the thumbnail chosen (its crop, or its proportions),
  no longer the first photo's; thumbnails are 80 wide, heights following.
- **Page players stay on one line** (Tomas, 29 Sep): a long title ends in …
  and moves across while playing, like the phone's bar, instead of the time
  wrapping onto a line of its own.
- **Lineup lines are added as needed** (Tomas): the event form shows only
  lines in use, each with a × to remove it, and "+ Live / + DJ / + Screening
  / + Workshop" buttons for the rest (`avo-overrides.js`).
- **Audio sections open with an orange audio chip** (Tomas's idea):
  "Recordings" on events, "Previews" on releases, in `tag--audio` like the
  category chips, instead of a plain "Recordings from the event:" line.
- **Event text written from fields** (Tomas, his sketch; it matches the
  usual event-page pattern): ticket prices beside Book Tickets at the top,
  the title and lineup (Live, DJ, Screening, Workshop), the venue, date
  (DD.MM.YYYY) and time in italic, then the free description. Archived
  events drop the tickets, date and time. Old descriptions had their
  labelled lines moved into the fields once (`events:move_details_out_of_descriptions`).
- **Home tile text written from fields too**, with a per-item switch to hide
  it (Tomas); the typed tile text fields were removed.
- **Audio before the scattered photos** (Tomas): events go poster, tickets,
  description, recordings, photos; releases go cover, info, price and Buy,
  previews, photos, description. The recording is what people come back
  for, and it keeps playing while the photos are browsed. Recordings
  without a file aren't listed.
- **Recordings upload like release tracks** (Tomas): the same upload box;
  a recording is published in full to `recordings/<event>/`, a release
  track gets its preview. No paths to type: the path fields are off the
  track form (shown read-only), release-only fields show only on release
  tracks. ME#1's recording, uploaded before this worked, was published.
- **Status lines are automatic** (Tomas): events "Upcoming – date" then
  "Archived – date"; releases their catalogue number, with "– Pre-order,
  out on date" until the release date. The admin fields were removed.
- **Dates are DD.MM.YYYY everywhere** (Tomas), the admin's date fields too.
- **Home order: dates, plus an optional pin** (Tomas). "Home position" on
  any event, release or product puts it first, in number order; everything
  else keeps the automatic date order. Fully manual numbering was offered
  and not chosen (it would need renumbering with every new item).

## 28 Sep 2026, labels, sold out and the cart's timing

- **Home tile labels** (Tomas): Book Tickets and Buy become **On Sale**;
  Pre-order stays. Sold-out things say **Sold Out** (title case, like the
  other labels); events past their date say Archived, sold out or not.
  The ticket and buy buttons on the pages keep their own labels.
- **Sold out on the pages**: a Sold Out tag (not a button) replaces Book
  Tickets, Buy or Buy on Bandcamp. On apparel it replaces the size and
  colour chips and stock notes too; the price stays. Events and products
  gained a `sold_out` switch (releases had one); apparel is also sold out
  when every size and colour is at 0.
- **M2 checked against the signed-off design** at 1440, 1240, 1024, 800
  and 390: it matched. One fix: on phones a tile whose photo hadn't loaded
  yet shrank to its caption, so its label jumped right when the photo
  arrived; tiles now take the full width (`align-items: stretch`). Filter
  pages need no extra build check: Parklife crawls them from the home
  page's links and fails on a broken one.
- **The admin's text editor everywhere, no `<br>`** (Tomas): headings,
  info, tile text, descriptions and credits. Where a field is lines (heading,
  info, tile text), Enter is a new line; older text with `<br>` still works.
- **White is a button in the editor, on any text** (Tomas); the credits'
  own colour setting was removed. Avo's editor has a fixed set of styles, so
  its underline button is relabelled "White" (CSS only) and the site shows
  `<u>` as white. Chosen over replacing Avo's editor code (extra npm
  packages, fragile across Avo updates).
- **Photos in the admin** (checked 28 Sep with browser tests): add from a
  record's Images panel, replace by choosing a new file and saving, delete
  with the bin icon. The delete button on an image's own file is hidden
  (removing the file alone is refused, silently); the current photo shows
  small on the edit form so the upload box stays in view.
- **Upload boxes acknowledge a chosen file** (Tomas): its name, a green
  outline and "Ready: press Save to upload" (`avo-overrides.js`), since
  the file only uploads on Save.
- **Track duration is for recordings only**; release tracks show 0:45.
- **Prices are edited in pounds** (Tomas), stored in pence: "Price (£)" in
  the admin takes 12, 12.50 or £12.
- **M5: release buttons follow the release date.** "Pre-order on
  Bandcamp" shows until the release date, "Buy on Bandcamp" from it, so ME004's button changes by itself at the
  9 Oct build (before, it would have said Pre-order for good).
- **Release audio is labelled "Previews"** and each player shows 0:45 at rest (0:00 / 0:45 until 29 Sep)
  (Tomas).
- **Previews are 45 seconds** (Tomas, 29 Sep: under a minute; they were 90). Tracks without a clip yet aren't listed (no dead [ PLAY ]).
- **Preview clip names carry a fingerprint of the sound**: Cloudflare and
  browsers cache media for 4 hours, so a remade clip at the same address
  would keep playing the old one.
- **The cart is built before launch, on its own branch** (Tomas, following
  the recommendation): the phase 1 features first, then from about 2 Oct
  the `cart` branch in Stripe test mode. Merged and switched on after 9 Oct,
  for ME004 shipping. Estimate: 5 to 6 sessions. Content arrives later;
  features are built and tested with the seed content meanwhile.

## 28 Sep 2026, M3 and M4

- **Tickets link out to each event's platform**; ME#13 stays on OutSavvy
  (Tomas). CLAUDE.md no longer says Ticket Tailor.
- **Link previews** on every page: title from the heading, description from
  the page's own first non-italic paragraph (~200 characters), image = the
  main photo cropped 1200x630 from the top (`gravity=top`: `auto` cut the
  ME#13 title), as JPEG. The canonical and preview URLs follow `SITE_URL`,
  so the cutover must change it.
- **Artist links** in the ME#13 and ME#12 descriptions stay `#` until Tomas
  edits them in the admin.
- **Audio keeps playing across pages** (Tomas agreed to try it): one shared
  `<audio>` kept by Turbo, and a now-playing bar. Built in Stimulus, not a
  React island, reusing the Ledger player. Not shown on the page whose own
  player is playing (no doubling).
- **The bar: option E, signed off by Tomas** (options A to D, under the
  column or in the corner, grey or reversed, were built and compared, then
  removed). A full-width strip at the very bottom of the window, darker grey
  (`--color-bar-bg` #b0b0b0, blue text about 4:1: Tomas's choice, below
  4.5:1), under the footer, which lifts by its height while it shows.
  Desktop, one line: [ STOP ] / [ PLAY ], "title · source" (a link back),
  the progress rule (click to seek), "0:03 / 33:28", [ CLOSE ].
- **[ STOP ] pauses and the bar stays** with [ PLAY ]; [ CLOSE ] stops and
  removes it. A separate close, rather than STOP removing the bar, so a
  pause doesn't lose your place.
- **Phones: one minimal line.** Playing: [ STOP ], the title, the elapsed
  time. Paused: [ PLAY ], the title, [ CLOSE ] in the time's place. No
  source, total or rule (the page's own player has them). A title too long
  for the line scrolls across on a loop (40px a second, 2 seconds at its
  start each time round), only while playing; paused, it ends in …. Chosen
  over wrapping onto a second line, so the bar keeps one height.
- **Reduced motion: the logo still turns, the scrolling title doesn't**
  (Tomas, following the recommendation). The logo only moves as you scroll
  and is part of the identity; the title moves by itself in a bar that's
  always on screen, the kind of motion that setting is for. This replaces
  "logo still for reduced motion" (25 Sep).

## 28 Sep 2026, M1: content in the database, media on Cloudflare R2

- **Media moved from Cloudinary and Backblaze to Cloudflare R2** (Tomas).
  Two buckets: `margate-electronics-media` (public, at
  `media.margate-electronics.org`) and `margate-electronics-masters` (private).
- **Not Rails' own image links.** Tomas's request asked for `url_for`,
  `rails_blob_path` and `variant`; those point at Rails, which the static site
  doesn't have (the build rejects `/rails/active_storage`). Pages link
  straight to R2 through `MediaUrls`, and Cloudflare Image Transformations
  resizes (Tomas chose this over sizes made on the Mac or originals only).
  The pasted `public_url:` setting isn't passed to the S3 library, which
  rejects unknown options; the address is `config.x.media_host`.
- **Backblaze is kept, read only, for good** (Tomas: "don't delete audio files
  from Backblaze"). Audio is copied to R2; videos stay on Backblaze only.
- **Full release files go in the private R2 bucket.** Systems EP and Tactile
  Machines were public in full on Backblaze; on R2 only their previews are.
- **R2 settings are named `R2_*`**, Tomas's names, in `.env` (`.env.example`).
- **Content models**: Event, Release, Track, Product with colours and
  sizes/stock, Image. Statuses come from dates at build time. Photos keep
  their own shape unless a crop is set; three seeds set one to match the
  signed-off layout (ME004's tile 4:3, ME003's cover 3:4, the T-shirt 4:5).
- **Seeds are the launch content and the test data.** Prototype placeholders
  (photos not exported, Figma's stand-in track titles, the Joanne Duo tile)
  aren't seeded. ME003's button reads "Buy on Bandcamp" (Figma said
  Pre-order, but it's out).
- **Admin**: Tiptap for descriptions and credits; tile captions and info
  lines stay HTML text areas, since they hold `<br>` inside one paragraph.
- **Browser tests serve photos and a silent recording from a test-only route**
  (`TestMediaController`), so they need no network; page tests still check
  the real R2 addresses.
- **Systems EP (TM002) and Tactile Machines (TM001) aren't Margate
  Electronics releases** (Tomas): they belong on tomasjef.com. Their full
  tracks and the preview clips made during setup stay on R2 for that site,
  but they aren't in this site's database. ME003's release date is 10 Aug
  2026 and the Waffle print is £20 (Tomas), which puts the home page back in
  the signed-off order.
- **M1 is on the `m1` branch** until the content is seeded with the R2 keys:
  merging to `main` deploys, and an empty content database would publish an
  empty site.

## 27 Sep 2026, audio by path

- **Audio is referenced by path, not through Active Storage** (Tomas's updated
  CLAUDE.md). Live recordings stay where they are at the top level of the
  public `archivalrecs` bucket (the current site reads them through
  `tracks.json`; don't move them before the cutover). Release previews are
  90-second clips made locally with ffmpeg into `archivalrecs/previews/`;
  full releases stay in the private `margate-electronics-releases`. One
  helper builds public URLs, percent-encoding each path segment.
- **The pasted design section was the pre-sign-off one again**; the
  signed-off design stays, as Tomas chose earlier the same day.
- **The newsletter works end to end**: from the deployed site, MailerLite
  answered success and the test address joined Events Promo and Website.
  MailerLite's API still reports the form as not "active"; that doesn't stop
  sign-ups.

## 27 Sep 2026, M0: the static pipeline

- **SQLite** (`sqlite3` replaces `pg`). Development and the build both use
  `storage/content.sqlite3`; the test and Solid Queue databases are not
  committed. The database was rebuilt from the migrations (the old Postgres
  one held no data, not even an admin user: run the seed command with
  `ADMIN_EMAIL` and `ADMIN_PASSWORD` before using the admin).
- **The admin's login row and sessions are committed with the content**
  (password only as a bcrypt hash, private repo). Login stays because
  `bin/lan` exposes the local server on the Wi-Fi.
- **Removed as server-only:** Solid Cache, Thruster, the Dockerfile and its CI
  job, the health check route, `allow_browser`, and the 400/406/422/500 pages
  (Cloudflare Pages serves `404.html` for missing pages).
- **Links end in `/`**, set in `ApplicationController#default_url_options`
  rather than on the routes, because parklife-rails replaces the routes'
  default URL options when it sets the site's address.
- **Parklife 0.9.0** always fails on a redirect; `on_404 = :error`.
- **The build copies from `public/assets` only the files pages reference**:
  the rest is the admin's (Avo's scripts even contain "localhost", which the
  build rejects). It removes precompiled assets afterwards, so development
  never serves stale copies.
- **`<meta charset="utf-8">` in the head**: without Rails sending the encoding,
  a static host may not, and こだま and ↑ came out garbled.
- **The static build test is a `bin/ci` step** ("Build: static site"), not a
  Minitest test: it needs the production build to mean anything.
- **Newsletter posts to MailerLite's existing "Sign up" embedded form**
  (account 1452160), via the `newsletter` Stimulus controller, which shows
  the result in place; without JavaScript the form posts to MailerLite
  directly. Tomas adds the Website group to that form and publishes it.
- **Backblaze keys live in the Rails credentials** (`backblaze.key_id`,
  `backblaze.application_key`), Tomas's choice, not `.env`. Previews go in the
  public `archivalrecs` bucket (served by URL, no signing), masters in the
  private `margate-electronics-releases`. The current key has full account
  access; a key limited to the two buckets' files is recommended.
- **Deploy:** `.github/workflows/deploy.yml` on push, daily at 05:00 UTC and by
  hand; it creates the Pages project `margate-electronics` on the first run.
  It doesn't wait for CI, but a failed static build deploys nothing.

## 27 Sep 2026, newsletter

- **Design signed off** (27 Sep). Missing images still to come.
- **Newsletter: MailerLite for now, no double opt-in.** A sign-up goes
  straight onto the list, and a custom welcome email goes out automatically
  (a MailerLite automation: "when a subscriber joins a group"). Later, the
  list moves to the site's own database with sending through Amazon SES;
  MailerLite is the stepping stone, not the long-term home.
- **The site keeps its own copy of every sign-up** (`Subscriber`), then sends
  it to MailerLite in the background. Reverses "Subscriber: to be removed".
  No sign-up is lost when MailerLite is down (retried with backoff, up to 10
  times); a refused address (invalid, bounced, junk) is recorded as a sync
  error, shown in `/admin`. Sign-ups join two groups: Website (triggers the
  welcome email, marks where they came from) and Events Promo (the main
  list). Signing up again re-sends with `resubscribe`, so someone who
  unsubscribed can come back. The reply is always "Thanks, you're on the
  list.", so the form never reveals who is subscribed.
- **Sending to MailerLite is live only in production**, and in development
  only with `NEWSLETTER_LIVE=1`; tests never touch the network.
- **Test assets are built once before the parallel test processes start.**
  (A small stub helper was added for the MailerLite tests, then removed with
  them the same day.)
- **Images: uploaded in Avo, stored on Cloudinary** through Active Storage
  (`cloudinary` gem, approved by Tomas). Development and production upload
  into separate folders (`margate-electronics/development`, `/production`);
  tests stay on disk. Pages ask Cloudinary for each image at the size that
  spot needs, in the best format for the browser, so originals go up as they
  are. Free plan: 10 MB per image. Each image will carry alt text, an
  optional caption, a position, and a colour for apparel (M1).

## 26 Sep 2026, design round 3

- **Dialog controls on phones are bracketed**: [ CLOSE ] (lightbox and
  newsletter), [ ← PREV ] and [ NEXT → ] in the lightbox, matching the menu;
  desktop keeps plain "Close", "← Prev", "Next →". On phones [ ← PREV ] sits
  bottom left and [ NEXT → ] bottom right, on the page margin. Bracketing the
  desktop header, footer, Back and dialog controls was tried and reverted.
- **Ledger rule measures the real character width** from the loaded font
  (not an assumed 0.6em), redraws when fonts load, and drops a character if
  it would overflow, so it can't run past the page margin on any device.
  Checked on Tomas's iPhone (393 wide, 26 Sep): the player sits 15 to 378,
  the same edges as the text. [ PLAY ] / [ STOP ] have no hover underline,
  like Menu / Close, since a tap left them looking underlined.
- **The first bar shows the moment sound starts** (the audio "playing"
  event, not the button press), so it's clear the stream works: [|.....].
  Pressing [ PLAY ] switches to [ STOP ] straight away; the bar stays empty
  while the file loads. After that, a bar for each cell reached.
- **Stylesheet loads with a `<link>` in the head** (its own Vite entrypoint,
  `entrypoints/application.css`), not imported from `application.ts`. In
  development Vite injected the imported CSS with JavaScript, so every reload
  showed the bare HTML for a moment, which looked like the mobile view.

- **The scrolled grey bar (below 1240) shows just "Margate Electronics"** on
  every page; the category chip scrolls away with the page. Wide screens
  keep name and chip pinned in the margin.

- **Audio tracks as far apart as the heading is from the first track**: 20
  of painted space, measured on screen (the gap is set to 20 − 0.33em to
  allow for the bracket tail and the space above [ PLAY ]). The category chip stays 10 below the name on phones (20
  was tried and reverted).

- **Brackets mean "press this", everywhere, spaced:** `[ PLAY ]`, `[ STOP ]`,
  `[ MENU ]`, `[ CLOSE ]` and the phone menu items. The space inside keeps
  the word's shape and reads as a text-interface button rather than a
  placeholder token. Never on things that can't be pressed (labels, status,
  chips). Keep bracketed labels to one short word so they fit small phones.

- **Words never split across lines**, on every screen: `word-break: keep-all`
  on `html`, so Japanese runs (こだま, こけのね) move to the next line whole
  instead of breaking between characters. Latin words were already never
  split. No `overflow-wrap` fallback, by choice: a single word wider than the
  whole line (e.g. a long raw URL) would overflow, so link words instead of
  showing raw URLs. Safari (so every iPhone browser) still broke just after
  an opening bracket when Japanese came before it ("こけのね (" / "ME004)"), a
  WebKit bug desktop Chrome doesn't have; `copy` and `words` wrap each word
  containing a bracket in `.nowrap`, which fixes it.

- **Body text 16px on phones** (14 on wider screens), the same as form
  fields, which must be at least 16px or iPhones zoom in when they're tapped.
  Chips, buttons, the player and the newsletter form all follow; small (12)
  and title (24) sizes are unchanged.

- **Phone page margin 15** (20 on wider screens; 10, 14 and 20 were tried). Set once
  (`--page-margin` below 768px); header, content, footer, menu, grey bar and
  the logo's corner all follow. The home description is capped at 28
  characters wide on phones, leaving clear space before Menu.
- **Tap targets at least 44px tall** for Menu, the menu links and Back:
  trimmed text is only about 10px tall, too small for a finger. Padding with
  matching negative margins, so nothing moves visually.
- **Development-only device reporter:** pages report to `log/client.log`
  (not in git) that the scripts started, the browser, screen width,
  Reduce Motion and any JavaScript errors, to debug real phones.

- **Phones (below 768px) get their own navigation:** "Menu" (top right, and in
  the grey bar when scrolled) opens a block that pushes the page down, not an
  overlay: About, E-mail, Newsletter, ↑ Bandcamp, ↑ Instagram, at the
  top left, level with Menu, with the name, category chip and everything else
  moved down below it, a section gap (40) under the menu (first tried
  right-aligned under Menu). Items as [ BRACKETED ] capitals (a space inside
  each bracket) at body size, 14
  apart (20 felt too wide), the same convention as the player's [ PLAY ]; [ MENU ] and [ CLOSE ]
  match, with no underline (a tap left [CLOSE] looking underlined). Heading-size capitals were tried and dropped as too loud next to
  the page heading. Each item's tap area is the full row. Scrolling down past
  the menu closes it, with the scroll adjusted so nothing on screen moves
  (closing at the first 40px of scroll made the page jump ~150px). Mid-page,
  [ MENU ] in the grey bar rolls the menu down right there, inside the bar,
  instead of jumping to the top: just the menu items (the name and chip are
  hidden) and 40 under the last item; scrolling down 40px closes it.
  [ MENU ] and [ CLOSE ] keep the same column width (the extra letter of
  CLOSE extends left), so the home description never re-wraps when the menu
  opens, and both stay top-aligned with the name (checked on painted pixels). No copyright line
  (Tomas will put it on the About page); the word turns to "Close" (Esc closes too). The header links,
  footer links and filter tabs are hidden on phones. Back is not fixed on
  phones: it sits at the end of the page, level with the centre of the logo.
  Wider screens are unchanged.

- **Phone preview:** Rails now proxies the Vite dev server (`skipProxy`
  removed), so pages load assets from their own address rather than
  `localhost:3036`, which a phone can't reach. `bin/lan` runs a second Rails
  server on port 3001, bound to the local network, alongside `bin/dev`. No
  live reload on the phone; refresh by hand.

- **Phase 2 is a full shop within the site for everything** (tapes, apparel,
  prints), confirmed by Tomas. Phase 1 stays catalogue only with Bandcamp
  links. Bandcamp keeps selling too, so phase 2 writes each site sale back to
  Bandcamp to keep a single stock count.

- **Footer: About · E-mail.** Bandcamp and Instagram moved to the header,
  before Newsletter ("↑ Bandcamp  ↑ Instagram  Newsletter"), stacked
  right-aligned on phones. ↑ marks external links; it is in Plex Mono's Latin
  subset, ↗ is not (it fell back to Noto Sans JP).
- **Known font gap:** ← and → (Back, Prev, Next) are not in the Plex Mono
  subsets we load, so they render in Noto Sans JP. Fixing it needs the full
  Plex Mono font files (a new package); not done yet.
- **About page** (`/about`): the home page line, then a draft from real
  sources only (old site's event history, the ME#12 Arts Council credit) and
  every artist from the M.E.#1 to #13 line-ups. Tomas will edit the text.
- **T-shirt Buy follows the colour**: Natural goes to Bandcamp
  `/merch/m-e-t-shirt`, Black to `/merch/m-e-t-shirt-2` (separate Bandcamp
  listings; size is chosen there). The details text switches too (Fabric:
  black, Print: white).
- **Stock notes: small italic text in red** (`--color-alert: #ff0000`, the
  pure-RGB counterpart of the blue ink). Pink chips were tried and were too
  prominent; pink text is nearly invisible on the grey (about 1.1:1). Red is
  about 2.5:1, an accepted exception like the white text.
- **Audio player: Ledger chosen** and used site-wide: "[ PLAY ] title  time"
  then a rule in characters, `[` solid blue where played, dots after `]`
  (was # characters). The pale bar, Line and Outline stay on the styleguide
  for reference. All designs draw their own controls; the audio element is
  never shown. Width: 440 on pages for now; a 680 (6 grid column) version is
  on the styleguide for comparison, where long titles fit on one line.
- **Ledger rule alignment, from measured Plex Mono metrics:** the solid bar is
  exactly bracket height (0.76em above the baseline to 0.14em below); the
  rule stretches its character spacing so "]" lands on the right edge, and
  reaches 0.18em further so the ink of "]" lines up with the ink of the time
  above. **Progress style: bars** (`[|||||.....]`, chosen by Tomas; "|" is
  exactly bracket height in Plex Mono). Solid, bullets and faded dots stay
  on the styleguide for reference.
- **ME003 links to its real Bandcamp page** (`/album/ne-mogus`). The orange
  "ME003" home tile is The Joanne Duo by YKLU & Danny
  (`/album/the-joanne-duo`); to confirm with Tomas.

## 26 Sep 2026, stock

- **Stock comes from Bandcamp, no Shopify.** Bandcamp's Merch Orders API
  (`get_merch_details`) gives stock per item and option; the site reads it
  on a schedule, matched by SKU. Phase 1 Buy buttons go to Bandcamp anyway.
  Bandcamp Pro's Shopify sync was considered and rejected (extra shop and
  subscription). Phase 2 (own checkout) will need to write sales back with
  `update_quantities`.

## 25 Sep 2026, design round 2

- **White text style on any text** (`.text-white` on a paragraph or
  `<span>`), not just credits. Credits keep a blue/white shortcut. Becomes a
  "White" style in the admin's text editor in M1.

- **Release credits are a separate block with a colour option**: blue
  (default) or white per release (an admin option in M1). ME004 and ME003
  are blue; white was tried and switched back. White on #cccccc is about
  1.6:1, below the 4.5:1 in CLAUDE.md, so it is an exception if used.

- **No visible heading in the newsletter dialog**: just the email field and
  Subscribe (the dialog is named "Newsletter sign up" for screen readers). Opening the dialog puts the cursor in the email field; opening
  the lightbox focuses the image (both avoid a focus box on "Margate
  Electronics").

- **Lightbox: clicking the image goes to the next one**, wrapping round (as
  Next does). With a single image, clicking it does nothing.

- **Breadcrumb section as a chip** in its category colour ("Margate
  Electronics  [Events]"), text on the header line; on phones the chip sits
  on its own line under the name. To review.

- **All chips and buttons are one size, 30 tall** (padding 10 top and
  bottom, 8 sides): tile labels, filter tabs, the ×, the breadcrumb chip,
  size and colour chips, Buy, Book Tickets, Subscribe. Tried 34 (12/9);
  Figma had 22 (6/3) for tags.

- **Two optional photo layouts on every page type**: a main photo with
  thumbnails, and/or scattered photos (`shared/_scatter`: masonry columns,
  seeded sideways shift on wide screens). Events have them after the text;
  releases, apparel and prints under the buy buttons. Both become optional
  admin fields in M1.
- **Print page added** (`/prints/waffle`) from the home tile's copy and photo;
  "Price to come" until a price is given. Prints have no sizes or colours.
- **Price and Buy side by side on every page**, as on releases ("£30  [Buy]").
  On apparel the size and colour chips and the stock notes come first, on
  their own lines, then price and Buy. (Buy aligned to the image's right
  edge was tried and dropped as too far from the price.)

- **A photo set per colour** on apparel pages: choosing a colour shows that
  colour's main photo and thumbnails; the lightbox only steps through the
  visible set. Black is placeholders until Tomas's photos are added.
- **Details text stays above the buttons** on release and apparel pages
  (moving price and Buy directly under the photos was tried and reverted).

- **Inventory per size and colour** (`Inventory`): stock is held per
  combination (XL Natural 1, XL Black 1, the rest 0 for now). The page works
  out sold-out sizes for the chosen colour, disables a colour with nothing
  left, and shows "N remaining in XL Natural" at 3 or fewer. Notes update as
  the choice changes (`variant` controller mirrors the server logic). Stock
  comes from the admin in M1; phase 2's checkout takes it off.

- **Audio section label is plain left-aligned text** ("Recordings from the
  event", "Audio"; no colon), no orange tag. Player time is ink blue (was white, which
  failed contrast). Orange now only means progress.

- **Event photos: horizontal scatter only (1240px and up).** They keep the
  two masonry columns and 40 gaps (the vertical layout of smaller screens);
  each photo moves to one of three grid positions in its half of the
  8-column width (left 260/380/500, right 740/860/980 at 1440), never the same
  as the photo above. Seeded by the event slug. A one-per-row ICA-style
  staircase was tried and dropped as too spread out vertically, and hand-set
  positions per photo were tried and reverted to this.
- **Grid: Figma is a 12-column grid** (80 columns, 40 gutters, 20 margins at
  1440). Text column = 4 columns (440), home = 8 (920). The audio section is
  the text width (440); a 6-column (680) version was tried and dropped.
- **Logo 50px** (was 60).
- **Thumbnails sit 10 below the main image**, the same as the gap between
  them (was 20).

- **Audio player styling.** The bar stays pale blue; orange fills in only with
  progress, and the whole bar turns orange once listened to the end. The
  title stays inside the bar (14px italic), a touch after the play symbol;
  long titles such as "Ben Sun w/ Sergio Serra & Gilli.jpg" wrap and the bar
  grows (checked on the styleguide). Time is 14px. Play and pause icons 14 by
  16 (were 17 by 20).
- **Lightbox Prev/Next centred**: vertical middle of the left and right edges
  on wide screens; together, centred at the bottom on phones.
- **Audio playing in the prototype.** The ME#12 hellocatfood recording streams
  straight from the public B2 bucket (`archivalrecs`, 80MB master, 33:28).
  Play/pause, progress fill (never narrower than the play button), elapsed and
  total time, click the bar to seek, arrow keys ±10s, one track at a time,
  `preload="none"`. Stimulus stand-in: M4 replaces it with the shared
  transport (React island, keeps playing across pages), 128kbps previews and
  signed URLs. Note: that bucket serves a master publicly today, which the
  audio rules in CLAUDE.md say should not happen at launch.

- **Lightbox Prev and Next.** "← Prev" bottom left and "Next →" bottom right
  (arrow keys too), stepping through every image on the page in page order,
  including gallery thumbnails, wrapping round. Hidden when a page has one
  image.
- **Orange "ME003" home tile is not ME003.** The photo is a YKLU & Danny tape
  ("The Joanne Duo", live at Cafe OTO). No longer used as an ME003 stand-in;
  open question for Tomas.

- **Sticky site name.** Home: "Margate Electronics" (the rest of the
  description hides once scrolled). Other pages: "Margate Electronics ·
  Events/Releases/Apparel". Transparent in the margin at 1240px and up,
  where it clears the content; a slim grey bar below 1240px so content passes
  under it. Newsletter stays with it (top right), opening the dialog.
- **Logo fixed bottom right at every size**, so it spins on phones too (it
  used to sit at the end of the page below 1240px).
- **Logo spin ends upright:** whole turns only (about one per 1440px of
  scroll, at least one), mapped to scroll progress.
- **Even page spacing:** 80 above and below the content on wide screens
  (home was 100 at the top), 40 on phones.

- **Home tile actions are labels.** Book Tickets, Pre-order, Buy sit on tiles
  as white descriptive labels like Archived, with no link or hover; the tile
  itself opens the page. Buttons with the blue hover stay on detail pages.
- **Filters: × instead of an "All" tab.** Choosing a filter shows a square ×
  beside it (22 by 22, blue on hover) that returns to everything.
- **Apparel options as chips, not dropdowns.** Native dropdown lists are
  drawn by the operating system (system font and colours) and can't be
  styled in Safari. Size and colour are radio buttons shown as chips: chosen
  = apparel pink, others plain (white on hover), sold out faded (struck-
  through "L" read as "Ł") plus a visible note under the options, "Sold
  out: L, M, S", in the caption style.
  Same 34px height as the buttons. Stock (XL; L, M, S sold out) and colours
  (Natural, Black) are placeholders. Phase 1: the choice is not sent
  anywhere; Buy links out.
- **Images in full colour**, with a category-colour stroke inside on hover (3px, was 2, originally 1).
  Replaces greyscale (and the blue monotone idea).
- **Spacing system of three gaps**: 10 within a group, 20 between related
  things, 40 between sections. Replaces the per-frame Figma values from round 1
  and resolves its inconsistencies. Home tiles are 40 apart (was 50).
- **Headings, optional per page**: one large heading holding the whole title
  on every page type (no small line above; that was tried and dropped). The
  header status line is optional as well. Both become optional admin fields
  (M1).
- **Hover rules**: category tags and filter tabs turn white; "All" (white by
  default) and buy, book and subscribe actions turn blue with white text; body
  links stay underlined.
- **Lightbox**: one native `<dialog>`, site grey, 80px padding (64/20 on
  phones). Close control is the word "Close" top-right, in both dialogs. The image's caption shows under it when there
  is one. Both dialogs keep "Margate Electronics" top left, linking home (no
  logo in the lightbox). Clicking outside closes the lightbox, but not the newsletter
  dialog (it closed too easily while typing): there, only Close or Esc. Thumbnails swap the main image, and the
  main image opens the lightbox.
- **Logo 60px**, one clockwise turn per 1440px of scroll, still for reduced
  motion.
- **Mobile**: status centred on its own row, 40 above and below; filter tabs
  in one spread row with counts hidden.
- **Newsletter: dialog chosen** (inline header version built, compared and
  removed). "Newsletter" in the header opens a dialog titled "Newsletter Sign
  up"; the field's underline sits on the bottom edge of the Subscribe button.
  Without JavaScript the link goes to `/newsletter`. Front end only:
  MailerLite is the next stage, and it replaces the Subscriber model.
- **Tests and a running bin/dev**: `config/vite.json` checks the test port
  (`devServerConnectionCheck`), because the dev server's `tmp/vite-ruby.json`
  otherwise makes tests think a test Vite server is running.

## 25 Sep 2026, design sign-off prototype

- **Sign off the design before the server stack.** All Figma pages are built
  front-end only from `app/prototype/catalogue.rb`; the views and CSS are the
  real templates.
- **Match Figma exactly**, including off-grid values. Supersedes the M0
  rounding (20px line height, 4px/20px tags): line height is 1.3, tags are
  3px/6px padding (22px tall), buttons 9px/12px (34px tall).
- **Text is trimmed to cap height and baseline** (`text-box`), so CSS spacing
  equals Figma spacing. Firefox lacks support and will be a few px off.
- **Plex Mono weights: 400, 400 italic, 500** (Heading/H1 is Medium). 700 is
  not used and was removed.
- **Home feed is masonry**: each tile goes to the shorter column
  (`Masonry.split`). On phones it is one column in feed order.
- **Footer, logo and filter key are fixed on wide screens (1240px and up)**,
  taken from the 822px home frame. The header scrolls away.
- **Images are greyscale until hover**, per CLAUDE.md, although Figma shows
  colour.
- **Figma MCP limit (Starter plan)** stopped exports for the release and
  apparel photos. They are dashed placeholders until exported.

## 25 Sep 2026, M1 (admin)

- **Avo over ActiveAdmin.** Avo ships precompiled assets that work with
  Propshaft and is built on Hotwire. ActiveAdmin 3 needs Sprockets, Sass and
  jQuery, and ActiveAdmin 4 needs a Tailwind build. Avo 4.2.7, Community
  edition (LGPL, no licence key).
- **Avo phones home in production.** The Community edition sends a report to
  avohq.io once every 24 hours in production: host, Ruby, Rails and Avo
  versions, and resource metadata (`Avo::Services::HqReporter`). There is no
  config switch. Accepted for now. Revisit if that is a problem.
- **Rails 8 authentication over Devise.** One user, no sign-up, no extra gem
  beyond bcrypt.
- **Password reset kept**, but its email only sends in production once
  Postmark is set up (M6).
- **Admin mounted at `/admin`**, not Avo's default `/avo`.
- **Time zone is London** (`config.time_zone`), and Avo is set to
  Europe/London and GBP. Avo's locale stays at the default, because it only
  ships an `en` translation.

## 25 Sep 2026, M0

- **New repo, fresh `rails new`.** The app lives in `margate-electronics-app`.
  The old static site (`tomasjef/margate-electronics`, GitHub Pages) stays live
  on margate-electronics.org as the temporary site until launch. An earlier
  July scaffold (`tomasjef/margate_electronics`) planned importmap, Render,
  DICE and Listmonk. It is superseded and should not be used.
- **Deploy is deferred.** No infrastructure exists yet, so M0 was built on
  GitHub and locally only. When deploying, use a staging subdomain first and
  move the apex domain on 7 Oct. This goes against the build plan's "deploy on
  day one", so it is a known risk.
- **Spacing scale gains 20 and 40**, to match Figma: 20 is the page edge margin
  and 40 the gap between the two 440 columns.
- **Body line height is 20px.** Figma sets Body/Normal to Plex's "normal" line
  height (100% auto), which renders at 18.2px. Rounded to the nearest multiple
  of 4. Small (12px) text uses 16px.
- **Tags use 4px horizontal padding and a 20px height.** Figma has 3px and 22px,
  which are off the scale.
- **Tokens not in Figma variables.** Figma only defines Body/Smaller,
  Body/Normal, tag/white, tag/releases, tag/prints and tag/apparel. Background,
  ink, the event tag colour, spacing and layout widths come from CLAUDE.md and
  frame measurements. Adding them as Figma variables would make Figma the single
  source.
- **Vite owns JS and CSS.** CSS lives in `app/assets/stylesheets` (so tokens stay
  where CLAUDE.md says) but is imported by the Vite entrypoint, not linked by
  Propshaft. Propshaft remains for images and gem assets.
- **Hotwire via npm.** `@hotwired/turbo-rails` and `@hotwired/stimulus` come from
  npm. The `turbo-rails` and `stimulus-rails` gems are kept for view helpers.
- **Node 24**, pinned in `.nvmrc`. Vite 8 needs Node 20.19 or newer.
- **Removed from the Rails defaults:** importmap, Kamal, jbuilder, Action Cable
  (and Solid Cable), Action Mailbox, Action Text.
- **Mobile breakpoint is 767px.** It is hardcoded in media queries, because
  custom properties cannot be used there. There is no 390 frame in Figma yet.
- **Chrome links (header, footer) are not underlined**, matching Figma, and
  underline on hover. Links in body copy are underlined.

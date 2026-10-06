> Public snapshot of the private working repository, taken from commit `a01ad83`.
> The content database ships without its admin user and sessions.

# Margate Electronics

Website for Margate Electronics, an experimental electronic music event series
and label based in Margate, UK: events with their recordings, releases with
preview clips, prints and apparel.

**Live at https://margate-electronics.org** (since 1 October 2026).

## How it works

- **A static site.** Rails runs only on Tomas's Mac. Content is edited in the
  admin (Avo, at http://localhost:3000/admin) and stored in SQLite
  (`storage/content.sqlite3`), committed to this repo.
- **Publishing:** `bin/publish` reads stock from Bandcamp, commits the content
  and pushes. GitHub Actions builds the site with Parklife and deploys it to
  Cloudflare Pages, about a minute later. It also rebuilds once a day, so
  date-based states (Next Event, Archived, pre-orders) and Bandcamp stock stay
  current.
- **Media** lives on Cloudflare R2 at `media.margate-electronics.org`: photos
  (resized by Cloudflare on the fly), event recordings, and 45-second preview
  clips of releases (made locally with ffmpeg; full release files stay
  private).
- **Buying** links out: tickets to each event's ticket platform, tapes and
  merch to Bandcamp. Stock counts come from Bandcamp. A cart of our own
  (Stripe) is phase 2.
- **Newsletter:** the `/newsletter/` page posts straight to MailerLite.

## Getting started

```
nvm use
bin/setup        # gems, npm packages, databases; then starts bin/dev
```

Then open http://localhost:3000 (the admin is at `/admin`). Uploading in the
admin and reading Bandcamp stock need keys in `.env`: copy `.env.example`.

Everyday commands:

```
bin/dev          # the local site and admin
bin/publish      # publish the content (and any committed code), wait until it's live
bin/ci           # all the checks; bin/rails test:system for the browser tests
```

## Docs

- `CLAUDE.md`: scope, stack, design system and conventions (the current state)
- `docs/decisions.md`: decisions as they were made, a dated log
- `docs/build-plan.md`: milestones and what's next
- `docs/cutover.md`: the switch to margate-electronics.org on 1 Oct, and the way back

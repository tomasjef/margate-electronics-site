# Launch cutover: margate-electronics.org to the new site

> **Done, Thursday 1 October 2026, about 10:00.** The new site is live at
> https://margate-electronics.org: served by Cloudflare Pages, www and http
> redirect to it, robots.txt allows indexing, every page, the audio and the
> newsletter form checked on desktop and iPhone. The way back below still
> applies while the old GitHub Pages site is kept.

**When:** Thursday 1 October, in the morning (brought forward from Wednesday
7 October by Tomas on 30 Sep: the site was ready). Never the 9th (event day,
no deploys).

The `SITE_URL` change is ready on the branch `cutover` (one commit): on the
day it's merged into `main` and pushed, never before, or a `bin/publish`
would send it ahead of the domain.

**What changes:** margate-electronics.org and www stop serving the old GitHub
Pages site (`tomasjef/margate-electronics`) and serve this one from Cloudflare
Pages (project `margate-electronics`). Nothing is deleted: the old site stays
built on GitHub Pages until the new one has run for a few days, which is what
makes going back instant.

## How it is today (checked 29 Sep)

- The domain's DNS is on Cloudflare (nameservers `stella` and `patryk`), and
  the apex is proxied through Cloudflare (orange cloud).
- Behind the proxy, the apex is GitHub Pages: repo `tomasjef/margate-electronics`,
  branch `main`, custom domain `margate-electronics.org`.
- `www.margate-electronics.org` answers with a 301 redirect to the apex.
- The new site is live at https://staging.margate-electronics.org and
  https://margate-electronics.pages.dev. Both send `X-Robots-Tag: noindex`
  (`public/_headers`), and `robots.txt` says `Disallow: /` until the switch.

## Before the day (by Tuesday 6 Oct)

1. **Tomas:** all launch content in the admin and published (`bin/publish`),
   checked on staging on a phone and a laptop.
2. **Tomas:** in the Cloudflare dashboard, open **margate-electronics.org →
   DNS → Records** and take a screenshot of the records for
   `margate-electronics.org` and `www`. This is the way back if needed.
   (Probably four `A` records for the apex, 185.199.108–111.153, and a
   `CNAME` for www to `tomasjef.github.io`.)
3. **Claude:** a last full check of staging: every page, the players and bar,
   the newsletter form, `bin/ci` and the browser tests.

## On the day

1. **Claude:** change `SITE_URL` in `.github/workflows/deploy.yml` from
   `https://staging.margate-electronics.org` to
   `https://margate-electronics.org`, and push. The build then writes the
   real address into link previews, the canonical links, `sitemap.xml`, and
   `robots.txt` (which now allows indexing). Staging keeps serving it, still
   marked noindex by `_headers`.
2. **Tomas:** Cloudflare dashboard → **Workers & Pages → margate-electronics →
   Custom domains → Set up a custom domain**, enter `margate-electronics.org`,
   continue. Cloudflare offers to replace the existing DNS records for it with
   one pointing at Pages: **confirm**. Then the same for
   `www.margate-electronics.org`.
3. Wait for both to show **Active** (Cloudflare issues the certificate; usually
   a few minutes).
4. **Tomas:** keep `www` redirecting to the apex. **Rules → Redirect Rules →
   Create rule**, name it "www to apex":
   - **When:** hostname equals `www.margate-electronics.org`;
   - **Then:** dynamic redirect to `concat("https://margate-electronics.org", http.request.uri.path)`,
     status 301, preserve the query string.
5. **Claude checks**, and reports each:
   - https://margate-electronics.org shows the new site (response headers
     from Cloudflare Pages, not GitHub), on a phone and a laptop;
   - every page in `sitemap.xml` answers 200, a made-up address shows the
     404 page, and `robots.txt` says `Allow` with the sitemap;
   - `www` redirects to the apex;
   - link previews (og:url, og:image) use the real address;
   - photos and audio load from media.margate-electronics.org, a recording
     plays and carries on in the bar;
   - a real newsletter sign-up from the live site reaches MailerLite.
6. **Tomas:** check a link preview of the home page and ME#13 in WhatsApp or
   iMessage.

## A few days later (after the launch night)

1. **Tomas:** GitHub → `tomasjef/margate-electronics` → **Settings → Pages**:
   remove the custom domain, then set the source to none (unpublish). The
   repository itself stays as it is. The old site's audio still lives on
   Backblaze, which is never deleted or changed.
2. **Optional:** add the site to Google Search Console and submit
   `https://margate-electronics.org/sitemap.xml`.

## Going back (if the new site misbehaves on the day)

1. **Tomas:** Workers & Pages → margate-electronics → Custom domains: remove
   `margate-electronics.org` and `www`.
2. **Tomas:** DNS → Records: recreate the records from the screenshot
   (proxied, as before). The old GitHub Pages site is still built, so it
   answers again within a minute or two.
3. **Claude:** revert the `SITE_URL` commit, so staging goes back to being
   noindex everywhere with `Disallow` in robots.txt.

## Analytics (any time before launch)

Cloudflare Web Analytics, which needs no cookie banner. **Workers & Pages →
margate-electronics → Metrics → Web Analytics → Enable.** Cloudflare adds its
small script to every page when it serves them; nothing changes in the
repository. Visits then appear under **Analytics & Logs → Web Analytics**.

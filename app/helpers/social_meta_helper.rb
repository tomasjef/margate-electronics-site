# What a page looks like when its link is shared (Open Graph tags, read by
# WhatsApp, iMessage, Instagram, Slack...) and in search results. A page sets
# its title, description and image with social_meta; shared/_social_meta
# writes the tags. Nothing new is written: the text comes from the page.
module SocialMetaHelper
  SITE_DESCRIPTION = "Margate Electronics is an experimental electronic music event series & label, based in Margate, UK."
  SUMMARY_LENGTH = 200

  def social_meta(title: nil, description: nil, image: nil)
    @social_meta = { title: title, description: description.presence, image: image }
  end

  def social_title = @social_meta&.dig(:title).presence || "Margate Electronics"

  def social_description = @social_meta&.dig(:description) || SITE_DESCRIPTION

  # image: an Image (a page's main photo). Pages without one (home, About,
  # Newsletter, 404) share the next event's poster, or the latest one's.
  def social_image = @social_meta&.dig(:image) || default_social_image

  def default_social_image
    (Event.published.select(&:upcoming?).min_by(&:date) || Event.published.order(date: :desc).first)&.main_image
  end

  # The first paragraph of a description that isn't all in italics (those are
  # the date and venue lines), as plain text, cut at a word near 200 characters.
  def summary_of(html)
    fragment = Nokogiri::HTML5.fragment(html.to_s)
    paragraph = fragment.css("p").find do |p|
      text = p.text.strip
      text.present? && p.css("em").sum { |em| em.text.strip.length } < text.length
    end
    text = (paragraph || fragment).text.squish
    text.present? ? truncate(text, length: SUMMARY_LENGTH, separator: " ", omission: "…") : nil
  end

  # This page's full address as the site it's built for serves it, ending in /
  # like every link (ApplicationController#default_url_options)
  def canonical_url = url_for(only_path: false)
end

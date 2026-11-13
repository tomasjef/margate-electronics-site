# Addressed by slug, on the site and in the admin (/releases/me003/,
# /admin/resources/releases/me003): to_param is the slug, and find_by_param!
# takes a slug, or the id for any link that still uses the number.
module Slugged
  extend ActiveSupport::Concern

  def to_param = slug

  class_methods do
    def find_by_param!(param) = find_by(slug: param) || find(param)
  end
end

# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/4.0/controllers.html
#
# There is one Newsletter page: "Newsletter page" in the sidebar, or making a new one,
# opens it for editing.
class Avo::NewsletterPagesController < Avo::ResourcesController
  def index
    NewsletterPage.exists? ? redirect_to(avo.edit_resources_newsletter_page_path(NewsletterPage.first)) : super
  end

  def new
    NewsletterPage.exists? ? redirect_to(avo.edit_resources_newsletter_page_path(NewsletterPage.first)) : super
  end
end

# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/4.0/controllers.html
#
# There is one About page: "About" in the sidebar, or making a new one, opens
# it for editing.
class Avo::AboutPagesController < Avo::ResourcesController
  def index
    AboutPage.exists? ? redirect_to(avo.edit_resources_about_page_path(AboutPage.first)) : super
  end

  def new
    AboutPage.exists? ? redirect_to(avo.edit_resources_about_page_path(AboutPage.first)) : super
  end
end

# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/4.0/controllers.html
#
# There is one Index page: "Index page" in the sidebar, or making a new one,
# opens it for editing.
class Avo::IndexPagesController < Avo::ResourcesController
  def index
    IndexPage.exists? ? redirect_to(avo.edit_resources_index_page_path(IndexPage.first)) : super
  end

  def new
    IndexPage.exists? ? redirect_to(avo.edit_resources_index_page_path(IndexPage.first)) : super
  end
end

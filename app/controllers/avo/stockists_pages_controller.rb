# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/4.0/controllers.html
#
# There is one Stockists page: "Stockists page" in the sidebar, or making a
# new one, opens it for editing.
class Avo::StockistsPagesController < Avo::ResourcesController
  def index
    StockistsPage.exists? ? redirect_to(avo.edit_resources_stockists_page_path(StockistsPage.first)) : super
  end

  def new
    StockistsPage.exists? ? redirect_to(avo.edit_resources_stockists_page_path(StockistsPage.first)) : super
  end
end

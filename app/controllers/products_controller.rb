class ProductsController < ApplicationController
  allow_unauthenticated_access

  def show
    @product = Product.published.includes(images: { file_attachment: :blob }).find_by!(slug: params[:slug])
  end
end

class ReleasesController < ApplicationController
  allow_unauthenticated_access

  def show
    @release = Release.published.includes(images: { file_attachment: :blob }).find_by!(slug: params[:slug])
  end
end

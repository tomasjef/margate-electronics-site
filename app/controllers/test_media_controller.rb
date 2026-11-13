# Test environment only (see config/routes.rb): stands in for R2's public
# address in browser tests, so pages show real photos without the network.
# Images: the blob by its key, after Cloudflare's /cdn-cgi/image/<options>/
# prefix. Audio: a short silent recording for any path.
class TestMediaController < ApplicationController
  allow_unauthenticated_access

  SILENCE = Rails.root.join("test/fixtures/files/silence.wav")

  def show
    key = params[:path].sub(%r{\Acdn-cgi/image/[^/]+/}, "")
    if (blob = ActiveStorage::Blob.find_by(key: key))
      send_data blob.download, type: blob.content_type, disposition: "inline"
    elsif key.end_with?(".mp3")
      send_audio SILENCE
    else
      head :not_found
    end
  end

  private

  # With byte ranges, like R2: browsers only seek in audio when the server
  # can send part of the file
  def send_audio(path)
    data = File.binread(path)
    response.headers["Accept-Ranges"] = "bytes"
    range = request.headers["Range"].to_s[/\Abytes=(\d+)-(\d*)\z/] && [ $1.to_i, ($2.presence || data.bytesize - 1).to_i ]
    if range
      first, last = range[0], [ range[1], data.bytesize - 1 ].min
      response.headers["Content-Range"] = "bytes #{first}-#{last}/#{data.bytesize}"
      send_data data.byteslice(first..last), type: "audio/wav", disposition: "inline", status: :partial_content
    else
      send_data data, type: "audio/wav", disposition: "inline"
    end
  end
end

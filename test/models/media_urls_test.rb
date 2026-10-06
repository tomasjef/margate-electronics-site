require "test_helper"

class MediaUrlsTest < ActiveSupport::TestCase
  HOST = "https://media.margate-electronics.org"

  # The awkward names really in the archive, as the old site's tracks.json has them
  {
    "ME#10_M2C_master_for_stream.mp3" => "ME%2310_M2C_master_for_stream.mp3",
    "A'Bear_ME6_nonmaster.mp3" => "A%27Bear_ME6_nonmaster.mp3",
    "ME5 Y&DanScott [MASTER].mp3" => "ME5%20Y%26DanScott%20%5BMASTER%5D.mp3",
    "Tomas_Jef_with Ian Powell_Live_Other_Echoes_2023.mp3" => "Tomas_Jef_with%20Ian%20Powell_Live_Other_Echoes_2023.mp3",
    "Systems EP/01 Tomas Jefanovas - Detroit in Margate.mp3" => "Systems%20EP/01%20Tomas%20Jefanovas%20-%20Detroit%20in%20Margate.mp3",
    "previews/ME004/01-こけのね.mp3" => "previews/ME004/01-%E3%81%93%E3%81%91%E3%81%AE%E3%81%AD.mp3"
  }.each do |path, encoded|
    test "audio_url encodes #{path}" do
      assert_equal "#{HOST}/#{encoded}", MediaUrls.audio_url(path)
    end
  end

  test "a # in a name never cuts the link short" do
    assert_equal "/ME%2310_M2C_master_for_stream.mp3", URI(MediaUrls.audio_url("ME#10_M2C_master_for_stream.mp3")).path
  end

  test "images go through Cloudflare's resizing at a set of standard widths" do
    blob = ActiveStorage::Blob.new(key: "abc123def")
    assert_equal "#{HOST}/cdn-cgi/image/width=440,quality=auto,format=auto/abc123def", MediaUrls.image_url(blob, width: 440)
    assert_equal "#{HOST}/cdn-cgi/image/width=880,quality=auto,format=auto/abc123def", MediaUrls.image_url(blob, width: 500)
    assert_equal "#{HOST}/cdn-cgi/image/width=3520,quality=auto,format=auto/abc123def", MediaUrls.image_url(blob, width: 5000)
  end

  test "the R2 settings can be read before any upload has loaded Active Storage" do
    assert_equal "margate-electronics-media", R2Storage.configurations.dig("cloudflare_r2", "bucket")
  end

  test "srcset offers 1x and 2x" do
    blob = ActiveStorage::Blob.new(key: "abc")
    assert_equal "#{HOST}/cdn-cgi/image/width=440,quality=auto,format=auto/abc 1x, " \
                 "#{HOST}/cdn-cgi/image/width=880,quality=auto,format=auto/abc 2x",
                 MediaUrls.image_srcset(blob, width: 440)
  end
end

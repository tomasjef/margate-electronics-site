require "test_helper"

# A photo's dithered stand-in while it loads (Dither): two colours, the
# site's blue and grey, made after an upload and again when it's replaced
class MakeDitherJobTest < ActiveJob::TestCase
  PHOTO = Rails.root.join("app/assets/images/prototype/me003-tile-orange.jpg")

  def png_of(data_uri) = MiniMagick::Image.read(Base64.decode64(data_uri.delete_prefix("data:image/png;base64,")))

  def new_image
    event = Event.find_by!(slug: "me-12")
    event.images.create!(alt: "Orange tape", placement: "scatter",
      file: { io: File.open(PHOTO), filename: "orange.jpg", content_type: "image/jpeg" })
  end

  test "a dither is a small two-colour PNG in the site's blue and grey" do
    uri = Dither.from(PHOTO)
    assert uri.start_with?("data:image/png;base64,")
    assert_operator uri.bytesize, :<, 1500
    png = png_of(uri)
    assert_equal Dither::WIDTH, png.width
    colours = png.get_pixels.flatten(1).uniq.sort
    assert_equal [ [ 0, 0, 255 ], [ 204, 204, 204 ] ], colours
  end

  test "an upload is dithered after saving, without marking its entry edited" do
    image = nil
    assert_enqueued_with(job: MakeDitherJob) { image = new_image }
    edited = image.imageable.reload.updated_at
    travel 1.minute do
      perform_enqueued_jobs(only: MakeDitherJob)
    end
    assert image.reload.dither.start_with?("data:image/png;base64,")
    assert_equal edited, image.imageable.reload.updated_at
  end

  test "replacing the file makes a new dither; other edits keep it" do
    image = new_image
    perform_enqueued_jobs(only: MakeDitherJob)
    assert_no_enqueued_jobs(only: MakeDitherJob) { image.reload.update!(alt: "Tape") }
    assert image.reload.dither.present?
    image.update!(file: { io: File.open(PHOTO), filename: "again.jpg", content_type: "image/jpeg" })
    assert_nil image.reload.dither
    assert_enqueued_jobs 1, only: MakeDitherJob
  end
end

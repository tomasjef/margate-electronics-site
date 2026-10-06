# Makes a photo's dithered stand-in (Dither) after it's uploaded or
# replaced in the admin. Runs locally, from the admin's queue.
class MakeDitherJob < ApplicationJob
  queue_as :default

  def perform(image)
    return unless image.file.attached?
    dither = image.file.blob.open { |file| Dither.from(file.path) }
    # update_column: no callbacks or touch, so the event or release it
    # belongs to isn't marked as edited
    image.update_column(:dither, dither)
  end
end

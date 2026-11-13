require "tmpdir"

# An event recording uploaded in the admin (the "Full file (upload)" box):
# recordings stream in full, so the file moves from the private bucket, where
# every upload lands, to recordings/<event slug>/<file name> in the public
# one, and becomes the track's audio_path. Then its length is read.
#
# storage is replaceable, so tests run without R2.
class PublishRecordingJob < ApplicationJob
  queue_as :default

  class_attribute :storage_factory, default: -> { R2Storage.new }

  def perform(track)
    raise ArgumentError, "Only event recordings are published in full" if track.release?
    return unless track.master_upload.attached?

    storage = storage_factory.call
    blob = track.master_upload.blob
    key = "recordings/#{track.trackable.slug}/#{blob.filename}"

    Dir.mktmpdir do |dir|
      file = File.join(dir, "recording#{File.extname(blob.filename.to_s)}")
      storage.download(:masters, blob.key, to: file)
      storage.upload(:media, key, from: file, content_type: blob.content_type.presence || "audio/mpeg")
    end
    # A replaced upload's old file goes; files copied from Backblaze (outside
    # recordings/) are never touched
    old = track.audio_path
    storage.delete(:media, old) if old.present? && old != key && old.start_with?("recordings/")

    # update_columns: no callbacks, so this doesn't start another job
    track.update_columns(audio_path: key, duration: nil, updated_at: Time.current)
    track.master_upload.purge
    ReadDurationJob.perform_later(track)
  end
end

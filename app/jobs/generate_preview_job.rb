require "tmpdir"

# Makes a release track's preview clip (runs locally, from the admin):
#
# 1. A full file uploaded in the admin (master_upload, already in the private
#    bucket) is moved to <folder>/<file name> there and becomes master_path.
# 2. The full file is read back, ffmpeg cuts the 45-second preview, and the
#    clip goes to previews/<folder>/ in the public bucket as audio_path.
#
# storage and cutter are replaceable, so tests run without R2 or ffmpeg.
class GeneratePreviewJob < ApplicationJob
  queue_as :default

  class_attribute :storage_factory, default: -> { R2Storage.new }
  class_attribute :cutter, default: PreviewClip

  def perform(track)
    raise ArgumentError, "Only release tracks get previews" unless track.trackable.is_a?(Release)

    storage = storage_factory.call
    master_path = take_upload(track, storage) || track.master_path
    raise ArgumentError, "Track #{track.id} has no full file" if master_path.blank?

    Dir.mktmpdir do |dir|
      full = File.join(dir, "full#{File.extname(master_path)}")
      clip = File.join(dir, "preview.mp3")
      storage.download(:masters, master_path, to: full)
      cutter.cut(full, clip, start: track.preview_start)

      key = PreviewClip.key_for(track, fingerprint: PreviewClip.fingerprint(clip))
      storage.upload(:media, key, from: clip, content_type: "audio/mpeg")
      storage.delete(:media, track.audio_path) if track.audio_path.present? && track.audio_path != key && track.audio_path.start_with?("previews/")
      # update_columns: no callbacks, so saving the result doesn't start another job
      track.update_columns(master_path: master_path, audio_path: key, updated_at: Time.current)
    end
  end

  private

  # Moves an uploaded full file to its place in the private bucket
  def take_upload(track, storage)
    return unless track.master_upload.attached?
    blob = track.master_upload.blob
    path = "#{track.trackable.folder}/#{blob.filename}"
    storage.copy(:masters, blob.key, path)
    track.master_upload.purge
    path
  end
end

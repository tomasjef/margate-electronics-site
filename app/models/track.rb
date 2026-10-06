# One piece of audio: a release track (streamed only as its preview clip) or
# a recording from an event (streamed in full). Files are referenced by their
# path in the public media bucket; a release's full file sits in the private
# masters bucket at master_path.
class Track < ApplicationRecord
  PREVIEW_LENGTH = 45 # seconds: under a minute (Tomas, 29 Sep)

  belongs_to :trackable, polymorphic: true, touch: true

  # A file uploaded in the admin, straight into the private bucket. A
  # release's full file stays private (GeneratePreviewJob files it and cuts
  # the preview); an event recording is published in full (PublishRecordingJob).
  has_one_attached :master_upload, service: :cloudflare_r2_masters

  validates :title, presence: true
  validates :preview_start, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # A new full file, or a new start point, makes a new preview
  after_save_commit :generate_preview, if: :preview_needed?
  # An uploaded recording is made public for streaming
  after_save_commit :publish_recording, if: -> { !release? && master_upload.attached? }
  # A recording saved without its duration gets it read from the file
  after_save_commit :read_duration, if: :duration_needed?

  def url = audio_path.presence && MediaUrls.audio_url(audio_path)

  def release? = trackable_type == "Release"

  # The duration typed or read from the file ("33:28", "1:08:00") in
  # seconds; 0 when there is none
  def seconds = duration.to_s.split(":").map(&:to_i).reduce(0) { |total, part| total * 60 + part }

  # The length the player shows before it plays: a release track only ever
  # plays its preview (0:45); a recording shows its length from the admin
  def shown_duration
    return duration unless release?
    minutes, seconds = PREVIEW_LENGTH.divmod(60)
    format("%d:%02d", minutes, seconds)
  end

  # Where it's from, for the player bar: "M.E.#12" for an event (the number
  # from its title, "Margate Electronics #12: …"; written as on the posters),
  # "ME004" for a release
  def source_label
    case trackable
    when Event then trackable.short_number || trackable.title
    when Release then trackable.catalogue_number.presence || trackable.title
    end
  end

  private

  def preview_needed?
    return false unless release?
    master_upload.attached? || (master_path.present? && (saved_change_to_master_path? || saved_change_to_preview_start?))
  end

  def generate_preview = GeneratePreviewJob.perform_later(self)

  def publish_recording = PublishRecordingJob.perform_later(self)

  def duration_needed? = !release? && duration.blank? && audio_path.present?

  def read_duration = ReadDurationJob.perform_later(self)
end

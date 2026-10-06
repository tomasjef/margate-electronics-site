# Fills in a recording's duration (shown before it plays) from the file
# itself, when the admin left it empty. Runs locally, from the admin.
class ReadDurationJob < ApplicationJob
  queue_as :default

  # Replaceable, so tests run without ffprobe or the network
  class_attribute :prober, default: DurationProbe

  def perform(track)
    return if track.release? || track.duration.present? || track.url.blank?
    seconds = prober.seconds(track.url)
    # update_columns: no callbacks, so saving the result doesn't start another job
    track.update_columns(duration: DurationProbe.clock(seconds), updated_at: Time.current) if seconds&.positive?
  end
end

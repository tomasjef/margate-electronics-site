# A release track's public preview: 45 seconds from preview_start, with
# 2-second fades in and out, as a 128kbps MP3. Cut locally with ffmpeg (a Mac
# dependency; bin/setup checks for it). Releases are never streamed in full.
module PreviewClip
  LENGTH = Track::PREVIEW_LENGTH
  FADE = 2

  module_function

  def ffmpeg_arguments(input, output, start:)
    [
      "-hide_banner", "-loglevel", "error", "-y",
      "-ss", start.to_s, "-t", LENGTH.to_s, "-i", input.to_s,   # seek first, so the clip's clock starts at 0
      "-af", "afade=t=in:st=0:d=#{FADE},afade=t=out:st=#{LENGTH - FADE}:d=#{FADE}",
      "-ac", "2", "-ar", "44100", "-codec:a", "libmp3lame", "-b:a", "128k",
      "-map_metadata", "-1", output.to_s
    ]
  end

  def cut(input, output, start:)
    system("ffmpeg", *ffmpeg_arguments(input, output, start: start), exception: true)
  end

  # previews/ME004/01-koke-no-ne-3f9a1c2e.mp3; titles in other scripts fall
  # back to the track's id. The fingerprint changes when the clip's sound
  # does, so a remade preview gets a new address: Cloudflare and browsers
  # cache media for 4 hours and would otherwise keep playing the old one.
  def key_for(track, fingerprint:)
    name = track.title.parameterize.presence || "track-#{track.id}"
    "previews/#{track.trackable.folder}/#{format("%02d", track.position)}-#{name}-#{fingerprint}.mp3"
  end

  def fingerprint(path) = Digest::SHA256.file(path).hexdigest.first(8)
end

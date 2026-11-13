require "open3"

# How long a recording is, read with ffprobe from its public address: only
# the file's header is fetched, so even an hour-long set takes about a second.
# A local dependency, like ffmpeg for the previews.
module DurationProbe
  module_function

  # Seconds, or nil if it can't be read
  def seconds(url)
    out, status = Open3.capture2("ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", url)
    status.success? ? Float(out.strip, exception: false) : nil
  rescue Errno::ENOENT
    nil # ffprobe isn't installed
  end

  # 2008.0 => "33:28"; an hour or more => "1:02:15"
  def clock(seconds)
    s = seconds.floor
    h, rest = s.divmod(3600)
    m, sec = rest.divmod(60)
    h.positive? ? format("%d:%02d:%02d", h, m, sec) : format("%d:%02d", m, sec)
  end
end

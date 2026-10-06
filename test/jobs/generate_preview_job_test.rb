require "test_helper"

class GeneratePreviewJobTest < ActiveJob::TestCase
  # Records what the job asks R2 to do
  class FakeStorage
    attr_reader :calls

    def initialize = @calls = []

    def download(bucket, key, to:)
      @calls << [ :download, bucket, key ]
      File.write(to, "full file")
    end

    def upload(bucket, key, from:, content_type:)
      @calls << [ :upload, bucket, key, content_type, File.read(from) ]
    end

    def copy(bucket, from_key, to_key) = @calls << [ :copy, bucket, from_key, to_key ]
    def delete(bucket, key) = @calls << [ :delete, bucket, key ]
  end

  # Stands in for ffmpeg: writes a "clip" and remembers the start point
  class FakeCutter
    attr_reader :starts

    def initialize = @starts = []

    def cut(_input, output, start:)
      @starts << start
      File.write(output, "clip")
    end
  end

  # The fake clip's fingerprint, in its file name
  CLIP = Digest::SHA256.hexdigest("clip").first(8)

  setup do
    @storage = FakeStorage.new
    @cutter = FakeCutter.new
    storage = @storage
    GeneratePreviewJob.storage_factory = -> { storage }
    GeneratePreviewJob.cutter = @cutter
    @release = Release.find_by!(slug: "me004")
  end

  teardown do
    GeneratePreviewJob.storage_factory = -> { R2Storage.new }
    GeneratePreviewJob.cutter = PreviewClip
  end

  test "a full file already in the private bucket becomes a 45-second clip in the public one" do
    track = @release.tracks.create!(title: "Kokedera", position: 2, master_path: "ME004/02 Kokedera.wav", preview_start: 75)
    GeneratePreviewJob.perform_now(track)

    assert_equal [ :download, :masters, "ME004/02 Kokedera.wav" ], @storage.calls.first
    assert_equal [ :upload, :media, "previews/ME004/02-kokedera-#{CLIP}.mp3", "audio/mpeg", "clip" ], @storage.calls.last
    assert_equal [ 75 ], @cutter.starts
    track.reload
    assert_equal "previews/ME004/02-kokedera-#{CLIP}.mp3", track.audio_path
    assert_equal "https://media.margate-electronics.org/previews/ME004/02-kokedera-#{CLIP}.mp3", track.url
  end

  test "a file uploaded in the admin moves into place in the private bucket first" do
    track = @release.tracks.create!(title: "Two For Joy", position: 1)
    track.master_upload.attach(io: StringIO.new("full file"), filename: "01 Two For Joy.mp3", content_type: "audio/mpeg")
    upload_key = track.master_upload.blob.key

    GeneratePreviewJob.perform_now(track)

    assert_includes @storage.calls, [ :copy, :masters, upload_key, "ME004/01 Two For Joy.mp3" ]
    track.reload
    assert_equal "ME004/01 Two For Joy.mp3", track.master_path
    refute track.master_upload.attached?, "the upload is removed once moved"
  end

  test "a new start point makes a new preview; event recordings never get one" do
    track = @release.tracks.create!(title: "Kokedera", position: 2)
    assert_no_enqueued_jobs(only: GeneratePreviewJob) { track.update!(title: "Kokedera (edit)") }
    assert_enqueued_with(job: GeneratePreviewJob) { track.update!(master_path: "ME004/02 Kokedera.wav") }
    assert_enqueued_with(job: GeneratePreviewJob) { track.update!(preview_start: 30) }

    recording = Event.find_by!(slug: "me-12").tracks.first
    assert_no_enqueued_jobs(only: GeneratePreviewJob) { recording.update!(title: "hellocatfood (live)") }
  end

  test "a renamed track's old clip is removed" do
    track = @release.tracks.create!(title: "New name", position: 3, master_path: "ME004/03.wav")
    track.update_columns(audio_path: "previews/ME004/03-old-name.mp3")
    GeneratePreviewJob.perform_now(track)
    assert_includes @storage.calls, [ :delete, :media, "previews/ME004/03-old-name.mp3" ]
    assert_equal "previews/ME004/03-new-name-#{CLIP}.mp3", track.reload.audio_path
  end

  test "a remade clip with different sound gets a new address, and the old one is removed" do
    track = @release.tracks.create!(title: "Kokedera", position: 2, master_path: "ME004/02 Kokedera.wav")
    track.update_columns(audio_path: "previews/ME004/02-kokedera-00000000.mp3")
    GeneratePreviewJob.perform_now(track)
    assert_equal "previews/ME004/02-kokedera-#{CLIP}.mp3", track.reload.audio_path
    assert_includes @storage.calls, [ :delete, :media, "previews/ME004/02-kokedera-00000000.mp3" ]
  end

  test "ffmpeg: 45 seconds from the start point, 2-second fades, 128kbps MP3" do
    args = PreviewClip.ffmpeg_arguments("in.wav", "out.mp3", start: 60)
    assert_equal [ "-ss", "60", "-t", "45", "-i", "in.wav" ], args[4, 6]
    assert_includes args, "afade=t=in:st=0:d=2,afade=t=out:st=43:d=2"
    assert_equal [ "-codec:a", "libmp3lame", "-b:a", "128k" ], args[args.index("-codec:a"), 4]
    assert_equal "out.mp3", args.last
  end

  test "previews are filed by catalogue number, with a readable name" do
    track = @release.tracks.build(title: "Two For Joy", position: 1)
    assert_equal "previews/ME004/01-two-for-joy-3f9a1c2e.mp3", PreviewClip.key_for(track, fingerprint: "3f9a1c2e")
    japanese = @release.tracks.create!(title: "こけのね", position: 4)
    assert_equal "previews/ME004/04-track-#{japanese.id}-3f9a1c2e.mp3", PreviewClip.key_for(japanese, fingerprint: "3f9a1c2e"), "no Latin letters to name it by"
  end
end

require "test_helper"

class PublishRecordingJobTest < ActiveJob::TestCase
  # Records what the job asks R2 to do
  class FakeStorage
    attr_reader :calls

    def initialize = @calls = []

    def download(bucket, key, to:)
      @calls << [ :download, bucket, key ]
      File.write(to, "recording")
    end

    def upload(bucket, key, from:, content_type:)
      @calls << [ :upload, bucket, key, content_type, File.read(from) ]
    end

    def delete(bucket, key) = @calls << [ :delete, bucket, key ]
  end

  setup do
    @storage = FakeStorage.new
    storage = @storage
    PublishRecordingJob.storage_factory = -> { storage }
    @event = Event.find_by!(slug: "me-12")
  end

  teardown { PublishRecordingJob.storage_factory = -> { R2Storage.new } }

  def upload(track, name)
    track.master_upload.attach(io: StringIO.new("recording"), filename: name, content_type: "audio/mpeg")
    track.master_upload.blob.key
  end

  test "an uploaded event recording is published in full and gets its duration read" do
    track = @event.tracks.create!(title: "Set", position: 2)
    upload_key = upload(track, "Set_ME12.mp3")

    assert_enqueued_with(job: ReadDurationJob) { PublishRecordingJob.perform_now(track) }

    assert_equal [ :download, :masters, upload_key ], @storage.calls.first
    assert_includes @storage.calls, [ :upload, :media, "recordings/me-12/Set_ME12.mp3", "audio/mpeg", "recording" ]
    track.reload
    assert_equal "recordings/me-12/Set_ME12.mp3", track.audio_path
    assert_equal "https://media.margate-electronics.org/recordings/me-12/Set_ME12.mp3", track.url
    refute track.master_upload.attached?, "the private copy is removed once published"
  end

  test "saving a recording with an upload starts the job; a release track's upload makes a preview instead" do
    recording = @event.tracks.create!(title: "Set", position: 2)
    upload(recording, "Set.mp3")
    assert_enqueued_with(job: PublishRecordingJob) { recording.save! }

    release_track = Release.find_by!(slug: "me004").tracks.create!(title: "Track one", position: 1)
    upload(release_track, "01.mp3")
    assert_no_enqueued_jobs(only: PublishRecordingJob) { release_track.save! }
  end

  test "a replaced upload's old file goes; files copied from Backblaze never do" do
    track = @event.tracks.create!(title: "Set", position: 2, audio_path: "recordings/me-12/Old.mp3")
    upload(track, "New.mp3")
    PublishRecordingJob.perform_now(track)
    assert_includes @storage.calls, [ :delete, :media, "recordings/me-12/Old.mp3" ]

    @storage.calls.clear
    copied = @event.tracks.first # ME12_Hellocatfood_master_streaming.mp3, at the top of the bucket
    upload(copied, "Replacement.mp3")
    PublishRecordingJob.perform_now(copied)
    assert_empty @storage.calls.select { |call| call.first == :delete }
  end
end

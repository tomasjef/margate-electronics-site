require "test_helper"

class ReadDurationJobTest < ActiveJob::TestCase
  # Stands in for ffprobe: answers a fixed length and remembers the address
  class FakeProbe
    attr_reader :urls

    def initialize(seconds) = (@seconds, @urls = seconds, [])

    def seconds(url)
      @urls << url
      @seconds
    end
  end

  teardown { ReadDurationJob.prober = DurationProbe }

  test "a recording saved without a duration gets it from the file" do
    probe = FakeProbe.new(2008.0065)
    ReadDurationJob.prober = probe
    recording = Event.find_by!(slug: "me-12").tracks.first
    recording.update_columns(duration: nil)

    assert_enqueued_with(job: ReadDurationJob) { recording.update!(title: "hellocatfood") }
    perform_enqueued_jobs(only: ReadDurationJob)

    assert_equal "33:28", recording.reload.duration
    assert_equal [ recording.url ], probe.urls
  end

  test "a duration typed in the admin is kept; release tracks and files that can't be read are left alone" do
    ReadDurationJob.prober = FakeProbe.new(nil)
    recording = Event.find_by!(slug: "me-12").tracks.first
    recording.update_columns(duration: nil)
    ReadDurationJob.perform_now(recording)
    assert_nil recording.reload.duration

    assert_no_enqueued_jobs(only: ReadDurationJob) { recording.update!(duration: "33:30") }
    release_track = Release.find_by!(slug: "me004").tracks.create!(title: "Track one", audio_path: "previews/ME004/01.mp3")
    assert_no_enqueued_jobs(only: ReadDurationJob) { release_track.update!(title: "Track 1") }
  end

  test "lengths read as the player shows them" do
    assert_equal "0:59", DurationProbe.clock(59.9)
    assert_equal "33:28", DurationProbe.clock(2008.0)
    assert_equal "1:02:15", DurationProbe.clock(3735)
  end
end

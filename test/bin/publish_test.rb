require "test_helper"
require "open3"

# bin/publish's last step: after pushing, wait for GitHub's deploy of that
# commit and say whether the site is live. GitHub's command-line tool (gh)
# is replaced by a stand-in that answers as told, so nothing is pushed or
# deployed here.
class PublishTest < ActiveSupport::TestCase
  SCRIPT = Rails.root.join("bin/publish").read
  # Just the settings and the waiting function, without the commit and push
  WAITING = SCRIPT[/^ACTIONS=.*?^}\n/m]

  def wait_for_deploy(gh: nil)
    Dir.mktmpdir do |dir|
      if gh
        File.write("#{dir}/gh", "#!/bin/sh\n#{gh}\n")
        File.chmod(0o755, "#{dir}/gh")
      end
      # Only the stand-in and the few tools the script uses on the PATH, so a
      # real gh (preinstalled on CI's machines) is never found
      # (found in Ruby: `command` is a shell builtin, not a program, on Linux)
      %w[sed head sleep].each { |tool| File.symlink(find_tool(tool), "#{dir}/#{tool}") }
      env = { "PATH" => dir }
      Open3.capture2e(env, "/bin/sh", "-c", "cd #{Rails.root} && #{WAITING}\nwait_for_deploy abc123")
    end
  end

  def find_tool(name)
    ENV["PATH"].split(File::PATH_SEPARATOR).map { |dir| File.join(dir, name) }.find { |path| File.executable?(path) }
  end

  test "says Live with the site's address once the deploy succeeds" do
    out, status = wait_for_deploy(gh: <<~SH)
      case "$1 $2" in
        "run list") echo 42 ;;
        "run watch") exit 0 ;;
      esac
    SH
    assert status.success?
    assert_includes out, "Live: https://margate-electronics.org"
  end

  test "says the deploy failed, with its link, and exits with an error" do
    out, status = wait_for_deploy(gh: <<~SH)
      case "$1 $2" in
        "run list") echo 42 ;;
        "run watch") exit 1 ;;
      esac
    SH
    assert_not status.success?
    assert_includes out, "the deploy failed"
    assert_includes out, "/actions/runs/42"
  end

  test "without the GitHub tool, points at the Actions page" do
    out, status = wait_for_deploy(gh: nil)
    assert status.success?
    assert_includes out, "https://github.com/tomasjef/margate-electronics-app/actions"
    assert_not_includes out, "Live:"
  end
end

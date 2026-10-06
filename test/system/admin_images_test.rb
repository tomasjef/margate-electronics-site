require "application_system_test_case"

# Photos in the admin, the way Tomas works: from a release's page, add one,
# replace one's file, delete one.
class AdminImagesTest < ApplicationSystemTestCase
  include AdminSystemHelpers

  PHOTO = Rails.root.join("app/assets/images/prototype/me003-tile-orange.jpg")

  # The admin's pages are heavier than the site's, and CI's machines slower:
  # give each step longer than Capybara's default 2 seconds
  setup do
    @default_wait = Capybara.default_max_wait_time
    Capybara.default_max_wait_time = 10
  end

  teardown { Capybara.default_max_wait_time = @default_wait }

  setup do
    visit "/session/new"
    fill_in "Email", with: users(:one).email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
    assert_no_selector "h1", text: "Sign in"
    @me003 = Release.find_by!(slug: "me003")
  end

  def save = save_form

  # The release page's Images panel loads once it's scrolled into view
  def images_panel
    visit "/admin/resources/releases/me003"
    frame = find("turbo-frame#has_many_field_show_images", visible: :all)
    frame.scroll_to(frame)
    assert frame.has_css?("table")
    frame
  end

  test "add a photo to a release from its Images panel" do
    panel = images_panel
    click_until(-> { within(panel) { find_link("Create new image") } }, ->(wait) { has_current_path?(%r{/admin/resources/images/new}, wait: wait) })
    attach_file "image_file", PHOTO, make_visible: true
    fill_in "image_alt", with: "A second photo"
    fill_in "image_position", with: "2"
    save
    assert_text "Image was successfully created"
    assert_equal [ "A second photo" ], @me003.images.reload.where(position: 2).pluck(:alt)
    assert @me003.images.find_by(alt: "A second photo").file.attached?
  end

  test "replace a photo's file" do
    image = @me003.images.first
    old_blob = image.file.blob.id
    visit "/admin/resources/images/#{image.id}/edit"
    assert_selector "input#image_file", visible: :all
    assert_selector "img[src*='#{image.file.filename}'], img[src*='redirect']"
    # No delete button on the file itself
    assert_no_selector "a[href*='active_storage_attachments']"
    attach_file "image_file", PHOTO, make_visible: true
    # The box acknowledges the chosen file, which uploads on Save
    assert_selector ".file-upload-input--chosen", text: "✓ me003-tile-orange.jpg"
    assert_text "Ready: press Save to upload"
    save
    assert_text "Image was successfully updated"
    assert_not_equal old_blob, image.reload.file.blob.id
    assert_equal "me003-tile-orange.jpg", image.file.filename.to_s
  end

  test "delete a photo from the release's Images panel" do
    image = @me003.images.first
    panel = images_panel
    click_until(-> { within(panel) { find("[data-control=destroy]", match: :first) } }, ->(wait) { has_button?("Yes, I'm sure", wait: wait) })
    click_on "Yes, I'm sure"
    assert_text "Record destroyed"
    assert_not Image.exists?(image.id)
  end

  test "choosing a track's full file shows its name until Save; Clear value undoes it" do
    track = @me003.tracks.create!(title: "Track one", position: 1)
    visit "/admin/resources/tracks/#{track.id}/edit"
    settle
    attach_file "track_master_upload", Rails.root.join("test/fixtures/files/silence.wav"), make_visible: true
    assert_selector ".file-upload-input--chosen", text: "✓ silence.wav"
    click_until(-> { find_button("Clear value") }, ->(wait) { has_no_selector?(".file-upload-input--chosen", wait: wait) })
    assert_text "Upload audio"
  end

  test "long captions and file names never make the lists scroll sideways" do
    page.driver.browser.manage.window.resize_to(1280, 800)
    @me003.images.first.update!(alt: "A very long description of the photo " * 4,
                                caption: "An equally long caption that goes on and on " * 3)
    @me003.tracks.create!(title: "A long track title that keeps going and going and going", position: 1,
                          audio_path: "previews/ME003/01-a-long-track-title-that-keeps-going-and-going-f5a3ec88.mp3")
    panel = images_panel
    # Shortened in the list, whole on the photo's page and in its form
    assert_text "A very long description of the photo"
    assert_no_text "A very long description of the photo A very long description of the photo"
    [ "turbo-frame#has_many_field_show_images", "turbo-frame#has_many_field_show_tracks" ].each do |frame|
      find(frame, visible: :all).scroll_to(find(frame, visible: :all))
      assert find(frame, visible: :all).has_css?("table")
      # Anything in the panel that would show a sideways scrollbar
      overflow = evaluate_script(<<~JS)
        [...document.querySelectorAll("#{frame} *")].some(el => el.scrollWidth > el.clientWidth + 1 && ["auto", "scroll"].includes(getComputedStyle(el).overflowX))
      JS
      assert_not overflow, "#{frame} scrolls sideways"
    end
    assert_includes panel.text, "Gallery"
  ensure
    page.driver.browser.manage.window.resize_to(1440, 900)
  end
end

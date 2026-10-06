require "test_helper"

# Literal paths: after a request inside the Avo engine, route helpers pick up
# the /admin script name.

class AdminAccessTest < ActionDispatch::IntegrationTest
  test "admin redirects to sign in when signed out" do
    get "/admin"
    assert_redirected_to "http://www.example.com/session/new"
  end

  test "admin loads when signed in" do
    sign_in_as users(:one)
    get "/admin/resources/users"
    assert_response :success
  end

  test "every content screen in the admin opens: list, record and new form" do
    sign_in_as users(:one)
    { "events" => Event, "releases" => Release, "products" => Product, "tracks" => Track,
      "images" => Image, "product_colours" => ProductColour, "product_variants" => ProductVariant }.each do |resource, model|
      get "/admin/resources/#{resource}"
      assert_response :success, "#{resource} list"
      get "/admin/resources/#{resource}/#{model.first.id}"
      assert_response :success, "#{resource} record"
      get "/admin/resources/#{resource}/new"
      assert_response :success, "#{resource} new"
    end
    get "/admin/resources/events/#{Event.find_by!(slug: "me-12").id}/edit"
    assert_response :success
  end

  test "events, releases and products open and save at their slug, as the admin links them" do
    sign_in_as users(:one)
    { "events" => Event.find_by!(slug: "me-12"), "releases" => Release.find_by!(slug: "me003"),
      "products" => Product.find_by!(slug: "t-shirt") }.each do |resource, record|
      get "/admin/resources/#{resource}"
      assert_select "a[href*='/admin/resources/#{resource}/#{record.slug}']", { minimum: 1 }, "#{resource} list links by slug"
      get "/admin/resources/#{resource}/#{record.slug}"
      assert_response :success, "#{resource} record"
      get "/admin/resources/#{resource}/#{record.slug}/edit"
      assert_response :success, "#{resource} edit"
      get "/admin/resources/#{resource}/#{record.id}"
      assert_response :success, "#{resource} record by number"
    end

    patch "/admin/resources/releases/me003", params: { release: { format: "Edited in the admin", price_pounds: "13.50" } }
    assert_redirected_to %r{/admin/resources/releases/me003}
    me003 = Release.find_by!(slug: "me003")
    assert_equal "Edited in the admin", me003.format
    assert_equal 1350, me003.price_pence, "the price field is in pounds"
    get "/admin/resources/releases/me003/edit"
    assert_select "input[name='release[price_pounds]'][value='13.5'], input[name='release[price_pounds]'][value='13.50']"
  end

  test "every text field in the admin is the text editor, with White in place of underline" do
    sign_in_as users(:one)
    get "/admin/resources/releases/me003/edit"
    %w[heading info description credits].each do |field|
      assert_select "tiptap-editor[input=tiptap_release_#{field}]", { count: 1 }, field
    end
    assert_select "textarea:not([data-tiptap-field-target=input])", 0, "no plain text boxes"
    assert_select "select[name='release[credits_colour]']", 0
    get "/admin/resources/products/t-shirt/edit"
    %w[heading info].each { |field| assert_select "tiptap-editor[input=tiptap_product_#{field}]", { count: 1 }, field }
  end

  test "entries can be pinned on the home page, and a new photo starts at position 1" do
    sign_in_as users(:one)
    { "events" => "me-12", "releases" => "me003", "products" => "t-shirt" }.each do |resource, slug|
      get "/admin/resources/#{resource}/#{slug}/edit"
      assert_select "input[name='#{resource.singularize}[home_position]']", { count: 1 }, resource
    end
    patch "/admin/resources/releases/me003", params: { release: { home_position: "1" } }
    assert_equal 1, Release.find_by!(slug: "me003").home_position
    assert_equal "/releases/me003/", Feed.new.items.first.path

    get "/admin/resources/images/new"
    assert_select "input[name='image[position]'][value='1']"
  end

  test "track forms show what applies: uploads for both, the preview start only for releases, nothing filled in for you to type" do
    sign_in_as users(:one)
    recording = Event.find_by!(slug: "me-12").tracks.first
    get "/admin/resources/tracks/#{recording.id}/edit"
    assert_select "input[type=file][name='track[master_upload]']"
    %w[duration audio_path master_path preview_start].each { |field| assert_select "input[name='track[#{field}]']", 0, field }

    release_track = Release.find_by!(slug: "me004").tracks.create!(title: "Track one", position: 1)
    get "/admin/resources/tracks/#{release_track.id}/edit"
    assert_select "input[type=file][name='track[master_upload]']"
    assert_select "input[name='track[preview_start]']", 1
    %w[audio_path master_path duration].each { |field| assert_select "input[name='track[#{field}]']", 0, field }

    get "/admin/resources/tracks/#{recording.id}"
    assert_select "body", text: /ME12_Hellocatfood_master_streaming\.mp3/
  end

  test "the admin edits the About page: its text and the artists" do
    sign_in_as users(:one)
    about = AboutPage.current
    get "/admin/resources/about_pages"
    assert_redirected_to "/admin/resources/about_pages/#{about.id}/edit", "the sidebar link opens it for editing"
    get "/admin/resources/about_pages/new"
    assert_redirected_to "/admin/resources/about_pages/#{about.id}/edit"
    assert_not about.destroy, "it can't be deleted"
    get "/admin/resources/about_pages/#{about.id}/edit"
    assert_response :success
    assert_select "[data-field-id=body]"
    assert_select "[data-field-id=artists]"
    assert_select "[data-field-id=credit]"
  end

    test "public site does not require sign in" do
    get "/"
    assert_response :success
  end

  test "signing in returns to the admin page that was requested" do
    get "/admin/resources/users"
    post "/session", params: { email_address: users(:one).email_address, password: "password" }
    assert_redirected_to "http://www.example.com/admin/resources/users"
  end

  test "signing out from the admin ends the session" do
    sign_in_as users(:one)
    get "/admin/resources/users"
    assert_select "form[action='/session'] input[name='_method'][value='delete']"

    delete "/session"
    get "/admin"
    assert_redirected_to "http://www.example.com/session/new"
  end
end

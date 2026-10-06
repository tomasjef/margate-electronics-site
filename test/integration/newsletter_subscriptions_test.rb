require "test_helper"

class NewsletterSubscriptionsTest < ActionDispatch::IntegrationTest
  test "the newsletter page's form posts straight to MailerLite" do
    get "/newsletter"
    assert_response :success
    assert_select "form.newsletter__form[method=post][action=?]", Rails.configuration.x.newsletter_form_action do
      assert_select "input[type=email][name='fields[email]'][required]"
      assert_select "input[type=hidden][name='ml-submit'][value='1']"
    end
  end

  test "nothing on the site posts to Rails" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/newsletter", method: :post)
    end
  end
end

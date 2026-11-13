# The newsletter page (the dialog carries the same form). The form posts
# straight to MailerLite, so there is nothing to handle here: the site is
# static and nothing posts to Rails.
class NewsletterSubscriptionsController < ApplicationController
  allow_unauthenticated_access

  def new
  end
end

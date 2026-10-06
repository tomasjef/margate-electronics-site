module Avo
  class ApplicationController < BaseApplicationController
    include Authentication
    delegate :new_session_path, to: :main_app

    prepend_before_action :require_authentication
  end
end

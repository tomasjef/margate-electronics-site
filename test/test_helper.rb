ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"
require_relative "test_helpers/admin_system_helpers"

# Build the test assets once, before parallel tests fork: each process
# building them at the same moment collides on public/vite-test.
ViteRuby.commands.build || abort("Vite build for tests failed")

# The launch content (db/seeds/content.rb) is the pages' test data: loaded
# once into each test database, outside the per-test transactions, like
# fixtures. Photos go to the test storage folder.
require_relative "../db/seeds/content"
ContentSeeds.run

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)
    # Each parallel worker has its own database, so it gets its own copy
    parallelize_setup { |_worker| ContentSeeds.run }

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

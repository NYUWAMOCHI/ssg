# frozen_string_literal: true

require "ssg"
require "active_record"
require "active_support"
require "active_support/core_ext/time"

# Load test support files
require_relative "support/test_models"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset test state before each test
  config.before(:each) do
    GachaCardRelation.delete_all
  end
end

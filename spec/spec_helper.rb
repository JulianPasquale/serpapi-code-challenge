# frozen_string_literal: true

require 'rspec'
require 'nokogiri'
require 'pry'

# Configure RSpec
RSpec.configure do |config|
  # Use color output
  config.color = true
  # Set up expectations to use the new syntax
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  # Configure mocks
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Share context across examples efficiently
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

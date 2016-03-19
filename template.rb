begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  gem 'activerecord', '4.2.3'
  gem 'sqlite3'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.integer :approval_status, limit: 1, default: 0
  end
end

class User < ActiveRecord::Base
  enum approval_status: [:pending, :approved, :declined]
end


class BugTest < Minitest::Test
  def setup
    User.create!
  end

  def teardown
    User.delete_all
  end

  def test_enum_with_string
    assert_equal 1, User.where(approval_status: 'pending').count
  end

  def test_enum_with_symbol
    assert_equal 1, User.where(approval_status: :pending).count
  end
end

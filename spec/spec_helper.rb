$:.unshift(File.expand_path('../../lib', __FILE__))

require 'rubygems'
require 'bundler/setup'
require 'fileutils'
require 'timecop'
require 'pp'
require 'pry'

if RUBY_PLATFORM != "java"
  if ENV['TRAVIS']
    require 'coveralls'
    Coveralls.wear!
  elsif ENV['COVERAGE'] && RUBY_VERSION > "1.8"
    require 'simplecov'
    SimpleCov.start do
      add_filter 'spec'
      add_group 'Core',         'lib/mark_mapper'
      add_group 'Rails',        'lib/rails'
      add_group 'Extensions',   'lib/mark_mapper/extensions'
      add_group 'Plugins',      'lib/mark_mapper/plugins'
      add_group 'Associations', 'lib/mark_mapper/plugins/associations'
    end
  end
end

require 'marklogic'
require 'mark_mapper'

# These environment variables can be set if wanting to test against a database
# that is not on the local machine.
ENV["MARKMAPPER_SPEC_HOST"] ||= "localhost"
ENV["MARKMAPPER_SPEC_PORT"] ||= "8009"

ENV["MARKMAPPER_SPEC_APP_SERVICES_PORT"] ||= "8000"
ENV["MARKMAPPER_SPEC_ADMIN_PORT"] ||= "8001"
ENV["MARKMAPPER_SPEC_MANAGE_PORT"] ||= "8002"

ENV["MARKMAPPER_SPEC_USER"] ||= "admin"
ENV["MARKMAPPER_SPEC_PASSWORD"] ||= "admin"
ENV["MARKMAPPER_SKIP_APP_CREATION"] ||= "false"

# These are used when creating any connection in the test suite.
HOST = ENV["MARKMAPPER_SPEC_HOST"]
PORT = ENV["MARKMAPPER_SPEC_PORT"].to_i

APP_SERVICES_PORT = ENV["MARKMAPPER_SPEC_APP_SERVICES_PORT"]
MANAGE_PORT = ENV["MARKMAPPER_SPEC_MANAGE_PORT"]
ADMIN_PORT = ENV["MARKMAPPER_SPEC_ADMIN_PORT"]

USER = ENV["MARKMAPPER_SPEC_USER"]
PASSWORD = ENV["MARKMAPPER_SPEC_PASSWORD"]

ADMIN_USER = ENV["MARKMAPPER_SPEC_ADMIN_USER"]
ADMIN_PASSWORD = ENV["MARKMAPPER_SPEC_ADMIN_PASSWORD"]

MarkLogic::Connection.configure({
  :host => HOST,
  :manage_port => MANAGE_PORT,
  :admin_port => ADMIN_PORT,
  :app_services_port => APP_SERVICES_PORT,
  :default_user => ADMIN_USER,
  :default_password => ADMIN_PASSWORD
})

CONNECTION = MarkLogic::Connection.new(HOST, PORT)
MarkMapper.application = MarkLogic::Application.new("markmapper-application-test", connection: CONNECTION )
MarkMapper.application.stale?

MarkMapper.logger.level = Logger::DEBUG

def Doc(name='Class', &block)
  klass = Class.new
  klass.class_eval do
    include MarkMapper::Document

    if name
      class_eval "def self.name; '#{name}' end"
      class_eval "def self.to_s; '#{name}' end"
    else
      set_collection_name :test
    end
  end

  klass.class_eval(&block) if block_given?
  klass.collection.remove if klass.database.exists?
  klass
end

def EDoc(name='Class', &block)
  klass = Class.new do
    include MarkMapper::EmbeddedDocument

    if name
      class_eval "def self.name; '#{name}' end"
      class_eval "def self.to_s; '#{name}' end"
    end
  end

  klass.class_eval(&block) if block_given?
  klass
end

def drop_indexes(klass)
  klass.collection.drop_indexes if klass.database.collection_names.include?(klass.collection.name)
end

log_dir = File.expand_path('../../log', __FILE__)
FileUtils.mkdir_p(log_dir) unless File.exist?(log_dir)
logger = Logger.new(log_dir + '/test.log')

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # config.filter_run_excluding :skip => true
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.fail_fast = true

  config.before(:all) do
    @application = MarkMapper.application.tap do |app|
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:_id, :type => 'string'))
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:name, :type => 'string'))
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:body, :type => 'string'))
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:age, :type => 'int'))
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:first_name, :type => 'string'))
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:position, :type => 'int'))
      app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:weight, :type => 'int'))
    end
    @application.sync
    @database = @application.content_databases[0]
    @database.clear
  end

  config.around(:each, :without_connection) do |example|
    old, MarkMapper.connection = MarkMapper.connection, nil
    example.run
    MarkMapper.connection = old
  end

  config.after(:suite) do
    puts "CLEANING UP AFTER ALL TESTS FINISHED"
    MarkLogic::Application.new("markmapper-application-test", :port => PORT).drop
  end
end

operators = %w{gt lt ge le ne eq asc desc}
SymbolOperators = operators

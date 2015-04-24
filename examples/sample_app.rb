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

puts "Configuring application again"
MarkMapper.application = MarkLogic::Application.new("sample-app", connection: CONNECTION )

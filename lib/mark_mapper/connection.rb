# encoding: UTF-8
require 'uri'

module MarkMapper
  module Connection
    @@connection    = nil
    @@database      = nil
    @@database_name = nil
    @@config        = nil

    # @api public
    def connection
      @@connection ||= application.connection
    end

    def connection?
      !!connection
    end

    # @api public
    def connection=(new_connection)
      @@connection = new_connection
    end

    # @api public
    def logger
      MarkLogic.logger
    end

    def application=(new_app)
      @@application = new_app
    end

    def application
      @@application
    end

    # @api public
    def database=(name)
      @@database = nil
      @@database_name = name
    end

    # @api public
    def database
      return nil if @@database_name.blank?

      @@database ||= MarkLogic::Database.new(@@database_name, connection)
    end

    def config=(hash)
      @@config = hash
    end

    def config
      raise 'Set config before connecting. MarkMapper.config = {...}' unless defined?(@@config)
      @@config
    end

    def setup(config, environment, options={})
      self.config = config
      connect(environment, options)
    end

    def connect(environment, options={})
      raise 'Set config before connecting. MongoMapper.config = {...}' if config.blank?
      env = config_for_environment(environment)

      MarkLogic::Connection.configure({
        host: env['host'],
        default_user: env['username'],
        default_password: env['password']
      })

      MarkLogic::Connection.configure(manage_port: env['manage_port']) if env['manage_port']
      MarkLogic::Connection.configure(admin_port: env['admin_port']) if env['admin_port']
      MarkLogic::Connection.configure(app_services_port: env['app_services_port']) if env['app_services_port']

      MarkMapper.application = MarkLogic::Application.new(
        "markmapper-application-test",
        connection: MarkLogic::Connection.new(env['host'], env['port'])
      )
      MarkMapper.application.stale?
    end

    def config_for_environment(environment)
      config[environment.to_s] || {}
    end
  end
end

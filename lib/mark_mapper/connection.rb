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
  end
end

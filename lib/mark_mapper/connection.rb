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
      @@connection ||= config.application.connection
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

    # @api public
    def database_name=(name)
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

    # @api private
    def config_for_environment(environment)
      env = config[environment.to_s] || {}
      return env if env['uri'].blank?

      uri = URI.parse(env['uri'])
      raise InvalidScheme.new('must be mongodb') unless uri.scheme == 'mongodb'
      {
        'host'     => uri.host,
        'port'     => uri.port,
        'database' => uri.path.gsub(/^\//, ''),
        'username' => uri.user,
        'password' => uri.password,
      }
    end

    def connect(environment, options={})
      raise 'Set config before connecting. MarkMapper.config = {...}' if config.blank?
      env = config_for_environment(environment)

      if env['options'].is_a?(Hash)
        options = env['options'].symbolize_keys.merge(options)
      end
      options[:read] = options[:read].to_sym if options[:read].is_a? String

      if env.key?('ssl')
        options[:ssl] = env['ssl']
      end

      MarkMapper.connection = if env.key?('hosts')
        klass = (env.key?("mongos") || env.key?("sharded")) ? Mongo::MongoShardedClient : Mongo::MongoReplicaSetClient
        if env['hosts'].first.is_a?(String)
          klass.new( env['hosts'], options )
        else
          klass.new( *env['hosts'].push(options) )
        end
      else
        Mongo::MongoClient.new(env['host'], env['port'], options)
      end

      MarkMapper.database = env['database']
      MarkMapper.database.authenticate(env['username'], env['password']) if env['username'] && env['password']
    end

    def setup(config, environment, options={})
      handle_passenger_forking
      self.config = config
      connect(environment, options)
    end

    def handle_passenger_forking
      # :nocov:
      if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          connection.connect if forked
        end
      end
      # :nocov:
    end
  end
end

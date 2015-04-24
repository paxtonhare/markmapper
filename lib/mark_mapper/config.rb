require 'yaml'

module MarkMapper

  # This module defines all the configuration options for MarkMapper, including the
  # database connections.
  module Config
    extend self

    def indexes
      @indexes ||= []
    end

    def settings
      @settings ||= {
        :host => 'localhost',
        :port => 8003,
        :manage_port => 8002,
        :admin_port => 8001,
        :app_name => defined?(Rails) ? Rails::Application.subclasses.first.parent.to_s.underscore : nil,
        :username => nil,
        :password => nil
      }
    end

    def application
      @application ||=
        begin
          MarkLogic::Application.new(app_name,
            :port => port,
            :connection => MarkLogic::Connection.new(host, port))
        end
      yield(@application) if block_given?
      @application
    end

    # Load the settings from a compliant mark_mapper.yml file. This can be used for
    # easy setup with frameworks other than Rails.
    #
    # @example Configure MarkMapper.
    #  MarkMapper.load!("/path/to/mark_mapper.yml")
    #
    # @param [ String ] path The path to the file.
    # @param [ String, Symbol ] environment The environment to load.
    #
    # @since 0.0.1
    def load!(path, environment = nil)
      options = load_yaml(path, environment)
      load_configuration(options) if options.present?
    end

    # From a hash of options, load all the configuration.
    #
    # @example Load the configuration.
    #  config.load_configuration(options)
    #
    # @param [ Hash ] options The configuration options.
    #
    # @since 0.0.1
    def load_configuration(options)
      options.each_pair do |key, value|
        if settings.has_key? key.to_sym
          settings[key.to_sym] = value
        else
          raise InvalidConfigurationOption, "Invalid configuration item: #{key}"
        end
      end
    end

    def env_name
      return Rails.env if defined?(Rails)
      ENV["RACK_ENV"] || ENV["MARKMAPPER_ENV"] || raise(Errors::NoEnvironment.new)
    end

    def load_yaml(path, environment = nil)
      env = environment ? environment.to_s : env_name
      YAML.load(ERB.new(File.new(path).read).result)[env]
    end

    def method_missing(name, *args)
      attr = name.to_s
      sym = attr.delete("=").to_sym
      if attr.include?("=")
        settings[sym] = args.first
      else
        settings[sym]
      end
    end
  end
end

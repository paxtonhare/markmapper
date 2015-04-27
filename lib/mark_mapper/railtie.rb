require "mark_mapper"
require "rails"
require "active_model/railtie"

# Need the action_dispatch railtie to have action_dispatch.rescu_responses initialized correctly
require "action_dispatch/railtie"

module MarkMapper
  # = MarkMapper Railtie
  class Railtie < Rails::Railtie

    config.mark_mapper = ActiveSupport::OrderedOptions.new

    # Rescue responses similar to ActiveRecord.
    config.action_dispatch.rescue_responses.merge!(
        'MarkMapper::DocumentNotFound'  => :not_found,
        'MarkMapper::InvalidKey'        => :unprocessable_entity,
        'MarkMapper::InvalidScheme'     => :unprocessable_entity,
        'MarkMapper::NotSupported'      => :unprocessable_entity
      )

    rake_tasks do
      load "mark_mapper/railtie/application.rake"
      load "mark_mapper/railtie/database.rake"
    end

    initializer "mark_mapper.set_configs" do |app|
      ActiveSupport.on_load(:mark_mapper) do
        app.config.mark_mapper.each do |k,v|
          send "#{k}=", v
        end
      end
    end

    # This sets the database configuration and establishes the connection.
    initializer "mark_mapper.initialize_database" do |app|
      config_file = Rails.root.join('config/marklogic.yml')
      if config_file.file?
        config = YAML.load(ERB.new(config_file.read).result)
        MarkMapper.setup(config, Rails.env, :logger => Rails.logger)
      end
    end
  end
end

# encoding: UTF-8
module MarkMapper
  module Plugins
    module Associations
      class SingleAssociation < Base
        def setup(model)
          @model = model
          model.associations_module.module_eval <<-end_eval
            def #{name}
              proxy = get_proxy(associations[#{name.inspect}])
              proxy.nil? ? nil : proxy
            end

            def #{name}=(value)
              association = associations[#{name.inspect}]
              proxy = get_proxy(association)

              if proxy.nil? || proxy.target != value
                proxy = build_proxy(association)
              end

              proxy.replace(value)
              value
            end

            def #{name}?
              get_proxy(associations[#{name.inspect}]).present?
            end

            def build_#{name}(attrs={}, &block)
              get_proxy(associations[#{name.inspect}]).build(attrs, &block)
            end

            def create_#{name}(attrs={}, &block)
              get_proxy(associations[#{name.inspect}]).create(attrs, &block)
            end

            def create_#{name}!(attrs={}, &block)
              get_proxy(associations[#{name.inspect}]).create!(attrs, &block)
            end
          end_eval
        end
      end
    end
  end
end
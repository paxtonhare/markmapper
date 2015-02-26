# encoding: UTF-8
module MarkMapper
  module Plugins
    module Clone
      extend ActiveSupport::Concern

      def initialize_copy(other)
        @_new       = true
        @_destroyed = false
        remove_instance_variable :@_id if instance_variable_defined?(:@_id)
        init_ivars

        associations.each do |name, association|
          instance_variable_set(association.ivar, nil)
        end
        self.attributes = other.attributes.clone.except(:_id).inject({}) do |hash, entry|
          key, value = entry
          hash[key] = value.duplicable? ? value.clone : value
          hash
        end
      end
    end
  end
end

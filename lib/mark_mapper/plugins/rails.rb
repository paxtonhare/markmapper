# encoding: UTF-8
module MarkMapper
  module Plugins
    module Rails
      autoload :ActiveRecordAssociationAdapter, "mark_mapper/plugins/rails/active_record_association_adapter"
      extend ActiveSupport::Concern

      def to_param
        id.to_s if persisted?
      end

      def to_model
        self
      end

      def to_key
        [id] if persisted?
      end

      def new_record?
        new?
      end

      def read_attribute(name)
        self[name]
      end

      def read_attribute_before_type_cast(name)
        @__mm_pre_cast ||= {}
        name = unalias_key name
        if !@__mm_pre_cast.key?(name)
          @__mm_pre_cast[name] = read_attribute(name)
        end
        @__mm_pre_cast[name]
      end

      def write_attribute(name, value)
        self[name] = value
        self[name]
      end

      def write_key(name, value)
        name = unalias_key name
        @__mm_pre_cast ||= {}
        @__mm_pre_cast[name.to_s] = value
        super
      end

      module ClassMethods
        def has_one(*args)
          one(*args)
        end

        def has_many(*args, &extension)
          many(*args, &extension)
        end

        def column_names
          unaliased_keys.keys
        end

        # Returns returns an ActiveRecordAssociationAdapter for an association. This adapter has an API that is a
        # subset of ActiveRecord::Reflection::AssociationReflection. This allows MarkMapper to be used with the
        # association helpers in gems like simple_form and formtastic.
        def reflect_on_association(name)
          ActiveRecordAssociationAdapter.for_association(associations[name]) if associations[name]
        end

        def create_accessors_for(key)
          super do
            define_method "#{key.name}_before_type_cast" do
              read_attribute_before_type_cast key.name
            end
          end
        end
      end
    end
  end
end

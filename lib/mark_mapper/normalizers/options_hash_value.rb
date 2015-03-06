require 'mark_mapper/normalizers/integer'
require 'mark_mapper/normalizers/fields_value'
require 'mark_mapper/normalizers/sort_value'

module MarkMapper
  module Normalizers
    class OptionsHashValue

      # Public: Initialize an OptionsHashValue.
      #
      # args - The hash of arguments (default: {})
      #        :key_normalizer - The key normalizer to use, must respond to call
      #        :value_normalizers - Hash where key is name of options hash key
      #                             to normalize and value is what should be used
      #                             to normalize the value accordingly (must respond
      #                             to call). Allows adding normalizers for new keys
      #                             and overriding existing default normalizers.
      #
      #
      # Examples
      #
      #   MarkMapper::Normalizers::OptionsHashValue.new({
      #     :key_normalizer => lambda { |key| key}, # key normalizer must responds to call
      #     :value_normalizers => {
      #       :new_key => lambda { |key| key.to_s.upcase }, # add normalizer for :new_key
      #       :fields  => lambda { |key| key }, # override normalizer for fields to one that does nothing
      #     }
      #   })
      #
      # Returns the duplicated String.
      def initialize(args = {})
        @key_normalizer = args.fetch(:key_normalizer) {
          raise ArgumentError, "Missing required key :key_normalizer"
        }

        @value_normalizers = {
          :fields => default_fields_value_normalizer,
          :sort   => default_sort_value_normalizer,
          :limit  => default_limit_value_normalizer,
          :skip   => default_skip_value_normalizer,
        }

        if (value_normalizers = args[:value_normalizers])
          @value_normalizers.update(value_normalizers)
        end
      end

      # Public: Returns value normalized for MarkLogic
      #
      # key - The name of the key whose value is being normalized
      # value - The value to normalize
      #
      # Returns value normalized for MarkLogic.
      def call(key, value)
        if (value_normalizer = @value_normalizers[key])
          value_normalizer.call(value)
        else
          value
        end
      end

      # Private
      def default_fields_value_normalizer
        Normalizers::FieldsValue.new
      end

      # Private
      def default_sort_value_normalizer
        Normalizers::SortValue.new(:key_normalizer => Normalizers::HashKey.new({:id => :_id}))
      end

      # Private
      def default_limit_value_normalizer
        Normalizers::Integer.new
      end

      # Private
      def default_skip_value_normalizer
        Normalizers::Integer.new
      end
    end
  end
end

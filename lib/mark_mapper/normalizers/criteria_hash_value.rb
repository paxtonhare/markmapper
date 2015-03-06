module MarkMapper
  module Normalizers
    class CriteriaHashValue

      # Internal: Used by normalized_value to determine if we need to run the
      # value through another criteria hash to normalize it.
      NestingOperators = [:$or, :$and, :$nor]

      def initialize(criteria_hash)
        @criteria_hash = criteria_hash
      end

      # Public: Returns value normalized for MarkLogic
      #
      # parent_key - The parent key if nested, otherwise same as key
      # key - The key we are currently normalizing
      # value - The value that should be normalized
      #
      # Returns value normalized for MarkLogic
      def call(parent_key, key, value)
        case value
          when Array, Set
            if nesting_operator?(key)
              value.map  { |v| criteria_hash_class.new(v, options).to_hash }
            elsif parent_key == key && !modifier?(key) && !value.empty?
              # we're not nested and not the value for a symbol operator
              {:$eq => value.to_a}
            else
              # we are a value for a symbol operator or nested hash
              value.to_a
            end
          when Time
            value.utc
          when String
            value
          when Hash
            value.each { |k, v| value[k] = call(key, k, v) }
            value
          when Regexp
            Regexp.new(value)
          else
            value
        end
      end

      # Private: Returns class of provided criteria hash
      def criteria_hash_class
        @criteria_hash.class
      end

      # Private: Returns options of provided criteria hash
      def options
        @criteria_hash.options
      end

      # Private: Returns true or false if key is a nesting operator
      def nesting_operator?(key)
        NestingOperators.include?(key)
      end

      def modifier?(key)
        MarkMapper.modifier?(key)
      end
    end
  end
end

# encoding: UTF-8
module MarkMapper
  module Extensions
    module Array
      extend ActiveSupport::Concern

      module ClassMethods
        def to_marklogic(value)
          value = value.respond_to?(:lines) ? value.lines : value
          value.to_a
        end

        def from_marklogic(value)
          value || []
        end
      end

      def _mark_mapper_deep_copy_
        map { |value| value._mark_mapper_deep_copy_ }
      end
    end
  end
end

class Array
  include MarkMapper::Extensions::Array
end
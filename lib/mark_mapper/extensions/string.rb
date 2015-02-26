# encoding: UTF-8
module MarkMapper
  module Extensions
    module String
      extend ActiveSupport::Concern

      module ClassMethods
        def to_marklogic(value)
          value && value.to_s
        end

        def from_marklogic(value)
          value && value.to_s
        end

        def xs_type
          "string"
        end

      end

      def _mark_mapper_deep_copy_
        self.dup
      end
    end
  end
end

class String
  include MarkMapper::Extensions::String
end

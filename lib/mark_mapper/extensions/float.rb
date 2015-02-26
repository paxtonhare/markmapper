# encoding: UTF-8
module MarkMapper
  module Extensions
    module Float
      def to_marklogic(value)
        value.blank? ? nil : value.to_f
      end

      def xs_type
        "float"
      end
    end
  end
end

class Float
  extend MarkMapper::Extensions::Float
end

# encoding: UTF-8
module MarkMapper
  module Extensions
    module Integer
      def to_marklogic(value)
        value_to_i = value.to_i
        if value_to_i == 0 && value != value_to_i
          value.to_s =~ /^(0x|0b)?0+/ ? 0 : nil
        else
          value_to_i
        end
      end

      def from_marklogic(value)
        value && value.to_i
      end

      def xs_type
        "int"
      end
    end
  end
end

class Integer
  extend MarkMapper::Extensions::Integer
end

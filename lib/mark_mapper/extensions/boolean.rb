# encoding: UTF-8
module MarkMapper
  module Extensions
    module Boolean
      Mapping = {
        true    => true,
        'true'  => true,
        'TRUE'  => true,
        'True'  => true,
        't'     => true,
        'T'     => true,
        '1'     => true,
        1       => true,
        1.0     => true,
        false   => false,
        'false' => false,
        'FALSE' => false,
        'False' => false,
        'f'     => false,
        'F'     => false,
        '0'     => false,
        0       => false,
        0.0     => false,
        nil     => nil
      }

      def to_marklogic(value)
        Mapping[value]
      end

      def from_marklogic(value)
        return nil if value == nil
        !!value
      end

      def xs_type
        "boolean"
      end
    end
  end
end

class Boolean; end unless defined?(Boolean)

Boolean.extend MarkMapper::Extensions::Boolean

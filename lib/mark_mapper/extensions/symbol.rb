# encoding: UTF-8
module MarkMapper
  module Extensions
    module Symbol
      def to_marklogic(value)
        value && value.to_s.to_sym
      end

      def from_marklogic(value)
        value && value.to_s.to_sym
      end
    end
  end
end

class Symbol
  extend MarkMapper::Extensions::Symbol
end

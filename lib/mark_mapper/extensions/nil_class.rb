# encoding: UTF-8
module MarkMapper
  module Extensions
    module NilClass
      def to_marklogic(value)
        value
      end

      def from_marklogic(value)
        value
      end
    end
  end
end

class NilClass
  include MarkMapper::Extensions::NilClass
end
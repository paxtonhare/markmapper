# encoding: UTF-8
require 'set'

module MarkMapper
  module Extensions
    module Set
      def to_marklogic(value)
        value.to_a
      end

      def from_marklogic(value)
        (value || []).to_set
      end
    end
  end
end

class Set
  extend MarkMapper::Extensions::Set
end
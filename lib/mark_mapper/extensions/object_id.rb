# encoding: UTF-8
module MarkMapper
  module Extensions
    module ObjectId
      def to_marklogic(value)
        Madmin.to_object_id(value)
      end

      def from_marklogic(value)
        value
      end
    end
  end
end

class ObjectId
  extend MarkMapper::Extensions::ObjectId
end

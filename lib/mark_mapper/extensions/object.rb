# encoding: UTF-8
module MarkMapper
  module Extensions
    module Object
      extend ActiveSupport::Concern

      module ClassMethods
        def to_marklogic(value)
          value
        end

        def from_marklogic(value)
          value
        end
      end

      def to_marklogic
        self.class.to_marklogic(self)
      end

      def _mark_mapper_deep_copy_
        self
      end
    end
  end
end

class Object
  include MarkMapper::Extensions::Object
end
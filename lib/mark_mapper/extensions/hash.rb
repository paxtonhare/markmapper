# encoding: UTF-8
module MarkMapper
  module Extensions
    module Hash
      extend ActiveSupport::Concern

      module ClassMethods
        def from_marklogic(value)
          HashWithIndifferentAccess.new(value || {})
        end
      end

      def _mark_mapper_deep_copy_
        self.class.new.tap do |new_hash|
          each do |key, value|
            new_hash[key._mark_mapper_deep_copy_] = value._mark_mapper_deep_copy_
          end
        end
      end
    end
  end
end

class Hash
  include MarkMapper::Extensions::Hash
end
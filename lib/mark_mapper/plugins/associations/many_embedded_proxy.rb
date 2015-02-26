# encoding: UTF-8
module MarkMapper
  module Plugins
    module Associations
      class ManyEmbeddedProxy < EmbeddedCollection
        def replace(values)
          @_values = (values || []).compact.map do |v|
            v.respond_to?(:attributes) ? v.attributes : v
          end
          reset
        end

        private
          def find_target
            (@_values ||= []).map do |attrs|
              klass.load(attrs, true).tap do |child|
                assign_references(child)
              end
            end
          end
      end
    end
  end
end

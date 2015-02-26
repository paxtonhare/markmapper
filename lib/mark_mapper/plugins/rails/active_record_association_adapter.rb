# encoding: UTF-8
module MarkMapper
  module Plugins
    module Rails
      class ActiveRecordAssociationAdapter
        attr_reader :klass, :macro, :name, :options

        def self.for_association(association)
          macro = case association
          when MarkMapper::Plugins::Associations::BelongsToAssociation
            :belongs_to
          when MarkMapper::Plugins::Associations::ManyAssociation
            :has_many
          when MarkMapper::Plugins::Associations::OneAssociation
            :has_one
          else
            raise "no #{name} for association of type #{association.class}"
          end

          new(association, macro)
        end

        def initialize(association, macro)
          @klass, @name = association.klass, association.name
          # only include compatible options
          @options = association.options.slice(:conditions, :order)

          @macro = macro
        end
      end
    end
  end
end

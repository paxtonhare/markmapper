# encoding: UTF-8
module MarkMapper
  module Extensions
    module SymbolClassMethods
      def to_marklogic(value)
        value && value.to_s.to_sym
      end

      def from_marklogic(value)
        value && value.to_s.to_sym
      end
    end

    module SymbolnstanceMethods
      def gt
        SymbolOperator.new(self, 'gt')
      end

      def lt
        SymbolOperator.new(self, 'lt')
      end

      def ge
        SymbolOperator.new(self, 'ge')
      end

      def le
        SymbolOperator.new(self, 'le')
      end

      def eq
        SymbolOperator.new(self, 'eq')
      end

      def ne
        SymbolOperator.new(self, 'ne')
      end

      def asc
        SymbolOperator.new(self, 'asc')
      end

      def desc
        SymbolOperator.new(self, 'desc')
      end
    end
  end
end

class SymbolOperator
  include Comparable

  attr_reader :field, :operator

  def initialize(field, operator)
    @field, @operator = field, operator
  end unless method_defined?(:initialize)

  def <=>(other)
    if field == other.field
      operator <=> other.operator
    else
      field.to_s <=> other.field.to_s
    end
  end

  def hash
    field.hash + operator.hash
  end

  def eql?(other)
    self == other
  end

  def ==(other)
    other.class == self.class && field == other.field && operator == other.operator
  end

  # def to_sym
  #   field
  # end
end

class Symbol
  extend MarkMapper::Extensions::SymbolClassMethods
  include MarkMapper::Extensions::SymbolnstanceMethods
end

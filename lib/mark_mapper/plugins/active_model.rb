# encoding: UTF-8
module MarkMapper
  module Plugins
    module ActiveModel
      extend ActiveSupport::Concern

      include ::ActiveModel::Conversion
      include ::ActiveModel::Serialization
      include ::ActiveModel::Serializers::Xml
      include ::ActiveModel::Serializers::JSON

      included do
        extend ::ActiveModel::Naming
        extend ::ActiveModel::Translation
      end
    end
  end
end
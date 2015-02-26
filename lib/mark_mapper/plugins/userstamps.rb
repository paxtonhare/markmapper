# encoding: UTF-8
module MarkMapper
  module Plugins
    module Userstamps
      extend ActiveSupport::Concern

      module ClassMethods
        def userstamps!(options = {})
          class_name = (options[:class_name] || options[:class] || 'User' ).to_s
          key :creator_id, ObjectId
          key :updater_id, ObjectId
          belongs_to :creator, :class_name => class_name
          belongs_to :updater, :class_name => class_name
        end
      end
    end
  end
end
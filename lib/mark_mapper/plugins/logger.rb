# encoding: UTF-8
module MarkMapper
  module Plugins
    module Logger
      extend ActiveSupport::Concern

      module ClassMethods
        def logger
          MarkMapper.logger
        end
      end

      def logger
        self.class.logger
      end
    end
  end
end
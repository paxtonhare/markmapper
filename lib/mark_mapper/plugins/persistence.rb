# encoding: UTF-8
module MarkMapper
  module Plugins
    module Persistence
      extend ActiveSupport::Concern

      module ClassMethods
        def inherited(subclass)
          unless subclass.embeddable?
            subclass.connection(connection)
            subclass.database = database
            subclass.set_collection_name(collection_name) unless subclass.explicit_collection_defined?
          end
          super
        end

        def connection(marklogic_connection=nil)
          assert_supported
          if marklogic_connection.nil? && MarkMapper.connection?
            @connection ||= MarkMapper.connection
          else
            @connection = marklogic_connection
          end
          @connection
        end

        def database_name
          assert_supported
          @database.database_name
        end

        def database=(database)
          assert_supported
          @database = database
        end

        def database
          assert_supported
          @database ||= MarkMapper.application.content_databases[0]
        end

        def set_collection_name(name)
          assert_supported
          @collection_name = name
        end

        def collection_name
          assert_supported
          @collection_name ||= begin
            name = self.to_s.tableize.gsub(/\//, '.')
            name = self.class.to_s.downcase if name[0] == '#'
            name
          end
        end

        def collection
          assert_supported
          database.collection(collection_name)
        end

        private
          def assert_supported
            @embeddable ||= embeddable?
            if @embeddable
              raise MarkMapper::NotSupported.new('This is not supported for embeddable documents at this time.')
            end
          end
      end

      def collection
        _root_document.class.collection
      end

      def database
        _root_document.class.database
      end
    end
  end
end

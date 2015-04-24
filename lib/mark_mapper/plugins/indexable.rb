module MarkMapper
  module Plugins
    module Indexable
      extend ActiveSupport::Concern

      module ClassMethods
        # Get all the defined indexes for this document
        #
        # @example Get the indexes hash
        #  person.index_defs
        #
        # @return[ Hash ] A hash containing all the index definitions
        #
        # @since 0.0.1
        def index_defs
          @index_defs ||= {}
        end

        # Defines all the MarkLogic indexes for this document
        #
        # @example Define an index.
        # Model.index :first_name, :type => String, :facet => true
        #
        # @param [ Symbol ] name The localname of the element to index.
        # @param [ Hash ] options The options to pass to the index.
        #
        # @option options [ String ] :type The atomic type of the element to index.
        # @option options [ Boolean ] :facet Whether to facet on this element index or not
        #
        # @since 0.0.1
        def index(name, options = {})
          options[:type] ||= String
          options[:type] = options[:type].xs_type if options[:type].respond_to?(:xs_type)

          raise InvalidIndexType, "Invalid index type: #{options[:type]}" unless [Boolean.xs_type, Integer.xs_type, String.xs_type, Float.xs_type].include? options[:type]

          new_index =
            begin
              case options[:kind]
                when "field" then MarkLogic::DatabaseSettings::RangeFieldIndex.new(name, options)
                when "path" then MarkLogic::DatabaseSettings::RangePathIndex.new(name, options)
                else MarkLogic::DatabaseSettings::RangeElementIndex.new(name, options)
              end
            end

          if !index_defs.has_key?(name.to_s)
            index_defs[name.to_s] = new_index
            MarkMapper.application.add_index(new_index)
          end
        end

        # Removes the definition for an index
        # Used for testing
        #
        # @example Remove an index
        # Model.remove_index :name
        #
        # @param [ String, Symbol ] name The name of the index to remove
        #
        # @since 0.0.1
        def remove_index(name)
          index_defs.delete name.to_s
        end

        # Generates an xml string with bootstrap configuration for the indexes
        # This is used when generating indexes automagically within MarkLogic
        #
        # @return [ String ] XML configuration
        #
        # @since 0.0.1
        # def index_setup_xml
        #  xml = ""
        #  index_defs.values do |index|
        #    xml << index.setup_xml
        #  end
        #  xml
        # end
      end

      included do
        index :_id, :type => String
      end

    end
  end
end

# encoding: UTF-8
require 'marklogic'
require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require "mark_mapper/railtie" if defined?(Rails)
require 'set'
require 'mark_mapper/criteria_hash'
require 'mark_mapper/options_hash'
require 'mark_mapper/query'
require 'mark_mapper/pagination'

I18n.load_path << File.expand_path('../mark_mapper/locale/en.yml', __FILE__)

module MarkMapper
  autoload :Connection,             'mark_mapper/connection'

  autoload :Error,                  'mark_mapper/exceptions'
  autoload :DocumentNotFound,       'mark_mapper/exceptions'
  autoload :InvalidScheme,          'mark_mapper/exceptions'
  autoload :DocumentNotValid,       'mark_mapper/exceptions'
  autoload :AccessibleOrProtected,  'mark_mapper/exceptions'
  autoload :InvalidKey,             'mark_mapper/exceptions'
  autoload :NotSupported,           'mark_mapper/exceptions'

  autoload :Document,               'mark_mapper/document'
  autoload :EmbeddedDocument,       'mark_mapper/embedded_document'
  autoload :Plugins,                'mark_mapper/plugins'
  autoload :Translation,            'mark_mapper/translation'
  autoload :Version,                'mark_mapper/version'

  module Middleware
    autoload :IdentityMap, 'mark_mapper/middleware/identity_map'
  end

  module Plugins
    autoload :ActiveModel,        'mark_mapper/plugins/active_model'
    autoload :Associations,       'mark_mapper/plugins/associations'
    autoload :Accessible,         'mark_mapper/plugins/accessible'
    autoload :Callbacks,          'mark_mapper/plugins/callbacks'
    autoload :Caching,            'mark_mapper/plugins/caching'
    autoload :Clone,              'mark_mapper/plugins/clone'
    autoload :CounterCache,       'mark_mapper/plugins/counter_cache'
    autoload :Dirty,              'mark_mapper/plugins/dirty'
    autoload :Document,           'mark_mapper/plugins/document'
    autoload :DynamicQuerying,    'mark_mapper/plugins/dynamic_querying'
    autoload :Dumpable,           'mark_mapper/plugins/dumpable'
    autoload :EmbeddedCallbacks,  'mark_mapper/plugins/embedded_callbacks'
    autoload :EmbeddedDocument,   'mark_mapper/plugins/embedded_document'
    autoload :Equality,           'mark_mapper/plugins/equality'
    autoload :IdentityMap,        'mark_mapper/plugins/identity_map'
    autoload :Inspect,            'mark_mapper/plugins/inspect'
    autoload :Indexable,         'mark_mapper/plugins/indexable'
    autoload :Keys,               'mark_mapper/plugins/keys'
    autoload :Logger,             'mark_mapper/plugins/logger'
    autoload :Modifiers,          'mark_mapper/plugins/modifiers'
    autoload :Pagination,         'mark_mapper/plugins/pagination'
    autoload :PartialUpdates,     'mark_mapper/plugins/partial_updates'
    autoload :Persistence,        'mark_mapper/plugins/persistence'
    autoload :Protected,          'mark_mapper/plugins/protected'
    autoload :Querying,           'mark_mapper/plugins/querying'
    autoload :Rails,              'mark_mapper/plugins/rails'
    autoload :Sci,                'mark_mapper/plugins/sci'
    autoload :Scopes,             'mark_mapper/plugins/scopes'
    autoload :Serialization,      'mark_mapper/plugins/serialization'
    autoload :Timestamps,         'mark_mapper/plugins/timestamps'
    autoload :Userstamps,         'mark_mapper/plugins/userstamps'
    autoload :Validations,        'mark_mapper/plugins/validations'
    autoload :Touch,              'mark_mapper/plugins/touch'

    module Associations
      autoload :Base,                         'mark_mapper/plugins/associations/base'
      autoload :Collection,                   'mark_mapper/plugins/associations/collection'
      autoload :EmbeddedCollection,           'mark_mapper/plugins/associations/embedded_collection'
      autoload :ManyAssociation,              'mark_mapper/plugins/associations/many_association'
      autoload :SingleAssociation,            'mark_mapper/plugins/associations/single_association'
      autoload :BelongsToAssociation,         'mark_mapper/plugins/associations/belongs_to_association'
      autoload :OneAssociation,               'mark_mapper/plugins/associations/one_association'
      autoload :ManyDocumentsProxy,           'mark_mapper/plugins/associations/many_documents_proxy'
      autoload :BelongsToProxy,               'mark_mapper/plugins/associations/belongs_to_proxy'
      autoload :BelongsToPolymorphicProxy,    'mark_mapper/plugins/associations/belongs_to_polymorphic_proxy'
      autoload :ManyPolymorphicProxy,         'mark_mapper/plugins/associations/many_polymorphic_proxy'
      autoload :ManyEmbeddedProxy,            'mark_mapper/plugins/associations/many_embedded_proxy'
      autoload :ManyEmbeddedPolymorphicProxy, 'mark_mapper/plugins/associations/many_embedded_polymorphic_proxy'
      autoload :ManyDocumentsAsProxy,         'mark_mapper/plugins/associations/many_documents_as_proxy'
      autoload :OneProxy,                     'mark_mapper/plugins/associations/one_proxy'
      autoload :OneAsProxy,                   'mark_mapper/plugins/associations/one_as_proxy'
      autoload :OneEmbeddedProxy,             'mark_mapper/plugins/associations/one_embedded_proxy'
      autoload :OneEmbeddedPolymorphicProxy,  'mark_mapper/plugins/associations/one_embedded_polymorphic_proxy'
      autoload :InArrayProxy,                 'mark_mapper/plugins/associations/in_array_proxy'
    end
  end

  extend Connection

  Methods = MarkMapper::Query::DSL.instance_methods.sort.map(&:to_sym)

  def self.to_object_id(value)
    return value if value.is_a?(MarkLogic::ObjectId)
    return nil   if value.nil? || (value.respond_to?(:empty?) && value.empty?)

    if MarkLogic::ObjectId.legal?(value.to_s)
      MarkLogic::ObjectId.from_string(value.to_s)
    else
      value
    end
  end

  # Private
  ModifierString = '$'

  # Internal
  def self.modifier?(key)
    key.to_s[0, 1] == ModifierString
  end
end

Dir[File.join(File.dirname(__FILE__), 'mark_mapper', 'extensions', '*.rb')].each do |extension|
  require extension
end

# FIXME: autoload with proxy is failing, need to investigate
require 'mark_mapper/plugins/associations/proxy'

ActiveSupport.run_load_hooks(:mark_mapper, MarkMapper)

$LOAD_PATH.unshift(File.expand_path('../../../lib', __FILE__))
require 'mark_mapper'
require 'pp'

MarkMapper.database = 'testing'

class User
  include MarkMapper::Document

  key :name, String
  key :tags, Array
end
User.collection.remove # empties collection

john = User.create(:name => 'John',  :tags => %w[ruby marklogic], :age => 28)
bill = User.create(:name => 'Bill',  :tags => %w[ruby marklogic], :age => 30)

User.set({:name => 'John'}, :tags => %[ruby])
pp john.reload

User.set(john.id, :tags => %w[ruby marklogic])
pp john.reload

john.set(:tags => %w[something different])
pp john.reload

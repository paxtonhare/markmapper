$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'mark_mapper'
require 'pp'

MarkMapper.database = 'testing'

class User
  include MarkMapper::Document

  key :name, String
  key :tags, Array
end
User.collection.remove # empties collection

User.create(:name => 'John',  :tags => %w[ruby marklogic], :age => 28)
User.create(:name => 'Bill',  :tags => %w[ruby marklogic], :age => 30)
User.create(:name => 'Frank', :tags => %w[marklogic],      :age => 35)
User.create(:name => 'Steve', :tags => %w[html5 css3], :age => 27)

[

  User.all(:name => 'John'),
  User.all(:tags => %w[marklogic]),
  User.all(:tags.all => %w[ruby marklogic]),
  User.all(:age.gte => 30),

  User.where(:age.gt => 27).sort(:age).all,
  User.where(:age.gt => 27).sort(:age.desc).all,
  User.where(:age.gt => 27).sort(:age).limit(1).all,
  User.where(:age.gt => 27).sort(:age).skip(1).limit(1).all,

].each do |result|
  pp result
  puts
end

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require_relative './sample_app'
require 'pp'

MarkMapper.application.create

class User
  include MarkMapper::Document

  key :first_name,  String, :required => true
  key :last_name,   String, :required => true
  key :token,       String, :default => lambda { 'some random string' }
  key :age,         Integer
  key :skills,      Array
  key :friend_ids,  Array, :typecast => 'ObjectId'
  key :links,       Hash
  timestamps!
end
User.collection.remove # empties collection

john = User.create({
  :first_name => 'John',
  :last_name  => 'Nunemaker',
  :age        => 28,
  :skills     => ['ruby', 'marklogic', 'javascript'],
  :links      => {"Google" => "http://www.google.com"}
})

steve = User.create({
  :first_name => 'Steve',
  :last_name  => 'Smith',
  :age        => 29,
  :skills     => ['html', 'css', 'javascript', 'design'],
})

john.friend_ids << steve.id.to_s # will get typecast to ObjectId
john.links["Ruby on Rails"] = "http://www.rubyonrails.com"
john.save

pp john

MarkMapper.application.drop

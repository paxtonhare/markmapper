$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require_relative './sample_app'
require 'pp'

MarkMapper.application.create

MarkMapper::Plugins::IdentityMap.enabled = true

class User
  include MarkMapper::Document

  key :name, String
end
User.delete_all

# User gets added to map on save
user = User.create(:name => 'John')

# Does not matter how you find user, it is always the same object until the identity map is cleared
puts "#{User.find(user.id).object_id} == #{user.object_id}"
puts "#{User.all[0].object_id} == #{user.object_id}"

MarkMapper::Plugins::IdentityMap.clear
puts "#{User.find(user.id).object_id} != #{user.object_id}"

# User gets removed from map on destroy
user = User.create
user.destroy

MarkMapper.application.drop

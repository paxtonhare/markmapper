$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require_relative './sample_app'

MarkMapper.application.create

class User
  include MarkMapper::Document
  key :email, String
  key :admin, Boolean, :default => false

  # Only accessible or protected can be used, they cannot be used together
  attr_protected :admin
end

# protected are ignored on new/create/etc.
user = User.create(:email => 'IDontLowerCaseThings@gmail.com', :admin => true)
puts user.admin # false

# can be set using accessor
user.admin = true
user.save
puts user.admin # true

MarkMapper.application.drop

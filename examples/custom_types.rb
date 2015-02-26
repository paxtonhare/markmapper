$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'mark_mapper'
require 'pp'

MarkMapper.database = 'testing'

class DowncasedString
  # to_marklogic gets called anytime a value is assigned
  def self.to_marklogic(value)
    value.nil? ? nil : value.to_s.downcase
  end

  # from marklogic gets called anytime a value is read
  def self.from_marklogic(value)
    value.nil? ? nil : value.to_s.downcase
  end
end

class User
  include MarkMapper::Document
  key :email, DowncasedString
end

pp User.create(:email => 'IDontLowerCaseThings@gmail.com')

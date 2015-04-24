$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require_relative '../sample_app'
require 'pp'

MarkMapper.application.create

class Field
  include MarkMapper::EmbeddedDocument
  key :name
  validates_presence_of :name
end

class Template
  include MarkMapper::Document
  key :name
  many :fields

  # This tells the template to validate all
  # fields when validating the template.
  validates_associated :fields
end

# Name is missing on embedded field
template = Template.new(:fields => [Field.new])
puts template.valid? # false

# Name is present on embedded field
template = Template.new(:fields => [Field.new(:name => 'Yay')])
puts template.valid? # true

MarkMapper.application.drop

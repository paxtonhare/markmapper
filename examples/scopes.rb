$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require_relative './sample_app'
require 'pp'

MarkMapper.application.tap do |app|
  app.add_index(MarkLogic::DatabaseSettings::RangeElementIndex.new(:age, :type => 'int'))
end.sync

class User
  include MarkMapper::Document

  # plain old vanilla scopes with fancy queries
  scope :johns,   where(:name => 'John')

  # plain old vanilla scopes with hashes
  scope :bills, :name => 'Bill'

  # dynamic scopes with parameters
  scope :by_name,  lambda { |name| where(:name => name) }
  scope :by_ages,  lambda { |low, high| where(:age.ge => low, :age.le => high) }

  # Yep, even plain old methods work as long as they return a query
  def self.by_tag(tag)
    where(:tags => tag)
  end

  # You can even make a method that returns a scope
  def self.twenties; by_ages(20, 29) end

  key :name, String
  key :tags, Array
end
User.collection.remove # empties collection

User.create(:name => 'John',  :tags => %w[ruby marklogic], :age => 28)
User.create(:name => 'Bill',  :tags => %w[ruby marklogic], :age => 30)
User.create(:name => 'Frank', :tags => %w[marklogic],      :age => 35)
User.create(:name => 'Steve', :tags => %w[html5 css3], :age => 27)

# simple scopes
pp User.johns.first
pp User.bills.first

# scope with arg
pp User.by_name('Frank').first

# scope with two args
pp User.by_ages(20, 29).all

# chaining class methods on scopes
pp User.by_ages(20, 40).by_tag('ruby').all

# scope made using method that returns scope
pp User.twenties.all

MarkMapper.application.drop

# The purpose of this is to check finding, initializing,
# and creating objects (typecasting times/dates and booleans).

require 'stackprof'
require 'pp'
require 'benchmark'
require 'rubygems'

$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require_relative "../examples/sample_app.rb"

StackProf.run(mode: :cpu, out: 'tmp/stackprof-cpu-read-write.dump') do

  MarkMapper.application.create

  class Foo
    include MarkMapper::Document
    key :approved, Boolean
    key :count, Integer
    key :approved_at, Time
    key :expire_on, Date
    timestamps!
  end

  Foo.collection.remove

  ids = []
  1000.times { |i| ids << Foo.create(:count => 0, :approved => true, :approved_at => Time.now, :expire_on => Date.today).id }

  ids.each { |id| Foo.first(:id => id) }
end

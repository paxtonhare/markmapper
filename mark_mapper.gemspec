# encoding: UTF-8
require File.expand_path('../lib/mark_mapper/version', __FILE__)

Gem::Specification.new do |s|
  s.name               = 'mark_mapper'
  s.homepage           = ''
  s.summary            = 'A Ruby Object Mapper for MarkLogic'
  s.description        = 'MarkMapper is a Object-Document Mapper for Ruby and Rails'
  s.require_path       = 'lib'
  s.license            = 'MIT'
  s.authors            = ['Paxton Hare']
  s.email              = ['paxton@greenllama.com']
  s.executables        = ['mmconsole']
  s.version            = MarkMapper::Version
  s.platform           = Gem::Platform::RUBY
  s.files              = Dir.glob("{bin,examples,lib,spec}/**/*") + %w[LICENSE UPGRADES README.rdoc]

  s.add_dependency 'activemodel',   ">= 4.2.0"
  s.add_dependency 'activesupport', '>= 4.2.0'
  s.add_dependency 'marklogic'
end

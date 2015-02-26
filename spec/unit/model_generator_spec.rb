# require 'spec_helper'
# require 'rails/generators'
# require 'rails/generators/test_case'
# require 'rails/generators/mark_mapper/model/model_generator'

# describe MarkMapper::Generators::ModelGenerator do
#   include GeneratorSpec::TestCase
#   destination File.expand_path('../../tmp', File.dirname(__FILE__))

#   before do
#     prepare_destination
#   end

#   it 'help shows MarkMapper options' do
#     content = run_generator ['--help']
#     assert_match(/rails generate mark_mapper:model/, content)
#   end

#   it 'model are properly created' do
#     run_generator ['Color']
#     assert_file 'app/models/color.rb', /class Color/
#     assert_file 'app/models/color.rb', /include MarkMapper::Document/
#   end

#   it 'model are properly created with attributes' do
#     run_generator ['Color', 'name:string', 'saturation:integer']
#     assert_file 'app/models/color.rb', /class Color/
#     assert_file 'app/models/color.rb', /include MarkMapper::Document/
#     assert_file 'app/models/color.rb', /key :name, String/
#     assert_file 'app/models/color.rb', /key :saturation, Integer/
#   end

#   it 'model are properly created with timestamps option' do
#     run_generator ['Color', '--timestamps']
#     assert_file 'app/models/color.rb', /class Color/
#     assert_file 'app/models/color.rb', /include MarkMapper::Document/
#     assert_file 'app/models/color.rb', /timestamps/
#   end

#   it 'model are properly created with parent option' do
#     run_generator ['Green', '--parent', 'Color']
#     assert_file 'app/models/green.rb', /class Green < Color/
#   end

# end

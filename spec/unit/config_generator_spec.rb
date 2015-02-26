# require 'spec_helper'
# require 'rails/generators'
# require 'rails/generators/test_case'
# require 'rails/generators/mark_mapper/config/config_generator'

# describe MarkMapper::Generators::ConfigGenerator do
#   include GeneratorSpec::TestCase

#   destination File.expand_path('../../tmp', File.dirname(__FILE__))
#   before do
#     prepare_destination
#   end

#   it 'marklogic.yml are properly created' do
#     run_generator
#     assert_file 'config/marklogic.yml', /#{File.basename(destination_root)}/
#   end

#   it 'marklogic.yml are properly created with defined database_name' do
#     run_generator %w{dummy}
#     assert_file 'config/marklogic.yml', /dummy/
#   end

# end

source 'https://rubygems.org'

gem 'rake'
gem 'multi_json',  '~> 1.2'
gem 'coveralls', :require => false
gem 'simplecov', :require => false
gem 'rest-client', '1.6.7'

platforms :ruby do
  gem "marklogic", :path => '/Users/phare/src/ml/marklogic'
  gem "madmin", :path => '/Users/phare/src/hs/madmin'
end

platforms :rbx do
  gem "rubysl"
end

group :test do
  gem 'rspec'
  gem 'timecop',        '= 0.6.1'
  gem 'rack-test',      '~> 0.5'
  gem 'generator_spec'
end

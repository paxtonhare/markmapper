source 'https://rubygems.org'

gem 'rake'
gem 'multi_json',  '~> 1.2'
gem 'coveralls', :require => false
gem 'simplecov', :require => false

platforms :rbx do
  gem "rubysl"
end

group :test do
  gem 'rspec'
  gem 'timecop',        '= 0.6.1'
  gem 'rack-test',      '~> 0.5'
  gem 'generator_spec'
end

gemspec

gem 'rails', '~> 4.2.0', :group => :test
gem 'pry', :group => :test
gem 'pry-byebug', :group => :test
gem 'terminal-notifier-guard'
gem 'rspec-nc'
gem 'stackprof'
gem 'net-http-persistent'

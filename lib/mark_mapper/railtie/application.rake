namespace :app do
  desc 'Drops all the entire application configuration for the current Rails.env'
  task :drop => :environment do
    MarkMapper.application.drop
  end

  desc 'Creates the application configuration for the current Rails.env'
  task :create => :environment do
    puts "creating application"
    MarkMapper.application.create
  end
end

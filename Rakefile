begin
  require 'rspec/core/rake_task'
  require 'coveralls/rake/task'
  RSpec::Core::RakeTask.new
  Coveralls::RakeTask.new
rescue LoadError
end

require 'csv'
require File.join(File.dirname(__FILE__), 'lib/find_a_standard.rb')

task :populate do
   CSV.foreach(ENV['FILE'], headers: true) do |row|
     FindAStandard::Index.new(row[1], row[2], row[3])
   end
end

namespace :assets do
  task :precompile do
    `bundle exec compass compile`
  end
end

task :default => [:spec, 'coveralls:push']

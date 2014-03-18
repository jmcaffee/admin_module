require "bundler/gem_tasks"

desc 'start a console'
task :console do
  require 'pry'
  require 'admin_module'
  ARGV.clear

  puts 'To create a CLI object, run:'
  puts 'cli = AdminModule::CLI.new'

  Pry.start
end

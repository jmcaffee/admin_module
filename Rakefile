require "bundler/gem_tasks"
require 'ktutils/os'

desc 'start a console'
task :console do
  require 'pry'
  require 'admin_module'
  ARGV.clear

  puts 'To create a CLI object, run:'
  puts 'cli = AdminModule::CLI.new'

  Pry.start
end

desc 'Start chrome with data dir'
task :start_chrome do
  if Ktutils::OS.windows?
    sh('"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --user-data-dir=C:\Users\Jeff\ams\hsbc\test\chrome-data')
  else
    chrome = `which chromium-browser`.chomp

    user_data_dir = File.expand_path('test/chrome-data')
    mkdirs user_data_dir unless File.exists?(user_data_dir) and File.directory?(user_data_dir)

    sh("#{chrome} --user-data-dir=#{user_data_dir}")
  end
end


require "bundler/gem_tasks"
require 'ktutils/os'

require 'rake/clean'
require 'rspec/core/rake_task'

# Windows Locations

CHROME_PATH = '"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"'

# Setup common clean and clobber targets

CLEAN.include("pkg")
CLOBBER.include("pkg")

##############################################################################

desc 'start a console'
task :console do
  require 'pry'
  require 'admin_module'
  ARGV.clear

  AdminModule.configure do |config|
    config.credentials = { :dev => ['admin', 'Password1*'] }
  end

  def console_help
    puts <<CONSOLE_HELP
 CONSOLE HELP
-------------

'cli' returns an initialized CLI object

    The default environment is :dev.
    To interact with a different environment, add credentials
    and activate the new environment:

    Ex:
      add_credentials ENV, USERNAME, PASSWORD
      cli.environment = :ENV
      cli.login

    or, call 'activate_env ENV, USERNAME, PASSWORD'


Avaliable commands/methods:

  cli
  add_credentials ENV, USERNAME, PASSWORD
  activate_env ENV, USERNAME, PASSWORD
  console_help

CONSOLE_HELP
  end

  def cli
    @cli ||= AdminModule::CLI.new
    @cli
  end

  def add_credentials env, username, pwd
    AdminModule.configure do |config|
      config.credentials[env.to_sym] = [username, pwd]
    end
  end

  def activate_env env, username, pwd
    add_credentials env, username, pwd
    cli.environment = env.to_sym
  end

  console_help
  Pry.start
end

##############################################################################

desc 'Start chrome with data dir'
task :start_chrome do
  user_data_dir = File.expand_path('test/chrome-data')
  mkdirs user_data_dir unless File.exists?(user_data_dir) and File.directory?(user_data_dir)

  if Ktutils::OS.windows?
    user_data_dir = user_data_dir.gsub('/', '\\')
    sh("#{CHROME_PATH} --user-data-dir=#{user_data_dir}")
  else
    chrome = `which chromium-browser`.chomp
    sh("#{chrome} --user-data-dir=#{user_data_dir}")
  end
end

#############################################################################
desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  #t.rcov = true
end


# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

if ENV['coverage']
  raise 'simplecov only works on Ruby 1.9' unless RUBY_VERSION =~ /^1\.9/

  require 'simplecov'
  SimpleCov.start { add_filter "spec/" }
end

require 'bundler/setup'
require 'rspec'

require 'pry-byebug'
require 'pry-doc'
require 'pry-docmore'
require 'pry-rescue'
require 'pry-stack_explorer'

require 'admin_module'

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.mock_with :rspec do |mocks|
    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelt names.
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
end

require 'support/stage_factory'
include Factory

##
# Write a data structure to a yml file
#
def write_yaml_data_file filename, data
  File.open(filename, 'w') { |f| f << YAML.dump(data) }
end

##
# Read a data from a yml file
#
def read_yaml_data_file filename
  data = {}
  File.open(filename, 'r') do |f|
    data = YAML.load(f)
  end
  data
end

def data_dir path = nil
  return 'spec/data' unless path
  return File.join('spec/data', path)
end

def output_dir path = nil
  tmp = Pathname.new('tmp/spec')
  tmp = tmp + path unless path.nil?
  tmp.mkpath
  tmp.expand_path
end

def clean_output_dir path = nil
  tmp = Pathname.new('tmp/spec')
  tmp = tmp + path unless path.nil?
  tmp.rmtree if tmp.exist?
  tmp.mkpath
  tmp.expand_path
end

##
# Command Line Interface object
#
def cli
  return $real_cli unless $real_cli.nil?
  AdminModule.configure do |config|
    config.credentials = { :dev => ['admin', 'Password1*'] }
  end
  $real_cli = AdminModule::CLI.new
end

def quit_cli
  cli.quit
  $real_cli = nil
end


##
# Create a stage given a stage data hash object
#
def create_stage_for_test stage_data
  cli.create_stage(stage_data)
rescue
end

##
# Delete a stage given a stage data hash object
#
def delete_stage_for_test stage_data
  cli.delete_stage stage_data
rescue
end

def admin_module *args
  `bin/admin_module #{args}`
end

def capture_output
  fake_stdout = StringIO.new
  actual_stdout = $stdout
  $stdout = fake_stdout
  yield
  fake_stdout.rewind
  fake_stdout.read
ensure
  $stdout = actual_stdout
end

def mock_watir_browser
  watir_browser = instance_double('Watir::Browser')
  allow(watir_browser).to receive(:is_a?).with(anything()).and_return(false)
  allow(watir_browser).to receive(:is_a?).with(Watir::Browser).and_return(true)
  allow(watir_browser).to receive(:goto).with(anything()).and_return(true)
  allow(watir_browser).to receive(:text_field).with(anything()).and_return(nil)
  watir_browser
end

def mock_login_page
  login_page = object_double(AdminModule::Pages::LoginPage.new(mock_watir_browser))
  #allow(login_page).to receive(:login_as)#.with(anything()).and_return(nil)
  login_page
end

def mock_guidelines_page
  gdls_page = object_double(AdminModule::Pages::GuidelinesPage.new(mock_watir_browser))
end

def mock_page_factory(meth, obj)
  page_factory = instance_double('AdminModule::PageFactory')
  allow(page_factory).to receive(meth).and_return(obj)
  page_factory
end

class MockPageFactory

  attr_writer :login_page
  attr_writer :guidelines_page

  def login_page
    @login_page
  end

  def guidelines_page
    @guidelines_page
  end
end


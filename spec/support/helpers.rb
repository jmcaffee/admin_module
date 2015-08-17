##############################################################################
# File::    helpers.rb
# Purpose:: Spec helper methods
#
# Author::    Jeff McAffee 07/05/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

def run_with_args(args, client = nil, exitcode = false)
    AdminModule::Runner.new(args, client, exitcode).execute!
end

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

def load_yml filename
  YAML::load_file(filename)
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


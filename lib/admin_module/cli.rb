##############################################################################
# File::    cli.rb
# Purpose:: Admin Module command line interface
# 
# Author::    Jeff McAffee 06/28/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'thor'
require 'admin_module/cli/client_access'
require 'admin_module/cli/gdl'
require 'admin_module/cli/config'
require 'admin_module/cli/ruleset'
require 'admin_module/cli/rule'
require 'admin_module/cli/lock'
require 'admin_module/cli/stage'
require 'admin_module/cli/dc'


module AdminModule
  class CLI < Thor

    def self.start(*)
      super
    rescue Exception => e
      raise e
    end

    def initialize(*args)
      super
    end

    desc "gdl [COMMAND]", "run a guideline command"
    subcommand "gdl", AdminModule::Gdl

    desc "config [COMMAND]", "modify configuration values"
    subcommand "config", AdminModule::Config

    desc "ruleset [COMMAND]", "run a ruleset command"
    subcommand "ruleset", AdminModule::Ruleset

    desc "rule [COMMAND]", "run a rule command"
    subcommand "rule", AdminModule::Rule

    desc "lock [COMMAND]", "run a lock command"
    subcommand "lock", AdminModule::Lock

    desc "stage [COMMAND]", "run a stage command"
    subcommand "stage", AdminModule::Stage

    desc "dc [COMMAND]", "run a data clearing command"
    subcommand "dc", AdminModule::Dc
  end # CLI
end # AdminModule


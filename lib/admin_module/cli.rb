##############################################################################
# File::    cli.rb
# Purpose:: Admin Module command line interface
#
# Author::    Jeff McAffee 06/28/2014
#
##############################################################################

require 'thor'
require 'admin_module/command'


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
    subcommand "gdl", AdminModule::Command::Gdl

    desc "config [COMMAND]", "modify configuration values"
    subcommand "config", AdminModule::Command::Config

    desc "ruleset [COMMAND]", "run a ruleset command"
    subcommand "ruleset", AdminModule::Command::Ruleset

    desc "rule [COMMAND]", "run a rule command"
    subcommand "rule", AdminModule::Command::Rule

    desc "lock [COMMAND]", "run a lock command"
    subcommand "lock", AdminModule::Command::Lock

    desc "stage [COMMAND]", "run a stage command"
    subcommand "stage", AdminModule::Command::Stage

    desc "dc [COMMAND]", "run a data clearing command"
    subcommand "dc", AdminModule::Command::Dc
  end # CLI
end # AdminModule


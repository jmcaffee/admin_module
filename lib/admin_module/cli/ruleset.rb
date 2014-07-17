##############################################################################
# File::    ruleset.rb
# Purpose:: filedescription
#
# Author::    Jeff McAffee 2014-06-28
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AdminModule
  class Ruleset < Thor
    include AdminModule::ClientAccess

    class_option :environment, :banner => "dev", :aliases => :e

    desc "rename <srcname> <destname>",
      "Rename a ruleset named <srcname> to <destname>"
    long_desc <<-LD
      Renme a ruleset with the name <srcname> to <destname>.

      With -e <env>, sets the environment to work with.

      This operation will fail if the source ruleset does not exist or
      if the destination ruleset name already exists.
    LD
    def rename(src, dest)
      rs = client.rulesets

      rs.rename src, dest

    rescue ArgumentError => e
      say e.message, :red

    ensure
      client.logout
    end

    desc "list",
      "List all rulesets in the environment"
    long_desc <<-LD
      List all rulesets in the current environment.

      With -e <env>, sets the environment to work with.
    LD
    def list
      rs = client.rulesets
      list = rs.list

      list.each { |r| say r; }

    ensure
      client.logout
    end
  end # Ruleset
end # AdminModule

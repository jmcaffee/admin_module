##############################################################################
# File::    lock.rb
# Purpose:: Lock command line interface
#
# Author::    Jeff McAffee 2014-06-28
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AdminModule
  class Lock < Thor
    include AdminModule::ClientAccess

    class_option :environment, :banner => "dev", :aliases => :e

    desc "rename <srcname> <destname>",
      "Rename a lock named <srcname> to <destname>"
    long_desc <<-LD
      Rename a lock with the name <srcname> to <destname>.

      With -e <env>, sets the environment to work with.

      This operation will fail if the source lock does not exist or
      if the destination lock name already exists.
    LD
    def rename(src, dest)
      rs = client.locks

      rs.rename src, dest

    rescue ArgumentError => e
      say e.message, :red

    ensure
      client.logout
    end

    desc "list",
      "List all locks in the environment"
    long_desc <<-LD
      List all locks in the current environment.

      With -e <env>, sets the environment to work with.
    LD
    def list
      rs = client.locks
      list = rs.list

      list.each { |r| say r; }

    ensure
      client.logout
    end
  end # Lock
end # AdminModule

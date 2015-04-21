##############################################################################
# File::    lock.rb
# Purpose:: Lock command line interface
#
# Author::    Jeff McAffee 2014-06-28
#
##############################################################################

module AdminModule
  module Command
    class Lock < Thor
      include AdminModule::Command::ClientAccess

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
        cl = client.locks

        cl.rename src, dest

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
        cl = client.locks
        list = cl.list

        list.each { |r| say r; }

      ensure
        client.logout
      end

      desc "import <filepath>",
        "Import a lock configuration file into the environment"
      long_desc <<-LD
        Import a lock configuration file into the environment.

        <filepath> is a path to a YAML configuration file to import.

        With -e <env>, sets the environment to work with.
      LD
      def import filepath
        cl = client.locks
        cl.import filepath

      ensure
        client.logout
      end

      desc "export <filepath>",
        "Export a lock configuration file from the environment"
      long_desc <<-LD
        Export a lock configuration file from the environment.

        <filepath> path where the YAML configuration file will be exported to.

        With -e <env>, sets the environment to work with.
      LD
      def export filepath
        cl = client.locks
        cl.export filepath

      ensure
        client.logout
      end

      desc "read <name>",
        "Emit a lock's configuration from the environment in YAML format"
      long_desc <<-LD
        Emit a lock's configuration from the environment in YAML format.

        <name> of lock to dump.

        With -e <env>, sets the environment to work with.
      LD
      def read name
        cl = client.locks
        data = cl.read(name)
        output = Hash.new
        output[name] = data
        $stdout << output.to_yaml

      ensure
        client.logout
      end
    end # Lock
  end
end # AdminModule

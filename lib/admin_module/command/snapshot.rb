##############################################################################
# File::    snapshot.rb
# Purpose:: Snapshot command line interface
#
# Author::    Jeff McAffee 2015-04-05
#
##############################################################################

module AdminModule
  module Command
    class Snapshot < Thor
      include AdminModule::Command::ClientAccess

      class_option :environment, :banner => "dev", :aliases => :e

      desc "list",
        "List snapshot definitions"
      long_desc <<-LD
        List all snapshot definitions

        With -e <env>, sets the environment to work with
      LD
      def list
        cl = client.snapshots
        list = cl.list

        list.each { |item| say item; }

      ensure
        client.logout
      end

      desc "import <filepath>",
        "Import a snapshot definition file into the environment"
      long_desc <<-LD
        Import a snapshot definition file into the environment.

        <filepath> is a path to a YAML definition file to import.

        With -e <env>, sets the environment to work with.
      LD
      def import filepath
        cl = client.snapshots
        cl.import filepath

      ensure
        client.logout
      end

      desc "export <filepath>",
        "Export a snapshot definition file from the environment"
      long_desc <<-LD
        Export a snapshot definition file from the environment.

        <filepath> path to location YAML definition file will be exported to.

        With -e <env>, sets the environment to work with.
      LD
      def export filepath
        cl = client.snapshots
        cl.export filepath

      ensure
        client.logout
      end

      desc "rename <srcname> <destname>",
        "Rename a snapshot definition from <srcname> to <destname>"
      long_desc <<-LD
        Rename a snapshot definition from <srcname> to <destname>.

        With -e <env>, sets the environment to work with.

        This operation will fail if the source definition does not exist or
        if the destination definition name already exists.
      LD
      def rename src, dest
        cl = client.snapshots

        cl.rename src, dest

      rescue ArgumentError => e
        say e.message, :red

      ensure
        client.logout
      end

      desc "read <name>",
        "Emit a snapshot definition from the environment in YAML format"
      long_desc <<-LD
        Emit a snapshot's definition from the environment in YAML format.

        <name> of snapshot definition to dump.

        With -e <env>, sets the environment to work with.
      LD
      def read name
        cl = client.snapshots
        data = cl.read name
        output = Hash.new
        output[name] = data
        $stdout << output.to_yaml

      ensure
        client.logout
      end
    end
  end
end

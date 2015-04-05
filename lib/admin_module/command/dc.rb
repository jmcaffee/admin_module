##############################################################################
# File::    dc.rb
# Purpose:: DC command line interface
#
# Author::    Jeff McAffee 04/01/2015
#
##############################################################################

module AdminModule
  module Command
    class Dc < Thor
      include AdminModule::Command::ClientAccess

      class_option :environment, :banner => "dev", :aliases => :e

      desc "list",
        "List data clearing definitions"
      long_desc <<-LD
        List all data clearing definitions

        With -e <env>, sets the environment to work with
      LD
      def list
        cl = client.dcs
        list = cl.list

        list.each { |item| say item; }

      ensure
        client.logout
      end

      desc "import <filepath>",
        "Import a Data Clearing definition file into the environment"
      long_desc <<-LD
        Import a data clearing definition file into the environment.

        <filepath> is a path to a YAML definition file to import.

        With -e <env>, sets the environment to work with.
      LD
      def import filepath
        cl = client.dcs
        cl.import filepath

      ensure
        client.logout
      end

      desc "export <filepath>",
        "Export a data clearing definition file from the environment"
      long_desc <<-LD
        Export a data clearing definition file from the environment.

        <filepath> path to location YAML definition file will be exported to.

        With -e <env>, sets the environment to work with.
      LD
      def export filepath
        cl = client.dcs
        cl.export filepath

      ensure
        client.logout
      end

      desc "rename <srcname> <destname>",
        "Rename a data clearing definition from <srcname> to <destname>"
      long_desc <<-LD
        Rename a data clearing definition from <srcname> to <destname>.

        With -e <env>, sets the environment to work with.

        This operation will fail if the source definition does not exist or
        if the destination definition name already exists.
      LD
      def rename src, dest
        cl = client.dcs

        cl.rename src, dest

      rescue ArgumentError => e
        say e.message, :red

      ensure
        client.logout
      end

      desc "read <name>",
        "Emit a data clearing definition from the environment in YAML format"
      long_desc <<-LD
        Emit a data clearing's definition from the environment in YAML format.

        <name> of data clearing definition to dump.

        With -e <env>, sets the environment to work with.
      LD
      def read name
        cl = client.dcs
        output = cl.read name
        $stdout << output.to_yaml

      ensure
        client.logout
      end
    end
  end
end

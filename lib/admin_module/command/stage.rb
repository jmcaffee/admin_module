##############################################################################
# File::    stage.rb
# Purpose:: Stage command line interface
#
# Author::    Jeff McAffee 11/15/2013
#
##############################################################################

module AdminModule
  module Command
    class Stage < Thor
      include AdminModule::Command::ClientAccess

      class_option :environment, :banner => "dev", :aliases => :e

      desc "rename <srcname> <destname>",
        "Rename a stage from <srcname> to <destname>"
      long_desc <<-LD
        Rename a stage from <srcname> to <destname>.

        With -e <env>, sets the environment to work with.

        This operation will fail if the source stage does not exist or
        if the destination stage name already exists.
      LD
      def rename src, dest
        cs = client.stages
        cs.rename src, dest

      rescue ArgumentError => e
        say e.message, :red

      ensure
        client.logout
      end

      desc "list",
        "List all stages in the environment"
      long_desc <<-LD
        List all stages in the current environment.

        With -e <env>, sets the environment to work with.
      LD
      def list
        cs = client.stages
        list = cs.list

        list.each { |s| say s; }

      ensure
        client.logout
      end

      desc "import <filepath>",
        "Import a stage configuration file into the environment"
      long_desc <<-LD
        Import a stage configuration file into the environment.

        <filepath> is a path to a YAML configuration file to import.

        With -e <env>, sets the environment to work with.

        With -c, allow creation of new stages
      LD
      option :create, :type => :boolean, :default => false, :aliases => :c
      def import filepath
        cs = client.stages
        cs.import filepath, options[:create]

      ensure
        client.logout
      end

      desc "export <filepath>",
        "Export a stage configuration file from the environment"
      long_desc <<-LD
        Export a stage configuration file from the environment.

        <filepath> path where the YAML configuration file will be exported to.

        With -e <env>, sets the environment to work with.
      LD
      def export filepath
        cs = client.stages
        cs.export filepath

      ensure
        client.logout
      end

      desc "delete <name>",
        "Delete a stage from the environment"
      long_desc <<-LD
        Delete a stage from the environment.

        <name> of stage to delete.

        With -e <env>, sets the environment to work with.
      LD
      def delete name
        cs = client.stages
        cs.delete name

      ensure
        client.logout
      end

      desc "read <name>",
        "Emit a stage's configuration from the environment in YAML format"
      long_desc <<-LD
        Emit a stage's configuration from the environment in YAML format.

        <name> of stage to dump.

        With -e <env>, sets the environment to work with.
      LD
      def read name
        cs = client.stages
        output = cs.read(name)
        $stdout << output.to_yaml

      ensure
        client.logout
      end
    end # class
  end
end # module

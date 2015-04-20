##############################################################################
# File::    task.rb
# Purpose:: Task command line interface
#
# Author::    Jeff McAffee 2014-06-28
#
##############################################################################

module AdminModule
  module Command
    class Task < Thor
      include AdminModule::Command::ClientAccess

      class_option :environment, :banner => "dev", :aliases => :e

      desc "rename <srcname> <destname>",
        "Rename a task named <srcname> to <destname>"
      long_desc <<-LD
        Rename a task with the name <srcname> to <destname>.

        With -e <env>, sets the environment to work with.

        This operation will fail if the source task does not exist or
        if the destination task name already exists.
      LD
      def rename(src, dest)
        cl = client.tasks

        cl.rename src, dest

      rescue ArgumentError => e
        say e.message, :red

      ensure
        client.logout
      end

      desc "list",
        "List all tasks in the environment"
      long_desc <<-LD
        List all tasks in the current environment.

        With -e <env>, sets the environment to work with.
      LD
      def list
        cl = client.tasks
        list = cl.list

        list.each { |r| say r; }

      ensure
        client.logout
      end

      desc "import <filepath>",
        "Import a task configuration file into the environment"
      long_desc <<-LD
        Import a task configuration file into the environment.

        <filepath> is a path to a YAML configuration file to import.

        With -e <env>, sets the environment to work with.
      LD
      def import filepath
        cl = client.tasks
        cl.import filepath

      ensure
        client.logout
      end

      desc "export <filepath>",
        "Export a task configuration file from the environment"
      long_desc <<-LD
        Export a task configuration file from the environment.

        <filepath> path where the YAML configuration file will be exported to.

        With -e <env>, sets the environment to work with.
      LD
      def export filepath
        cl = client.tasks
        cl.export filepath

      ensure
        client.logout
      end

      desc "read <name>",
        "Emit a task's configuration from the environment in YAML format"
      long_desc <<-LD
        Emit a task's configuration from the environment in YAML format.

        <name> of task to dump.

        With -e <env>, sets the environment to work with.
      LD
      def read name
        cl = client.tasks
        output = cl.read(name)
        $stdout << output.to_yaml

      ensure
        client.logout
      end
    end # Task
  end
end # AdminModule

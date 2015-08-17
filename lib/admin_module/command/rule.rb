##############################################################################
# File::    rule.rb
# Purpose:: Rule command line interface
#
# Author::    Jeff McAffee 2014-06-28
#
##############################################################################

module AdminModule
  module Command
    class Rule < Thor
      include AdminModule::Command::ClientAccess

      class_option :environment, :banner => "dev", :aliases => :e

      desc "rename <srcname> <destname>",
        "Rename a rule named <srcname> to <destname>"
      long_desc <<-LD
        Rename a rule with the name <srcname> to <destname>.

        With -e <env>, sets the environment to work with.

        This operation will fail if the source rule does not exist or
        if the destination rule name already exists.
      LD
      def rename(src, dest)
        rs = client.rules

        rs.rename src, dest

      rescue ArgumentError => e
        say e.message, :red

      ensure
        client.logout
      end

      desc "delete <rulename>",
        "Delete a rule named <rulename>"
      long_desc <<-LD
        Delete a rule with the name <rulename>.

        With -e <env>, sets the environment to work with.

        This operation will fail if the rule does not exist.
      LD
      def delete(rule)
        rs = client.rules

        rs.delete rule

      rescue ArgumentError => e
        say e.message, :red

      ensure
        client.logout
      end

      desc "list",
        "List all rules in the environment"
      long_desc <<-LD
        List all rules in the current environment.

        With -e <env>, sets the environment to work with.
      LD
      def list
        rs = client.rules
        list = rs.list

        list.each { |r| say r; }

      ensure
        client.logout
      end
    end # Rule
  end
end # AdminModule

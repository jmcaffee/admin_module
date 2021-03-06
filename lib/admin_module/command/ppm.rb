##############################################################################
# File::    ppm.rb
# Purpose:: PPM command line interface
#
# Author::    Jeff McAffee 2015-06-23
#
##############################################################################

module AdminModule
  module Command
    class Ppm < Thor
      include AdminModule::Command::ClientAccess

      class_option :environment, :banner => "dev", :aliases => :e

      #desc "rename <srcname> <destname>",
      #  "Rename a lock named <srcname> to <destname>"
      #long_desc <<-LD
      #  Rename a lock with the name <srcname> to <destname>.

      #  With -e <env>, sets the environment to work with.

      #  This operation will fail if the source lock does not exist or
      #  if the destination lock name already exists.
      #LD
      #def rename(src, dest)
      #  cl = client.locks

      #  cl.rename src, dest

      #rescue ArgumentError => e
      #  say e.message, :red

      #ensure
      #  client.logout
      #end

      desc "list",
        "List PPMs in the environment"
      long_desc <<-LD
        List PPMs in the current environment.

        With -e <env>, sets the environment to work with.
      LD
      def list
        cl = client.ppms
        list = cl.list

        list.each { |r| say r; }

      ensure
        client.logout
      end

      desc "import <filepath>",
        "Import a PPM configuration file into the environment"
      long_desc <<-LD
        Import a PPM configuration file into the environment.

        <filepath> is a path to a YAML configuration file to import.

        With -e <env>, sets the environment to work with.
      LD
      def import filepath
        cl = client.ppms
        cl.import filepath

      ensure
        client.logout
      end

      desc "export <filepath>",
        "Export a PPM configuration file from the environment"
      long_desc <<-LD
        Export a PPM configuration file from the environment.

        <filepath> path where the YAML configuration file will be exported to.

        With -e <env>, sets the environment to work with.
      LD
      def export filepath
        cl = client.ppms
        cl.export filepath

      ensure
        client.logout
      end

      method_option :format, :default => "txt", :aliases => '-f', :banner => "format=FMT", :desc => "output format", :type => :string, :enum => ['txt','csv']
      desc "dups",
        "List duplicate PPMs in the environment"
      long_desc <<-LD
        List duplicate PPMs found in the environment.

        With -e <env>, sets the environment to work with.
      LD
      def dups
        cl = client.ppms
        data = cl.dups
        output_method = "output_as_#{options[:format]}"

        if self.respond_to? output_method
          self.send(output_method, data)
        else
          $stderr << "Invalid format: #{options[:format]}"
        end

      ensure
        client.logout
      end

      private

      def output_as_txt data
        if data.count > 0
          $stdout << "        Name                ID\n"
          $stdout << '-'*79 << "\n"
        else
          $stdout << 'No duplicates found'
          return
        end

        data.each do |dp|
          $stdout << "#{dp[:name]}\t#{dp[:id]}\n"
        end
      end

      def output_as_csv data
        if data.count > 0
          $stdout << "Name,ID\n"
        else
          $stdout << 'No duplicates found'
          return
        end

        data.each do |dp|
          $stdout << "#{dp[:name]},#{dp[:id]}\n"
        end
      end
    end # Ppm
  end
end # AdminModule

##############################################################################
# File::    gdl.rb
# Purpose:: filedescription
#
# Author::    Jeff McAffee 2014-06-28
#
##############################################################################

module AdminModule
  module Command
    class Gdl < Thor
      include AdminModule::Command::ClientAccess

      class_option :environment, :banner => "dev", :aliases => :e

      desc "deploy <srcdir> <comments>",
        "Deploy all XML files in <srcdir> with version <comments>"
      long_desc <<-LD
        Deploy all XML files in  <srcdir> with version <comments>.

        With -e <env>, sets the environment to work with.

        With -f <file_xml>, only deploy a single file.

        With -t <target_gdl>, sets the guideline to update (only valid with -f option).
      LD
      option :file, :banner => "<file_xml>", :aliases => :f
      option :target, :banner => "<target_gdl>", :aliases => :t
      def deploy(srcdir, comments = nil)
        gdl = client.guideline

        if options[:file]
          srcfile = Pathname(srcdir) + options[:file]
          gdl.deploy_file(srcfile, comments)
        else
          gdl.deploy(srcdir, comments)
        end

        client.logout
      end

      desc "version <comments>",
        "Version guidelines with <comments>"
      long_desc <<-LD
        Version guidelines with provided comments. Comments are optional.

        By default, all configured guidelines are versioned.
        Use -t option to version a specific guideline.

        With -e <env>, sets the environment to work with.

        With -t <gdlname>, versions a specific guideline.
      LD
      option :target, :banner => "<target_gdl>", :aliases => :t
      def version(comments = nil)
        gdl = client.guideline

        gdls = [options[:target]] unless options[:target].nil?
        gdls = AdminModule.configuration.xmlmaps.values.uniq if options[:target].nil?
        if gdls.empty?
          say "aborting version. no guidelines configured", :red
          return
        end

        gdl.version(gdls, comments)

        client.logout
      end

      desc "download <guideline> <to_path>",
        "Download guideline XML to destination path (includes filename)"
      long_desc <<-LD
        Download a guideline's XML and save it to a specified path and filename.

        With -e <env>, sets the environment to work with.
      LD
      def download(guideline, to_path)
        gdl = client.guideline

        #gdls = [options[:target]] unless options[:target].nil?
        #gdls = AdminModule.configuration.xmlmaps.values.uniq if options[:target].nil?
        #if gdls.empty?
        #  say "aborting version. no guidelines configured", :red
        #  return
        #end

        #gdl.version(gdls, comments)

        client.logout
      end
    end # Gdl
  end
end # AdminModule

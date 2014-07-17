##############################################################################
# File::    gdl.rb
# Purpose:: filedescription
#
# Author::    Jeff McAffee 2014-06-28
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AdminModule
  class Gdl < Thor
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

  private

    def credentials
      config = AdminModule.configuration
      user, pass = config.user_credentials
      if user.nil? || pass.nil?
        user = ask "username for #{config.current_env} environment:"
        pass = ask "password:"
      end
      [user, pass]
    end

    def client
      return @client unless @client.nil?

      @client = AdminModule.client
      @client.env = options[:environment] unless options[:environment].nil?

      user, pass = credentials
      if user.empty? || pass.empty?
        say "aborting deploy", :red
        return
      end

      @client.user = user
      @client.password = pass
      @client
    end
  end # Gdl
end # AdminModule

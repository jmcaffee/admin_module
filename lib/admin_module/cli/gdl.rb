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
=begin
  ##
  # Deploy an array of source files to the current environment.
  #
  # +source_files+ array of files, each file's basename must be in the configured aliases.
  # +comments+ to be added to Version Notes area. Defaults to 'auto upload'

  def deploy_files source_files, comments = nil
    source_files.each do |src|
      deploy src, File.basename(src, '.xml'), comments
    end
  end

  ##
  # Deploy a source file to a guideline in the current environment.
  #
  # +source_file+ full path to xml file to upload
  # +gdl_name_or_alias+ guideline name (or alias) to version
  # +comments+ to be added to Version Notes area. Defaults to 'auto upload'

  def old_deploy source_file, gdl_name_or_alias, comments = nil
    source_file = Array(source_file)[0]
    raise IOError.new("Missing source file [#{source_file}]") unless File.exists? source_file
    source_file = File.expand_path(source_file)

    gdl_name_or_alias = File.basename(source_file, '.xml') if gdl_name_or_alias.nil?

    login

    gdl_name = alias_to_name(gdl_name_or_alias)

    gdl_page_url = GuidelinesPage.new(browser, base_url).
      open_guideline(gdl_name)

    version_gdl_url = GuidelinePage.new(browser, gdl_page_url).
      add_version()

    GuidelineVersionPage.new(browser, version_gdl_url).
      upload(source_file, comments)
  end

  ##
  # Retrieve a guideline name from the configured aliases

  def alias_to_name gdl_name_or_alias
    aliases = AdminModule.configuration.aliases

    gdl_name = aliases[gdl_name_or_alias]
    gdl_name = gdl_name_or_alias if gdl_name.nil?

    gdl_name
  end

  ###
  # Version all guidelines

  def version_all gdl_names, comments = nil
    login

    version_all_page_url = GuidelinesPage.new(browser, base_url).version_all
    page = GuidelinesVersionAllPage.new(browser, version_all_page_url)

    page.version gdl_names, comments
  end
=end
end # CLI::GuidelineCommand
end # AdminModule

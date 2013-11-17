##############################################################################
# File::    cli.rb
# Purpose:: filedescription
# 
# Author::    Jeff McAffee 11/15/2013
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

class AdminModule::CLI
  include AdminModule::Pages


  def initialize
    # Make sure the configuration has been initialized.
    AdminModule.configure
  end

  ##
  # Set the current environment

  def environment=(env)
    @env = env
  end

  ##
  # Return the current environment

  def environment
    @env ||= AdminModule.configuration.default_environment
    @env
  end

  ##
  # Return the credentials for the current environment

  def credentials
    return AdminModule.configuration.credentials[environment]
  end

  ##
  # Return the base url for the current environment

  def base_url
    return AdminModule.configuration.base_urls[environment]
  end

  ##
  # Login to the Admin Module
  #
  # If we're already logged in, do nothing unless the +force+ flag is true.
  #
  # +force+ force a re-login if we've already logged in

  def login(force = false)
    if force || @login_page.nil?
      @login_page = LoginPage.new(browser, base_url)
      @login_page.login_as(*credentials)
    end

    @login_page
  end

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

  def deploy source_file, gdl_name_or_alias, comments = nil
    raise IOError.new("Missing source file [#{source_file}]") unless File.exists? source_file
    source_file = File.expand_path(source_file)

    login

    gdl_name = gdl_name_from_alias(gdl_name_or_alias)

    gdl_page_url = GuidelinesPage.new(browser, base_url).
      open_guideline(gdl_name)

    version_gdl_url = GuidelinePage.new(browser, gdl_page_url).
      add_version()

    GuidelineVersionPage.new(browser, version_gdl_url).
      upload(source_file, comments)
  end

  ##
  # Retrieve a guideline name from the configured aliases

  def gdl_name_from_alias gdl_name_or_alias
    aliases = AdminModule.configuration.aliases

    gdl_name = aliases[gdl_name_or_alias]
    gdl_name = gdl_name_or_alias if gdl_name.nil?

    gdl_name
  end

  ##
  # Close the browser

  def quit
    @browser.close unless @browser.nil?
  end
end

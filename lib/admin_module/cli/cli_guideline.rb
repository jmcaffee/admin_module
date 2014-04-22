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
end

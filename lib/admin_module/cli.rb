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
    AdminModule.configure do |config|
      config.default_environment = env
    end
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

  ##
  # Close the browser

  def quit
    @browser.close unless @browser.nil?
  end

  ##
  # Retrieve lock configuration data from the current environment

  def get_lock lock_name
    login

    begin
      lock_def_url = LockDefinitionsPage.new(browser, base_url).
        modify_lock(lock_name)
    rescue Watir::Exception::NoValueFoundException => e
      raise ArgumentError, "Lock [#{lock_name}] not found.\n\n#{e.message}"
    end

    lock_data = LockDefinitionPage.new(browser, lock_def_url).get_lock_data
  end

  ##
  # Return a list of lock names in the current environment

  def current_lock_names
    login
    LockDefinitionsPage.new(browser, base_url).locks_options
  end

  ##
  # Return configuration data for all locks in the current environment

  def all_locks
    locks = {}

    current_lock_names.each do |name|
      locks[name] = get_lock(name)
    end

    locks
  end

  ##
  # Test lock data structure for validity
  #
  # Required:
  #   at least 1 parameter OR dts

  def valid_lock_data? lock_data
    if !lock_data.key?(:parameters) || lock_data[:parameters].empty?
      if !lock_data.key?(:dts) || lock_data[:dts].empty?
        return false
      end
    end
    true
  end

  ##
  # Test lock data structure for valid name
  #

  def lock_data_has_name? lock_data
    return false unless lock_data.key?(:name)
    return false if lock_data[:name].empty?
    true
  end

  ##
  # Create a lock in the current environment

  def create_lock lock_data
    raise ArgumentError, "Invalid lock data: #{lock_data.inspect}" unless valid_lock_data?(lock_data)
    raise ArgumentError, "Missing lock name: #{lock_data.inspect}" unless lock_data_has_name?(lock_data)

    login

    lock_def_url = LockDefinitionsPage.new(browser, base_url).
      create_lock(lock_data)

    LockDefinitionPage.new(browser, lock_def_url).set_lock_data lock_data
  end

  ##
  # Modify an existing lock in the current environment

  def modify_lock lock_data, lock_name = nil
    lock_name ||= lock_data[:name]
    raise ArgumentError, "Invalid lock data: #{lock_data.inspect}" unless valid_lock_data?(lock_data)
    raise ArgumentError, "Missing lock name" if (lock_name.nil? || lock_name.empty?)

    # Make sure we populate the data's name param if empty so we don't try to write
    # and save an empty name.
    if lock_data[:name].nil? || lock_data[:name].empty?
      lock_data[:name] = lock_name
    end

    login

    lock_def_url = LockDefinitionsPage.new(browser, base_url).
      modify_lock(lock_name)

    LockDefinitionPage.new(browser, lock_def_url).set_lock_data lock_data
  end

  ##
  # Export all lock configurations in the current environment to a file.

  def export_locks file_name
    FileUtils.mkdir_p File.dirname(file_name)
    File.open(file_name, 'w') do |f|
      # Write array of lock hashes.
      f << YAML.dump(all_locks)
    end
  end

  ##
  # Import lock configurations into the current environment from a file.

  def import_locks file_name
    raise IOError, "File not found: #{file_name}" unless File.exists?(file_name)

    locks = {}
    File.open(file_name, 'r') do |f|
      # Write array of lock hashes.
      locks = YAML.load(f)
    end

    existing_locks = current_lock_names

    locks.each do |name, data|
      if existing_locks.include?(name)
        modify_lock(data, name)
      else
        create_lock(data)
      end
    end
  end

  ##
  # Export all stage data from the current environment to a file

  def export_stages file_name
    FileUtils.mkdir_p File.dirname(file_name)
    File.open(file_name, 'w') do |f|
      # Write array of stage hashes.
      f << YAML.dump(all_stages)
    end
  end

  ##
  # Return configuration data for all stages in the current environment

  def all_stages
    stages = {}

    current_stage_names.each do |name|
      stages[name] = get_stage(name)
    end

    stages
  end

  ##
  # Return a list of stage names in the current environment

  def current_stage_names
    login
    WorkflowDetailsPage.new(browser, base_url).states_options
  end

  ##
  # Retrieve lock configuration data from the current environment

  def get_stage stage_name
    login

    begin
      workflow_details_url = WorkflowDetailsPage.new(browser, base_url).
        modify_stage(stage_name)
    rescue Watir::Exception::NoValueFoundException => e
      raise ArgumentError, "Stage [#{stage_name}] not found.\n\n#{e.message}"
    end

    stage_data = WorkflowDetailPage.new(browser, workflow_details_url).get_stage_data
  end

  ##
  # Create a new stage in the current environment

  def create_stage data
    raise ArgumentError, "Invalid stage data: #{data.inspect}" unless valid_stage_data?(data)
    raise ArgumentError, "Stage name already in use: #{data[:name]}" if current_stage_names.include?(data[:name])

    login

    workflow_details_url = WorkflowDetailsPage.new(browser, base_url).
      create_stage(data)

    WorkflowDetailPage.new(browser, workflow_details_url).set_stage_data data
  end

  ##
  # Delete a stage in the current environment

  def delete_stage data
    name = data
    if data.class == Hash
      raise ArgumentError, "Invalid stage data: #{data.inspect}" unless valid_stage_data?(data)
      name = data[:name]
    end
    raise ArgumentError, "Stage name does not exist: #{name}" if !current_stage_names.include?(name)

    login

    workflow_details_url = WorkflowDetailsPage.new(browser, base_url).
      delete_stage(name)
  end

  ##
  # Test stage data structure for validity
  #
  # Required: name

  def valid_stage_data? data
    if !data.key?(:name) || data[:name].nil? || data[:name].empty?
      return false
    end
    true
  end

  ##
  # Modify an existing stage in the current environment

  def modify_stage data, stage_name = nil
    stage_name ||= data[:name]
    raise ArgumentError, "Missing stage name" if (stage_name.nil? || stage_name.empty?)
    data[:name] ||= stage_name
    raise ArgumentError, "Invalid stage data: #{data.inspect}" unless valid_stage_data?(data)

    # Make sure we populate the data's name param if empty so we don't try to write
    # and save an empty name.
    if data[:name].nil? || data[:name].empty?
      data[:name] = stage_name
    end

    login

    workflow_details_url = WorkflowDetailsPage.new(browser, base_url).
      modify_stage(stage_name)

    WorkflowDetailPage.new(browser, workflow_details_url).set_stage_data data
  end

  ##
  # Import stage configurations into the current environment from a file.

  def import_stages file_name
    raise IOError, "File not found: #{file_name}" unless File.exists?(file_name)

    stages = {}
    File.open(file_name, 'r') do |f|
      stages = YAML.load(f)
    end

    existing_stages = current_stage_names

    stages.each do |name, data|
      if existing_stages.include?(name)
        modify_stage(data, name)
      else
        create_stage(data)
      end
    end
  end

  ###
  # Return a list of all rules in the environment. This does not include
  # powerlookup rules.

  def get_rules
    login

    rules = RulesPage.new(browser, base_url).get_rules
  end

  ###
  # Rename an existing rule

  def rename_rule old_name, new_name
    raise ArgumentError, "old name cannot be blank" if (old_name.nil? || old_name.empty?)
    raise ArgumentError, "new name cannot be blank" if (new_name.nil? || new_name.empty?)

    login

    rule_page_url = RulesPage.new(browser, base_url).open_rule(old_name)
    rule_page = RulePage.new(browser, rule_page_url)
    rule_page.set_name(new_name)
    rule_page.save

  end
end

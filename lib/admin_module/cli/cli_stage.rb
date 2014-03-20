##############################################################################
# File::    cli_stage.rb
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
end

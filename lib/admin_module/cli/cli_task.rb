##############################################################################
# File::    cli_task.rb
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
  # Retrieve task configuration data from the current environment

  def get_task task_name
    login

    begin
      task_def_url = TaskDefinitionsPage.new(browser, base_url).
        modify_task(task_name)
    rescue Watir::Exception::NoValueFoundException => e
      raise ArgumentError, "Task [#{task_name}] not found.\n\n#{e.message}"
    end

    task_data = WorkflowTasksPage.new(browser, task_def_url).get_task_data
  end

  ##
  # Return a list of task names in the current environment

  def current_task_names
    login
    TaskDefinitionsPage.new(browser, base_url).tasks_options
  end

  ##
  # Return configuration data for all tasks in the current environment

  def all_tasks
    tasks = {}

    current_task_names.each do |name|
      tasks[name] = get_task(name)
    end

    tasks
  end

  ##
  # Test task data structure for validity
  #
  # Required:
  #   at least 1 parameter OR dts

  def valid_task_data? task_data
    if !task_data.key?(:parameters) || task_data[:parameters].empty?
      if !task_data.key?(:dts) || task_data[:dts].empty?
        return false
      end
    end
    true
  end

  ##
  # Test task data structure for valid name
  #

  def task_data_has_name? task_data
    return false unless task_data.key?(:name)
    return false if task_data[:name].empty?
    true
  end

  ##
  # Create a task in the current environment

  def create_task task_data
    raise ArgumentError, "Invalid task data: #{task_data.inspect}" unless valid_task_data?(task_data)
    raise ArgumentError, "Missing task name: #{task_data.inspect}" unless task_data_has_name?(task_data)

    login

    task_def_url = TaskDefinitionsPage.new(browser, base_url).
      create_task(task_data)

    WorkflowTasksPage.new(browser, task_def_url).set_task_data task_data
  end

  ##
  # Modify an existing task in the current environment

  def modify_task task_data, task_name = nil
    task_name ||= task_data[:name]
    raise ArgumentError, "Invalid task data: #{task_data.inspect}" unless valid_task_data?(task_data)
    raise ArgumentError, "Missing task name" if (task_name.nil? || task_name.empty?)

    # Make sure we populate the data's name param if empty so we don't try to write
    # and save an empty name.
    if task_data[:name].nil? || task_data[:name].empty?
      task_data[:name] = task_name
    end

    login

    task_def_url = TaskDefinitionsPage.new(browser, base_url).
      modify_task(task_name)

    WorkflowTasksPage.new(browser, task_def_url).set_task_data task_data
  end

  ##
  # Export all task configurations in the current environment to a file.

  def export_tasks file_name
    FileUtils.mkdir_p File.dirname(file_name)
    File.open(file_name, 'w') do |f|
      # Write array of task hashes.
      f << YAML.dump(all_tasks)
    end
  end

  ##
  # Import task configurations into the current environment from a file.

  def import_tasks file_name
    raise IOError, "File not found: #{file_name}" unless File.exists?(file_name)

    tasks = {}
    File.open(file_name, 'r') do |f|
      # Write array of task hashes.
      tasks = YAML.load(f)
    end

    existing_tasks = current_task_names

    tasks.each do |name, data|
      if existing_tasks.include?(name)
        modify_task(data, name)
      else
        create_task(data)
      end
    end
  end
end

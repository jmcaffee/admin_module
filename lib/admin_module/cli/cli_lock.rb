##############################################################################
# File::    cli_lock.rb
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
end

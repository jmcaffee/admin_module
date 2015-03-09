##############################################################################
# File::    locks.rb
# Purpose:: Interface to locks functionality in admin module
# 
# Author::    Jeff McAffee 2014-07-18
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

module AdminModule

  class Locks
    attr_reader :page_factory

    def initialize(page_factory)
      @page_factory = page_factory
    end

    def rename src, dest
      src = assert_lock_exists( extract_lock_name(src) )
      dest = assert_lock_does_not_exist( extract_lock_name(dest) )

      locks_page
        .modify(src)
        .set_name(dest)
        .save
    end

    def list
      locks_page.get_locks
    end

    def create lock
      lock_name = assert_lock_does_not_exist( extract_lock_name(lock) )

      locks_page
        .add
        .set_lock_data lock
        .save
    end

    def read lock
      lock_name = assert_lock_exists( extract_lock_name(lock) )

      locks_page
        .modify( lock_name )
        .get_lock_data
    end

    def update lock
      lock_name = assert_lock_exists( extract_lock_name(lock) )

      locks_page
        .modify( lock_name )
        .set_lock_data lock
    end

    #
    # No functionality exists to DELETE locks.
    #

    def export file_path
      locks = list
      export_data = {}

      locks.each do |lock|
        export_data[lock] = read lock
      end

      File.open(file_path, 'w') do |f|
        f.write export_data.to_yaml
      end

    rescue Exception => e
      if e.message.include? 'No such file or directory'
        raise IOError, "No such directory - #{file_path}"
      else
        raise e
      end
    end

    ##
    # Import lock configurations into the current environment from a file.

    def import file_path
      raise IOError, "File not found: #{file_path}" unless File.exists?(file_path)

      locks = {}
      File.open(file_path, 'r') do |f|
        # Read array of lock hashes.
        locks = YAML.load(f)
      end

      existing_locks = list

      locks.each do |name, data|
        if existing_locks.include?(name)
          update(data)
        else
          create(data)
        end
      end
    end

  private

    def locks_page
      page_factory.locks_page
    end

    def extract_lock_name lock
      lock_name = if lock.is_a? Hash
                    lock[:name]
                  else
                    String(lock)
                  end
    end

    def assert_lock_exists lock_name
      unless list.include? lock_name
        fail ArgumentError.new("A lock named '#{lock_name}' does not exist")
      end

      lock_name
    end

    def assert_lock_does_not_exist lock_name
      if list.include? lock_name
        fail ArgumentError.new("A lock named '#{lock_name}' already exists")
      end

      lock_name
    end
  end # class Locks
end # module

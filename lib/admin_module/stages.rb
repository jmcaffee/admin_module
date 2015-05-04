##############################################################################
# File::    stages.rb
# Purpose:: filedescription
# 
# Author::    Jeff McAffee 2015-03-09
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

module AdminModule

  class Stages
    attr_reader :page_factory

    def initialize page_factory
      @page_factory = page_factory
    end

    ##
    # Return a list of stage names

    def list
      stages_page.get_stages
    end

    ##
    # Retrieve stage configuration data for an existing stage

    def read name
      stages_page
        .modify(name)
        .get_stage_data
    end

    ##
    # Update stage configuration data for an existing stage

    def update name, data
      stages_page
        .modify(name)
        .set_stage_data(data)
        .save
    end

    ##
    # Create stage configuration data for a new stage

    def create data
      # When creating a stage, we need to set its name and save it so
      # an ID is created in the database to tie the tasks to.
      #
      # Foreign key errors will result otherwise.
      stages_page
        .add
        .set_name(data[:name])
        .save

      # Now, populate the rest of the data.
      stages_page
        .add
        .set_stage_data(data)
        .save
    end

    ##
    # Delete a stage

    def delete name
      assert_stage_exists name

      stages_page
        .delete name
    end

    def rename src, dest
      assert_stage_exists src
      assert_stage_does_not_exist dest

      stages_page
        .modify(src)
        .set_name(dest)
        .save
    end

    ##
    # Export data for all stages to a file

    def export file_path
      stages = list
      export_data = {}

      stages.each do |stage|
        export_data[stage] = read stage
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
    # Import stage data from a file
    #
    # If the stage name doesn't currently exist, a new stage will be created.
    # If the stage name exists, it will be updated.
    # If allow_creation is false (default) a stage will NOT be created if it
    # doesn't exist, existing stages will be updated.

    def import file_path, allow_creation = false
      raise IOError, "File not found: #{file_path}" unless File.exist? file_path

      import_data = {}
      File.open(file_path, 'r') do |f|
        # Read array of stage hashes
        # FIXME is this REALLY an array?
        import_data = YAML.load(f)
      end

      existing_stages = list

      import_data.each do |name, data|
        if existing_stages.include? name
          update name, data
        else
          if allow_creation
            create data
          else
            puts "Stage '#{name}' does not exist. Skipping import."
          end
        end
      end
    end

  private

    def stages_page
      page_factory.stages_page
    end

    def assert_stage_exists name
      fail ArgumentError.new("A stage named '#{name}' does not exist") unless list.include? name
    end

    def assert_stage_does_not_exist name
      fail ArgumentError.new("A stage named '#{name}' already exists") if list.include? name
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
  end # class
end # module

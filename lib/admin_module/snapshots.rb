##############################################################################
# File::    dc.rb
# Purpose:: Interface to DataClearing functionality in admin module1
#
# Author::    Jeff McAffee 04/01/2015
##############################################################################

require 'admin_module/pages'

module AdminModule

  class Snapshots
    attr_reader :page_factory

    def initialize page_factory
      @page_factory = page_factory
    end

    def list
      snapshot_page.get_definitions
    end

    def rename src, dest
      src = assert_definition_exists src
      dest = assert_definition_does_not_exist dest

      snapshot_page
        .modify(src)
        .set_name(dest)
        .save
    end

    def import file_path
      assert_file_exists file_path

      defns = {}
      File.open(file_path, 'r') do |f|
        # Read array of definition hashes
        defns = YAML.load(f)
      end

      existing_defns = list

      defns.each do |name, data|
        if existing_defns.include?(name)
          update(data)
        else
          create(data)
        end
      end
    end

    def export file_path
      defns = list
      export_data = {}

      defns.each do |defn|
        export_data[defn] = read defn
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

    def read name
      name = assert_definition_exists name

      snapshot_page
        .modify(name)
        .get_definition_data
    end

  private

    def snapshot_page
      page_factory.snapshot_definitions_page
    end

    def assert_definition_exists name
      unless list.include? name
        fail ArgumentError.new("A data clearing definition named '#{name}' does not exist")
      end

      name
    end

    def assert_definition_does_not_exist name
      if list.include? name
        fail ArgumentError.new("A data clearing definition named '#{name}' already exists")
      end

      name
    end

    def assert_file_exists file_path
      raise IOError, "File not found: #{file_path}" unless File.exists?(file_path)
    end

    def update data
      name = assert_definition_exists( extract_defn_name(data) )

      snapshot_page
        .modify(name)
        .set_definition_data(data)
        .save
    end

    def create data
      name = assert_definition_does_not_exist( extract_defn_name(data) )

      snapshot_page
        .add
        .set_definition_data(data)
        .save
    end

    def extract_defn_name data
      name = if data.is_a? Hash
               data[:name]
             else
               String(data)
             end
    end
  end
end # module

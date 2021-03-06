##############################################################################
# File::    ppms.rb
# Purpose:: Interface to ppms functionality in admin module
#
# Author::    Jeff McAffee 2015-06-23
#
##############################################################################

require 'admin_module/pages'

module AdminModule

  class Ppms
    attr_reader :page_factory

    def initialize(page_factory)
      @page_factory = page_factory
    end

    def list
      ppms_page.get_ppms_data
    end

    def dups
      all_ppms = ppms_page.get_ppms_with_ids

      seen = Hash.new
      duplicates = Array.new

      all_ppms.each do |pdata|
        if seen.has_key?(pdata[:name])
          duplicates << pdata
          duplicates << seen[pdata[:name]]
        end

        seen[pdata[:name]] = pdata
      end

      duplicates.sort! { |a,b| a[:name] <=> b[:name] }
    end

    def export file_path
      File.open(file_path, 'w') do |f|
        f.write list.to_yaml
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

      ppms = Array.new
      File.open(file_path, 'r') do |f|
        # Read array of PPM names
        ppms = YAML.load(f)
      end

      ppms_page
        .set_ppms_data(ppms)
        .save
    end

  private

    def ppms_page
      page_factory.ppms_page
    end
  end # class Ppms
end # module

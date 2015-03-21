##############################################################################
# File::    guideline.rb
# Purpose:: Interface to guideline functionality in admin module
# 
# Author::    Jeff McAffee 06/30/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

module AdminModule

  class Guideline
    attr_reader :page_factory

    def initialize(page_factory)
      @page_factory = page_factory
    end

    def deploy srcdir, comments = nil
      files = Pathname(srcdir).each_child.select { |f| f.file? && f.extname == '.xml' }

      files.each do |file|
        deploy_file file, comments
      end
    end

    def deploy_file xmlfile, comments = nil
      gdlname = mapped_guideline(xmlfile)

      page = guidelines_page
        .open_guideline(gdlname)
        .add_version
        .upload(xmlfile.expand_path, comments_or_default(comments))
    end

    def version gdls, comments = nil
      gdls = Array(gdls)
      page = guidelines_page
        .version_all

      gdl_list = page.get_guidelines

      version_list = []
      not_found_list = []
      gdls.each do |gdl|
        if gdl_list.include? gdl
          version_list << gdl
        else
          mapped_name = mapped_guideline gdl
          if mapped_name.nil?
            not_found_list << gdl
          else
            version_list << mapped_name
          end
        end
      end

      if not_found_list.count > 0
        puts "Can't find the following guidelines in the available list:"
        not_found_list.each do |nf|
          puts "  #{nf}"
        end
        return page
      end

      page.version(version_list, comments_or_default(comments))
    end

  private

    def guidelines_page
      page_factory.guidelines_page
    end

    def mapped_guideline xmlfile
      AdminModule.configuration.xmlmap Pathname(xmlfile).basename('.xml').to_s
    end

    def comments_or_default comments
      return AdminModule.configuration.default_comment if comments.nil? || comments.empty?
      comments
    end
  end # class Guideline
end # module

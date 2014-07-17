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
        .upload(xmlfile, comments_or_default(comments))
    end

    def version gdls, comments = nil
      page = guidelines_page
        .version_all
        .version(gdls, comments_or_default(comments))
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

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

  class BaseInterface
    include AdminModule::Pages
  end

  class Guideline
    attr_reader :page_factory

    def initialize(page_factory)
      @page_factory = page_factory
    end

    def deploy srcdir, comments
      files = Pathname(srcdir).each_child.select { |f| f.file? && f.extname == '.xml' }

      files.each do |file|
        deploy_file file, comments
      end
    end

    def deploy_file xmlfile, comments
      gdlname = mapped_guideline(xmlfile)

      page = guidelines_page
        .open_guideline(gdlname)
        .add_version
        .upload(xmlfile, comments)
    end

  private

    def guidelines_page
      page_factory.guidelines_page
    end

    def mapped_guideline xmlfile
      AdminModule.configuration.xmlmap xmlfile
    end
  end # class Guideline
end # module

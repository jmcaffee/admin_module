##############################################################################
# File::    rulesets.rb
# Purpose:: Interface to rulesets functionality in admin module
# 
# Author::    Jeff McAffee 2014-07-17
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

module AdminModule

  class Rulesets
    attr_reader :page_factory

    def initialize(page_factory)
      @page_factory = page_factory
    end

    def rename src, dest
      current_rulesets = list
      fail ArgumentError.new("A ruleset named '#{src}' does not exist") unless current_rulesets.include? src
      fail ArgumentError.new("A ruleset named '#{dest}' already exists") if current_rulesets.include? dest

      rulesets_page
        .open_ruleset(src)
        .set_name(dest)
        .save
    end

    def list
      rulesets_page.get_rulesets
    end

  private

    def rulesets_page
      page_factory.rulesets_page
    end
  end # class Rulesets
end # module

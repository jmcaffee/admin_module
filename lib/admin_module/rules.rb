##############################################################################
# File::    rules.rb
# Purpose:: Interface to rules functionality in admin module
# 
# Author::    Jeff McAffee 2014-07-17
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

module AdminModule

  class Rules
    attr_reader :page_factory

    def initialize(page_factory)
      @page_factory = page_factory
    end

    def rename src, dest
      current_rules = list
      fail ArgumentError.new("A rule named '#{src}' does not exist") unless current_rules.include? src
      fail ArgumentError.new("A rule named '#{dest}' already exists") if current_rules.include? dest

      rules_page
        .open_rule(src)
        .set_name(dest)
        .save
    end

    def list
      rules_page.get_rules
    end

    def delete rule
      current_rules = list
      fail ArgumentError.new("A rule named '#{rule}' does not exist") unless current_rules.include? rule

      rules_page
        .delete_rule rule
    end

  private

    def rules_page
      page_factory.rules_page
    end
  end # class Rules
end # module

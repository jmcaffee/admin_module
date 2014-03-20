##############################################################################
# File::    cli_ruleset.rb
# Purpose:: Ruleset methods
# 
# Author::    Jeff McAffee 11/15/2013
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

class AdminModule::CLI
  include AdminModule::Pages


  ###
  # Return a list of all rules in the environment. This does not include
  # powerlookup rules.

  def get_rules
    login

    rules = RulesPage.new(browser, base_url).get_rules
  end

  ###
  # Rename an existing rule

  def rename_rule old_name, new_name
    raise ArgumentError, "old name cannot be blank" if (old_name.nil? || old_name.empty?)
    raise ArgumentError, "new name cannot be blank" if (new_name.nil? || new_name.empty?)

    login

    rule_page_url = RulesPage.new(browser, base_url).open_rule(old_name)
    rule_page = RulePage.new(browser, rule_page_url)
    rule_page.set_name(new_name)
    rule_page.save
  end
end

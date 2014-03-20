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
  # Return a list of all rulesets in the environment.

  def get_rulesets
    login

    rulesets = RulesetsPage.new(browser, base_url).get_rulesets
  end

  ###
  # Rename an existing ruleset

  def rename_ruleset old_name, new_name
    raise ArgumentError, "old name cannot be blank" if (old_name.nil? || old_name.empty?)
    raise ArgumentError, "new name cannot be blank" if (new_name.nil? || new_name.empty?)

    login

    ruleset_page_url = RulesetsPage.new(browser, base_url).open_ruleset(old_name)
    ruleset_page = RulesetPage.new(browser, ruleset_page_url)
    ruleset_page.set_name(new_name)
    ruleset_page.save
  end
end

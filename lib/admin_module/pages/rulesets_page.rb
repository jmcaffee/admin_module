##############################################################################
# File::    rulesets_page.rb
# Purpose:: Rulesets page for AdminModule
# 
# Author::    Jeff McAffee 2014-03-17
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'
require 'nokogiri'

module AdminModule::Pages

class RulesetsPage
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(RulesetsPage)
  end

  select_list(:rulesets,
              id: 'ctl00_cntPlh_ctlRulesets_lstItems')

  button(:modify,
         id: 'ctl00_cntPlh_ctlRulesets_btnModify')

  def get_rulesets
    ruleset_list = []
    Nokogiri::HTML(@browser.html).css("select#ctl00_cntPlh_ctlRulesets_lstItems>option").each do |elem|
      ruleset_list << elem.text
    end

    ruleset_list
  end

  def open_ruleset(ruleset_name)
    #rulesets_options # List of option text
    rulesets_element.select ruleset_name
    self.modify

    clear_browser_alert

    # Return the next page object
    RulesetPage.new(@browser, false)
  end

private

  def clear_browser_alert
    if @browser.alert.exists?
      while @browser.alert.exists?
        @browser.alert.ok
      end
    end
  end
end

end # module Pages


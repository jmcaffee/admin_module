##############################################################################
# File::    rules_page.rb
# Purpose:: Rules page for AdminModule
# 
# Author::    Jeff McAffee 2014-03-17
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'
require 'nokogiri'

module AdminModule::Pages

class RulesPage
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(RulesPage)
  end

  select_list(:rules,
              id: 'ctl00_cntPlh_ctlRules_lstItems')

  button(:modify,
         id: 'ctl00_cntPlh_ctlRules_btnModify')

  button(:delete,
         id: 'ctl00_cntPlh_ctlRules_btnDelete')

  def get_rules
    rule_list = []
    Nokogiri::HTML(@browser.html).css("select#ctl00_cntPlh_ctlRules_lstItems>option").each do |elem|
      rule_list << elem.text
    end

    rule_list
  end

  def open_rule(rule_name)
    #rules_options # List of option text
    rules_element.select rule_name
    self.modify

    clear_browser_alert

    # Return the url of the landing page.
    current_url
  end

  def delete_rule(rule_name)
    #rules_options # List of option text
    rules_element.select rule_name
    self.delete

    clear_browser_alert

    # Return the url of the landing page.
    current_url
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


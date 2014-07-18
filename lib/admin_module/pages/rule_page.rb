##############################################################################
# File::    rule_page.rb
# Purpose:: Rule page for AdminModule
# 
# Author::    Jeff McAffee 2014-03-17
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'

module AdminModule::Pages

class RulePage
  include PageObject

  #page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(RulePage)
  end

  text_field(:rule_name,
             id: 'txtRuleName')

  button(:save_button,
         id: 'btnRuleSave')

  button(:cancel_button,
         id: 'btnRuleCancel')

  def set_name new_name
    clear_browser_alert

    self.rule_name = new_name
    # Return self as page object.
    self
  end

  def save
    clear_browser_alert

    self.save_button

    # Return the next page object.
    RulesPage.new(@browser, false)
  end

  def cancel
    clear_browser_alert

    self.cancel_button

    # Return the next page object.
    RulesPage.new(@browser, false)
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


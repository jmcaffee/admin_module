##############################################################################
# File::    ruleset_page.rb
# Purpose:: Ruleset page for AdminModule
# 
# Author::    Jeff McAffee 2014-03-17
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'

module AdminModule::Pages

class RulesetPage
  include PageObject

  #page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(RulesetPage)
  end

  text_field(:ruleset_name,
             id: 'ctl00_cntPlh_txtName')

  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')

  def set_name new_name
    clear_browser_alert

    self.ruleset_name = new_name

    self
  end

  def save
    clear_browser_alert

    self.save_button
    RulesetsPage.new(@browser, false)
  end

  def cancel
    clear_browser_alert

    self.cancel_button
    RulesetsPage.new(@browser, false)
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


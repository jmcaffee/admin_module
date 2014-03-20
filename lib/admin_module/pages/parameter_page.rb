##############################################################################
# File::    parameter_page.rb
# Purpose:: Parameter page for AdminModule
# 
# Author::    Jeff McAffee 2014-03-19
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'
require 'nokogiri'

module AdminModule::Pages

class ParameterPage
  include PageObject

  #page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(ParameterPage)
  end

  text_field(:parameter_name,
              id: 'ctl00_cntPlh_txtParamName')

  select_list(:parameter_type,
              id: 'ctl00_cntPlh_cboParameterType')

  select_list(:decision_parameter,
              id: 'ctl00_cntPlh_cboDecisionParameter')

  text_field(:parameter_order,
              id: 'ctl00_cntPlh_txtOrder')

  select_list(:precision,
              id: 'ctl00_cntPlh_ddlPrecision')

  checkbox(:include_in_application_xml,
              id: 'ctl00_cntPlh_chkIncludeInAppXML')

  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')

  def save
    self.save_button
  end

  def cancel
    self.cancel_button
  end

  def update_parameter(params)
    require 'pry'; binding.pry
    
  end
end # class ParameterPage

end # module Pages


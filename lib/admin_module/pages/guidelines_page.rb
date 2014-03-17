##############################################################################
# File::    guidelines_page.rb
# Purpose:: Guidelines page for AdminModule
# 
# Author::    Jeff McAffee 11/15/2013
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'

module AdminModule::Pages

class GuidelinesPage
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(GuidelinesPage)
  end

  select_list(:guidelines,
              id: 'ctl00_cntPlh_ctlGuidelines_lstItems')

  button(:modify,
         id: 'ctl00_cntPlh_ctlGuidelines_btnModify')

  button(:version_all_button,
         text: 'Version All')

  def open_guideline(gdl_name)
    #guidelines_options # List of option text
    guidelines_element.select gdl_name
    self.modify

    # Return the url of the landing page.
    current_url
  end

  def version_all
    version_all_button

    current_url
  end


end

end # module Pages


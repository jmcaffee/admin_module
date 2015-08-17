##############################################################################
# File::    parameters_page.rb
# Purpose:: Parameters page for AdminModule
#
# Author::    Jeff McAffee 2014-03-19
#
##############################################################################
require 'page-object'
require 'nokogiri'

module AdminModule::Pages

class ParametersPage
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(ParametersPage)
  end

  select_list(:parameters,
              id: 'ctl00_cntPlh_ctlParameters_lstItems')

  button(:modify,
         id: 'ctl00_cntPlh_ctlParameters_btnModify')

  def edit_parameter(var_name)
    parameters_element.select var_name
    self.modify

    # Return the url of the landing page.
    current_url
  end

  def get_parameters
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_ctlParameters_lstItems > option').each do |elem|
      vars << elem.text
    end
    vars
  end
end

end # module Pages


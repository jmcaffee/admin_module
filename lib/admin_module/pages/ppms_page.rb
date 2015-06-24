##############################################################################
# File::    ppms_page.rb
# Purpose:: PPM configuration page for AdminModule
#
# Author::    Jeff McAffee 2015-06-23
#
##############################################################################
require 'page-object'

module AdminModule::Pages

class PpmsPage
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.base_url + "/admin/security/act/parameters.aspx?act=2"
  end


  select_list(:parameters_available,
              id: 'ctl00_cntPlh_tsParameters_lstAvailable')

  select_list(:parameters_selected,
              id: 'ctl00_cntPlh_tsParameters_lstSelected')

  button(:add_parameters_button,
              id: 'ctl00_cntPlh_tsParameters_btnAdd')

  button(:add_all_parameters_button,
              id: 'ctl00_cntPlh_tsParameters_btnAddAll')

  button(:remove_parameters_button,
              id: 'ctl00_cntPlh_tsParameters_btnRemove')

  button(:remove_all_parameters_button,
              id: 'ctl00_cntPlh_tsParameters_btnRemoveAll')


  button(:save_button,
         id: 'ctl00_cntPlh_cmdSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_cmdCancel')

  def get_active_ppms
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsParameters_lstSelected > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def get_available_ppms
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsParameters_lstAvailable > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def get_ppms_with_ids
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsParameters_lstSelected > option').each do |elem|
      name = elem.text
      id = elem.attributes['value'].value
      vars << { name: name, id: id }
    end

    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsParameters_lstAvailable > option').each do |elem|
      name = elem.text
      id = elem.attributes['value'].value
      vars << { name: name, id: id }
    end

    vars
  end

  def get_ppms_data
    get_active_ppms
  end

  def set_ppms_data data
    self.remove_all_params_button
    assert_all_fields_removed self.parameters_selected_options, 'Parameters'

    data.each do |p|
      parameters_available_element.select(p)
      self.add_parameters_button
    end

    self
  end

  def save
    self.save_button
  end

private

  def assert_all_fields_removed control, label
    raise "Unable to remove #{label}" unless control.count == 0
  end
end

end # module Pages


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

  button(:add_parameter_button,
              id: 'ctl00_cntPlh_tsParameters_btnAdd')

  button(:add_all_parameters_button,
              id: 'ctl00_cntPlh_tsParameters_btnAddAll')

  button(:remove_parameter_button,
              id: 'ctl00_cntPlh_tsParameters_btnRemove')

  button(:remove_all_parameters_button,
              id: 'ctl00_cntPlh_tsParameters_btnRemoveAll')


  button(:save_button,
         id: 'ctl00_cntPlh_cmdSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_cmdCancel')

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
    get_selected_ppm_options
  end

  def set_ppms_data data
    sync_available_and_selected_lists get_available_ppm_options,
                                      parameters_available_element,
                                      get_selected_ppm_options,
                                      parameters_selected_element,
                                      add_parameter_button_element,
                                      remove_parameter_button_element,
                                      data

    self
  end

  def save
    self.save_button
  end

private

  include SelectListSyncable

  def get_available_ppm_options
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsParameters_lstAvailable > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def get_selected_ppm_options
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsParameters_lstSelected > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def assert_all_fields_removed control, label
    raise "Unable to remove #{label}" unless control.count == 0
  end
end

end # module Pages


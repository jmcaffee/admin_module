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
    avail_ppms = get_available_ppms
    active_ppms = get_active_ppms
    working_set = data.dup
    ppms_to_remove = Array.new
    ppms_to_add = Array.new

    # Build a list of indices of PPMs to remove from the selected list
    active_ppms.each_index do |i|
      if working_set.include? active_ppms[i]
        working_set.delete active_ppms[i]
      else
        ppms_to_remove << i
      end
    end

    # Build a list of indices of PPMs to add from the available list
    avail_ppms.each_index do |i|
      if working_set.include? avail_ppms[i]
        ppms_to_add << i
        working_set.delete avail_ppms[i]
      end
    end

    # Select and remove all PPMs in the removal list
    ppms_to_remove.each do |i|
      parameters_selected_element.options[i].click
    end
    self.remove_parameters_button

    # Select and add all PPMs in the add list
    ppms_to_add.each do |i|
      parameters_available_element.options[i].click
    end
    self.add_parameters_button

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


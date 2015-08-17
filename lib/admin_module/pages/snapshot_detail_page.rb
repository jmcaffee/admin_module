##############################################################################
# File::    snapshot_detail_page.rb
# Purpose:: Snapshot definition edit page for AdminModule
#
# Author::    Jeff McAffee 2015-04-05
#
##############################################################################
require 'page-object'

module AdminModule::Pages

class SnapshotDetailPage
  include PageObject

  #page_url(:get_dynamic_url)

  #def get_dynamic_url
  #  AdminModule.configuration.url(SnapshotDetailPage)
  #end

  text_field(:name,
             id: 'ctl00_cntPlh_txtName')

  text_area(:description,
            id: 'ctl00_cntPlh_txtDesc')

  select_list(:decision_data,
              id: 'ctl00_cntPlh_ddlDecision')


  # Parameters Tab
  #

  link(:parameters_tab,
        text: 'Parameters')

    select_list(:params_available,
                id: 'ctl00_cntPlh_tsParams_lstAvailable')

    select_list(:params_selected,
                id: 'ctl00_cntPlh_tsParams_lstSelected')

    button(:add_param_button,
                id: 'ctl00_cntPlh_tsParams_btnAdd')

    button(:add_all_params_button,
                id: 'ctl00_cntPlh_tsParams_btnAddAll')

    button(:remove_param_button,
                id: 'ctl00_cntPlh_tsParams_btnRemove')

    button(:remove_all_params_button,
                id: 'ctl00_cntPlh_tsParams_btnRemoveAll')


  # DTS/UDF Tab
  #

  link(:dts_tab,
        text: 'DTS/UDF')

    select_list(:dts_available,
                id: 'ctl00_cntPlh_tsSnapshotDTS_lstAvailable')

    select_list(:dts_selected,
                id: 'ctl00_cntPlh_tsSnapshotDTS_lstSelected')

    button(:add_dts_button,
                id: 'ctl00_cntPlh_tsSnapshotDTS_btnAdd')

    button(:add_all_dts_button,
                id: 'ctl00_cntPlh_tsSnapshotDTS_btnAddAll')

    button(:remove_dts_button,
                id: 'ctl00_cntPlh_tsSnapshotDTS_btnRemove')

    button(:remove_all_dts_button,
                id: 'ctl00_cntPlh_tsSnapshotDTS_btnRemoveAll')


  # Snapshot Control Fields Tab
  #

  link(:control_fields_tab,
        text: 'Snapshot Control Fields')

    select_list(:control_fields_available,
                id: 'ctl00_cntPlh_tsSnapshotControls_lstAvailable')

    select_list(:control_fields_selected,
                id: 'ctl00_cntPlh_tsSnapshotControls_lstSelected')

    button(:add_control_field_button,
                id: 'ctl00_cntPlh_tsSnapshotControls_btnAdd')

    button(:add_all_control_fields_button,
                id: 'ctl00_cntPlh_tsSnapshotControls_btnAddAll')

    button(:remove_control_field_button,
                id: 'ctl00_cntPlh_tsSnapshotControls_btnRemove')

    button(:remove_all_control_fields_button,
                id: 'ctl00_cntPlh_tsSnapshotControls_btnRemoveAll')


  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')

  def get_definition_data
    data = { name: self.name,
              description: self.description,
              parameters: [],
              dts: [],
              control_fields: [],
    }

    self.parameters_tab
    data[:parameters] = get_selected_parameter_options

    self.dts_tab
    data[:dts] = get_selected_dts_options

    self.control_fields_tab
    data[:control_fields] = self.control_fields_selected_options

    data
  end

  def set_definition_data data
    self.name = data[:name]
    self.description = data[:description]

    self.parameters_tab
    set_parameter_fields data[:parameters]

    self.dts_tab
    set_dts_fields data[:dts]

    self.control_fields_tab
    set_control_fields data[:control_fields]

    self
  end

  def save
    self.save_button
  end

  def set_name name
    self.name = name

    self
  end

private

  include SelectListSyncable

  def get_available_parameter_options
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsParams_lstAvailable > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def get_selected_parameter_options
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsParams_lstSelected > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def get_available_dts_options
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsSnapshotDTS_lstAvailable > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def get_selected_dts_options
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsSnapshotDTS_lstSelected > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def get_available_control_field_options
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsSnapshotControls_lstAvailable > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def get_selected_control_field_options
    vars = []
    Nokogiri::HTML(@browser.html).css('#ctl00_cntPlh_tsSnapshotControls_lstSelected > option').each do |elem|
      vars << elem.text
    end
    vars
  end

  def set_parameter_fields data
    sync_available_and_selected_lists get_available_parameter_options,
                                      params_available_element,
                                      get_selected_parameter_options,
                                      params_selected_element,
                                      add_param_button_element,
                                      remove_param_button_element,
                                      data
  end

  def set_dts_fields data
    sync_available_and_selected_lists get_available_dts_options,
                                      dts_available_element,
                                      get_selected_dts_options,
                                      dts_selected_element,
                                      add_dts_button_element,
                                      remove_dts_button_element,
                                      data
  end

  def set_control_fields data
    sync_available_and_selected_lists get_available_control_field_options,
                                      control_fields_available_element,
                                      get_selected_control_field_options,
                                      control_fields_selected_element,
                                      add_control_field_button_element,
                                      remove_control_field_button_element,
                                      data
  end

  def assert_all_fields_removed control, label
    raise "Unable to remove #{label} fields" unless control.count == 0
  end
end

end # module Pages


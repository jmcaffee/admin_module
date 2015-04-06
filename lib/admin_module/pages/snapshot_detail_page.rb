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
    data[:parameters] = self.params_selected_options

    self.dts_tab
    data[:dts] = self.dts_selected_options

    self.control_fields_tab
    data[:control_fields] = self.control_fields_selected_options

    data
  end

  def set_definition_data data
    self.name = data[:name]
    self.description = data[:description]

    self.parameters_tab

    self.remove_all_params_button
    assert_all_fields_removed self.params_selected_options, 'Parameters'

    data[:parameters].each do |p|
      params_available_element.select(p)
      self.add_param_button
    end

    self.dts_tab

    self.remove_all_dts_button
    assert_all_fields_removed self.dts_selected_options, 'DTS'

    data[:dts].each do |d|
      dts_available_element.select(d)
      self.add_dts_button
    end

    self.control_fields_tab

    self.remove_all_control_fields_button
    assert_all_fields_removed self.control_fields_selected_options, 'Control Fields'

    data[:control_fields].each do |f|
      control_fields_available_element.select(f)
      self.add_control_field_button
    end

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

  def assert_all_fields_removed control, label
    raise "Unable to remove #{label} fields" unless control.count == 0
  end
end

end # module Pages


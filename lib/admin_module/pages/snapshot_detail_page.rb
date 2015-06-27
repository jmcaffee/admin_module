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

  def sync_available_and_selected_lists available_items, available_element, selected_items, selected_element, add_btn, remove_btn, items_to_select
    working_set = items_to_select.dup
    items_to_remove = Array.new
    items_to_add = Array.new

    # Build a list of indices of items to remove from the selected list
    selected_items.each_index do |i|
      if working_set.include? selected_items[i]
        working_set.delete selected_items[i]
      else
        items_to_remove << i
      end
    end

    # Build a list of indices of items to add from the available list
    available_items.each_index do |i|
      if working_set.include? available_items[i]
        items_to_add << i
        working_set.delete available_items[i]
      end
    end

    # Select and remove all params in the removal list
    items_to_remove.each do |i|
      selected_element.options[i].click
    end
    remove_btn.click if items_to_remove.count > 0

    # Select and add all params in the add list
    items_to_add.each do |i|
      available_element.options[i].click
    end
    add_btn.click if items_to_add.count > 0
  end

  def set_parameter_fields data
    sync_available_and_selected_lists get_available_parameter_options,
                                      params_available_element,
                                      get_selected_parameter_options,
                                      params_selected_element,
                                      add_params_button_element,
                                      remove_params_button_element,
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

  def depset_parameter_fields data
    avail_params = get_available_parameter_options
    selected_params = get_selected_parameter_options
    working_set = data.dup
    params_to_remove = Array.new
    params_to_add = Array.new

    # Build a list of indices of params to remove from the selected list
    selected_params.each_index do |i|
      if working_set.include? selected_params[i]
        working_set.delete selected_params[i]
      else
        params_to_remove << i
      end
    end

    # Build a list of indices of params to add from the available list
    avail_params.each_index do |i|
      if working_set.include? avail_params[i]
        params_to_add << i
        working_set.delete avail_params[i]
      end
    end

    # Select and remove all params in the removal list
    params_to_remove.each do |i|
      params_selected_element.options[i].click
    end
    self.remove_params_button if params_to_remove.count > 0

    # Select and add all params in the add list
    params_to_add.each do |i|
      params_available_element.options[i].click
    end
    self.add_params_button if params_to_add.count > 0
  end

  def depset_dts_fields data
    avail_dts = get_available_dts_options
    selected_dts = get_selected_dts_options
    working_set = data.dup
    dts_to_remove = Array.new
    dts_to_add = Array.new

    # Build a list of indices of dts to remove from the selected list
    selected_dts.each_index do |i|
      if working_set.include? selected_dts[i]
        working_set.delete selected_dts[i]
      else
        dts_to_remove << i
      end
    end

    # Build a list of indices of dts to add from the available list
    avail_dts.each_index do |i|
      if working_set.include? avail_dts[i]
        dts_to_add << i
        working_set.delete avail_dts[i]
      end
    end

    # Select and remove all dts in the removal list
    dts_to_remove.each do |i|
      dts_selected_element.options[i].click
    end
    self.remove_dts_button if dts_to_remove.count > 0

    # Select and add all dts in the add list
    dts_to_add.each do |i|
      dts_available_element.options[i].click
    end
    self.add_dts_button if dts_to_add.count > 0
  end

  def assert_all_fields_removed control, label
    raise "Unable to remove #{label} fields" unless control.count == 0
  end
end

end # module Pages


##############################################################################
# File::    lock_definition.rb
# Purpose:: Lock edit page for AdminModule
#
# Author::    Jeff McAffee 2013-11-22
#
##############################################################################
require 'page-object'

module AdminModule::Pages

class LockDefinitionPage
  include PageObject

  #page_url(:get_dynamic_url)

  #def get_dynamic_url
  #  AdminModule.configuration.url(GuidelinePage)
  #end

  text_field(:name,
             id: 'ctl00_cntPlh_txtName')

  text_area(:description,
            id: 'ctl00_cntPlh_txtDesc')

  checkbox(:is_program_lock,
           id: 'ctl00_cntPlh_chkViewType')

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


  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')

  def get_lock_data
    lock_data = { name: self.name,
                  description: self.description,
                  is_program_lock: self.is_program_lock_checked? }

    self.parameters_tab
    lock_data[:parameters] = get_selected_parameter_options

    self.dts_tab
    lock_data[:dts] = get_selected_dts_options

    lock_data
  end

  def set_lock_data lock_data
    self.name = lock_data[:name]
    self.description = lock_data[:description]
    self.check_is_program_lock if lock_data[:is_program_lock] == true
    self.uncheck_is_program_lock if lock_data[:is_program_lock] == false

    self.parameters_tab
    set_parameter_fields lock_data[:parameters]

    self.dts_tab
    set_dts_fields lock_data[:dts]

    self
  end

  def save
    self.save_button
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

  def assert_all_params_removed
    raise "Unable to remove parameters" unless get_selected_parameter_options.count == 0
  end

  def assert_all_dts_fields_removed
    raise "Unable to remove DTS fields" unless get_selected_dts_options.count == 0
  end
end

end # module Pages


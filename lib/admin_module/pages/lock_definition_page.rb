##############################################################################
# File::    lock_definition.rb
# Purpose:: Lock edit page for AdminModule
# 
# Author::    Jeff McAffee 2013-11-22
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
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

    button(:remove_all_param_button,
                id: 'ctl00_cntPlh_tsParams_btnRemoveAll')

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


  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')

  def get_lock_data
    lock_data = { name: self.name,
                  description: self.description,
                  is_program_lock: self.is_program_lock_checked? }

    self.parameters_tab
    lock_data[:parameters] = self.params_selected_options
    #require 'pry'; binding.pry
    
    self.dts_tab
    lock_data[:dts] = self.dts_selected_options

    lock_data
  end

  def set_lock_data lock_data
    self.name = lock_data[:name]
    self.description = lock_data[:description]
    self.check_is_program_lock if lock_data[:is_program_lock] == true
    self.uncheck_is_program_lock if lock_data[:is_program_lock] == false

    self.parameters_tab

    self.remove_all_param_button
    lock_data[:parameters].each do |p|
      params_available_element.select(p)
      self.add_param_button
    end

    self.dts_tab
    self.remove_all_dts_button
    lock_data[:dts].each do |d|
      dts_available_element.select(d)
      self.add_dts_button
    end

    self.save_button
  end
end

end # module Pages


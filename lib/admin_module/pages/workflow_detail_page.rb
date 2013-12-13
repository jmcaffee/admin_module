##############################################################################
# File::    workflow_detail_page.rb
# Purpose:: Stage detail page for AdminModule
# 
# Author::    Jeff McAffee 2013-12-12
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'

module AdminModule::Pages

class WorkflowDetailPage
  include PageObject

  #page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(WorkflowDetailPage)
  end

  # Tabs
  link(:details_tab,
        text: 'Details')

  link(:transition_reasons_tab,
        text: 'Transition Reasons')

  link(:transition_to_states_tab,
        text: 'Transition To States')

  link(:groups_tab,
        text: 'Groups')

  link(:tasks_tab,
        text: 'Tasks')

  link(:workflow_events_tab,
        text: 'Workflow Events')

  link(:data_clearing_definitions_tab,
        text: 'Data Clearing Definitions')

  # Controls
  # Details Tab
  text_field( :name,
              id: 'ctl00_cntPlh_txtStateName')

  # Transition To States Tab
  select_list(:available_states,
              id: 'ctl00_cntPlh_tsStates_lstAvailable')

  select_list(:selected_states,
              id: 'ctl00_cntPlh_tsStates_lstSelected')

  button(:add_state_button,
         id: 'ctl00_cntPlh_tsStates_btnAdd')

  button(:add_all_states_button,
         id: 'ctl00_cntPlh_tsStates_btnAddAll')

  button(:remove_state_button,
         id: 'ctl00_cntPlh_tsStates_btnRemove')

  button(:remove_all_states_button,
         id: 'ctl00_cntPlh_tsStates_btnRemoveAll')


  # Save/Cancel buttons
  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')


  def get_stage_data
    stage_data = {}

    self.details_tab
    stage_data[:name] = self.name

    self.transition_to_states_tab
    stage_data[:transition_to] = self.selected_states_options

    stage_data
  end

  def set_stage_data data
    set_stage_name data[:name] if data.key?(:name)

    set_transitions data[:transition_to] if data.key?(:transition_to)

    self.save_button
  end

  def set_stage_name name
    self.details_tab
    self.name = name
  end

  def set_transitions trans
    self.transition_to_states_tab

    # Remove all states, then add back the requested states.
    self.remove_all_states_button
    trans.each do |t|
      available_states_element.select(t)
      self.add_state_button
    end
  end
end # class WorkflowDetailPage

end # module Pages


##############################################################################
# File::    workflow_detail_page.rb
# Purpose:: Stage detail page for AdminModule
#
# Author::    Jeff McAffee 2013-12-12
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'
require 'nokogiri'

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

  # Groups Tab

  select_list(:available_groups,
              id: 'ctl00_cntPlh_tsGroups_lstAvailable')

  select_list(:selected_groups,
              id: 'ctl00_cntPlh_tsGroups_lstSelected')

  button(:add_group_button,
         id: 'ctl00_cntPlh_tsGroups_btnAdd')

  button(:add_all_groups_button,
         id: 'ctl00_cntPlh_tsGroups_btnAddAll')

  button(:remove_group_button,
         id: 'ctl00_cntPlh_tsGroups_btnRemove')

  button(:remove_all_groups_button,
         id: 'ctl00_cntPlh_tsGroups_btnRemoveAll')

  # Tasks Tab

  select_list(:available_tasks,
              id: 'ctl00_cntPlh_tsTasks_lstAvailable')

  select_list(:selected_tasks,
              id: 'ctl00_cntPlh_tsTasks_lstSelected')

  button(:add_task_button,
         id: 'ctl00_cntPlh_tsTasks_btnAdd')

  button(:add_all_task_button,
         id: 'ctl00_cntPlh_tsTasks_btnAddAll')

  button(:remove_task_button,
         id: 'ctl00_cntPlh_tsTasks_btnRemove')

  button(:remove_all_tasks_button,
         id: 'ctl00_cntPlh_tsTasks_btnRemoveAll')

  button(:additional_details_button,
         text: 'Manage Addl Details')

  button(:screen_mappings_button,
         text: 'Manage Screen Mappings')

  button(:version_button,
         text: 'Version')

  # Data Clearing Definitions Tab

  select_list(:data_clearing_definition,
              id: 'ctl00_cntPlh_ddlDataClearing')

  text_field( :data_clearing_days,
              id: 'ctl00_cntPlh_txtDays')

  select_list(:data_clearing_days_type,
              id: 'ctl00_cntPlh_ddlDays')

  button(:version_dc_button,
         id: 'ctl00_cntPlh_btnDataVersion')

  # Errors Span

  span(:errors_span,
       id: 'ctl00_cntPlh_ctlErrors_lblError')

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

    self.groups_tab
    stage_data[:groups] = self.selected_groups_options

    stage_data[:tasks] = get_tasks

    self.workflow_events_tab
    stage_data[:events] = capture_events

    self.data_clearing_definitions_tab
    stage_data[:dc] = Hash.new
    stage_data[:dc][:definition] = self.data_clearing_definition
    stage_data[:dc][:days] = self.data_clearing_days
    stage_data[:dc][:days_type] = self.data_clearing_days_type

    stage_data
  end


    class WorkflowEvent
      attr_reader :guideline
      attr_reader :event
      attr_reader :id

      def initialize(cells)
        @event = cells[0].text.strip
        @guideline = get_selected_option(cells[1].css('select'))
        @id = cells[1].css('select').attribute('id').value
      end

      def get_selected_option elem
        elem.children.each do |c|
          if c.attributes.has_key? 'selected'
            return c.text
          end
        end
      end
    end


  def workflow_events
    events = []

    Nokogiri::HTML(@browser.html).css("table#ctl00_cntPlh_DatagridEvents").each do |tbl|
      rows = tbl.css('tr')
      rows.each do |r|
        next if r.attribute('class').value == 'GridHeader'
        cells = r.css('td')

        events << WorkflowEvent.new(cells)
      end # ech row
    end # nokogiri

    events
  end

  def capture_events
    captured_events = {}

    workflow_events.each do |ev|
      captured_events[ev.event] = ev.guideline
    end

    captured_events
  end

  def set_stage_data data
    # Set tasks first - Save button on Addl Details and/or Version button
    # causes a refresh which discards changes made in other tabs.
    set_tasks data[:tasks] if data.key?(:tasks)

    # Version button on DC tab may cause a refresh which discards changes
    # made in other tabs.
    set_data_clearing data[:dc] if data.key?(:dc)

    set_name data[:name] if data.key?(:name)

    set_transitions data[:transition_to] if data.key?(:transition_to)

    set_groups data[:groups] if data.key?(:groups)

    set_events data[:events] if data.key?(:events)

    self
  end

  def save
    self.save_button
  end

  def set_name name
    self.details_tab
    self.name = name

    self
  end

  def set_transitions trans
    self.transition_to_states_tab

    # Remove all states, then add back the requested states.
    self.remove_all_states_button
    trans.each do |t|
      available_states_element.select(t)
      self.add_state_button
    end

    self
  end

  def set_groups groups
    self.groups_tab

    # Remove all groups, then add back the requested groups.
    self.remove_all_groups_button
    groups.each do |item|
      available_groups_element.select(item)
      self.add_group_button
    end

    self
  end

  def get_tasks
    self.tasks_tab

    tasks = Array.new
    selected_tasks_options.each do |task_name|
      tasks << { name: task_name }
    end

    # Open the Addl Details page and update the settings
    self.additional_details_button
    addtl_page = WorkflowDetailTaskAddlDetailPage.new(@browser, false)

    addl_data = addtl_page.get_data
    addtl_page.cancel

    # Merge addl detail data
    tasks.collect! do |task|
      task[:sequence] = addl_data[task[:name]][:sequence]
      task[:predecessors] = addl_data[task[:name]][:predecessors]
      task[:regenerate] = addl_data[task[:name]][:regenerate]
      task
    end

    # Open the screen mappings page and update the mappings
    self.screen_mappings_button
    mappings_page = WorkflowDetailTaskMappingsPage.new(@browser, false)

    mapping_data = mappings_page.get_data
    mappings_page.back

    tasks.collect! do |task|
      task[:mapped_screens] = mapping_data[task[:name]][:mapped_screens]
      task
    end

    #  Merge mapping data in to the task data structure
    tasks
  end

  def set_tasks tasks
    self.tasks_tab

    has_existing_tasks = (selected_tasks_options.count > 0)

    if has_existing_tasks
      # Open the Addl Details page and clear all settings
      self.additional_details_button
      addtl_page = WorkflowDetailTaskAddlDetailPage.new(@browser, false)

      addtl_page.clear_data
      addtl_page.save

      self.version_button
    end

    # Remove all tasks, then add back the requested tasks.
    self.remove_all_tasks_button
    tasks.each do |task|
      available_tasks_element.select(task[:name])
    end

    if tasks.count > 0
      self.add_task_button
      # Version the added tasks before opening Addtl Details screen
      self.version_button

      # Open the Addl Details page and update the settings
      self.additional_details_button
      addtl_page = WorkflowDetailTaskAddlDetailPage.new(@browser, false)

      addtl_page.set_data tasks
      addtl_page.save

      # Open the screen mappings page and update the mappings
      self.screen_mappings_button
      mappings_page = WorkflowDetailTaskMappingsPage.new(@browser, false)

      mappings_page.set_data tasks
      mappings_page.back

      # Click the version button to save the changes
      self.version_button
    end
  end

  def set_events events
    self.workflow_events_tab

    current_events = {}
    workflow_events.each do |ev|
      current_events[ev.event] = ev
    end

    events.each do |event, gdl|
      current_event = current_events[event]

      unless current_event.nil?
        id = current_event.id
        current_gdl = current_event.guideline

        if gdl != current_gdl
          sel = select_list_elements(id: id)[0]

          unless sel.nil?
            sel.select gdl
          end
        end
      end
    end

    self
  end

  def set_data_clearing dc
    self.data_clearing_definitions_tab

    # No need to make changes if none need to be made
    return if dc[:definition].empty? && self.data_clearing_definition.empty?

    self.data_clearing_definition_element.select dc[:definition]
    self.data_clearing_days = dc[:days]
    self.data_clearing_days_type_element.select dc[:days_type]

    self.version_dc_button
  end
end # class WorkflowDetailPage

end # module Pages


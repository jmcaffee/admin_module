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

    self.workflow_events_tab
    stage_data[:events] = capture_events

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
    set_stage_name data[:name] if data.key?(:name)

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
end # class WorkflowDetailPage

end # module Pages


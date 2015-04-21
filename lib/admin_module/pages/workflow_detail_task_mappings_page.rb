##############################################################################
# File::    workflow_detail_task_mappings_page.rb
# Purpose:: Stage Task Screen Mappings page for AdminModule
#
# Author::    Jeff McAffee 2015-04-20
#
##############################################################################
require 'page-object'
require 'nokogiri'

module AdminModule::Pages

class WorkflowDetailTaskMappingsPage
  include PageObject

  #page_url(:get_dynamic_url)

  # The only access is through the Tasks tab Manage Screen Mappings button

  #def get_dynamic_url
  #  AdminModule.configuration.url(WorkflowDetailPage)
  #end

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

  button(:back_button,
         id: 'ctl00_cntPlh_btnCancel')


  def get_data
    get_tasks_details
  end

  def set_data data
    set_tasks_details data

    self
  end

  def back
    self.back_button
  end

  private

  def details_table
    table_elements[0].table_elements[1]
  end

  def get_tasks_details
    details = Hash.new

    capture_details.each do |item|
      details[item.name] = item.to_hsh
    end

    details
  end

  def set_screen_mappings btn_id, screens
    btn = button_elements(id: btn_id)[0]
    btn.click

    WorkflowDetailTaskScreensPage.new(@browser, false)
      .set_screens(screens)
      .save

    self
  end

  def set_tasks_details details
    capture_details.each do |item|
      details.each do |dtl|
        if dtl[:name] == item.name
          # We've found a match, see if the mapping screens value matches
          if item.screens != dtl[:mapped_screens]
            # Not a match, we need to change it so find the button
            set_screen_mappings item.edit_button_id, dtl[:mapped_screens]
          end

          break
        end
      end
    end

    self
  end

  class TaskDetail
    attr_accessor :sequence
    attr_accessor :name
    attr_accessor :mapped_screens
    attr_accessor :edit_button_id

    def to_hsh
      {
        sequence: @sequence,
        name: @name,
        mapped_screens: screens,
      }
    end

    def screens
      # Clean up the screens list by splitting into an array
      screens = @mapped_screens.split(', ')
      # and removing whitespace (specifically, non-breaking spaces)
      screens.collect! { |scr| scr.gsub("\u00A0",'').strip }
    end
  end

  ###
  # Build a list of objects containing task detail data.
  #
  # We use this method even though we don't need to (for get_xxx) because we'll
  # need the captured field ids for *setting* values.
  #

  def capture_details
    details = []

    Nokogiri::HTML(@browser.html).css("#ctl00_cntPlh_gvScreenMapping>tbody>tr").each do |tr|
      # Skip the header row
      next if tr['class'] == 'GridHeader'

      detail = TaskDetail.new
      detail.sequence = tr.css("td:nth-child(1)").text
      detail.name = tr.css("td:nth-child(2)").text
      detail.mapped_screens = tr.css("td:nth-child(3)").text
      detail.edit_button_id = tr.css("td:nth-child(4)>input")[0]['id']

      details << detail
    end # css

    details
  end
end # class WorkflowDetailTaskMappingsPage

end # module Pages


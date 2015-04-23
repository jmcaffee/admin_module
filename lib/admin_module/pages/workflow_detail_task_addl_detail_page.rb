##############################################################################
# File::    workflow_detail_task_addl_detail_page.rb
# Purpose:: Stage Task Additional Detail page for AdminModule
#
# Author::    Jeff McAffee 2015-04-20
#
##############################################################################
require 'page-object'
require 'nokogiri'

module AdminModule::Pages

class WorkflowDetailTaskAddlDetailPage
  include PageObject

  #page_url(:get_dynamic_url)

  # The only access is through the Tasks tab Manage Addl Details button

  #def get_dynamic_url
  #  AdminModule.configuration.url(WorkflowDetailPage)
  #end

  # Controls

  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')


  def get_data
    get_tasks_details
  end

  def set_data data
    set_tasks_details data

    self
  end

  def clear_data
    clear_tasks_details

    self
  end

  def save
    self.save_button
  end

  def cancel
    self.cancel_button
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

  def set_tasks_details details
    capture_details.each do |item|
      details.each do |dtl|
        if dtl[:name] == item.name
          # We've found a match, get the field
          txt = text_field_elements(id: item.pred_id)[0]
          # set the predecessors field to the stored value
          txt.value = dtl[:predecessors]

          # Get the checkbox field
          ck = checkbox_elements(id: item.reg_id)[0]
          # Check/uncheck it
          if dtl[:regenerate]
            ck.check
          else
            ck.uncheck
          end

          break
        end
      end
    end

    self
  end

  def clear_tasks_details
    capture_details.each do |item|
      # set the predecessors field to blank
      txt = text_field_elements(id: item.pred_id)[0]
      txt.value = ''

      # Clear the checkbox field
      ck = checkbox_elements(id: item.reg_id)[0]
      ck.uncheck
    end

    self
  end

  class TaskDetail
    attr_accessor :sequence
    attr_accessor :name
    attr_accessor :predecessors
    attr_accessor :pred_id
    attr_accessor :regenerate
    attr_accessor :reg_id

    def to_hsh
      {
        sequence: @sequence,
        name: @name,
        predecessors: @predecessors,
        regenerate: @regenerate,
      }
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

    Nokogiri::HTML(@browser.html).css("#ctl00_cntPlh_gvTask>tbody>tr").each do |tr|
      # Skip the header row
      next if tr['class'] == 'GridHeader'

      detail = TaskDetail.new
      detail.sequence = tr.css("td:nth-child(1)").text
      detail.name = tr.css("td:nth-child(2)").text
      detail.predecessors = tr.css("td:nth-child(3)>input").text
      detail.pred_id = tr.css("td:nth-child(3)>input")[0]['id']
      detail.regenerate = tr.css("td:nth-child(4)>input")[0]['checked'] == 'checked'
      detail.reg_id = tr.css("td:nth-child(4)>input")[0]['id']

      details << detail
    end # css

    details
  end
end # class WorkflowDetailTaskAddlDetailPage

end # module Pages


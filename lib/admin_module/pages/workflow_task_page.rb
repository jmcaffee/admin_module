##############################################################################
# File::    workflow_task_page.rb
# Purpose:: Task definition edit page for AdminModule
#
# Author::    Jeff McAffee 2015-04-19
#
##############################################################################
require 'page-object'

module AdminModule::Pages

class WorkflowTaskPage
  include PageObject

  #page_url(:get_dynamic_url)

  #def get_dynamic_url
  #  AdminModule.configuration.url(DcDetailPage)
  #end

  text_field(:name,
             id: 'ctl00_cntPlh_txtTaskName')

  select_list(:schedule,
              id: 'ctl00_cntPlh_ddlSchedule')

  select_list(:priority,
              id: 'ctl00_cntPlh_ddlPriority')

  text_field(:due_days,
            id: 'ctl00_cntPlh_txtDueDays')

  select_list(:due_hours,
              id: 'ctl00_cntPlh_ddlDueHours')

  select_list(:due_minutes,
              id: 'ctl00_cntPlh_ddlDueMinutes')

  select_list(:followup,
              id: 'ctl00_cntPlh_ddlFollowupOptions')

  select_list(:assignedto,
              id: 'ctl00_cntPlh_ddlScheduleFor')

  text_field(:fees,
              id: 'ctl00_cntPlh_txtFeesAssigned')

  text_area(:details,
            id: 'ctl00_cntPlh_txtTaskDescription')

  select_list(:letter_agreement,
              id: 'ctl00_cntPlh_ddlLetterAgreement')



  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')

  def get_task_data
    data = { name: self.name,
             schedule: self.schedule_element.selected_options[0],
             priority: self.priority_element.selected_options[0],
             due_days: self.due_days,
             due_hours: self.due_hours_element.selected_options[0],
             due_minutes: self.due_minutes_element.selected_options[0],
             followup: self.followup_element.selected_options[0],
             assignedto: self.assignedto_element.selected_options[0],
             fees: self.fees,
             details: self.details,
             letter_agreement: self.letter_agreement_element.selected_options[0],
    }

    data
  end

  def set_task_data data
    self.name = data[:name]
    self.schedule_element.select data[:schedule]
    self.priority_element.select data[:priority]
    self.due_days = data[:due_days]
    self.due_hours_element.select data[:due_hours]
    self.due_minutes_element.select data[:due_minutes]
    self.followup_element.select data[:followup]
    self.assignedto_element.select data[:assignedto]
    self.fees = data[:fees]
    self.details = data[:details]
    self.letter_agreement_element.select data[:letter_agreement]

    self
  end

  def save
    self.save_button
  end

  def set_name name
    self.name = name

    self
  end
end

end # module Pages


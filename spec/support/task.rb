##############################################################################
# File::    task.rb
# Purpose:: Task testing helpers
#
# Author::    Jeff McAffee 2015-04-19
#
##############################################################################

def create_task_hash name
  { name: name,
    schedule: "To-Do",
    priority: "Normal",
    due_days: 2,
    due_hours: "0",
    due_minutes: "00",
    followup: "",
    assigned_to: "Negotiator",
    fees_assigned: "0.00",
    task_description: "#{name} task description",
    letter_agreement: "",
  }
end


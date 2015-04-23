##############################################################################
# File::    workflow_detail_task_screens_page.rb
# Purpose:: Stage Task Screens detail page for AdminModule
#
# Author::    Jeff McAffee 2015-04-20
#
##############################################################################
require 'page-object'
require 'nokogiri'

module AdminModule::Pages

class WorkflowDetailTaskScreensPage
  include PageObject

  #page_url(:get_dynamic_url)

  # The only access is through the Tasks tab Manage Screen Mappings button

  #def get_dynamic_url
  #  AdminModule.configuration.url(WorkflowDetailTaskScreensPage)
  #end

  # Controls

  select_list(:available_screens,
              id: 'ctl00_cntPlh_tsTaskScreen_lstAvailable')

  select_list(:selected_screens,
              id: 'ctl00_cntPlh_tsTaskScreen_lstSelected')

  button(:add_screen_button,
         id: 'ctl00_cntPlh_tsTaskScreen_btnAdd')

  button(:add_all_screens_button,
         id: 'ctl00_cntPlh_tsTaskScreen_btnAddAll')

  button(:remove_screen_button,
         id: 'ctl00_cntPlh_tsTaskScreen_btnRemove')

  button(:remove_all_screens_button,
         id: 'ctl00_cntPlh_tsTaskScreen_btnRemoveAll')

  # Save/Cancel buttons
  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')


  def set_screens data
    # Remove all screens, then add back the requested sreens.
    self.remove_all_screens_button
    data.each do |t|
      unless t.nil? or t.empty?
        available_screens_element.select(t)
        self.add_screen_button
      end
    end

    self
  end

  def save
    self.save_button
  end

  def cancel
    self.cancel_button
  end
end # class WorkflowDetailTaskScreensPage

end # module Pages


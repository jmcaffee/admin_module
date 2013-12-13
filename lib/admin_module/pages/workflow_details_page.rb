##############################################################################
# File::    workflow_details_page.rb
# Purpose:: Guidelines page for AdminModule
# 
# Author::    Jeff McAffee 2013-12-12
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'

module AdminModule::Pages

class WorkflowDetailsPage
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(WorkflowDetailsPage)
  end

  select_list(:states,
              id: 'ctl00_cntPlh_elStates_lstItems')

  button(:add,
         id: 'ctl00_cntPlh_elStates_btnAdd')

  button(:modify,
         id: 'ctl00_cntPlh_elStates_btnModify')

  button(:delete_button,
         id: 'ctl00_cntPlh_elStates_btnDelete')

  def modify_stage stage_name
    #states_options # List of option text
    states_element.select stage_name
    self.modify

    # Return the url of the landing page.
    current_url
  end

  def create_stage data
    name = data[:name]
    raise ArgumentError, "Missing stage name" if name.nil? || name.empty?
    raise ArgumentError, "Stage name [#{name}] already exists" if states_options.include? name

    self.add

    # Return the url of the landing page.
    current_url
  end

  def delete_stage data
    name = data
    name = data[:name] if data.class == Hash
    raise ArgumentError, "Missing stage name" if name.nil? || name.empty?
    raise ArgumentError, "Stage name [#{name}] does not exist" if !states_options.include?(name)

    self.states_element.select name
    self.delete_button

    # Return the url of the landing page.
    current_url
  end
end # class WorkflowDetailsPage

end # module Pages


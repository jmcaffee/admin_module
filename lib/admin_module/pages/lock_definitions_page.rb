##############################################################################
# File::    lock_definitions_page.rb
# Purpose:: Lock Definitions page for AdminModule
# 
# Author::    Jeff McAffee 2013-11-22
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'

module AdminModule::Pages

class LockDefinitionsPage
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(LockDefinitionsPage)
  end

  select_list(:locks,
              id: 'ctl00_cntPlh_elViews_lstItems')

  button(:add,
         id: 'ctl00_cntPlh_elViews_btnAdd')

  button(:modify,
         id: 'ctl00_cntPlh_elViews_btnModify')

  def modify_lock(lock_name)
    #locks_options # List of option text
    locks_element.select lock_name
    self.modify

    # Return the url of the landing page.
    current_url
  end

  def create_lock lock_data
    name = lock_data[:name]
    raise ArgumentError, "Missing lock name" if name.nil? || name.empty?
    raise ArgumentError, "Lock name [#{name}] already exists" if locks_options.include? name

    self.add

    # Return the url of the landing page.
    current_url
  end
end

end # module Pages


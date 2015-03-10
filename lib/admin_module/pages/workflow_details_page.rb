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

    button(:add_button,
          id: 'ctl00_cntPlh_elStates_btnAdd')

    button(:modify_button,
          id: 'ctl00_cntPlh_elStates_btnModify')

    button(:delete_button,
          id: 'ctl00_cntPlh_elStates_btnDelete')

    def get_stages
      stage_list = []
      Nokogiri::HTML(@browser.html).css("select#ctl00_cntPlh_elStates_lstItems>option").each do |elem|
        stage_list << elem.text
      end

      stage_list
    end

    def modify stage_name
      states_element.select stage_name
      self.modify_button

      # Return the page object of the next page.
      WorkflowDetailPage.new(@browser, false)
    end

    def delete stage_name
      raise ArgumentError, "Missing stage name" if stage_name.nil? || stage_name.empty?
      raise ArgumentError, "Stage name '#{name}' does not exist" if !states_options.include?(stage_name)

      states_element.select stage_name
      self.delete_button

      self
    end

    def add stage_name
      raise ArgumentError, "Missing stage name" if stage_name.nil? || stage_name.empty?
      raise ArgumentError, "Stage name '#{name}' already exists" if states_options.include? stage_name

      self.add_button

      # Return the page object of the next page.
      WorkflowDetailPage.new(@browser, false)
    end
  end # class
end # module


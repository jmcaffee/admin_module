##############################################################################
# File::    workflow_tasks_page.rb
# Purpose:: Workflow Tasks page
#
#             admin/security/WorkflowTasks.aspx?act=2
#
# Author::    Jeff McAffee 2015-04-19
#
##############################################################################
require 'page-object'

module AdminModule
  module Pages
    class WorkflowTasksPage
      include PageObject

      page_url(:get_dynamic_url)

      def get_dynamic_url
        AdminModule.configuration.base_url + "/admin/security/WorkflowTasks.aspx?act=2"
      end

      button(:add_button,
            id: 'ctl00_cntPlh_btnAdd')

      button(:modify_button,
            id: 'ctl00_cntPlh_btnModify')

      button(:delete_button,
            id: 'ctl00_cntPlh_btnDelete')

      ###
      # Return an array of task names
      #

      def get_tasks
        get_tasks_and_ids.keys
      end

      ###
      # Modify a task - browses to the task details page.
      #
      # Returns the Task Details page object (so methods can be chained).
      #

      def modify name
        tasks = get_tasks_and_ids

        detail_page tasks[name]
      end

      ###
      # Add a task - browses to the 'new' task page.
      #
      # Returns the Task Details page object (so methods can be chained).
      #

      def add
        self.add_button

        # Return the page object of the next page.
        detail_page
      end

    private

      ###
      # Not used at this time, but this is a valid reference to the task details table.
      #

      def tasks_table
        table_elements[0].table_elements[1]
      end

      ###
      # Return a hash of task names and ids
      #
      # ex: { 'Some Task Name' => 24 }
      #
      # The ID can be used to edit a specific task.
      #

      def get_tasks_and_ids
        task_names = Hash.new

        Nokogiri::HTML(@browser.html).css("#ctl00_cntPlh_dgrTasks>tbody>tr").each do |tr|
          id = tr['taskid']
          name = tr.css("td:nth-child(1)").text
          task_names[name] = id
        end # css

        task_names
      end

      ###
      # Return a page object for the Task Detail page
      #
      # To edit a specific task, pass an id. The browser will navigate to the task edit url.
      #

      def detail_page id = nil
        unless id.nil?
          navigate_to AdminModule.configuration.base_url + "/admin/security/WorkflowTask.aspx?TaskID=#{id}"
        end

        WorkflowTaskPage.new(@browser, false)
      end
    end
  end
end


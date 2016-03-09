##############################################################################
# File::    pages.rb
# Purpose:: Require all Page classes
#
# Author::    Jeff McAffee 11/15/2013
#
##############################################################################

require 'watir-webdriver'
require 'ktutils/os'
require 'admin_module/pages/select_list_syncable'
require 'admin_module/pages/login_page'
require 'admin_module/pages/login_page_400'
require 'admin_module/pages/guidelines_page'
require 'admin_module/pages/guidelines_page_400'
require 'admin_module/pages/guidelines_version_all_page'
require 'admin_module/pages/guidelines_version_all_page_400'
require 'admin_module/pages/guideline_page'
require 'admin_module/pages/guideline_page_400'
require 'admin_module/pages/guideline_version_page'
require 'admin_module/pages/lock_definitions_page'
require 'admin_module/pages/lock_definition_page'
require 'admin_module/pages/workflow_details_page'
require 'admin_module/pages/workflow_detail_page'
require 'admin_module/pages/workflow_detail_task_addl_detail_page'
require 'admin_module/pages/workflow_detail_task_screens_page'
require 'admin_module/pages/workflow_detail_task_mappings_page'
require 'admin_module/pages/rules_page'
require 'admin_module/pages/rule_page'
require 'admin_module/pages/rulesets_page'
require 'admin_module/pages/ruleset_page'
require 'admin_module/pages/parameters_page'
require 'admin_module/pages/parameter_page'
require 'admin_module/pages/dc_definitions_page'
require 'admin_module/pages/dc_detail_page'
require 'admin_module/pages/snapshot_definitions_page'
require 'admin_module/pages/snapshot_detail_page'
require 'admin_module/pages/workflow_task_page'
require 'admin_module/pages/workflow_tasks_page'
require 'admin_module/pages/ppms_page'
require 'browser_loader'

module AdminModule::Pages

  class BrowserInst
    @@browser = nil

    ##
    # Return a configured browser object. If a browser has already been created,
    # this returns the existing browser.
    #
    # An +at_exit+ proc is created to close the browser when the program exits.

    def self.browser
      if ! open_browser?
        BrowserLoader::Factory.browser_timeout = AdminModule.configuration.browser_timeout
        BrowserLoader::Factory.download_dir = AdminModule.configuration.download_dir unless AdminModule.configuration.download_dir.empty?
        @@browser = BrowserLoader::Factory.build

        at_exit do
          unless ! open_browser?
            # Make sure every webdriver window is closed.
            @@browser.windows.each { |w| w.close rescue nil }
            @@browser.close rescue nil
          end
        end
      end

      @@browser
    end

    def self.open_browser?
      return (! @@browser.nil? && @@browser.exist? )
    end
  end

  ##
  # Return a configured browser object. If a browser has already been created,
  # this returns the existing browser.
  #
  # An +at_exit+ proc is created to close the browser when the program exits.

  def browser
    BrowserInst.browser
  end
end

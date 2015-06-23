##############################################################################
# File::    page_factory.rb
# Purpose:: Provides Page objects
#
# Author::    Jeff McAffee 06/30/2014
#
##############################################################################

require 'admin_module/pages'

module AdminModule
  class PageFactory
    include AdminModule::Pages

    def login_page(goto_page = true)
      return Pages::LoginPage.new(browser, goto_page)
    end

    def guidelines_page(goto_page = true)
      return Pages::GuidelinesPage.new(browser, goto_page)
    end

    def rulesets_page(goto_page = true)
      return Pages::RulesetsPage.new(browser, goto_page)
    end

    def rules_page(goto_page = true)
      return Pages::RulesPage.new(browser, goto_page)
    end

    def locks_page(goto_page = true)
      return Pages::LockDefinitionsPage.new(browser, goto_page)
    end

    def stages_page(goto_page = true)
      return Pages::WorkflowDetailsPage.new(browser, goto_page)
    end

    def dc_definitions_page(goto_page = true)
      return Pages::DcDefinitionsPage.new(browser, goto_page)
    end

    def snapshot_definitions_page(goto_page = true)
      return Pages::SnapshotDefinitionsPage.new(browser, goto_page)
    end

    def tasks_page(goto_page = true)
      return Pages::WorkflowTasksPage.new(browser, goto_page)
    end

    def ppms_page(goto_page = true)
      return Pages::PpmsPage.new(browser, goto_page)
    end
  end
end # AdminModule

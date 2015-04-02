##############################################################################
# File::    lock_definitions_page.rb
# Purpose:: Lock Definitions page for AdminModule
#
#           Note that the admin module has at least 3 pages that all reference
#           the same url with the difference being the 'type' parameter.
#
#           The Lock Defintions page has a type of 2 and account of 2:
#
#             admin/security/ViewDefinitions.aspx?type=2&Act=2
#
# Author::    Jeff McAffee 2013-11-22
#
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

    button(:add_button,
          id: 'ctl00_cntPlh_elViews_btnAdd')

    button(:modify_button,
          id: 'ctl00_cntPlh_elViews_btnModify')

    def get_locks
      lock_list = []
      Nokogiri::HTML(@browser.html).css("select#ctl00_cntPlh_elViews_lstItems>option").each do |elem|
        lock_list << elem.text
      end

      lock_list
    end

    def modify lock_name
      #locks_options # List of option text
      locks_element.select lock_name
      self.modify_button

      # Return the page object of the next page.
      detail_page
    end

    def add
      self.add_button

      # Return the page object of the next page.
      detail_page
    end

  private

    def detail_page
      LockDefinitionPage.new(@browser, false)
    end
  end # class
end # module Pages


##############################################################################
# File::    snapshot_definitions_page.rb
# Purpose:: Snapshot Definitions page
#
#           Note that the admin module has at least 3 pages that all reference
#           the same url with the difference being the 'type' parameter.
#
#           The Snapshot page has a type of 1:
#
#             admin/security/ViewDefinitions.aspx?type=1
#
# Author::    Jeff McAffee 2015-04-05
#
##############################################################################
require 'page-object'

module AdminModule
  module Pages
    class SnapshotDefinitionsPage
      include PageObject

      page_url(:get_dynamic_url)

      def get_dynamic_url
        AdminModule.configuration.base_url + "/admin/security/ViewDefinitions.aspx?type=1&Act=2"
      end

      select_list(:definitions,
                  id: 'ctl00_cntPlh_elViews_lstItems')

      button(:add_button,
            id: 'ctl00_cntPlh_elViews_btnAdd')

      button(:modify_button,
            id: 'ctl00_cntPlh_elViews_btnModify')

      button(:delete_button,
            id: 'ctl00_cntPlh_elViews_btnDelete')

      def get_definitions
        defn_list = []
        Nokogiri::HTML(@browser.html).css("select#ctl00_cntPlh_elViews_lstItems>option").each do |elem|
          defn_list << elem.text
        end

        defn_list
      end

      def modify name
        definitions_element.select name
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
        SnapshotDetailPage.new(@browser, false)
      end
    end
  end
end


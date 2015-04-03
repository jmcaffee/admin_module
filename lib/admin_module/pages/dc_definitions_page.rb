##############################################################################
# File::    dc_definitions_page.rb
# Purpose:: Data Clearing Definitions page
#
#           Note that the admin module has at least 3 pages that all reference
#           the same url with the difference being the 'type' parameter.
#
#           The DataClearing page has a type of 3:
#
#             admin/security/ViewDefinitions.aspx?type=3
#
# Author::    Jeff McAffee 04/01/2015
#
##############################################################################
require 'page-object'

module AdminModule
  module Pages
    class DcDefinitionsPage
      include PageObject

      page_url(:get_dynamic_url)

      def get_dynamic_url
        AdminModule.configuration.url(DcDefinitionsPage)
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

      def modify dc_name
        definitions_element.select dc_name
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
        DcDetailPage.new(@browser, false)
      end
    end
  end
end


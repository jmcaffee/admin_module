##############################################################################
# File::    guidelines_page.rb
# Purpose:: Guidelines page for AdminModule
#
# Author::    Jeff McAffee 11/15/2013
#
##############################################################################
require 'page-object'

module AdminModule::Pages
  class GuidelinesPage
    include PageObject

    page_url(:get_dynamic_url)

    def get_dynamic_url
      AdminModule.configuration.base_url + "/admin/decision/guidelines.aspx"
    end

    # This must be a class method so it's available for the control
    # method generation methods.
    #

    def self.gdls_id
      'ctl00_cntPlh_ctlGuidelines_lstItems'
    end

    select_list(:guidelines,
                id: gdls_id)

    button(:modify,
          id: 'ctl00_cntPlh_ctlGuidelines_btnModify')

    button(:version_all_button,
          text: 'Version All')

    def get_guidelines
      gdl_list = []
      Nokogiri::HTML(@browser.html).css("select##{GuidelinesPage.gdls_id}>option").each do |elem|
        gdl_list << elem.text
      end

      gdl_list
    end

    def open_guideline(gdl_name)
      #guidelines_options # List of option text
      guidelines_element.select gdl_name
      self.modify

      # Return the next page object.
      AdminModule::ConfigHelper.page_factory.guideline_page(false)
      #GuidelinePage.new(@browser, false)
    end

    def version_all
      version_all_button

      # Return the next page object.
      AdminModule::ConfigHelper.page_factory.guidelines_version_all_page(false)
      #GuidelinesVersionAllPage.new(@browser, false)
    end
  end
end # module Pages


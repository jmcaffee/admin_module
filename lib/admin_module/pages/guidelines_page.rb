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
    "/admin/decision/guidelines.aspx"
  end

  select_list(:guidelines,
              id: 'ctl00_cntPlh_ctlGuidelines_lstItems')

  button(:modify,
         id: 'ctl00_cntPlh_ctlGuidelines_btnModify')

  button(:version_all_button,
         text: 'Version All')

  def get_guidelines
    gdl_list = []
    Nokogiri::HTML(@browser.html).css("select#ctl00_cntPlh_ctlGuidelines_lstItems>option").each do |elem|
      gdl_list << elem.text
    end

    gdl_list
  end

  def open_guideline(gdl_name)
    #guidelines_options # List of option text
    guidelines_element.select gdl_name
    self.modify

    # Return the next page object.
    GuidelinePage.new(@browser, false)
  end

  def version_all
    version_all_button

    # Return the next page object.
    GuidelinesVersionAllPage.new(@browser, false)
  end


end

end # module Pages


##############################################################################
# File::    guideline_page.rb
# Purpose:: Guideline page for AdminModule
#
# Author::    Jeff McAffee 11/15/2013
#
##############################################################################
require 'page-object'

module AdminModule::Pages
  class GuidelinePage
    include PageObject

    #page_url(:get_dynamic_url)

    def get_dynamic_url
      AdminModule.configuration.base_url + "/admin/decision/guideline.aspx"
    end

    link(:versions,
          text: 'Versions')

    button(:add_version_button,
          id: 'cmdAddVersion')

    def add_version
      self.versions
      self.add_version_button

      # Return the next page object.
      GuidelineVersionPage.new(@browser, false)
    end
  end
end # module Pages


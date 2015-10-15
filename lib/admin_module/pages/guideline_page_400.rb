##############################################################################
# File::    guideline_page_400.rb
# Purpose:: Guideline page for AdminModule
#
# Author::    Jeff McAffee 2015-10-08
#
##############################################################################
require 'page-object'

module AdminModule::Pages
  class GuidelinePage400
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
      AdminModule::ConfigHelper.page_factory.guideline_version_page(false)
    end
  end
end # module Pages


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

    def download(dest_file_path)
      versions

      # Get the first download link.
      dl_link = link_elements.find do |e|
        e.text == "Download"
      end

      gdl_id = id_from_href(dl_link.href)
      gdl_version = version_from_href(dl_link.href)

      # Click the download
      dl_link.click

      default_filename = "gdl#{gdl_id}.#{gdl_version}.xml"
      downloaded_file = Pathname(AdminModule.configuration.download_dir) + default_filename

      i = 0
      while !downloaded_file.exist?
        i += 1
        # Wait for download to complete
        sleep 5

        break if i > 30
      end

      FileUtils.mv downloaded_file, dest_file_path
    end

    private

    def id_from_href href
      str = href.split("?")[1]
      str = str.split("&")[0]
      str = str.split("=")[1]
    end

    def version_from_href href
      str = href.split("?")[1]
      str = str.split("&")[1]
      str = str.split("=")[1]
    end

    def latest_version
      doc = Nokogiri::HTML(@browser.html)
      # The specific version notes TD element:
      #version_notes_row_1 = doc.css("#dgrVersions > tbody > tr:nth-child(2) > td:nth-child(13)")

      # The entire 1st version row (TR) element:
      version_row = doc.css("#dgrVersions > tbody > tr:nth-child(2)")
    end
  end
end # module Pages


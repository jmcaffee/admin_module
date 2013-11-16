##############################################################################
# File::    guideline_version_page.rb
# Purpose:: Guideline Versioning page for AdminModule
# 
# Author::    Jeff McAffee 11/15/2013
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################
require 'page-object'

module AdminModule::Pages

class GuidelineVersionPage
  include PageObject

  #page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.url(GuidelineVersionPage)
  end

  file_field(:file_input,
         id: 'ctl00_cntPlh_inputUpload')

  text_area(:version_notes,
        id: 'ctl00_cntPlh_txtVersionNotes')

  button(:save,
         id: 'ctl00_cntPlh_cmdSave')

  def upload(source_file, comments = nil)
    # The file field (visible as a button) has a negative margin.
    # We can't do anything with it (it's not 'visible') as it is,
    # so we'll use JS to set the left margin to 0.
    reposition_file_input

    # Set the file to upload.
    #file_input_element.set(source_file)  # The watir way...
    self.file_input = source_file

    if comments.nil?
      comments = "auto upload"
    end
    self.version_notes = comments

    self.save

    # Return the url of the version guideline page.
    current_url
  end

  def reposition_file_input
    repos_script = <<EOS
document.getElementsByTagName('input');
p = document.getElementsByName('ctl00$cntPlh$inputUpload');
if (p != null)
{
    p[0].style.marginLeft='0';
}
EOS

    @browser.execute_script(repos_script)
  end

end

end # module Pages


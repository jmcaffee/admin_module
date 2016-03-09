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

  attr_reader :errors

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

  div(:version_errors,
        id: 'ctl00_cntPlh_ctlErrors_vsmErrors')

  div(:add_version_page_errors,
        id: 'vsmErrors')

  table(:versions_table,
        id: 'dgrVersions')

  def errors
    @errors ||= []
  end

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

    reset_errors

    self.save

    capture_errors
    verify_latest_version comments

    # Return the url of the version guideline page.
    self

  rescue Timeout::Error => e
      add_error 'Timeout occurred. Try adjusting the browser_timeout configuration option.'

  rescue Exception => e
      add_error e.message

  ensure
    raise_if_errors
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

  def reset_errors
    errors = []
  end

  def has_errors?
    errors.size > 0
  end

  def add_error err_msg
    errors << err_msg
  end

  def capture_errors
    add_error(version_errors) unless (!version_errors? || version_errors.empty?)
    add_error(add_version_page_errors) unless (!add_version_page_errors? || add_version_page_errors.empty?)
  end

  def raise_if_errors
    if has_errors?
      error = ''
      errors.each { |err| error << err + "\n" }
      raise error
    end
  end

  def verify_latest_version comments
    if !versions_table?
      add_error("Version upload not completed. Did a timeout occur?") unless has_errors?
      return
    end

    version_row = latest_version

    # We have to account for HTML encodings when comparing comments.
    unless version_row.to_s.include?(CGI.escapeHTML(comments))
      add_error("Version upload not completed. Comment not found.")
    end
  end

  def latest_version
    doc = Nokogiri::HTML(@browser.html)
    # The specific version notes TD element:
    #version_notes_row_1 = doc.css("#dgrVersions > tbody > tr:nth-child(2) > td:nth-child(13)")

    # The entire 1st version row (TR) element:
    version_row = doc.css("#dgrVersions > tbody > tr:nth-child(2)")
  end
end # class GuidelineVersionPage

end # module Pages


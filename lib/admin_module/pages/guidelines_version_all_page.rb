##############################################################################
# File::    guidelines_version_all_page.rb
# Purpose:: Guidelines Version All page for AdminModule
#
# Author::    Jeff McAffee 2014-03-17
#
##############################################################################
require 'page-object'

module AdminModule::Pages

class GuidelinesVersionAllPage
  include PageObject

  attr_reader :errors

  #page_url(:get_dynamic_url)

  def get_dynamic_url
    "/admin/decision/versionAllGuideline.aspx"
  end

  select_list(:guidelines_available,
              id: 'ctl00_cntPlh_tsGuidelines_lstAvailable' )

  select_list(:guidelines_selected,
              id: 'ctl00_cntPlh_tsGuidelines_lstSelected' )

  button(:add_guideline_button,
         id: 'ctl00_cntPlh_tsGuidelines_btnAdd' )

  text_area(:version_notes,
        id: 'ctl00_cntPlh_txtVersionAllNotes')

  button(:save_button,
         id: 'ctl00_cntPlh_cmdSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_cmdCancel')

  div(:version_errors,
        id: 'ctl00_cntPlh_ctlErrors_vsmErrors')

  def errors
    @errors ||= []
  end

  def get_guidelines
    gdl_list = []
    Nokogiri::HTML(@browser.html).css("select#ctl00_cntPlh_tsGuidelines_lstAvailable>option").each do |elem|
      gdl_list << elem.text
    end

    gdl_list
  end

  def version(gdl_names, comments = nil)
    gdl_names = Array(gdl_names)

    if comments.nil?
      comments = "auto version"
    end
    self.version_notes = comments

    reset_errors

    # Add guidelines to be versioned to the selected area.
    gdl_names.each do |gdl|
      guidelines_available_element.select(gdl)
      self.add_guideline_button
    end

    self.save_button

    capture_errors

    # Return the url of the version guideline page.
    current_url

  rescue Timeout::Error => e
      add_error 'Timeout occurred. Try adjusting the browser_timeout configuration option.'

  rescue Exception => e
      add_error e.message

  ensure
    raise_if_errors
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
  end

  def raise_if_errors
    if has_errors?
      error = ''
      errors.each { |err| error << err + "\n" }
      raise error
    end
  end
end # class GuidelinesVersionAllPage

end # module Pages


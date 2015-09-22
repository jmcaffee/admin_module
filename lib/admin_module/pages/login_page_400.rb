##############################################################################
# File::    login_page_400.rb
# Purpose:: Login page for Admin Module versions less than 4.4.0
#
# Author::    Jeff McAffee 2015-09-22
#
##############################################################################

require 'page-object'

module AdminModule::Pages

class LoginPage400
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.base_url
  end

  text_field(:username, :id => "txtUserName" )
  text_field(:password_mask, :id => "ctl00_cntPlh_txtPasswordMask" )
  text_field(:password, :id => "txtPassword" )
  button(:login, :id => "btnLogin" )

  def login_as(username, password)
    if !self.username? && current_url == AdminModule.configuration.base_url + '/AdminMain.aspx'
      # We're still logged in.
      return
    end

    raise ArgumentError.new("Missing username for login.\nHave you set the <CLIENT>_envname_USER environment variable?") if username.nil?

    raise ArgumentError.new("Missing password for login.\nHave you set the <CLIENT>_envname_PASSWORD environment variable?") if password.nil?

    unless current_url.downcase.include? get_dynamic_url.downcase
      navigate_to get_dynamic_url
    end

    self.username = username

    enable_login_button

    self.password = password
    login
  end

  def logout
    navigate_to get_dynamic_url + '/user/logout.aspx'
  end

  def enable_login_button
    # For 'unsupported' browsers (anything other than IE < v9), the login button
    # is disabled and hidden.
    #
    # Use JS to enable the button and make it visible.
    #
    enable_button_script = <<-EOS
      login_button = document.getElementById('btnLogin');
      login_button.disabled = false;
      login_button.style.visibility = 'visible';

      document.getElementById('lblBrowserCheck').textContent = "Automation courtesy of AdminModule"
    EOS

    @browser.execute_script(enable_button_script)
  end

end

end # module Pages


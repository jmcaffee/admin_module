##############################################################################
# File::    login_page.rb
# Purpose:: Login page for Admin Module
#
# Author::    Jeff McAffee 11/15/2013
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'page-object'

module AdminModule::Pages

class LoginPage
  include PageObject

  page_url(:get_dynamic_url)

  def get_dynamic_url
    AdminModule.configuration.base_url
  end

  text_field(:username, :id => "ctl00_cntPlh_txtUserName" )
  text_field(:password_mask, :id => "ctl00_cntPlh_txtPasswordMask" )
  text_field(:password, :id => "ctl00_cntPlh_txtPassword" )
  button(:login, :id => "ctl00_cntPlh_btnLogin" )

  def login_as(username, password)
    if !self.username? && current_url == AdminModule.configuration.base_url + '/AdminMain.aspx'
      # We're still logged in.
      return
    end

    raise ArgumentError.new("Missing username for login.\nHave you set the HSBC_envname_USER environment variable?") if username.nil?

    self.username = username

    raise ArgumentError.new("Missing password for login.\nHave you set the HSBC_envname_PASSWORD environment variable?") if password.nil?

    allow_password_entry

    self.password = password
    login
  end

  def allow_password_entry
    # We used to have to click on the password mask before the page would let us enter the password itself:
    #
    # # For some unknown reason, we must click on a password mask input before
    # # we can access the password field itself.
    #   password_mask_element.click
    #
    # Now, we have to use javascript to hide the mask and display the password field.
    hide_mask_script = <<EOS
pwdmasks = document.getElementsByClassName('passwordmask');
pwdmasks[0].style.display = 'none';
pwds = document.getElementsByClassName('password');
pwds[0].style.display = 'block';
EOS

    @browser.execute_script(hide_mask_script)
  end

end

end # module Pages


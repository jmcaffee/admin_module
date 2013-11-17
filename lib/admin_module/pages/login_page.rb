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

    self.username = username
    # For some unknown reason, we must click on a password mask input before
    # we can access the password field itself.
    password_mask_element.click
    self.password = password
    login
  end


end

end # module Pages


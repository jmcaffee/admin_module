##############################################################################
# File::    page_factory.rb
# Purpose:: Provides Page objects
# 
# Author::    Jeff McAffee 06/30/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

module AdminModule
  class PageFactory
    include AdminModule::Pages

    def login_page(goto_page = true)
      return Pages::LoginPage.new(browser, goto_page)
    end

    def guidelines_page(goto_page = true)
      return Pages::GuidelinesPage.new(browser, goto_page)
    end
  end
end # AdminModule

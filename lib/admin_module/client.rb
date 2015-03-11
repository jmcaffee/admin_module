##############################################################################
# File::    client.rb
# Purpose:: AdminModule client object
# 
# Author::    Jeff McAffee 07/11/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AdminModule
  class Client

    attr_writer :page_factory

    #
    # Override credentials
    #

    attr_writer :user
    attr_writer :password

    def env=(environment)
      AdminModule.configuration.current_env = environment
    end

    def env
      AdminModule.configuration.current_env
    end

    def guideline
      login
      Guideline.new page_factory
    end

    def rulesets
      login
      Rulesets.new page_factory
    end

    def rules
      login
      Rules.new page_factory
    end

    def locks
      login
      Locks.new page_factory
    end

    def stages
      login
      Stages.new page_factory
    end

    def page_factory
      @page_factory ||= AdminModule::PageFactory.new
    end

    ##
    # Login to the admin module.
    #
    # If no credentials are provided, try to get credentials from the config object.
    #

    def login(user = nil, pass = nil)
      puts caller
      puts '*'*40
      if @logged_in
        return true
      end

      user, pass = verify_credentials user, pass

      logout
      page_factory.login_page(true).login_as(user, pass)
      @logged_in = true
    end

    ##
    # Logout of the admin module
    #

    def logout
      page_factory.login_page(true).logout
      @logged_in = false
    end

    ##
    # Logout of the admin module and quit the browser
    #

    def quit
      logout
      page_factory.login_page(false).browser.close
    end

  private

    ##
    # If credential args are empty, attempt to look them up,
    #  first in the client attributes, then in the config obj.

    def verify_credentials user, pass
      return [user, pass] if valid_user_and_pass? user, pass

      # Pull values stored in this client.
      user, pass = @user, @password
      return [user, pass] if valid_user_and_pass? user, pass

      # Pull values stored in the config.
      user, pass = AdminModule.configuration.user_credentials
      return [user, pass] if valid_user_and_pass? user, pass

      fail AuthenticationRequired.new("Missing credentials for #{env}")
    end

    def valid_user_and_pass? user, pass
      if user.nil? || user.empty?
        return false
      end

      if pass.nil? || pass.empty?
        return false
      end

      true
    end
  end # Client
end # AdminModule

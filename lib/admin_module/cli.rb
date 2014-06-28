##############################################################################
# File::    cli.rb
# Purpose:: filedescription
# 
# Author::    Jeff McAffee 11/15/2013
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'
require_relative 'cli/cli_parameter'
require_relative 'cli/cli_rule'
require_relative 'cli/cli_ruleset'
require_relative 'cli/cli_guideline'
require_relative 'cli/cli_lock'
require_relative 'cli/cli_stage'


class AdminModule::CLI
  include AdminModule::Pages


  def initialize
    # Make sure the configuration has been initialized.
    AdminModule.configure
  end

  ##
  # Set the current environment

  def environment=(env)
    raise "Unknown environment [#{env}]" unless AdminModule.configuration.credentials.key?(env)
    @env = env
    AdminModule.configure do |config|
      config.default_environment = env
    end
  end

  ##
  # Return the current environment

  def environment
    @env ||= AdminModule.configuration.default_environment
    @env
  end

  ##
  # Return the credentials for the current environment

  def credentials
    return AdminModule.configuration.credentials[environment]
  end

  ##
  # Return the base url for the current environment

  def base_url
    return AdminModule.configuration.base_urls[environment]
  end

  ##
  # Login to the Admin Module
  #
  # If we're already logged in, do nothing unless the +force+ flag is true.
  #
  # +force+ force a re-login if we've already logged in

  def login(force = false)
    if force || @login_page.nil?
      @login_page = LoginPage.new(browser, base_url)
      @login_page.login_as(*credentials)
    end

    @login_page
  end

  def logout
    @login_page.logout
    @login_page = nil
  end

  ##
  # Close the browser

  def quit
    unless @browser.nil?
      logout
      @browser.close
      @browser = nil
    end
  end
end

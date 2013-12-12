##############################################################################
# File::    pages.rb
# Purpose:: Require all Page classes
#
# Author::    Jeff McAffee 11/15/2013
# Copyright:: Copyright (c) 2013, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'watir-webdriver'
require 'admin_module/pages/login_page'
require 'admin_module/pages/guidelines_page'
require 'admin_module/pages/guideline_page'
require 'admin_module/pages/guideline_version_page'
require 'admin_module/pages/lock_definitions_page'
require 'admin_module/pages/lock_definition_page'

module AdminModule::Pages

  ##
  # Return a configured browser object. If a browser has already been created,
  # this returns the existing browser.
  #
  # An +at_exit+ proc is created to close the browser when the program exits.

  def browser
    if @browser.nil?
      @browser = configure_browser

      at_exit do
        @browser.close unless @browser.nil?
      end
    end

    @browser
  end

private

  def configure_browser
    # Specify chrome browser capabilities.
    caps = Selenium::WebDriver::Remote::Capabilities.chrome
    #caps['chromeOptions'] = {'binary' => '/opt/bin/test/chrome-27.0.1453.94.exe' }
    # See http://peter.sh/experiments/chromium-command-line-switches/ for a list of available switches.

    # NOTE: The only way I've found to stop the EULA from being displayed is to
    # use the user-data-dir switch and point to a dir where chrome can put the
    # data indicating it (EULA) has already been accepted.

    # Store chrome profile at test/chrome-data.
    # user_data_dir must be expanded to a full (absolute) path. A relative path
    # results in chromedriver failing to start.
    user_data_dir = File.expand_path('test/chrome-data')
    #puts "*** user_data_dir location: #{user_data_dir}"

    switches = %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate --no-first-run]
    switches << "--user-data-dir=#{user_data_dir}"

    # Create a client so we can adjust the timeout period.
    client = Selenium::WebDriver::Remote::Http::Default.new

    # Set the browser timeout. Default is 60 seconds.
    client.timeout = AdminModule.configuration.browser_timeout

    browser = Watir::Browser.new :chrome,
      :switches => switches,
      :http_client => client,
      :silent => true,
      :service_log_path => user_data_dir + '/chromedriver.out'
      #:desired_capabilities => caps
  end

end

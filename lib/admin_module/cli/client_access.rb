##############################################################################
# File::    client_access.rb
# Purpose:: Module providing client access helper methods for CLI classes.
# 
# Author::    Jeff McAffee 07/17/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AdminModule
  module ClientAccess
    private def credentials
      config = AdminModule.configuration
      user, pass = config.user_credentials
      if user.nil? || pass.nil?
        user = ask "username for #{config.current_env} environment:"
        pass = ask "password:", echo: false
        # Force a new line - hiding the echo on the password eats the new line.
        say "\n"
      end
      [user, pass]
    end

    private def client
      return @client unless @client.nil?

      @client = AdminModule.client
      @client.env = options[:environment] unless options[:environment].nil?

      user, pass = credentials
      if user.empty? || pass.empty?
        say "aborting deploy", :red
        return
      end

      @client.user = user
      @client.password = pass
      @client
    end
  end # ClientAccess
end # AdminModule

##############################################################################
# File::    config_helper.rb
# Purpose:: Configuration object wrapper
# 
# Author::    Jeff McAffee 07/01/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AdminModule
  class ConfigHelper

    def self.env=(env)
      @env = env.to_sym
    end

    def self.env
      @env ||= AdminModule.configuration.default_environment
    end

    def self.page_factory=(factory)
      @page_factory = factory
    end

    def self.page_factory
      @page_factory ||= PageFactory.new
    end

    def self.credentials
      AdminModule.configuration.credentials[env]
    end
  end
end # AdminModule

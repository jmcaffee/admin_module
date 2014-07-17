##############################################################################
# File::    config.rb
# Purpose:: Config command
# 
# Author::    Jeff McAffee 06/29/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AdminModule

  class Config < Thor

    class Add < Thor

      desc "env <envname> <url>", "add a environment url"
      def env(envname, url)
        with_loaded_config do
          unless AdminModule.configuration.base_urls.key? envname.to_sym
            AdminModule.configuration.base_urls[envname.to_sym] = url
          else
            say "environment '#{envname}' already exists", :red
          end
        end
      end

      desc "xmlmap <xmlfile> <gdlname>", "map an xml file name to a guideline"
      def xmlmap(xmlfile, gdlname)
        with_loaded_config do
          xmlfile = File.basename(xmlfile, '.xml')

          unless AdminModule.configuration.xmlmaps.key? xmlfile
            AdminModule.configuration.xmlmaps[xmlfile] = gdlname
          else
            say "a mapping already exists for '#{xmlfile}'", :red
            say "delete and re-add the mapping to change it"
          end
        end
      end

      desc "credentials <envname> <username> <pass>", "add login credentials for an environment"
      def credentials(envname, username, pass)
        with_loaded_config do
          if AdminModule.configuration.base_urls.key? envname.to_sym
            unless AdminModule.configuration.credentials.key? envname.to_sym
              AdminModule.configuration.credentials[envname.to_sym] = [username, pass]
            else
              say "credentials already exist for environment '#{envname}'", :red
            end
          else
            say "environment '#{envname}' doesn't exist", :red
            say "create environment before adding credentials"
          end
        end
      end

    private

      def with_loaded_config &block
        fail "expecting block" unless block_given?

        unless AdminModule.load_configuration
          say "Configuration file not found!", :red
          say "Have you tried 'config init' first?"
          return
        end

        yield

        AdminModule.save_configuration
      end
    end

    desc "add [CATEGORY]", "add a configuration value"
    subcommand "add", Add


    class Show < Thor

      desc "envs", "display configured environments"
      def envs
        with_loaded_config do
          say "Environments:"

          output = []
          AdminModule.configuration.base_urls.each do |env, url|
            output << [env, url]
          end
          print_table output, indent: 8
        end
      end

      desc "xmlmaps", "display configured xmlmaps"
      def xmlmaps
        with_loaded_config do
          say "xmlmaps:"

          output = []
          AdminModule.configuration.xmlmaps.each do |file, gdl|
            output << [file, gdl]
          end
          print_table output, indent: 8
        end
      end

      desc "credentials <envname>", "display configured credentials for an environment"
      long_desc <<-LD
        Display configured credentials for an environment.

        If an environment name is not provided, credentials for all
        environments will be displayed.
      LD
      def credentials(envname=nil)
        with_loaded_config do
          say "credentials:"

          output = []
          AdminModule.configuration.credentials.each do |env, cred|
            if envname.nil? || env == envname.to_sym
              output << [env, cred.first, cred.last]
            end
          end
          print_table output, indent: 8
        end
      end

    private

      def with_loaded_config &block
        fail "expecting block" unless block_given?

        unless AdminModule.load_configuration
          say "Configuration file not found!", :red
          say "Have you tried 'config init' first?"
          return
        end

        yield
      end
    end

    desc "show [CATEGORY]", "display configuration values for [CATEGORY]"
    subcommand "show", Show


    class Del < Thor

      desc "env <envname>", "delete an environment configuration"
      def env(envname)
        with_loaded_config do
          if AdminModule.configuration.base_urls.key?(envname.to_sym)
            AdminModule.configuration.base_urls.delete(envname.to_sym)
          end
        end

        credentials(envname)
      end

      desc "xmlmap <xmlfile>", "delete an xml file to guideline mapping"
      def xmlmap(xmlfile)
        xmlfile = File.basename(xmlfile, '.xml')

        with_loaded_config do
          if AdminModule.configuration.xmlmaps.key?(xmlfile)
            AdminModule.configuration.xmlmaps.delete(xmlfile)
          end
        end
      end

      desc "credentials <envname>", "delete credentials for an environment"
      def credentials(envname)
        with_loaded_config do
          if AdminModule.configuration.credentials.key?(envname.to_sym)
            AdminModule.configuration.credentials.delete(envname.to_sym)
          end
        end
      end

    private

      def with_loaded_config &block
        fail "expecting block" unless block_given?

        unless AdminModule.load_configuration
          say "Configuration file not found!", :red
          say "Have you tried 'config init' first?"
          return
        end

        yield

        AdminModule.save_configuration
      end
    end

    desc "del [CATEGORY]", "delete a configuration value for [CATEGORY]"
    subcommand "del", Del


    desc "init <filedir>", "create a configuration file"
    long_desc <<-LD
      Initialize and write a configuration file to disk.

      If <filedir> is provided, config file will be written to the
      given directory.

      If <filedir> is not given, the configuration file will be
      written to the current working directory.

      If you do not yet have a configuration file, this command
      should be run before any other modifications so your config
      changes are safely stored.
    LD
    option :quiet, :type => :boolean, :default => false, :aliases => :q
    def init(filedir = nil)
      outpath = AdminModule.save_configuration filedir
      say("configuration written to #{outpath.to_s}", :green) unless options[:quiet]
    end


    desc "timeout <seconds>", "show or set the browser timeout period"
    long_desc <<-LD
      Show or set the browser timeout period.
      Default value is 360.

      If <seconds> is not provided, display the current setting.

      <seconds> must be an integer value.
    LD
    def timeout(seconds=nil)
      if seconds.nil?
        with_loaded_config do
          say "browser timeout: #{AdminModule.configuration.browser_timeout}"
        end
      else
        seconds = Integer(seconds)
        with_loaded_config(true) do
          AdminModule.configuration.browser_timeout = seconds
        end
      end
    rescue ArgumentError => e
      say 'argument error: seconds must be an integer', :red
    end


    desc "defenv <envname>", "show or set the default environment"
    long_desc <<-LD
      Show or set the default environment.

      If <envname> is not provided, display the current setting.

      <envname> must be an existing environment.
    LD
    def defenv(envname=nil)
      if envname.nil?
        with_loaded_config do
          say "default environment: #{AdminModule.configuration.default_environment}"
        end
        return
      end

      with_loaded_config(true) do
        if AdminModule.configuration.base_urls.key? envname.to_sym
          AdminModule.configuration.default_environment = envname.to_sym
        else
          say "argument error: environment '#{envname}' has not been configured", :red
        end
      end
    end


    desc "defcomment '<comment>'", "show or set the default comment"
    long_desc <<-LD
      Show or set the default comment.

      The default comment will be applied to deployments and versions when
      no comment is provided.

      A good example of a default comment would be your initials.
    LD
    def defcomment(comment=nil)
      if comment.nil?
        with_loaded_config do
          say "default comment: #{AdminModule.configuration.default_comment}"
        end
        return
      end

      with_loaded_config(true) do
        AdminModule.configuration.default_comment = comment
      end
    end

  private

    def with_loaded_config save = false
      fail "expecting block" unless block_given?

      unless AdminModule.load_configuration
        say "Configuration file not found!", :red
        say "Have you tried 'config init' first?"
        return
      end

      yield

      AdminModule.save_configuration if save
    end
  end # Config
end # AdminModule

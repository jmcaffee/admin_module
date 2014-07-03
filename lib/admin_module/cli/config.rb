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
          if AdminModule.configuration.base_urls.key? envname.to_sym
            say "environment '#{envname}' already exists"
            return
          end

          AdminModule.configuration.base_urls[envname.to_sym] = url
        end
      end

      desc "xmlmap <xmlfile> <gdlname>", "map an xml file name to a guideline"
      def xmlmap(xmlfile, gdlname)
        with_loaded_config do
          xmlfile = File.basename(xmlfile, '.xml')
          if AdminModule.configuration.xmlmaps.key? xmlfile
            say "a mapping already exists for '#{xmlfile}'"
            say "delete and re-add the mapping to change it"
            return
          end

          AdminModule.configuration.xmlmaps[xmlfile] = gdlname
        end
      end

      desc "credentials <envname> <username> <pass>", "add login credentials for an environment"
      def credentials(envname, username, pass)
        with_loaded_config do
          unless AdminModule.configuration.base_urls.key? envname.to_sym
            say "environment '#{envname}' doesn't exist"
            say "create environment before adding credentials"
            return
          end

          if AdminModule.configuration.credentials.key? envname.to_sym
            say "credentials already exist for environment '#{envname}'"
            return
          end
          AdminModule.configuration.credentials[envname.to_sym] = [username, pass]
        end
      end

    private

      def with_loaded_config &block
        fail "expecting block" unless block_given?

        unless AdminModule.find_config_path.nil?
          AdminModule.load_configuration
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

        unless AdminModule.find_config_path.nil?
          AdminModule.load_configuration
        end

        yield
      end
    end

    desc "show [CATEGORY]", "display configuration values for [CATEGORY]"
    subcommand "show", Show


    class Del < Thor

      desc "env <envname>", "delete an environment configuration"
      def env(envname)
        if AdminModule.configuration.base_urls.key?(envname.to_sym)
          AdminModule.configuration.base_urls.delete(envname.to_sym)
          credentials(envname)
        end
      end

      desc "xmlmap <xmlfile>", "delete an xml file to guideline mapping"
      def xmlmap(xmlfile)
        xmlfile = File.basename(xmlfile, '.xml')

        if AdminModule.configuration.xmlmaps.key?(xmlfile)
          AdminModule.configuration.xmlmaps.delete(xmlfile)
        end
      end

      desc "credentials <envname>", "delete credentials for an environment"
      def credentials(envname)
        if AdminModule.configuration.credentials.key?(envname.to_sym)
          AdminModule.configuration.credentials.delete(envname.to_sym)
        end
      end
    end

    desc "del [CATEGORY]", "delete a configuration value for [CATEGORY]"
    subcommand "del", Del


    desc "write <filedir>", "write a configuration file"
    long_desc <<-LD
      Write a configuration file to disk.

      If <filedir> is provided, config file will be written to the
      given directory.

      If <filedir> is not given, admin_module will search up the
      directory tree attempting to find a configuration file, if
      found, it will be used, otherwise the configuration file will be
      written to the current working directory.

      If you do not yet have a configuration file, this should be
      written before any other modifications so the config changes
      have someplace to be written to.
    LD
    def write(filedir = nil)
      if ! filedir.nil?
        filedir = Pathname(filedir) + '.admin_module' unless filedir.to_s.end_with?('/.admin_module')
      end

      outpath = AdminModule.save_configuration filedir
      say "configuration written to #{outpath.to_s}", :green
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
        say "browser timeout: #{AdminModule.configuration.browser_timeout}"
      else
        AdminModule.configuration.browser_timeout = Integer(seconds)
      end
    rescue ArgumentError => e
      say 'argument error: seconds must be an integer'
    end


    desc "defenv <envname>", "show or set the default environment"
    long_desc <<-LD
      Show or set the default environment.

      If <envname> is not provided, display the current setting.

      <envname> must be an existing environment.
    LD
    def defenv(envname=nil)
      if envname.nil?
        say "default environment: #{AdminModule.configuration.default_environment}"
        return
      end

      if AdminModule.configuration.base_urls.key? envname.to_sym
        AdminModule.configuration.default_environment = envname.to_sym
        return
      end

      say "argument error: environment '#{envname}' has not been configured"
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
        say "default comment: #{AdminModule.configuration.default_comment}"
        return
      end

      AdminModule.configuration.default_comment = comment
    end
  end # Config
end # AdminModule

require "admin_module/version"
require 'admin_module/config_helper'
require "admin_module/cli"
require 'admin_module/page_factory'
require 'admin_module/pages'
require 'admin_module/guideline'
require 'admin_module/rulesets'
require 'admin_module/rules'
require 'admin_module/stages'
require 'admin_module/locks'
require 'admin_module/dc'
require 'admin_module/snapshots'
require 'admin_module/tasks'
require 'admin_module/ppms'
require 'admin_module/client'

if ENV['DEBUG'].nil?
  $debug = false
else
  $debug = true
end

class AuthenticationRequired < StandardError
end

module AdminModule
  CONFIG_FILE_NAME = '.admin_module'

  class << self
    attr_accessor :configuration
    attr_accessor :client
  end

  ##
  # Setup admin_module configuration
  #
  # Attempts to find and load a configuration file the first time
  # it's requested. If a config file cannot be found on in the current
  # directory tree (moving towards trunk, not the leaves), a default
  # configuration object is created.
  #
  # If a block is provided, the configuration object is yielded to the block
  # after the configuration is loaded/created.
  #

  def self.configure
    if self.configuration.nil?
      unless self.load_configuration
        self.configuration = Configuration.new
      end
    end
    yield(configuration) if block_given?
  end

  ##
  # Walk up the directory tree from current working dir (pwd) till a file
  # named .admin_module is found
  #
  # Returns file path if found, nil if not.
  #

  def self.find_config_path
    path = Pathname(Pathname.pwd).ascend{|d| h=d+CONFIG_FILE_NAME; break h if h.file?}
  end

  ##
  # Write configuration to disk
  #
  # Writes to current working dir (pwd) if path is nil
  #
  # Returns path of emitted file
  #

  def self.save_configuration(path = nil)
    # If no path provided, see if we can find one in the dir tree.
    if path.nil?
      path = find_config_path
    end

    # Still no path? Use the current working dir.
    if path.nil?
      path = Pathname.pwd
    end

    unless path.to_s.end_with?('/' + CONFIG_FILE_NAME)
      path = Pathname(path) + CONFIG_FILE_NAME
    end

    path = Pathname(path).expand_path
    File.write(path, YAML.dump(configuration))

    path
  end

  ##
  # Load the configuration from disk
  #
  # Returns true if config file found and loaded, false otherwise.
  #

  def self.load_configuration(path = nil)
    # If no path provided, see if we can find one in the dir tree.
    if path.nil?
      path = find_config_path
    end

    return false if path.nil?
    return false unless Pathname(path).exist?

    File.open(path, 'r') do |f|
      self.configuration = YAML.load(f)
      puts "configuration loaded from #{path}" if $debug
    end

    true
  end

  class Configuration
    attr_accessor :default_environment
    attr_accessor :default_comment
    attr_accessor :credentials
    attr_accessor :base_urls
    attr_accessor :xmlmaps
    attr_accessor :aliases
    attr_accessor :page_urls

    # Browser timeout in seconds. Default: 360 (6 mins).
    attr_accessor :browser_timeout


    def initialize
      reset
    end

    def reset
      @default_environment = :dev
      @current_env = nil

      @default_comment = 'no comment'

      @credentials = {}
      #@credentials = { dev: [ ENV['HSBC_DEV_USER'], ENV['HSBC_DEV_PASSWORD'] ],
      #                dev2: [ ENV['HSBC_DEV2_USER'], ENV['HSBC_DEV2_PASSWORD'] ],
      #                 sit: [ ENV['HSBC_SIT_USER'], ENV['HSBC_SIT_PASSWORD'] ],
      #                 uat: [ ENV['HSBC_UAT_USER'], ENV['HSBC_UAT_PASSWORD'] ] }

      @base_urls   = { dev: "http://207.38.119.211/fap2Dev/Admin",
                      dev2: "http://207.38.119.211/fap2Dev2/Admin",
                       sit: "http://207.38.119.211/fap2SIT/Admin",
                       uat: "http://207.38.119.211/fap2UAT/Admin" }

      @xmlmaps      = {}

      @aliases      = {}

      @page_urls   = {
                       'ParametersPage' => "/admin/decision/parameters.aspx",
                       'ParameterPage'  => "/admin/decision/parameter.aspx",
                    }

      @browser_timeout = 360
    end

    ##
    # Set the current environment.
    #

    def current_env=(env)
      env = env.to_sym

      fail "Cannot set current_env to un-configured environment: #{env}" unless @base_urls.key? env

      # This value is NOT included when dumping to YAML.
      # See Configurtion#encode_with
      @current_env = env.to_sym
    end

    ##
    # Return the current environment.
    # Will return the default environment if current environment is not set.
    #

    def current_env
      return @default_environment if @current_env.nil?
      @current_env
    end

    def base_url
      @base_urls[current_env]
    end

    def url page_class
      suffix = @page_urls[page_class.to_s.split('::').last]
      raise "Unkown page [#{page_class.to_s}]" if suffix.nil?
      base_url + suffix
    end

    def xmlmap xmlfile
      gdlname = xmlmaps[File.basename(xmlfile, '.xml')]
      if gdlname.nil?
        errmsg = "No guideline has been mapped for #{File.basename(xmlfile)}"
        trymsg = "Have you configured your gdl mappings?"
        trymsg2= " Try: admin_module config add xmlmap <xmlfile> <gdlname>"
        fail("#{errmsg}\n\n#{trymsg}\n#{trymsg2}") if gdlname.nil?
      end
      gdlname
    end

    def user_credentials
      @credentials[current_env]
    end

    ##
    # Control which instance vars are emitted when dumped to YAML.
    #

    def encode_with(coder)
      vars = instance_variables.map { |x| x.to_s }
      vars = vars - ["@current_env"]

      vars.each do |var|
        var_val = eval(var)
        coder[var.gsub('@', '')] = var_val
      end
    end
  end # Configuration


  class Runner
    def initialize(argv, client = AdminModule::Client.new, exit_code = true)
      @argv = argv
      AdminModule.client = client
      @exit_code = exit_code
    end

    def execute!
      exit_code = begin

        # Run the Thor app
        AdminModule::CLI.start(@argv)

        # Thor::Base#start does not have a return value,
        # assume success if no exception is thrown.
        0
      rescue StandardError => e
        b = e.backtrace
        b.unshift("#{b.shift}: #{e.message} (#{e.class})")
        puts(b.map { |s| "\tfrom #{s}"}.join("\n"))
        1
      end

      # Return the exit code
      exit(exit_code) if @exit_code
    end
  end
end

# Call configure to force creation of the configuration object.
AdminModule.configure


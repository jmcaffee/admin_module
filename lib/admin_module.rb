require "admin_module/version"
require 'admin_module/config_helper'
require "admin_module/cli"
require 'admin_module/page_factory'
require 'admin_module/pages'
require 'admin_module/guideline'

if ENV['DEBUG'].nil?
  $debug = false
else
  $debug = true
end

module AdminModule
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
    unless block_given?
      load_configuration
    end
  rescue
    # NOP. Do nothing if the config file isn't found.
  end

  def self.save_configuration(path = nil)
    # If no path provided, see if we can find one in the dir tree.
    if path.nil?
      path = find_config_path
    end

    # Still no path? Use the current working dir.
    if path.nil?
      path = Pathname.pwd + '.admin_module'
    end

    path = Pathname(path).expand_path
    File.write(path, YAML.dump(configuration))

    path
  end

  def self.load_configuration(path = nil)
    # If no path provided, see if we can find one in the dir tree.
    if path.nil?
      path = find_config_path
    end

    fail("Unable to find a configuration file named .admin_module in the current directory tree") if path.nil?
    fail("File not found: #{path.to_s}") unless path.exist?

    File.open(path, 'r') do |f|
      self.configuration = YAML.load(f)
      puts "configuration loaded from #{path}" if $debug
    end
  end

  def self.find_config_path
    path = Pathname(Pathname.pwd).ascend{|d| h=d+'.admin_module'; break h if h.file?}
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

      @default_comment = 'no comment'

      @credentials = { dev: [ ENV['HSBC_DEV_USER'], ENV['HSBC_DEV_PASSWORD'] ],
                      dev2: [ ENV['HSBC_DEV2_USER'], ENV['HSBC_DEV2_PASSWORD'] ],
                       sit: [ ENV['HSBC_SIT_USER'], ENV['HSBC_SIT_PASSWORD'] ],
                       uat: [ ENV['HSBC_UAT_USER'], ENV['HSBC_UAT_PASSWORD'] ] }

      @base_urls   = { dev: "http://207.38.119.211/fap2Dev/Admin",
                      dev2: "http://207.38.119.211/fap2Dev2/Admin",
                       sit: "http://207.38.119.211/fap2SIT/Admin",
                       uat: "http://207.38.119.211/fap2UAT/Admin" }

      @xmlmaps      = {}

      @aliases      = {}

      @page_urls   = { 'GuidelinesPage'           => "/admin/decision/guidelines.aspx",
                       'GuidelinesVersionAllPage' => "/admin/decision/versionAllGuideline.aspx",
                       'GuidelinePage'            => "/admin/decision/guideline.aspx", #?gdl=34
                       'LockDefinitionsPage'      => "/admin/security/ViewDefinitions.aspx?act=2&type=2",
                       'WorkflowDetailsPage'      => "/admin/security/workflows.aspx",
                       'RulesPage'                => "/admin/decision/rules.aspx",
                       'RulePage'                 => "/admin/decision/rule.aspx",
                       'RulesetsPage'             => "/admin/decision/rulesets.aspx",
                       'RulesetPage'              => "/admin/decision/ruleset.aspx",
                       'ParametersPage'           => "/admin/decision/parameters.aspx",
                       'ParameterPage'            => "/admin/decision/parameter.aspx",
                    }

      @browser_timeout = 360
    end

    def base_url
      @base_urls[@default_environment]
    end

    def url page_class
      suffix = @page_urls[page_class.to_s.split('::').last]
      raise "Unkown page [#{page_class.to_s}]" if suffix.nil?
      base_url + suffix
    end

    def xmlmap xmlfile
      gdlname = xmlmaps[File.basename(xmlfile, '.xml')]
      fail("No guideline has been mapped for #{File.basename(xmlfile)}") if gdlname.nil?
      gdlname
    end

    def user_credentials env
      @credentials[env.to_sym]
    end
  end
end

AdminModule.configure


require "admin_module/version"
require "admin_module/cli"

module AdminModule
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :default_environment
    attr_accessor :credentials
    attr_accessor :base_urls
    attr_accessor :aliases
    attr_accessor :page_urls

    def initialize
      @default_environment = :dev

      @credentials = { dev: [ ENV['HSBC_DEV_USER'], ENV['HSBC_DEV_PASSWORD'] ],
                      dev2: [ ENV['HSBC_DEV2_USER'], ENV['HSBC_DEV2_PASSWORD'] ],
                       sit: [ ENV['HSBC_SIT_USER'], ENV['HSBC_SIT_PASSWORD'] ],
                       uat: [ ENV['HSBC_UAT_USER'], ENV['HSBC_UAT_PASSWORD'] ] }

      @base_urls   = { dev: "http://207.38.119.211/fap2Dev/Admin",
                      dev2: "http://207.38.119.211/fap2Dev2/Admin",
                       sit: "http://207.38.119.211/fap2SIT/Admin",
                       uat: "http://207.38.119.211/fap2UAT/Admin" }

      @aliases      = {}

      @page_urls   = { 'GuidelinesPage'       => "/admin/decision/guidelines.aspx",
                       'GuidelinePage'        => "/admin/decision/guideline.aspx", #?gdl=34
                       'LockDefinitionsPage'  => "/admin/security/ViewDefinitions.aspx?act=2&type=2",
                    }
    end

    def base_url
      @base_urls[@default_environment]
    end

    def url page_class
      suffix = @page_urls[page_class.to_s.split('::').last]
      raise "Unkown page [#{page_class.to_s}]" if suffix.nil?
      base_url + suffix
    end
  end
end

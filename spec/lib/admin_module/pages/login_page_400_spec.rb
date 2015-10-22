require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe 'LoginPage' do

  let(:page_factory) do
    AdminModule::PageFactory.new
  end

  before do
    AdminModule.configure do |config|
      config.credentials.clear
      config.credentials[:dev] = ['user', 'pass']

      config.xmlmaps.clear
      config.xmlmaps['test1'] = 'Z-TEMP'
      config.xmlmaps['test2'] = 'Z-TEMP2'

      config.ams_version = "4.0.0"
    end

    base_url = ENV['AM_LIVE_BASE_URL_400']
    login_url = "login400.aspx.html"

    unless base_url.nil? || base_url.empty?
      HtmlSpec.always_use_server = true
      login_url = File.join(base_url, "user/login.aspx")
    else
      HtmlSpec.always_use_server = false
    end
    allow_any_instance_of(AdminModule::Pages::LoginPage400).to receive(:get_dynamic_url).and_return(HtmlSpec.url_for(login_url))
  end

  context "logging in" do
    it "populates the correct fields" do
      page = page_factory.login_page
      expect { page.login_as("user", "password") }.to_not raise_error
    end
  end
end



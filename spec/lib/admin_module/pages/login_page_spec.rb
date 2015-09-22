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

      config.ams_version = "4.4.0"
    end

    allow_any_instance_of(AdminModule::Pages::LoginPage).to receive(:get_dynamic_url).and_return(HtmlSpec.url_for("login.aspx.html"))
  end

  context "logging in" do
    it "populates the correct fields" do
      page = page_factory.login_page
      expect { page.login_as("user", "password") }.to_not raise_error
    end
  end
end



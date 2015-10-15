require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe 'Guideline:Page (4.0.0)' do

  let(:page) do
    the_page = AdminModule::PageFactory.new.guideline_page
    the_page.navigate_to the_page.get_dynamic_url
    the_page
  end

  before do
    AdminModule.configure do |config|
      config.credentials.clear
      config.credentials[:dev] = ['user', 'pass']

      config.xmlmaps.clear
      config.xmlmaps['test1'] = 'Z-TEMP'
      config.xmlmaps['test2'] = 'Z-TEMP2'

      config.ams_version = "4.0.0"

      # Fail fast
      config.browser_timeout = 5
    end

    allow_any_instance_of(AdminModule::Pages::GuidelinePage400).to receive(:get_dynamic_url).and_return(HtmlSpec.url_for("guideline-400.html"))

  end

  after(:each) do
    page.browser.close
  end

  context "control IDs" do

    context "versions" do
      it "exists" do
        expect( page.versions? ).to eq true
      end
    end

    context "add_version_button" do
      it "exists" do
        expect( page.add_version_button? ).to eq true
      end
    end
  end
end



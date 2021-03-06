require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe 'Guidelines:Page (4.4.0)' do

  let(:gdl) { "TS-Stage002" }

  let(:page) do
    the_page = AdminModule::PageFactory.new.guidelines_page
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

      config.ams_version = "4.4.0"

      # Fail fast damnit!
      config.browser_timeout = 5
    end

    allow_any_instance_of(AdminModule::Pages::GuidelinesPage).to receive(:get_dynamic_url).and_return(HtmlSpec.url_for("guidelines.html"))
    allow_any_instance_of(AdminModule::Pages::GuidelinePage).to receive(:get_dynamic_url).and_return(HtmlSpec.url_for("guideline.html"))
    allow_any_instance_of(AdminModule::Pages::GuidelinesVersionAllPage).to receive(:get_dynamic_url).and_return(HtmlSpec.url_for("version_all_guidelines.html"))
    allow_any_instance_of(AdminModule::Pages::GuidelinesPage).to receive(:version_all_button).and_return(nil)
    allow_any_instance_of(AdminModule::Pages::GuidelinesPage).to receive(:modify).and_return(nil)

  end

  after(:each) do
    page.browser.close
  end

  context "#get_guidelines" do

    it "returns list of guidelines in environment" do
      expect { page.get_guidelines }.to_not raise_error

      gdl_list = page.get_guidelines
      expect( gdl_list ).to include gdl
    end
  end

  context "#version_all" do

    it "opens 'Versions All' page" do
      allow_any_instance_of(AdminModule::PageFactory).to receive(:guidelines_version_all_page).and_return(HtmlSpec.url_for("version_all_guidelines.html"))

      expect { page.version_all }.to_not raise_error
    end
  end

  context "#open_guideline" do

    it "opens 'Guideline' page" do
      allow_any_instance_of(AdminModule::PageFactory).to receive(:guideline_page).and_return(HtmlSpec.url_for("version_all_guidelines.html"))

      expect { page.open_guideline(gdl) }.to_not raise_error
    end
  end

  context "control IDs" do

    context "guidelines" do
      it "exists" do
        expect( page.guidelines? ).to eq true
      end
    end

    context "modify" do
      it "exists" do
        expect( page.modify? ).to eq true
      end
    end

    context "version_all_button" do
      it "exists" do
        expect( page.version_all_button? ).to eq true
      end
    end
  end
end



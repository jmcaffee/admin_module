require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe 'GuidelinesVersionAll:Page (4.4.0)' do

  let(:page_factory) do
    AdminModule::PageFactory.new
  end

  def page
    @page ||= AdminModule::PageFactory.new.guidelines_version_all_page
    @page.navigate_to @page.get_dynamic_url
    @page
  end

  def close_page
    unless @page.nil?
      @page.browser.close
      @page = nil
    end
  end

  let(:gdl) { "TS-Stage002" }

  before do
    AdminModule.configure do |config|
      config.credentials.clear
      config.credentials[:dev] = ['user', 'pass']

      config.xmlmaps.clear
      config.xmlmaps['test1'] = 'Z-TEMP'
      config.xmlmaps['test2'] = 'Z-TEMP2'

      config.ams_version = "4.4.0"
    end

    allow_any_instance_of(AdminModule::Pages::GuidelinesVersionAllPage).to receive(:get_dynamic_url).and_return(HtmlSpec.url_for("version_all_guidelines.html"))
  end

  after(:each) do
    close_page
  end

  context "#get_guidelines" do
    it "returns list of guidelines in environment" do
      expect { page.get_guidelines }.to_not raise_error

      gdl_list = page.get_guidelines
      expect( gdl_list ).to include gdl
    end
  end

  context "#version" do
    it "versions a guideline" do
      expect { page.version(gdl) }.to_not raise_error
    end
  end

  context "control IDs" do

    context "guidelines_available" do
      it "exists" do
        expect( page.guidelines_available? ).to eq true
      end
    end

    context "guidelines_selected" do
      it "exists" do
        expect( page.guidelines_selected? ).to eq true
      end
    end

    context "add_guideline_button" do
      it "exists" do
        expect( page.add_guideline_button? ).to eq true
      end
    end

    context "version_notes" do
      it "exists" do
        expect( page.version_notes? ).to eq true
      end
    end

    context "save_button" do
      it "exists" do
        expect( page.save_button? ).to eq true
      end
    end

    context "cancel_button" do
      it "exists" do
        expect( page.cancel_button? ).to eq true
      end
    end

    context "version_errors" do
      it "exists" do
        expect( page.version_errors? ).to eq true
      end
    end
  end
end



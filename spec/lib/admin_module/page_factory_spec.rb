require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe AdminModule::PageFactory do

  let(:mock_browser) do
    mock_browser_at_creation( mock_watir_browser )
  end

  context "#login_page" do

    context "with default ams version" do

      it 'returns LoginPage object' do
        mock_browser

        AdminModule.configure do |config|
          config.ams_version = "4.4.0"
        end

        factory = AdminModule::PageFactory.new
        expect( factory.login_page(false).class ).to eq AdminModule::Pages::LoginPage
      end
    end

    context "with ams version < 4.4.0" do

      it 'returns LoginPage400 object' do
        mock_browser

        AdminModule.configure do |config|
          config.ams_version = "4.0.0"
        end

        factory = AdminModule::PageFactory.new
        expect( factory.login_page(false).class ).to eq AdminModule::Pages::LoginPage400
      end
    end
  end

  context "#guidelines_version_all_page" do

    context "with default ams version" do

      it 'returns GuidelinesVersionAllPage object' do
        mock_browser

        AdminModule.configure do |config|
          config.ams_version = "4.4.0"
        end

        factory = AdminModule::PageFactory.new
        expect( factory.guidelines_version_all_page(false).class ).to eq AdminModule::Pages::GuidelinesVersionAllPage
      end
    end

    context "with ams version < 4.4.0" do

      it 'returns GuidelinesVersionAllPage400 object' do
        mock_browser

        AdminModule.configure do |config|
          config.ams_version = "4.0.0"
        end

        factory = AdminModule::PageFactory.new
        expect( factory.guidelines_version_all_page(false).class ).to eq AdminModule::Pages::GuidelinesVersionAllPage400
      end
    end
  end
end


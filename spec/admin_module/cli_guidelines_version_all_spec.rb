require 'spec_helper'
#require_relative '../../lib/admin_module/pages/guidelines_page'
#require_relative '../../lib/admin_module/pages/guideline_version_page'

describe AdminModule::CLI do

  let(:cli) do
              AdminModule.configure do |config|
                config.credentials = { :dev => ['admin', 'Password1*'] }
              end
              AdminModule::CLI.new
            end

      after(:each) do
        cli.quit
      end

  let(:test_message) { 'JM: ' + timestamp }

  let(:timestamp) do
    now = DateTime.now
    m = "%02d" % now.month
    d = "%02d" % now.day
    y = "%04d" % now.year
    hour = "%02d" % now.hour
    min  = "%02d" % now.minute
    sec  = "%02d" % now.sec

    time_stamp = "#{y}#{m}#{d}T#{hour}#{min}#{sec}"
  end

  let(:test_gdl) { 'WF-FwdApp-Pre' }
  let(:base_url) { cli.base_url }
  let(:browser) { cli.browser }

  describe "#version_all" do

    context "with version message" do

      it "guidelines are versioned with supplied message" do
        cli.version_all(test_gdl, test_message)

        # To verify, we open a guideline page,
        # goto the versions tab,
        # and ask the GuidelineVersionPage object to verify the version message for us.
        gdl_page_url = AdminModule::Pages::GuidelinesPage.new(browser, base_url).
          open_guideline(test_gdl)

        AdminModule::Pages::GuidelinePage.new(browser, gdl_page_url).versions
        version_page = AdminModule::Pages::GuidelineVersionPage.new(browser, gdl_page_url)

        version_page.verify_latest_version test_message

        expect{ version_page.raise_if_errors }.to_not raise_error
      end
    end # context
  end # describe "#version_all"
end # describe AdminModule

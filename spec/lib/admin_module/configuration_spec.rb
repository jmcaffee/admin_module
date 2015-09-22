require 'spec_helper'

describe AdminModule::Configuration do

  before do
    # Reset config to a known state.
    AdminModule.configuration.reset
  end

  let(:config) do
    AdminModule.configure
    AdminModule.configuration
  end

  describe "Configuration fields" do
    context "#ams_version" do

      it "returns a default AMS version of 4.4.0" do
        AdminModule.configure
        expect( AdminModule.configuration.ams_version ).to eq "4.4.0"
      end

      it "returns configured AMS version if set" do
        AdminModule.configure do |config|
          config.ams_version = "4.0.4"
        end

        expect( AdminModule.configuration.ams_version ).to eq "4.0.4"
      end

      it "returns default version if existing config doesn't contain ams_version setting" do
        copy_from_spec_data "config/no_ams_version.admin_module", "config/ams_version/.admin_module"

        with_target_dir('config/ams_version') do |target_dir|
          target = target_dir + '.admin_module'

          # Create a config file to find
          AdminModule.load_configuration target

          expect( AdminModule.configuration.ams_version).to eq "4.4.0"
        end
      end
    end

  end
end # describe AdminModule::Configuration


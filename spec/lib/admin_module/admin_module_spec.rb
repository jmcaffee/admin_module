require 'spec_helper'

describe AdminModule do

  before do
    # Reset config to a known state.
    AdminModule.configuration.reset
  end

  let(:config) do
    AdminModule.configure
    AdminModule.configuration
  end

  describe ".configure" do
    context "no arguments provided" do

      it "creates configuration" do
        AdminModule.configure
        expect( AdminModule.configuration ).to_not be nil
      end
    end

  end

  describe ".find_config_path" do

    it "returns nil if config not found" do
      with_target_dir('config/location') do
        expect( AdminModule.find_config_path ).to be nil
      end
    end

    it "returns path if config found" do
      with_target_dir('config/location') do |target_dir|
        target = target_dir + '.admin_module'

        # Create a config file to find
        AdminModule.save_configuration target

        actual = nil

        # Find the file in a parent directory
        with_target_dir(target_dir + 'some/nested/location') do
          actual = AdminModule.find_config_path
        end

        expect( actual.to_s ).to eq target.expand_path.to_s
      end
    end
  end

  describe ".save_configuration" do

    context "filename argument provided" do

      it "creates a file" do
        with_target_dir('config/location') do |target|
          target = target + '.admin_module'

          AdminModule.save_configuration target

          expect( target.exist? ).to be true
        end
      end
    end

    context "no filename argument provided" do

      context "config file doesn't exist in any parent directory" do

        it "creates a file in current dir" do
          with_target_dir('config/location') do |target|
            AdminModule.save_configuration

            target = target + '.admin_module'

            expect( target.exist? ).to be true
          end
        end
      end

      context "config file exists in a parent directory" do

        it "updates file in parent directory" do
          with_target_dir('config/location') do |actual_location|
            actual = actual_location + '.admin_module'

            # Save the default configuration in a known location
            AdminModule.configuration.reset
            AdminModule.save_configuration actual

            # Change the configuration
            AdminModule.configure do |c|
              c.browser_timeout = 1800
            end

            with_target_dir(actual_location + 'some/nested/location') do |start_dir|
              AdminModule.save_configuration
            end

            expect( File.readlines(actual) ).to include "browser_timeout: 1800\n"
          end
        end
      end
    end
  end

  describe ".load_configuration" do

    context "filename argument provided" do
      context "config file doesn't exist" do
        it "returns false" do
          expect( AdminModule.load_configuration('not/a/real/path') ).to eq false
        end
      end

      context "config file exists" do
        it "loads the configuration" do
          with_target_dir('config/load') do |actual_location|
            actual = actual_location + '.admin_module'

            # Change the configuration
            AdminModule.configure do |c|
              c.browser_timeout = 900
            end

            # Save the configuration in a known location
            AdminModule.save_configuration actual

            # Reset the config (clean the slate)
            AdminModule.configuration.reset

            AdminModule.load_configuration actual
            expect( AdminModule.configuration.browser_timeout ).to eq 900
          end
        end
      end
    end

    context "no filename argument provided" do
      context "config file doesn't exist in any parent directory" do
        it "returns false" do
          expect( AdminModule.load_configuration ).to eq false
        end
      end

      context "config file exists in a parent directory" do
        it "loads the configuration" do
          with_target_dir('config/load') do |actual_location|
            actual = actual_location + '.admin_module'

            # Change the configuration
            AdminModule.configure do |c|
              c.browser_timeout = 950
            end

            # Save the configuration in a known location
            AdminModule.save_configuration actual

            # Reset the config (clean the slate)
            AdminModule.configuration.reset

            with_target_dir(actual_location + 'some/nested/path') do |start_dir|
              AdminModule.load_configuration
            end

            expect( AdminModule.configuration.browser_timeout ).to eq 950
          end
        end
      end
    end
  end
end # describe AdminModule


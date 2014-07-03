require 'spec_helper'

describe AdminModule::CLI do

  let(:cli) do
              AdminModule.configure do |config|
                config.credentials = { :dev => ['devuser', 'devpassword'] }
              end
              AdminModule::CLI.new
            end

      after(:each) do
        cli.quit
      end

  describe "#environment=" do
    context "sets the environment to use" do
      context "when set to :sit" do
        let(:cli) do
          AdminModule.configure do |config|
            config.credentials = { :sit => ['situser', 'sitpassword*'] }
          end
          cli = AdminModule::CLI.new
          cli.environment = :sit
          cli
        end


        it "#environment returns :sit" do
          expect(cli.environment).to eq :sit
        end

        it "#credentials returns values for :sit" do
          expect(cli.credentials).to eq ['situser', 'sitpassword*']
        end

        it "#base_url returns values for :sit" do
          expect(cli.base_url).to eq "http://207.38.119.211/fap2SIT/Admin"
        end
      end
    end

    #context "with :test configured as default environment" do
    #  AdminModule.configure do |config|
    #    config.default_environment = :test
    #  end

    #  it "returns :test" do
    #    expect(cli.environment).to eq :test
    #  end
    #end # context "with invalid source file"
  end

  describe "#environment" do
    context "returns default environment if not overridden" do
        let(:devuser) { 'DevUser' }
        let(:devpass) { 'DevPassword1*' }
        let(:cli) do
          AdminModule.configure do |config|
            config.reset
            config.credentials = { :dev => [devuser, devpass] }
          end
          cli = AdminModule::CLI.new
          cli
        end


      it "returns :dev" do
        expect(cli.environment).to eq :dev
      end
    end

    #context "with :test configured as default environment" do
    #  AdminModule.configure do |config|
    #    config.default_environment = :test
    #  end

    #  it "returns :test" do
    #    expect(cli.environment).to eq :test
    #  end
    #end # context "with invalid source file"
  end


  describe "#credentials" do
    context "returns default credentials if not overridden" do
        let(:devuser) { 'DevUser' }
        let(:devpass) { 'DevPassword1*' }
        let(:cli) do
          AdminModule.configure do |config|
            config.reset
            config.credentials = { :dev => [devuser, devpass] }
          end
          cli = AdminModule::CLI.new
          cli
        end


      it "returns :dev's credentials" do
        expect(cli.credentials).to eq [devuser, devpass]
      end
    end
  end


  describe "#base_urls" do
    context "returns default urls if not overridden" do
        let(:devuser) { 'DevUser' }
        let(:devpass) { 'DevPassword1*' }
        let(:cli) do
          AdminModule.configure do |config|
            config.reset
            config.credentials = { :dev => [devuser, devpass] }
          end
          cli = AdminModule::CLI.new
          cli
        end


      it "returns :dev's base url" do
        expect(cli.base_url).to eq "http://207.38.119.211/fap2Dev/Admin"
      end
    end
  end

end # describe AdminModule

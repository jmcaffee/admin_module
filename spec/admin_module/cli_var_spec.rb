require 'spec_helper'

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

  describe "#get_parameters" do
    let(:var_name) { 'Decision' }

    it 'returns a list of variables in the environment' do
      expect( cli.get_parameters.include?(var_name) ).to eq true
    end
  end

  describe "#update_parameter" do

    let(:var_name)  { 'ZExclusion Decision' }
    let(:not_a_var) { 'Not a Var' }

    it "updates a variables 'Save in XML' state" do
      expect { cli.update_parameter(var_name, :include => true) }.not_to raise_exception
    end

    it "raises an exception when invalid parameter keys are passed" do
      expect { cli.update_parameter(var_name, :invalid => true) }.to raise_exception
    end

    it "raises an exception if variable doesn't exist" do
      expect { cli.update_parameter(not_a_var, :include => true) }.to raise_exception
    end
  end
end # describe AdminModule

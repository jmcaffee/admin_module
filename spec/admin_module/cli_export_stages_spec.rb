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

  describe "#get_stage" do
    context "invalid stage name" do
      it "will raise exception" do
        expect { cli.get_stage('invalid') }.to raise_exception(ArgumentError)
      end
    end # context "invalid stage name"


    context "valid stage name" do

      let(:expected_stage)  do
                              { name: '020 Pending Docs',
                                transition_to: [
                                                '001 New File',
                                                '022 Docs Verification',
                                                '060 Reconsideration Exceptions/Overrides',
                                                '096 Withdrawn',
                                                '120 Second Review-Pending Docs' ]
                              }
                            end


      it "will return stage configuration data" do
        expect( cli.get_stage('020 Pending Docs') ).to eq expected_stage
      end
    end # context "valid stage name"
  end # describe "#get_stage"

  describe "#export_stages" do
    context "with filename" do

      let(:target_file)   { 'tmp/spec/admin_module/stages.yml' }

      before(:each) do
        FileUtils.rm_rf target_file
      end


      it "writes multiple stages to a file" do
        cli.export_stages(target_file)
        stages = read_yaml_data_file(target_file)
        expect(stages.size).to eq 48
      end
    end # context
  end # describe "#export_stages"
end # describe AdminModule

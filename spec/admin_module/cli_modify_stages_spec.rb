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

  let(:test_stage)   do
                        { name: 'Test Stage',
                          transition_to: [
                                          '001 New File',
                                          '022 Docs Verification',
                                          '060 Reconsideration Exceptions/Overrides',
                                          '096 Withdrawn',
                                          '120 Second Review-Pending Docs' ]
                        }
                      end

  let(:create_test_stage) do
    begin
        cli.create_stage(test_stage)
    rescue
    end
  end

  let(:delete_test_stage) do
    begin
        cli.delete_stage(test_stage)
    rescue
    end
  end

  let(:test_stage_2)   do
                        { name: 'Test Stage Two',
                          transition_to: [
                                          '001 New File',
                                          '005 Application and Eligibility' ]
                        }
                      end

  let(:delete_test_stage_2) do
    begin
        cli.delete_stage(test_stage_2)
    rescue
    end
  end


  describe "#modify_stage" do

    context "stage data missing name parameter" do

      let(:missing_name)  do
                            missing_name = test_stage
                            missing_name[:name] = nil
                            missing_name
                          end


      it "will raise exception" do
        expect { cli.modify_stage(missing_name) }.to raise_exception(ArgumentError)
      end


      context "stage name specified" do

        it "stage is modified" do
          create_test_stage

          tmp_test = test_stage_2
          tmp_test[:name] = nil

          cli.modify_stage(test_stage_2, test_stage[:name])
          tmp_test[:name] = test_stage[:name]
          expect(cli.get_stage(test_stage[:name])).to eq tmp_test

          delete_test_stage
          delete_test_stage_2
        end
      end # context
    end # context


    context "stage data has different name" do

      it "stage is renamed" do
          create_test_stage

          cli.modify_stage(test_stage_2, test_stage[:name])
          expect(cli.get_stage(test_stage_2[:name])).to eq test_stage_2

          delete_test_stage
          delete_test_stage_2
      end
    end # context "stage data has different name"

  end # describe "#modify_stage"
end # describe AdminModule

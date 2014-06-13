require 'spec_helper'

describe AdminModule::CLI do

  after(:each) do
    quit_cli
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

  let(:test_stage_2)   do
                        { name: 'Test Stage Two',
                          transition_to: [
                                          '001 New File',
                                          '005 Application and Eligibility' ]
                        }
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
          delete_stage_for_test test_stage
          delete_stage_for_test test_stage_2
          create_stage_for_test test_stage

          stage_name = test_stage[:name]
          tmp_test = test_stage_2
          tmp_test[:name] = nil

          cli.modify_stage(tmp_test, stage_name)
          actual = cli.get_stage stage_name

          # Name is left as is, transitions change.
          expect(actual[:name]).to eq stage_name
          expect(actual[:transition_to]).to eq tmp_test[:transition_to]
        end
      end # context
    end # context


    context "stage data has different name" do

      it "stage is renamed" do
          delete_stage_for_test test_stage
          delete_stage_for_test test_stage_2
          create_stage_for_test test_stage

          cli.modify_stage test_stage_2, test_stage[:name]
          actual = cli.get_stage test_stage_2[:name]

          expect(actual[:name]).to eq test_stage_2[:name]
          expect(actual[:transition_to]).to eq test_stage_2[:transition_to]
      end
    end # context "stage data has different name"

  end # describe "#modify_stage"
end # describe AdminModule

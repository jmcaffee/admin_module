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


  describe "#create_stage" do
    context "stage data missing name parameter" do

      let(:missing_name)  do
                            { name: '',
                              transition_to: [
                                              '001 New File',
                                              '022 Docs Verification',
                                              '060 Reconsideration Exceptions/Overrides',
                                              '096 Withdrawn',
                                              '120 Second Review-Pending Docs' ]
                            }
                          end


      it "will raise exception" do
        expect { cli.create_stage(missing_name) }.to raise_exception(ArgumentError)
      end
    end # context


    context "stage name already exists" do

      let(:name_exists)   do
                            { name: '020 Pending Docs',
                              transition_to: [
                                              '001 New File',
                                              '022 Docs Verification',
                                              '060 Reconsideration Exceptions/Overrides',
                                              '096 Withdrawn',
                                              '120 Second Review-Pending Docs' ]
                            }
                          end


      it "will raise exception" do
        expect { cli.create_stage(name_exists) }.to raise_exception(ArgumentError)
      end
    end # context

    context "stage name does not exist" do

      let(:new_stage) do
                        { name: 'Test Stage',
                          transition_to: [
                                          '001 New File',
                                          '022 Docs Verification',
                                          '060 Reconsideration Exceptions/Overrides',
                                          '096 Withdrawn',
                                          '120 Second Review-Pending Docs' ]
                        }
      end

      it "stage is created" do
        cli.create_stage(new_stage)
        expect(cli.get_stage(new_stage[:name])).to eq new_stage
      end

      it "stage is deleted" do
        cli.delete_stage(new_stage)
        expect{ cli.get_stage(new_stage[:name]) }.to raise_exception
      end
    end # context
  end # describe "#create_stage"

end # describe AdminModule

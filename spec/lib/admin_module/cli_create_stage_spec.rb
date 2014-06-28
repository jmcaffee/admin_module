require 'spec_helper'

describe AdminModule::CLI do

  # Kill the browser after each test.
  after(:each) do
    quit_cli
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
        factory = StageFactory.new
        factory.name('020 Pending Docs')
          .set_transitions([
                          '001 New File',
                          '022 Docs Verification',
                          '060 Reconsideration Exceptions/Overrides',
                          '096 Withdrawn',
                          '120 Second Review-Pending Docs' ])

        factory.data
      end


      it "will raise exception" do
        expect { cli.create_stage(name_exists) }.to raise_exception(ArgumentError)
      end
    end # context

    context "stage name does not exist" do

      let(:new_stage) do
        factory = StageFactory.new
        factory.name('Test Stage')
          .set_transitions([
                          '001 New File',
                          '022 Docs Verification',
                          '060 Reconsideration Exceptions/Overrides',
                          '096 Withdrawn',
                          '120 Second Review-Pending Docs' ])

        factory.data
      end

      it "stage is created" do
        delete_stage_for_test new_stage

        cli.create_stage(new_stage)

        stage_name = new_stage[:name]
        actual = cli.get_stage stage_name

        expect(actual[:name]).to eq stage_name
        expect(actual[:transition_to]).to eq new_stage[:transition_to]
      end

      it "stage is deleted" do
        create_stage_for_test new_stage

        cli.delete_stage(new_stage)
        expect{ cli.get_stage(new_stage[:name]) }.to raise_exception
      end
    end # context
  end # describe "#create_stage"

end # describe AdminModule

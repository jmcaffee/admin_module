require_relative '../spec_helper'

describe AdminModule::CLI do

  # Quit the browser after each test.
  after(:each) do
    quit_cli
  end

#  describe "#get_stage" do
#    context "invalid stage name" do
#      it "will raise exception" do
#        expect { cli.get_stage('invalid') }.to raise_exception(ArgumentError)
#      end
#    end # context "invalid stage name"
#
#
#    context "valid stage name" do
#
#      let(:expected_stage)  do
#        factory = StageFactory.new
#        factory.name('020 Pending Docs').
#          set_transitions([
#                            '001 New File',
#                            '022 Docs Verification',
#                            '060 Reconsideration Exceptions/Overrides',
#                            '096 Withdrawn',
#                            '120 Second Review-Pending Docs'
#                          ]
#          )
#        factory.data
#      end
#
#
#      it "will return stage configuration data" do
#        stage_name = expected_stage[:name]
#        actual = cli.get_stage stage_name
#
#        expect(actual[:name]).to eq stage_name
#        expect(actual[:transition_to]).to eq expected_stage[:transition_to]
#      end
#    end # context "valid stage name"
#  end # describe "#get_stage"

  describe "#export_tasks" do
    context "with filename" do

      let(:target_file)   { 'tmp/spec/admin_module/tasks.yml' }

      before(:each) do
        FileUtils.rm_rf target_file
      end


      it "writes multiple tasks to a file" do
        cli.export_tasks(target_file)
        tasks = read_yaml_data_file(target_file)
        expect(tasks.size).to eq 49
      end
    end # context
  end # describe "#export_tasks"
end # describe AdminModule

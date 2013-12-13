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

  let(:test_stage_missing_stages)   do
                        { name: 'Test Stage With Missing Stages',
                          transition_to: [
                                          'Z Test Stage 1',
                                          'Z Test Stage 2',
                                          'Z Test Stage 3' ]
                        }
                      end

  let(:create_test_stage_missing_stages) do
    begin
        cli.create_stage(test_stage_missing_stages)
    rescue
    end
  end

  let(:delete_test_stage_missing_stages) do
    begin
        cli.delete_stage(test_stage_missing_stages)
    rescue
    end
  end



  describe "#import_stages" do
    context "with filename" do

      let(:src_file_path)   { 'tmp/spec/admin_module/stages.yml' }
      let(:src_file)        { write_yaml_data_file(src_file_path, {test_stage[:name] => test_stage}); src_file_path }

      let(:bad_src_file_path) { 'tmp/spec/admin_module/stages_bad.yml' }
      let(:bad_src_file)      { write_yaml_data_file(bad_src_file_path, {test_stage_missing_stages[:name] => test_stage_missing_stages}); bad_src_file_path }


      it "configures stages sourced from a file" do
        delete_test_stage

        cli.import_stages(src_file)
        expect(cli.get_stage(test_stage[:name])).to eq test_stage

        delete_test_stage
      end

      context "with non-existing stage names" do
        it "raises an exception" do
          delete_test_stage_missing_stages

          expect { cli.import_stages(bad_src_file) }.to raise_exception

          delete_test_stage_missing_stages
          delete_test_stage
        end
      end
    end # context

    context "with invalid filename" do
      it "raises an IOError" do
        expect { cli.import_stages('does_not_exist.yml') }.to raise_exception(IOError)
      end
    end

  end # describe "#import_stages"
end # describe AdminModule

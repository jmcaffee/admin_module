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

  describe "#get_lock" do
    context "invalid lock name" do
      it "will raise exception" do
        expect { cli.get_lock('invalid') }.to raise_exception(ArgumentError)
      end
    end # context "invalid lock name"


    context "valid lock name" do

      let(:expected_income_lock)  do
                                    { name: 'IncomeLock',
                                      description: '',
                                      is_program_lock: false,
                                      parameters: [ 'Monthly Gross Income' ],
                                      dts: []
                                    }
                                  end


      it "will return lock configuration data" do
        expect( cli.get_lock('IncomeLock') ).to eq expected_income_lock
      end
    end # context "valid lock name"
  end # describe "#get_lock"

  describe "#export_locks" do
    context "with filename" do

      let(:target_file)   { 'tmp/spec/admin_module/locks.yml' }

      before(:each) do
        FileUtils.rm_rf target_file
      end


      it "writes multiple locks to a file" do
        cli.export_locks(target_file)
        locks = read_yaml_data_file(target_file)
        expect(locks.size).to eq 12
      end
    end # context
  end # describe "#export_locks"
end # describe AdminModule

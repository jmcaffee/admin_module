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

  describe "#deploy" do
    context "with invalid source file" do
      it "will raise an IOError exception" do
        expect { cli.deploy('source_xml.xml', 'dest_gdl_name') }.to raise_exception(IOError)
      end
    end # context "with invalid source file"

    context "with valid source file" do
      let(:data_dir)          { 'spec/data' }
      let(:test_source_file)  { File.join(data_dir, 'patch-test.xml') }

      AdminModule.configure do |config|
        config.aliases = { 'temp' => 'Z-TEMP' }
      end


      it "deploys to default environment" do
        expect { cli.deploy(test_source_file, 'Z-TEMP') }.not_to raise_exception
      end
    end # context "with invalid source file"
  end


  describe "#deploy_files" do
    context "with one invalid source file" do
      it "will raise an IOError exception" do
        expect { cli.deploy_files(['source_xml.xml'], 'Multi-upload fail test') }.to raise_exception(IOError)
      end
    end

    context "with valid source files" do
      let(:data_dir)          { 'spec/data' }
      let(:test_source_file1) { File.join(data_dir, 'patch-test.xml') }
      let(:test_source_file2) { File.join(data_dir, 'patch-test.xml') }
      let(:test_source_files) { [test_source_file1, test_source_file2] }

      AdminModule.configure do |config|
        config.aliases = { 'patch-test' => 'Z-TEMP' }
        config.browser_timeout = 359
      end


      it "deploys to default environment" do
        expect { cli.deploy_files(test_source_files, 'Multi-upload test') }.not_to raise_exception
      end
    end # context "with invalid source file"
  end

end # describe AdminModule

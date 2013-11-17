require 'spec_helper'

describe AdminModule::CLI do

  let(:cli) { AdminModule::CLI.new }

  after(:each) do
    cli.quit
  end

  describe "#environment=" do

    context "sets the environment to use" do

      context "when set to :sit" do
        let(:cli) do
          cli = AdminModule::CLI.new
          cli.environment = :sit
          cli
        end

        it "#environment returns :sit" do
          expect(cli.environment).to eq :sit
        end

        it "#credentials returns values for :sit" do
          expect(cli.credentials).to eq ['admin', 'Password11*']
        end

        it "#base_url returns values for :sit" do
          expect(cli.base_url).to eq "http://207.38.119.211/fap2SIT/Admin"
        end
      end
    end

    #context "with :test configured as default environment" do
    #  AdminModule.configure do |config|
    #    config.default_environment = :test
    #  end

    #  it "returns :test" do
    #    expect(cli.environment).to eq :test
    #  end
    #end # context "with invalid source file"
  end

  describe "#environment" do

    context "returns default environment if not overridden" do

      it "returns :dev" do
        expect(cli.environment).to eq :dev
      end
    end

    #context "with :test configured as default environment" do
    #  AdminModule.configure do |config|
    #    config.default_environment = :test
    #  end

    #  it "returns :test" do
    #    expect(cli.environment).to eq :test
    #  end
    #end # context "with invalid source file"
  end

  describe "#credentials" do

    context "returns default credentials if not overridden" do

      it "returns :dev's credentials" do
        expect(cli.credentials).to eq ["admin", "Password1*"]
      end
    end
  end

  describe "#base_urls" do

    context "returns default urls if not overridden" do

      it "returns :dev's base url" do
        expect(cli.base_url).to eq "http://207.38.119.211/fap2Dev/Admin"
      end
    end
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
      end

      it "deploys to default environment" do
        expect { cli.deploy_files(test_source_files, 'Multi-upload test') }.not_to raise_exception
      end
    end # context "with invalid source file"
  end


end # describe AdminModule

require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

require 'admin_module'

describe 'gdl command' do

  let(:guideline_page_stub) do
    obj = double('guideline_page')
    obj
  end

  let(:guidelines_page_stub) do
    obj = double('guidelines_page')
    #obj.stub(:add_version).and_return(obj)
    #obj.stub(:upload).and_return(obj)
    obj
  end

  let(:page_factory) do
    obj = MockPageFactory.new
    obj.login_page = double('login_page')
    obj.guidelines_page = guidelines_page_stub
    obj
  end

  let(:default_comment) { 'no comment' }

  let(:cli) { AdminModule::CLI }

  let(:guideline_obj) { mock_guideline(page_factory) }

  before do
    allow_any_instance_of(AdminModule::Client)
      .to receive(:page_factory)
      .and_return(page_factory)

    allow_any_instance_of(AdminModule::Client)
      .to receive(:guideline)
      .and_return(guideline_obj)

    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
      config.xmlmaps['test1'] = 'Z-TEMP'
      config.xmlmaps['test2'] = 'Z-TEMP2'
    end
  end

  context "gdl deploy" do
    it "deploys multiple guidelines" do
      expect_any_instance_of(AdminModule::Client)
        .to receive(:user=)
        .with('user')

      expect_any_instance_of(AdminModule::Client)
        .to receive(:password=)
        .with('pass')

      expect_any_instance_of(AdminModule::Client)
        .to receive(:guideline)

      expect(guideline_obj)
        .to receive(:deploy)

      expect_any_instance_of(AdminModule::Client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %W(gdl deploy -e dev #{build_dir})
    end

    it "deploys a single guideline" do
      build_dir = data_dir('build')
      file_to_upload = Pathname(build_dir) + 'test1.xml'

      expect_any_instance_of(AdminModule::Client)
        .to receive(:user=)
        .with('user')

      expect_any_instance_of(AdminModule::Client)
        .to receive(:password=)
        .with('pass')

      expect_any_instance_of(AdminModule::Client)
        .to receive(:guideline)

      expect(guideline_obj)
        .to receive(:deploy_file)
        .with(file_to_upload, anything)

      expect_any_instance_of(AdminModule::Client)
        .to receive(:logout)

      run_with_args %W(gdl deploy -f test1.xml -e dev #{build_dir})
    end
  end

  context "gdl version" do
    it "versions multiple guidelines" do
      expect_any_instance_of(AdminModule::Client)
        .to receive(:user=)
        .with('user')

      expect_any_instance_of(AdminModule::Client)
        .to receive(:password=)
        .with('pass')

      expect_any_instance_of(AdminModule::Client)
        .to receive(:guideline)

      expect(guideline_obj)
        .to receive(:version)
        .with(['Z-TEMP', 'Z-TEMP2'], anything)

      expect_any_instance_of(AdminModule::Client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %w(gdl version -e dev)
    end

    context "with --target option" do
      it "versions specified guideline" do
        expect_any_instance_of(AdminModule::Client)
          .to receive(:user=)
          .with('user')

        expect_any_instance_of(AdminModule::Client)
          .to receive(:password=)
          .with('pass')

        expect_any_instance_of(AdminModule::Client)
          .to receive(:guideline)

        expect(guideline_obj)
          .to receive(:version)
          .with(['TestGdl'], anything)

        expect_any_instance_of(AdminModule::Client)
          .to receive(:logout)

        build_dir = data_dir('build')
        run_with_args %w(gdl version -e dev --target TestGdl)
      end
    end
  end

  it "returns help info" do
    output = capture_output do
      cli.start %w(help gdl)
    end

    expect( output ).to include "gdl help [COMMAND]"
    expect( output ).to include "gdl deploy <srcdir> <comments>"
    expect( output ).to include "gdl version <comments>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


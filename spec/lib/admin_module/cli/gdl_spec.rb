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

  context "gdl deploy" do
    it "deploys multiple guidelines" do
      AdminModule::ConfigHelper.page_factory = page_factory

      AdminModule.configure do |config|
        config.credentials[:dev] = ['user', 'pass']
        config.xmlmaps['test1'] = 'Z-TEMP'
        config.xmlmaps['test2'] = 'Z-TEMP'
      end

      expect(page_factory.login_page)
        .to receive(:login_as)
        .with('user', 'pass')

      expect(page_factory.guidelines_page)
        .to receive(:open_guideline)
        .with('Z-TEMP')
        .and_return(guideline_page_stub)
        .twice

      expect(guideline_page_stub)
        .to receive(:add_version)
        .and_return(guideline_page_stub)
        .twice

      expect(guideline_page_stub)
        .to receive(:upload)
        .and_return(page_factory.guidelines_page)
        .twice

      expect(page_factory.login_page)
        .to receive(:logout)

      build_dir = data_dir('build')
      cli.start %W(gdl deploy -e dev #{build_dir})
    end

    it "deploys a single guideline" do
      AdminModule::ConfigHelper.page_factory = page_factory

      AdminModule.configure do |config|
        config.credentials[:dev] = ['user', 'pass']
        config.xmlmaps['test1'] = 'Z-TEMP'
        config.xmlmaps['test2'] = 'Z-TEMP'
      end

      build_dir = data_dir('build')
      file_to_upload = Pathname(build_dir) + 'test1.xml'

      expect(page_factory.login_page)
        .to receive(:login_as)
        .with('user', 'pass')

      expect(page_factory.guidelines_page)
        .to receive(:open_guideline)
        .with('Z-TEMP')
        .and_return(guideline_page_stub)

      expect(guideline_page_stub)
        .to receive(:add_version)
        .and_return(guideline_page_stub)

      expect(guideline_page_stub)
        .to receive(:upload)
        .with(file_to_upload, default_comment)

      expect(page_factory.login_page)
        .to receive(:logout)

      cli.start %W(gdl deploy -f test1.xml -e dev #{build_dir})
    end
  end

  context "gdl version" do
    it "versions multiple guidelines" do
      AdminModule::ConfigHelper.page_factory = page_factory

      AdminModule.configure do |config|
        config.credentials[:dev] = ['user', 'pass']
        config.xmlmaps['test1'] = 'Z-TEMP'
        config.xmlmaps['test2'] = 'Z-TEMP2'
      end

      expect(page_factory.login_page)
        .to receive(:login_as)
        .with('user', 'pass')

      expect(page_factory.guidelines_page)
        .to receive(:version_all)
        .and_return(page_factory.guidelines_page)

      expect(page_factory.guidelines_page)
        .to receive(:version)
        .with(['Z-TEMP', 'Z-TEMP2'], default_comment)
        .and_return(page_factory.guidelines_page)

      expect(page_factory.login_page)
        .to receive(:logout)

      build_dir = data_dir('build')
      cli.start %w(gdl version -e dev)
    end

    context "with --target option" do
      it "versions specified guideline" do
        AdminModule::ConfigHelper.page_factory = page_factory

        AdminModule.configure do |config|
          config.credentials[:dev] = ['user', 'pass']
          config.xmlmaps['test1'] = 'Z-TEMP'
          config.xmlmaps['test2'] = 'Z-TEMP2'
        end

        expect(page_factory.login_page)
          .to receive(:login_as)
          .with('user', 'pass')

        expect(page_factory.guidelines_page)
          .to receive(:version_all)
          .and_return(page_factory.guidelines_page)

        expect(page_factory.guidelines_page)
          .to receive(:version)
          .with(['TestGdl'], anything())
          .and_return(page_factory.guidelines_page)

        expect(page_factory.login_page)
          .to receive(:logout)

        build_dir = data_dir('build')
        cli.start %w(gdl version -e dev --target TestGdl)
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


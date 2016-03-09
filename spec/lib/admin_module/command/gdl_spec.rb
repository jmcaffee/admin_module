require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe 'gdl command' do

  let(:page_factory) do
    obj = MockPageFactory.new
    obj.login_page = double('login_page')
    obj.guidelines_page = double('guidelines_page')
    obj
  end

  let(:guideline_mock) { mock_guideline(page_factory) }

  let(:client) { AdminModule::Client.new }

  before do
    AdminModule.configure do |config|
      config.credentials.clear
      config.credentials[:dev] = ['user', 'pass']
      config.xmlmaps.clear
      config.xmlmaps['test1'] = 'Z-TEMP'
      config.xmlmaps['test2'] = 'Z-TEMP2'
    end

    allow(client)
      .to receive(:guideline)
      .and_return(guideline_mock)
  end

  context "gdl deploy" do
    it "deploys multiple guidelines" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:guideline)

      expect(guideline_mock)
        .to receive(:deploy)

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %W(gdl deploy -e dev #{build_dir}), client
    end

    it "deploys a single guideline" do
      build_dir = data_dir('build')
      file_to_upload = Pathname(build_dir) + 'test1.xml'

      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:guideline)

      expect(guideline_mock)
        .to receive(:deploy_file)
        .with(file_to_upload, anything)

      expect(client)
        .to receive(:logout)

      run_with_args %W(gdl deploy -f test1.xml -e dev #{build_dir}), client
    end
  end

  context "gdl download" do
    it "downloads a single guideline" do
      build_dir = data_dir('build')
      gdl_to_download = 'Z-TEMP'
      download_path = Pathname(build_dir) + 'Z-TEMP.xml'

      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:guideline)

      expect(guideline_mock)
        .to receive(:download)
        .with(gdl_to_download, download_path.to_s)

      expect(client)
        .to receive(:logout)

      run_with_args %W(gdl download -e dev Z-TEMP #{download_path}), client
    end
  end

  context "gdl version" do
    it "versions multiple guidelines" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:guideline)

      expect(guideline_mock)
        .to receive(:version)
        .with(['Z-TEMP', 'Z-TEMP2'], anything)

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %w(gdl version -e dev), client
    end

    context "with --target option" do
      it "versions specified guideline" do
        expect(client)
          .to receive(:user=)
          .with('user')

        expect(client)
          .to receive(:password=)
          .with('pass')

        expect(client)
          .to receive(:guideline)

        expect(guideline_mock)
          .to receive(:version)
          .with(['TestGdl'], anything)

        expect(client)
          .to receive(:logout)

        build_dir = data_dir('build')
        run_with_args %w(gdl version -e dev --target TestGdl), client
      end
    end
  end

  it "returns help info" do
    output = capture_output do
      run_with_args %w(help gdl)
    end

    expect( output ).to include "gdl help [COMMAND]"
    expect( output ).to include "gdl deploy <srcdir> <comments>"
    expect( output ).to include "gdl download <guideline> <to_path>"
    expect( output ).to include "gdl version <comments>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


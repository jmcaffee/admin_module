require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe 'command dc' do

  let(:login_page) do
    obj = double('login_page')
    allow(obj)
      .to receive(:logout)
    obj
  end

  let(:page_factory) do
    obj = MockPageFactory.new
    obj.login_page = login_page
    obj.dc_page = double('dc_page')
    obj
  end

  let(:dc_mock) { mock_dc(page_factory) }

  let(:client) do
    obj = AdminModule::Client.new
    obj.page_factory = page_factory
    obj
  end

  let(:dc_list) { ['dc1', 'dc2', 'dc 33'] }

  before do
    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
    end

    allow(client)
      .to receive(:dcs)
      .and_return(dc_mock)
  end

  context "list" do
    it "displays list of dataclearing configs" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:dcs)

      expect(dc_mock)
        .to receive(:list)
        .and_return(dc_list)

      expect(client)
        .to receive(:logout)

      output = capture_output do
        run_with_args %W(dc list -e dev), client
      end

      expect( output ).to include dc_list[0]
      expect( output ).to include dc_list[1]
      expect( output ).to include dc_list[2]
    end
  end

  context "rename" do
    it "renames a dataclearing configuration" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:dcs)

      expect(dc_mock)
        .to receive(:rename)
        .with('TestDC1', 'TestDC2')

      expect(client)
        .to receive(:logout)

      run_with_args %w(dc rename -e dev TestDC1 TestDC2), client
    end

    it "displays a helpful message if rename fails" do
      msg = 'rename failed'

      expect(dc_mock)
        .to receive(:rename)
        .and_raise(ArgumentError, msg)

      output = capture_output do
        run_with_args %w(dc rename -e dev TestDC1 TestDC2), client
      end

      expect( output ).to include msg
    end
  end

  context "import" do
    it "imports a dc yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:dcs)

      expect(dc_mock)
        .to receive(:import)
        .with('path/to/import/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(dc import -e dev path/to/import/file), client
    end
  end

  context "export" do
    it "exports a dc yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:dcs)

      expect(dc_mock)
        .to receive(:export)
        .with('path/to/export/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(dc export -e dev path/to/export/file), client
    end
  end

  context "read" do
    it "dumps a dc's configuration to the console" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:dcs)

      expect(dc_mock)
        .to receive(:read)
        .with('TestDC1')
        .and_return(create_dc_hash('TestDC1'))

      expect(client)
        .to receive(:logout)

      output = capture_output do
        run_with_args %w(dc read -e dev TestDC1), client
      end

      normalized_yaml = create_dc_hash('TestDC1').to_yaml

      expect( output ).to include normalized_yaml
    end
  end

  it "returns help info" do
    output = capture_output do
      run_with_args %w(help dc)
    end

    expect( output ).to include "dc help [COMMAND]"
    expect( output ).to include "dc list"
    expect( output ).to include "dc import <filepath>"
    expect( output ).to include "dc export <filepath>"
    expect( output ).to include "dc rename <srcname> <destname>"
    expect( output ).to include "dc read <name>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


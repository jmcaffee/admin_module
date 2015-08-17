require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe 'command snapshot' do

  let(:login_page) do
    obj = double('login_page')
    allow(obj)
      .to receive(:logout)
    obj
  end

  let(:page_factory) do
    obj = MockPageFactory.new
    obj.login_page = login_page
    obj.snapshot_definitions_page = double('snapshot_page')
    obj
  end

  let(:snapshot_mock) { mock_snapshots(page_factory) }

  let(:client) do
    obj = AdminModule::Client.new
    obj.page_factory = page_factory
    obj
  end

  let(:snapshot_list) { ['snapshot1', 'snapshot2', 'snapshot 33'] }

  before do
    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
    end

    allow(client)
      .to receive(:snapshots)
      .and_return(snapshot_mock)
  end

  context "list" do
    it "displays list of snapshot configs" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:snapshots)

      expect(snapshot_mock)
        .to receive(:list)
        .and_return(snapshot_list)

      expect(client)
        .to receive(:logout)

      output = capture_output do
        run_with_args %W(snapshot list -e dev), client
      end

      expect( output ).to include snapshot_list[0]
      expect( output ).to include snapshot_list[1]
      expect( output ).to include snapshot_list[2]
    end
  end

  context "rename" do
    it "renames a snapshot configuration" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:snapshots)

      expect(snapshot_mock)
        .to receive(:rename)
        .with('TestSnapshot1', 'TestSnapshot2')

      expect(client)
        .to receive(:logout)

      run_with_args %w(snapshot rename -e dev TestSnapshot1 TestSnapshot2), client
    end

    it "displays a helpful message if rename fails" do
      msg = 'rename failed'

      expect(snapshot_mock)
        .to receive(:rename)
        .and_raise(ArgumentError, msg)

      output = capture_output do
        run_with_args %w(snapshot rename -e dev TestSnapshot1 TestSnapshot2), client
      end

      expect( output ).to include msg
    end
  end

  context "import" do
    it "imports a snapshot yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:snapshots)

      expect(snapshot_mock)
        .to receive(:import)
        .with('path/to/import/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(snapshot import -e dev path/to/import/file), client
    end
  end

  context "export" do
    it "exports a snapshot yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:snapshots)

      expect(snapshot_mock)
        .to receive(:export)
        .with('path/to/export/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(snapshot export -e dev path/to/export/file), client
    end
  end

  context "read" do
    it "dumps a snapshot's configuration to the console" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:snapshots)

      expect(snapshot_mock)
        .to receive(:read)
        .with('TestSnapshot1')
        .and_return(create_snapshot_hash('TestSnapshot1'))

      expect(client)
        .to receive(:logout)

      output = capture_output do
        run_with_args %w(snapshot read -e dev TestSnapshot1), client
      end

      normalized_yaml = create_snapshot_hash('TestSnapshot1')
      normalized_yaml = { 'TestSnapshot1' => normalized_yaml }.to_yaml

      expect( output ).to include normalized_yaml
    end
  end

  it "returns help info" do
    output = capture_output do
      run_with_args %w(help snapshot)
    end

    expect( output ).to include "snapshot help [COMMAND]"
    expect( output ).to include "snapshot list"
    expect( output ).to include "snapshot import <filepath>"
    expect( output ).to include "snapshot export <filepath>"
    expect( output ).to include "snapshot rename <srcname> <destname>"
    expect( output ).to include "snapshot read <name>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


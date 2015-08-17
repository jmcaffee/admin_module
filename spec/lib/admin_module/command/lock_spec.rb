require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}


describe 'command lock' do

  let(:login_page) do
    obj = double('login_page')
    allow(obj)
      .to receive(:logout)
    obj
  end

  let(:page_factory) do
    obj = MockPageFactory.new
    obj.login_page = login_page
    obj.guidelines_page = double('guidelines_page')
    obj.locks_page = double('locks_page')
    obj
  end

  let(:locks_mock) { mock_locks(page_factory) }

  let(:client) do
    obj = AdminModule::Client.new
    obj.page_factory = page_factory
    obj
  end

  let(:lock_list) { ['Lock1', 'Lock2', 'Lock 33'] }

  before do
    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
    end

    allow(client)
      .to receive(:locks)
      .and_return(locks_mock)
  end

  context "list" do
    it "displays list of locks" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:locks)

      expect(locks_mock)
        .to receive(:list)
        .and_return(lock_list)

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')

      output = capture_output do
        run_with_args %W(lock list -e dev), client
      end

      expect( output ).to include lock_list[0]
      expect( output ).to include lock_list[1]
      expect( output ).to include lock_list[2]
    end
  end

  context "rename" do
    it "renames a lock" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:locks)

      expect(locks_mock)
        .to receive(:rename)
        .with('TestLock1', 'TestLock2')

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %w(lock rename -e dev TestLock1 TestLock2), client
    end

    it "displays a helpful message if rename fails" do
      msg = 'rename failed'

      expect(locks_mock)
        .to receive(:rename)
        .and_raise(ArgumentError, msg)

      output = capture_output do
        run_with_args %w(lock rename -e dev TestLock1 TestLock2), client
      end

      expect( output ).to include msg
    end
  end

  context "import" do
    it "imports a locks yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:locks)

      expect(locks_mock)
        .to receive(:import)
        .with('path/to/import/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(lock import -e dev path/to/import/file), client
    end
  end

  context "export" do
    it "exports a locks yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:locks)

      expect(locks_mock)
        .to receive(:export)
        .with('path/to/export/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(lock export -e dev path/to/export/file), client
    end
  end

  context "read" do
    it "dumps a lock's configuration to the console" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:locks)

      expect(locks_mock)
        .to receive(:read)
        .with('TestLock1')
        .and_return(create_lock_hash('TestLock1'))

      expect(client)
        .to receive(:logout)

      output = capture_output do
        run_with_args %w(lock read -e dev TestLock1), client
      end

      normalized_yaml = create_lock_hash('TestLock1')
      normalized_yaml = { 'TestLock1' => normalized_yaml }.to_yaml

      expect( output ).to include normalized_yaml
    end
  end

  it "returns help info" do
    output = capture_output do
      run_with_args %w(help lock)
    end

    expect( output ).to include "lock help [COMMAND]"
    expect( output ).to include "lock list"
    expect( output ).to include "lock import <filepath>"
    expect( output ).to include "lock export <filepath>"
    expect( output ).to include "lock rename <srcname> <destname>"
    expect( output ).to include "lock read <name>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


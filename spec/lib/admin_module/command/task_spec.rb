require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}


describe 'command task' do

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
    obj.tasks_page = double('tasks_page')
    obj
  end

  let(:tasks_mock) { mock_tasks(page_factory) }

  let(:client) do
    obj = AdminModule::Client.new
    obj.page_factory = page_factory
    obj
  end

  let(:task_list) { ['Task1', 'Task2', 'Task 33'] }

  before do
    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
    end

    allow(client)
      .to receive(:tasks)
      .and_return(tasks_mock)
  end

  context "list" do
    it "displays list of tasks" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:tasks)

      expect(tasks_mock)
        .to receive(:list)
        .and_return(task_list)

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')

      output = capture_output do
        run_with_args %W(task list -e dev), client
      end

      expect( output ).to include task_list[0]
      expect( output ).to include task_list[1]
      expect( output ).to include task_list[2]
    end
  end

  context "rename" do
    it "renames a task" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:tasks)

      expect(tasks_mock)
        .to receive(:rename)
        .with('TestTask1', 'TestTask2')

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %w(task rename -e dev TestTask1 TestTask2), client
    end

    it "displays a helpful message if rename fails" do
      msg = 'rename failed'

      expect(tasks_mock)
        .to receive(:rename)
        .and_raise(ArgumentError, msg)

      output = capture_output do
        run_with_args %w(task rename -e dev TestTask1 TestTask2), client
      end

      expect( output ).to include msg
    end
  end

  context "import" do
    it "imports a tasks yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:tasks)

      expect(tasks_mock)
        .to receive(:import)
        .with('path/to/import/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(task import -e dev path/to/import/file), client
    end
  end

  context "export" do
    it "exports a tasks yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:tasks)

      expect(tasks_mock)
        .to receive(:export)
        .with('path/to/export/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(task export -e dev path/to/export/file), client
    end
  end

  context "read" do
    it "dumps a task's configuration to the console" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:tasks)

      expect(tasks_mock)
        .to receive(:read)
        .with('TestTask1')
        .and_return(create_task_hash('TestTask1'))

      expect(client)
        .to receive(:logout)

      output = capture_output do
        run_with_args %w(task read -e dev TestTask1), client
      end

      normalized_yaml = create_task_hash('TestTask1')
      normalized_yaml = { 'TestTask1' => normalized_yaml }.to_yaml

      expect( output ).to include normalized_yaml
    end
  end

  it "returns help info" do
    output = capture_output do
      run_with_args %w(help task)
    end

    expect( output ).to include "task help [COMMAND]"
    expect( output ).to include "task list"
    expect( output ).to include "task import <filepath>"
    expect( output ).to include "task export <filepath>"
    expect( output ).to include "task rename <srcname> <destname>"
    expect( output ).to include "task read <name>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


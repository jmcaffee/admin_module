require 'spec_helper'

describe 'command stage' do

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
    obj.stages_page = double('stages_page')
    obj
  end

  let(:stages_mock) { mock_stages(page_factory) }

  let(:client) do
    obj = AdminModule::Client.new
    obj.page_factory = page_factory
    obj
  end

  let(:stage_list) { ['Stage1', 'Stage2', 'Stage 33'] }

  before do
    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
    end

    allow(client)
      .to receive(:stages)
      .and_return(stages_mock)
  end

  context "list" do
    it "displays list of stages" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:stages)

      expect(stages_mock)
        .to receive(:list)
        .and_return(stage_list)

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')

      output = capture_output do
        run_with_args %W(stage list -e dev), client
      end

      expect( output ).to include stage_list[0]
      expect( output ).to include stage_list[1]
      expect( output ).to include stage_list[2]
    end
  end

  context "rename" do
    it "renames a stage" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:stages)

      expect(stages_mock)
        .to receive(:rename)
        .with('TestStage1', 'TestStage2')

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %w(stage rename -e dev TestStage1 TestStage2), client
    end

    it "displays a helpful message if rename fails" do
      msg = 'rename failed'

      expect(stages_mock)
        .to receive(:rename)
        .and_raise(ArgumentError, msg)

      output = capture_output do
        run_with_args %w(stage rename -e dev TestStage1 TestStage2), client
      end

      expect( output ).to include msg
    end
  end

  context "import" do
    it "imports a stages yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:stages)

      expect(stages_mock)
        .to receive(:import)
        .with('path/to/import/file', false)

      expect(client)
        .to receive(:logout)

      run_with_args %w(stage import -e dev path/to/import/file), client
    end

    it "allows stage creation during import of a yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:stages)

      expect(stages_mock)
        .to receive(:import)
        .with('path/to/import/file', true)

      expect(client)
        .to receive(:logout)

      run_with_args %w(stage import -e dev -c path/to/import/file), client
    end
  end

  context "export" do
    it "exports a stages yaml file" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:stages)

      expect(stages_mock)
        .to receive(:export)
        .with('path/to/export/file')

      expect(client)
        .to receive(:logout)

      run_with_args %w(stage export -e dev path/to/export/file), client
    end
  end

  context "delete" do
    it "deletes a stage" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:stages)

      expect(stages_mock)
        .to receive(:delete)
        .with('SomeStageName')

      expect(client)
        .to receive(:logout)

      run_with_args %w(stage delete -e dev SomeStageName), client
    end
  end

  context "read" do
    it "dumps a stage's configuration to the console" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:stages)

      expect(stages_mock)
        .to receive(:read)
        .with('TestStage1')
        .and_return(create_stage_hash('TestStage1'))

      expect(client)
        .to receive(:logout)

      output = capture_output do
        run_with_args %w(stage read -e dev TestStage1), client
      end

      normalized_yaml = create_stage_hash('TestStage1').to_yaml

      expect( output ).to include normalized_yaml
    end
  end

  it "returns help info" do
    output = capture_output do
      run_with_args %w(help stage)
    end

    expect( output ).to include "stage help [COMMAND]"
    expect( output ).to include "stage list"
    expect( output ).to include "stage import <filepath>"
    expect( output ).to include "stage export <filepath>"
    expect( output ).to include "stage rename <srcname> <destname>"
    expect( output ).to include "stage delete <name>"
    expect( output ).to include "stage read <name>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


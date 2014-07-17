require 'spec_helper'

describe 'ruleset command' do

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
    obj.rulesets_page = double('rulesets_page')
    obj
  end

  let(:rulesets_mock) { mock_rulesets(page_factory) }

  let(:client) do
    obj = AdminModule::Client.new
    obj.page_factory = page_factory
    obj
  end

  let(:ruleset_list) { ['Ruleset1', 'Ruleset2', 'Ruleset 33'] }

  before do
    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
    end

    allow(client)
      .to receive(:rulesets)
      .and_return(rulesets_mock)
  end

  context "ruleset list" do
    it "displays list of rulesets" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:rulesets)

      expect(rulesets_mock)
        .to receive(:list)
        .and_return(ruleset_list)

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')

      output = capture_output do
        run_with_args %W(ruleset list -e dev), client
      end

      expect( output ).to include ruleset_list[0]
      expect( output ).to include ruleset_list[1]
      expect( output ).to include ruleset_list[2]
    end
  end

  context "ruleset rename" do
    it "renames a ruleset" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:rulesets)

      expect(rulesets_mock)
        .to receive(:rename)
        .with('TestRuleset1', 'TestRuleset2')

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %w(ruleset rename -e dev TestRuleset1 TestRuleset2), client
    end

    it "displays a helpful message if rename fails" do
      msg = 'rename failed'

      expect(rulesets_mock)
        .to receive(:rename)
        .and_raise(ArgumentError, msg)

      output = capture_output do
        run_with_args %w(ruleset rename -e dev TestRuleset1 TestRuleset2), client
      end

      expect( output ).to include msg
    end
  end

  it "returns help info" do
    output = capture_output do
      run_with_args %w(help ruleset)
    end

    expect( output ).to include "ruleset help [COMMAND]"
    expect( output ).to include "ruleset list"
    expect( output ).to include "ruleset rename <srcname> <destname>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


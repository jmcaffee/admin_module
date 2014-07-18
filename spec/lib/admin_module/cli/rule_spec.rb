require 'spec_helper'

describe 'rule command' do

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
    obj.rules_page = double('rules_page')
    obj
  end

  let(:rules_mock) { mock_rules(page_factory) }

  let(:client) do
    obj = AdminModule::Client.new
    obj.page_factory = page_factory
    obj
  end

  let(:rule_list) { ['Rule1', 'Rule2', 'Rule 33'] }

  before do
    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
    end

    allow(client)
      .to receive(:rules)
      .and_return(rules_mock)
  end

  context "rule list" do
    it "displays list of rules" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:rules)

      expect(rules_mock)
        .to receive(:list)
        .and_return(rule_list)

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')

      output = capture_output do
        run_with_args %W(rule list -e dev), client
      end

      expect( output ).to include rule_list[0]
      expect( output ).to include rule_list[1]
      expect( output ).to include rule_list[2]
    end
  end

  context "rule rename" do
    it "renames a rule" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:rules)

      expect(rules_mock)
        .to receive(:rename)
        .with('TestRule1', 'TestRule2')

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %w(rule rename -e dev TestRule1 TestRule2), client
    end

    it "displays a helpful message if rename fails" do
      msg = 'rename failed'

      expect(rules_mock)
        .to receive(:rename)
        .and_raise(ArgumentError, msg)

      output = capture_output do
        run_with_args %w(rule rename -e dev TestRule1 TestRule2), client
      end

      expect( output ).to include msg
    end
  end

  context "rule delete" do
    it "deletes a rule" do
      expect(client)
        .to receive(:user=)
        .with('user')

      expect(client)
        .to receive(:password=)
        .with('pass')

      expect(client)
        .to receive(:rules)

      expect(rules_mock)
        .to receive(:delete)
        .with('TestRule1')

      expect(client)
        .to receive(:logout)

      build_dir = data_dir('build')
      run_with_args %w(rule delete -e dev TestRule1), client
    end

    it "displays a helpful message if delete fails" do
      msg = 'delete failed'

      expect(rules_mock)
        .to receive(:delete)
        .and_raise(ArgumentError, msg)

      output = capture_output do
        run_with_args %w(rule delete -e dev TestRule1), client
      end

      expect( output ).to include msg
    end
  end

  it "returns help info" do
    output = capture_output do
      run_with_args %w(help rule)
    end

    expect( output ).to include "rule help [COMMAND]"
    expect( output ).to include "rule list"
    expect( output ).to include "rule rename <srcname> <destname>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


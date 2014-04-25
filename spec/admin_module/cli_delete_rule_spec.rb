require 'spec_helper'

describe AdminModule::CLI do

  let(:cli) do
              AdminModule.configure do |config|
                config.credentials = { :dev => ['admin', 'Password1*'] }
              end
              AdminModule::CLI.new
            end

      after(:each) do
        cli.quit
      end

  let(:non_existant_rule_name) { 'Z-NotARule' }
  let(:test_rule_name) { 'Z-TestDelRule' }
  let(:test_rule_xml) { 'spec/data/test_del_rule.xml' }
  let(:remove_test_rule_xml) { 'spec/data/remove_test_del_rule.xml' }


  describe "#delete_rule" do

    context "invalid parameters" do

      context "missing rule name parameter" do

        it "will raise exception" do
          expect { cli.delete_rule(nil) }.to raise_exception(ArgumentError)
          expect { cli.delete_rule('') }.to raise_exception(ArgumentError)
        end

      end # context

      context "rule does not exist" do

        it "will raise exception" do
          expect { cli.delete_rule(non_existant_rule_name) }.to raise_exception(ArgumentError)
        end
      end # context
    end # context

    context "valid parameters" do

      it "rule is deleted" do
        # Create a rule to delete.
        cli.deploy test_rule_xml, 'Z-TEMP', 'Running cli_delete_spec - step 1: Add Z-TestDelRule.'
        # Have to upload another gdl so we don't have a guideline pointing to
        # the rule we're going to delete.
        cli.deploy remove_test_rule_xml, 'Z-TEMP', 'Running cli_delete_spec - step 2: Remove Z-TestDelRule.'

        cli.delete_rule(test_rule_name)
        expect(cli.get_rules().include?(test_rule_name)).to eq false
      end
    end # context
  end # describe "#delete_rule"
end # describe AdminModule

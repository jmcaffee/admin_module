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

  let(:old_rule_name) { 'Z-TestDummy' }
  let(:new_rule_name) { 'Z-NewTestDummy' }


  describe "#rename_rule" do

    context "invalid parameters" do

      context "missing old rule name parameter" do

        it "will raise exception" do
          expect { cli.rename_rule(nil, new_rule_name) }.to raise_exception(ArgumentError)
          expect { cli.rename_rule('', new_rule_name) }.to raise_exception(ArgumentError)
        end

      end # context

      context "missing new rule name parameter" do

        it "will raise exception" do
          expect { cli.rename_rule(old_rule_name, nil) }.to raise_exception(ArgumentError)
          expect { cli.rename_rule(old_rule_name, '') }.to raise_exception(ArgumentError)
        end
      end # context
    end # context

    context "valid parameters" do

      it "rule is renamed" do
        cli.rename_rule(old_rule_name, new_rule_name)
        expect(cli.get_rules().include?(new_rule_name)).to eq true
        expect(cli.get_rules().include?(old_rule_name)).to eq false

        cli.rename_rule(new_rule_name, old_rule_name)
      end
    end # context
  end # describe "#rename_rule"
end # describe AdminModule

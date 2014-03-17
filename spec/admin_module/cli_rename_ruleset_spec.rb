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

  let(:old_ruleset_name) { 'Z-DummyRuleset' }
  let(:new_ruleset_name) { 'Z-NewDummyRuleset' }


  describe "#rename_ruleset" do

    context "invalid parameters" do

      context "missing old ruleset name parameter" do

        it "will raise exception" do
          expect { cli.rename_ruleset(nil, new_ruleset_name) }.to raise_exception(ArgumentError)
          expect { cli.rename_ruleset('', new_ruleset_name) }.to raise_exception(ArgumentError)
        end

      end # context

      context "missing new ruleset name parameter" do

        it "will raise exception" do
          expect { cli.rename_ruleset(old_ruleset_name, nil) }.to raise_exception(ArgumentError)
          expect { cli.rename_ruleset(old_ruleset_name, '') }.to raise_exception(ArgumentError)
        end
      end # context
    end # context

    context "valid parameters" do

      it "ruleset is renamed" do
        cli.rename_ruleset(old_ruleset_name, new_ruleset_name)
        expect(cli.get_rulesets().include?(new_ruleset_name)).to eq true
        expect(cli.get_rulesets().include?(old_ruleset_name)).to eq false

        cli.rename_ruleset(new_ruleset_name, old_ruleset_name)
      end
    end # context
  end # describe "#rename_ruleset"
end # describe AdminModule

require 'spec_helper'

describe AdminModule::Rulesets do

  context "api" do

    let(:rs_list) { ['TstRuleset1', 'TstRuleset2'] }

    let(:rulesets_page_stub) do
      obj = double('rulesets_page')
      allow(obj).to receive(:get_rulesets).and_return(rs_list)
      allow(obj).to receive(:open_ruleset).and_return(obj)
      allow(obj).to receive(:set_name).and_return(obj)
      allow(obj).to receive(:save)
      #allow(obj).to receive(:add_version).and_return(obj)
      obj
    end

    let(:page_factory) do
      obj = MockPageFactory.new
      obj.login_page = double('login_page')
      obj.rulesets_page = rulesets_page_stub
      obj
    end

    let(:default_comment) { 'no comment' }

    context "#list" do
      it "returns list of rulesets" do
        expect(page_factory.rulesets_page)
          .to receive(:get_rulesets)

        rs = AdminModule::Rulesets.new(page_factory)
        rulesets = rs.list()

        expect( rulesets ).to include 'TstRuleset1'
        expect( rulesets ).to include 'TstRuleset2'
      end
    end

    context "#rename" do
      context "source name exists and destination name does not exist" do
        it "renames the ruleset" do
          src = 'TstRuleset1'
          dest = 'RnTstRuleset1'

          expect(page_factory.rulesets_page)
            .to receive(:open_ruleset)
            .with(src)

          expect(page_factory.rulesets_page)
            .to receive(:set_name)
            .with(dest)

          expect(page_factory.rulesets_page)
            .to receive(:save)

          rs = AdminModule::Rulesets.new(page_factory)
          rs.rename(src, dest)
        end
      end

      context "source name does not exist" do
        it "raises exception" do
          src = 'NotARuleset1'
          dest = 'TstRuleset2'

          rs = AdminModule::Rulesets.new(page_factory)
          expect { rs.rename(src, dest) }.to raise_exception /named 'NotARuleset1' does not exist/
        end
      end

      context "destination name already exists" do
        it "raises exception" do
          src = 'TstRuleset1'
          dest = 'TstRuleset2'

          rs = AdminModule::Rulesets.new(page_factory)
          expect { rs.rename(src, dest) }.to raise_exception /named 'TstRuleset2' already exists/
        end
      end
    end
  end
end


require 'spec_helper'

describe AdminModule::Rules do

  context "api" do

    let(:rs_list) { ['TstRule1', 'TstRule2'] }

    let(:rules_page_stub) do
      obj = double('rules_page')
      allow(obj).to receive(:get_rules).and_return(rs_list)
      allow(obj).to receive(:open_rule).and_return(obj)
      allow(obj).to receive(:delete_rule).and_return(obj)
      allow(obj).to receive(:set_name).and_return(obj)
      allow(obj).to receive(:save)
      #allow(obj).to receive(:add_version).and_return(obj)
      obj
    end

    let(:page_factory) do
      obj = MockPageFactory.new
      obj.login_page = double('login_page')
      obj.rules_page = rules_page_stub
      obj
    end

    let(:default_comment) { 'no comment' }

    context "#list" do
      it "returns list of rules" do
        expect(page_factory.rules_page)
          .to receive(:get_rules)

        rs = AdminModule::Rules.new(page_factory)
        rules = rs.list()

        expect( rules ).to include 'TstRule1'
        expect( rules ).to include 'TstRule2'
      end
    end

    context "#rename" do
      context "source name exists and destination name does not exist" do
        it "renames the rule" do
          src = 'TstRule1'
          dest = 'RnTstRule1'

          expect(page_factory.rules_page)
            .to receive(:open_rule)
            .with(src)

          expect(page_factory.rules_page)
            .to receive(:set_name)
            .with(dest)

          expect(page_factory.rules_page)
            .to receive(:save)

          rs = AdminModule::Rules.new(page_factory)
          rs.rename(src, dest)
        end
      end

      context "source name does not exist" do
        it "raises exception" do
          src = 'NotARule1'
          dest = 'TstRule2'

          rs = AdminModule::Rules.new(page_factory)
          expect { rs.rename(src, dest) }.to raise_exception /named 'NotARule1' does not exist/
        end
      end

      context "destination name already exists" do
        it "raises exception" do
          src = 'TstRule1'
          dest = 'TstRule2'

          rs = AdminModule::Rules.new(page_factory)
          expect { rs.rename(src, dest) }.to raise_exception /named 'TstRule2' already exists/
        end
      end
    end

    context "#delete" do
      context "rule exists" do
        it "deletes the rule" do
          src = 'TstRule1'

          expect(page_factory.rules_page)
            .to receive(:delete_rule)
            .with(src)

          rs = AdminModule::Rules.new(page_factory)
          rs.delete(src)
        end
      end

      context "rule does not exist" do
        it "raises exception" do
          src = 'NotARule1'

          rs = AdminModule::Rules.new(page_factory)
          expect { rs.delete(src) }.to raise_exception /named 'NotARule1' does not exist/
        end
      end
    end
  end
end


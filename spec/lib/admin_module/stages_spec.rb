require 'spec_helper'

def create_stage_hash name
  { name: name,
    transition_to: {},
    groups: ['Appeal Underwriter', 'CV Admin'],
    events: {'ForwardApplication PreEvent' => '', 'ForwardApplication PostEvent' => 'WF-ForwardApp-Post'},
  }
end

describe AdminModule::Stages do

  context "api" do

    let(:stages_list) { ['TstStage1', 'TstStage2'] }

    let(:stages_page_stub) do
      obj = double('stages_page')
      allow(obj).to receive(:get_stages).and_return(stages_list)
      allow(obj).to receive(:modify).and_return(obj)
      allow(obj).to receive(:delete).and_return(obj)
      allow(obj).to receive(:set_stage_data).and_return(obj)
      allow(obj).to receive(:set_name).and_return(obj)
      allow(obj).to receive(:save)
      obj
    end

    let(:page_factory) do
      obj = MockPageFactory.new
      obj.login_page = double('login_page')
      obj.stages_page = stages_page_stub
      obj
    end

    let(:default_comment) { 'no comment' }

    context "#list" do
      it "returns list of stages" do
        expect(page_factory.stages_page)
          .to receive(:get_stages)

        sp = AdminModule::Stages.new(page_factory)
        stages = sp.list()

        expect( stages ).to include 'TstStage1'
        expect( stages ).to include 'TstStage2'
      end
    end

    context "#rename" do
      context "source name exists and destination name does not exist" do
        it "renames the stage" do
          src = 'TstStage1'
          dest = 'RnTstStage1'

          expect(page_factory.stages_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.stages_page)
            .to receive(:set_name)
            .with(dest)

          expect(page_factory.stages_page)
            .to receive(:save)

          sp = AdminModule::Stages.new(page_factory)
          sp.rename(src, dest)
        end
      end

      context "source name does not exist" do
        it "raises exception" do
          src = 'NotAStage1'
          dest = 'TstStage2'

          sp = AdminModule::Stages.new(page_factory)
          expect { sp.rename(src, dest) }.to raise_exception /named 'NotAStage1' does not exist/
        end
      end

      context "destination name already exists" do
        it "raises exception" do
          src = 'TstStage1'
          dest = 'TstStage2'

          sp = AdminModule::Stages.new(page_factory)
          expect { sp.rename(src, dest) }.to raise_exception /named 'TstStage2' already exists/
        end
      end
    end

    context "#delete" do
      context "stage exists" do
        it "deletes the stage" do
          src = 'TstStage1'

          expect(page_factory.stages_page)
            .to receive(:delete)
            .with(src)

          sp = AdminModule::Stages.new(page_factory)
          sp.delete(src)
        end
      end

      context "stage does not exist" do
        it "raises exception" do
          src = 'NotAStage1'

          sp = AdminModule::Stages.new(page_factory)
          expect { sp.delete(src) }.to raise_exception /named 'NotAStage1' does not exist/
        end
      end
    end

    context "#import" do
      context "file exists" do
        it "imports stage definitions" do
          src_file = spec_data_dir + 'import_stages.yml'
          src = 'TstStage1'

          #allow(File).to receive(:exists?).and_return(true)

          expect(page_factory.stages_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.stages_page)
            .to receive(:set_stage_data)

          sp = AdminModule::Stages.new(page_factory)
          sp.import(src_file)
        end
      end

      context "file does not exist" do
        it "raises exception" do
          src = 'NotAStage1'

          sp = AdminModule::Stages.new(page_factory)
          expect { sp.import(src) }.to raise_exception /File not found: NotAStage1/
        end
      end
    end

    context "#export" do
      context "file directory exists" do
        it "exports the stage definitions" do
          dest_file = spec_tmp_dir('stages') + 'export.yml'
          src = 'TstStage1'

          expect(page_factory.stages_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.stages_page)
            .to receive(:get_stage_data)
            .and_return(create_stage_hash('TstStage1'))

          expect(page_factory.stages_page)
            .to receive(:get_stage_data)
            .and_return(create_stage_hash('TstStage2'))

          sp = AdminModule::Stages.new(page_factory)
          sp.export(dest_file)

          expect(File.exist?(dest_file)).to eq true
        end
      end

      context "file directory does not exist" do
        it "raises exception" do
          dest_path = spec_tmp_dir('stages') + 'not/a/real/dir/export.yml'

          allow(page_factory.stages_page)
            .to receive(:get_stage_data)
            .and_return(create_stage_hash('TstStage1'))

          sp = AdminModule::Stages.new(page_factory)
          expect { sp.export(dest_path) }.to raise_exception /No such directory - #{dest_path}/
        end
      end
    end
  end
end


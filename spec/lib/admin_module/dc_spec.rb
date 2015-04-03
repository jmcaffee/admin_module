require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}


describe AdminModule::DC do

  context "api" do

    let(:defns_list) { ['TstDefn1', 'TstDefn2'] }


    let(:detail) do
      detail = double('DcDetailPage')

      allow(detail).to receive(:set_name).and_return(detail)
      allow(detail).to receive(:set_definition_data).and_return(detail)
      allow(detail).to receive(:get_definition_data).and_return(create_dc_hash('TstDefn1'))

      detail
    end

    let(:dc_defns_page_stub) do
      obj = double('DcDefinitionsPage')

      allow(obj).to receive(:get_definitions).and_return(defns_list)
      allow(obj).to receive(:add).and_return(detail)
      allow(obj).to receive(:modify).and_return(detail)
      allow(obj).to receive(:detail_page).and_return(detail)

      allow(detail).to receive(:save).and_return(obj)

      obj
    end

    let(:page_factory) do
      obj = MockPageFactory.new
      obj.login_page = double('login_page')
      obj.dc_definitions_page = dc_defns_page_stub
      obj
    end

    context "#list" do
      it "returns list of definitions" do
        expect(page_factory.dc_definitions_page)
          .to receive(:get_definitions)

        dcs = AdminModule::DC.new(page_factory)
        dcs = dcs.list()

        expect( dcs ).to include 'TstDefn1'
        expect( dcs ).to include 'TstDefn2'
      end
    end

    context "#rename" do
      context "source name exists and destination name does not exist" do
        it "renames the definition" do
          src = 'TstDefn1'
          dest = 'RnTstDefn1'

          expect(page_factory.dc_definitions_page)
            .to receive(:modify)
            .with(src)

          expect(detail)
            .to receive(:set_name)
            .with(dest)

          expect(detail)
            .to receive(:save)

          dcs = AdminModule::DC.new(page_factory)
          dcs.rename(src, dest)
        end
      end

      context "source name does not exist" do
        it "raises exception" do
          src = 'NotADefn1'
          dest = 'TstDefn2'

          dcs = AdminModule::DC.new(page_factory)
          expect { dcs.rename(src, dest) }.to raise_exception /named 'NotADefn1' does not exist/
        end
      end

      context "destination name already exists" do
        it "raises exception" do
          src = 'TstDefn1'
          dest = 'TstDefn2'

          dcs = AdminModule::DC.new(page_factory)
          expect { dcs.rename(src, dest) }.to raise_exception /named 'TstDefn2' already exists/
        end
      end
    end

    context "#read" do
      context "definition exists" do
        it "reads the definition" do
          src = 'TstDefn1'

          expect(page_factory.dc_definitions_page)
            .to receive(:modify)
            .with(src)

          expect(detail)
            .to receive(:get_definition_data)
            .and_return(create_dc_hash('TstDefn1'))

          dcs = AdminModule::DC.new(page_factory)
          dcs.read(src)
        end
      end

      context "definition does not exist" do
        it "raises exception" do
          src = 'NotADefn1'

          dcs = AdminModule::DC.new(page_factory)
          expect { dcs.read(src) }.to raise_exception /named 'NotADefn1' does not exist/
        end
      end
    end

    context "#export" do
      context "file directory exists" do
        it "exports the dc definitions" do
          dest_file = spec_tmp_dir('dcs') + 'export.yml'
          src = 'TstDefn1'

          expect(page_factory.dc_definitions_page)
            .to receive(:modify)
            .with(src)

          expect(detail)
            .to receive(:get_definition_data)
            .and_return(create_dc_hash('TstDefn1'))

          expect(detail)
            .to receive(:get_definition_data)
            .and_return(create_dc_hash('TstDefn2'))

          dcs = AdminModule::DC.new(page_factory)
          dcs.export(dest_file)

          expect(File.exist?(dest_file)).to eq true
        end
      end

      context "file directory does not exist" do
        it "raises exception" do
          dest_path = spec_tmp_dir('dcs') + 'not/a/real/dir/export.yml'

          dcs = AdminModule::DC.new(page_factory)
          expect { dcs.export(dest_path) }.to raise_exception /No such directory - #{dest_path}/
        end
      end
    end

    context "#import" do
      context "file exists" do
        it "imports the dc definitions" do
          src_file = spec_data_dir + 'import_dcs.yml'
          src = 'TstDefn1'

          #allow(File).to receive(:exists?).and_return(true)

          expect(page_factory.dc_definitions_page)
            .to receive(:modify)
            .with(src)

          expect(detail)
            .to receive(:set_definition_data)

          dcs = AdminModule::DC.new(page_factory)
          dcs.import(src_file)
        end
      end

      context "file does not exist" do
        it "raises exception" do
          src = 'NotADefn1'

          dcs = AdminModule::DC.new(page_factory)
          expect { dcs.import(src) }.to raise_exception /File not found: NotADefn1/
        end
      end
    end
  end
end


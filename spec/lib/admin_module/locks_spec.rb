require 'spec_helper'

def create_lock_hash name
  { name: name,
    description: "Description of #{name}",
    is_program_lock: false,
    parameters: [ 'Var 1', 'Var 2' ],
    dts: [ 'Field 1', 'Field 2' ],
  }
end

describe AdminModule::Locks do

  context "api" do

    let(:lock_list) { ['TstLock1', 'TstLock2'] }

    let(:locks_page_stub) do
      obj = double('locks_page')
      allow(obj).to receive(:get_locks).and_return(lock_list)
      allow(obj).to receive(:add).and_return(obj)
      allow(obj).to receive(:modify).and_return(obj)
      allow(obj).to receive(:set_name).and_return(obj)
      allow(obj).to receive(:set_lock_data).and_return(nil)
      allow(obj).to receive(:get_lock_data).and_return(create_lock_hash('TstLock1'))
      allow(obj).to receive(:save).and_return(obj)
      #allow(obj).to receive(:add_version).and_return(obj)
      obj
    end

    let(:page_factory) do
      obj = MockPageFactory.new
      obj.login_page = double('login_page')
      obj.locks_page = locks_page_stub
      obj
    end

    context "#list" do
      it "returns list of locks" do
        expect(page_factory.locks_page)
          .to receive(:get_locks)

        locks = AdminModule::Locks.new(page_factory)
        locks = locks.list()

        expect( locks ).to include 'TstLock1'
        expect( locks ).to include 'TstLock2'
      end
    end

    context "#rename" do
      context "source name exists and destination name does not exist" do
        it "renames the lock" do
          src = 'TstLock1'
          dest = 'RnTstLock1'

          expect(page_factory.locks_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.locks_page)
            .to receive(:set_name)
            .with(dest)

          expect(page_factory.locks_page)
            .to receive(:save)

          locks = AdminModule::Locks.new(page_factory)
          locks.rename(src, dest)
        end
      end

      context "source name does not exist" do
        it "raises exception" do
          src = 'NotALock1'
          dest = 'TstLock2'

          locks = AdminModule::Locks.new(page_factory)
          expect { locks.rename(src, dest) }.to raise_exception /named 'NotALock1' does not exist/
        end
      end

      context "destination name already exists" do
        it "raises exception" do
          src = 'TstLock1'
          dest = 'TstLock2'

          locks = AdminModule::Locks.new(page_factory)
          expect { locks.rename(src, dest) }.to raise_exception /named 'TstLock2' already exists/
        end
      end
    end

    context "#read" do
      context "lock exists" do
        it "reads the lock" do
          src = 'TstLock1'

          expect(page_factory.locks_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.locks_page)
            .to receive(:get_lock_data)
            .and_return(create_lock_hash('TstLock1'))

          locks = AdminModule::Locks.new(page_factory)
          locks.read(src)
        end
      end

      context "lock does not exist" do
        it "raises exception" do
          src = 'NotALock1'

          locks = AdminModule::Locks.new(page_factory)
          expect { locks.read(src) }.to raise_exception /named 'NotALock1' does not exist/
        end
      end
    end

    context "#export" do
      context "file directory exists" do
        it "exports the lock definitions" do
          dest_file = spec_tmp_dir('locks') + 'export.yml'
          src = 'TstLock1'

          expect(page_factory.locks_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.locks_page)
            .to receive(:get_lock_data)
            .and_return(create_lock_hash('TstLock1'))

          expect(page_factory.locks_page)
            .to receive(:get_lock_data)
            .and_return(create_lock_hash('TstLock2'))

          locks = AdminModule::Locks.new(page_factory)
          locks.export(dest_file)

          expect(File.exist?(dest_file)).to eq true
        end
      end

      context "file directory does not exist" do
        it "raises exception" do
          dest_path = spec_tmp_dir('locks') + 'not/a/real/dir/export.yml'

          locks = AdminModule::Locks.new(page_factory)
          expect { locks.export(dest_path) }.to raise_exception /No such directory - #{dest_path}/
        end
      end
    end

    context "#import" do
      context "file exists" do
        it "imports the lock definitions" do
          src_file = spec_data_dir + 'import_stages.yml'
          src = 'TstLock1'

          #allow(File).to receive(:exists?).and_return(true)

          expect(page_factory.locks_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.locks_page)
            .to receive(:set_lock_data)

          locks = AdminModule::Locks.new(page_factory)
          locks.import(src_file)
        end
      end

      context "file does not exist" do
        it "raises exception" do
          src = 'NotALock1'

          locks = AdminModule::Locks.new(page_factory)
          expect { locks.import(src) }.to raise_exception /File not found: NotALock1/
        end
      end
    end
  end
end


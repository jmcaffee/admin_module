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

  describe "#environment=" do
    context "sets the environment to use" do
      context "when set to :sit" do
        let(:cli) do
          cli = AdminModule::CLI.new
          cli.environment = :sit
          cli
        end


        it "#environment returns :sit" do
          expect(cli.environment).to eq :sit
        end

        it "#credentials returns values for :sit" do
          expect(cli.credentials).to eq ['admin', 'Password11*']
        end

        it "#base_url returns values for :sit" do
          expect(cli.base_url).to eq "http://207.38.119.211/fap2SIT/Admin"
        end
      end
    end

    #context "with :test configured as default environment" do
    #  AdminModule.configure do |config|
    #    config.default_environment = :test
    #  end

    #  it "returns :test" do
    #    expect(cli.environment).to eq :test
    #  end
    #end # context "with invalid source file"
  end

  describe "#environment" do
    context "returns default environment if not overridden" do
      it "returns :dev" do
        expect(cli.environment).to eq :dev
      end
    end

    #context "with :test configured as default environment" do
    #  AdminModule.configure do |config|
    #    config.default_environment = :test
    #  end

    #  it "returns :test" do
    #    expect(cli.environment).to eq :test
    #  end
    #end # context "with invalid source file"
  end


  describe "#credentials" do
    context "returns default credentials if not overridden" do
      it "returns :dev's credentials" do
        expect(cli.credentials).to eq ["admin", "Password1*"]
      end
    end
  end


  describe "#base_urls" do
    context "returns default urls if not overridden" do
      it "returns :dev's base url" do
        expect(cli.base_url).to eq "http://207.38.119.211/fap2Dev/Admin"
      end
    end
  end

  describe "#deploy" do
    context "with invalid source file" do
      it "will raise an IOError exception" do
        expect { cli.deploy('source_xml.xml', 'dest_gdl_name') }.to raise_exception(IOError)
      end
    end # context "with invalid source file"

    context "with valid source file" do
      let(:data_dir)          { 'spec/data' }
      let(:test_source_file)  { File.join(data_dir, 'patch-test.xml') }

      AdminModule.configure do |config|
        config.aliases = { 'temp' => 'Z-TEMP' }
      end


      it "deploys to default environment" do
        expect { cli.deploy(test_source_file, 'Z-TEMP') }.not_to raise_exception
      end
    end # context "with invalid source file"
  end


  describe "#deploy_files" do
    context "with one invalid source file" do
      it "will raise an IOError exception" do
        expect { cli.deploy_files(['source_xml.xml'], 'Multi-upload fail test') }.to raise_exception(IOError)
      end
    end

    context "with valid source files" do
      let(:data_dir)          { 'spec/data' }
      let(:test_source_file1) { File.join(data_dir, 'patch-test.xml') }
      let(:test_source_file2) { File.join(data_dir, 'patch-test.xml') }
      let(:test_source_files) { [test_source_file1, test_source_file2] }

      AdminModule.configure do |config|
        config.aliases = { 'patch-test' => 'Z-TEMP' }
      end


      it "deploys to default environment" do
        expect { cli.deploy_files(test_source_files, 'Multi-upload test') }.not_to raise_exception
      end
    end # context "with invalid source file"
  end


  describe "#get_lock" do
    context "invalid lock name" do
      it "will raise exception" do
        expect { cli.get_lock('invalid') }.to raise_exception(ArgumentError)
      end
    end # context "invalid lock name"


    context "valid lock name" do

      let(:expected_income_lock)  do
                                    { name: 'IncomeLock',
                                      description: '',
                                      is_program_lock: false,
                                      parameters: [ 'Monthly Gross Income' ],
                                      dts: []
                                    }
                                  end


      it "will return lock configuration data" do
        expect( cli.get_lock('IncomeLock') ).to eq expected_income_lock
      end
    end # context "invalid lock name"
  end # describe "#get_lock"


  describe "#create_lock" do
    context "lock data missing name parameter" do

      let(:lock_data_missing_name)  do
                                      { description: '',
                                        is_program_lock: false,
                                        parameters: [ 'Monthly Gross Income' ],
                                        dts: []
                                      }
                                    end


      it "will raise exception" do
        expect { cli.create_lock(lock_data_missing_name) }.to raise_exception(ArgumentError)
      end
    end # context


    context "lock data missing both dsm and dts parameters" do

      let(:lock_data_missing_params_and_dts)  do
                                                { name: 'MissingDataLock',
                                                  description: '',
                                                  is_program_lock: false,
                                                }
                                              end


      it "will raise exception" do
        expect { cli.create_lock(lock_data_missing_params_and_dts) }.to raise_exception(ArgumentError)
      end
    end # context

    context "lock data contains empty dsms and empty dts parameters" do

      let(:lock_data_empty_params_and_dts)  do
                                              { name: 'MissingDataLock',
                                                description: '',
                                                is_program_lock: false,
                                                parameters: [],
                                                dts: []
                                              }
                                            end


      it "will raise exception" do
        expect { cli.create_lock(lock_data_empty_params_and_dts) }.to raise_exception(ArgumentError)
      end
    end # context


    context "lock name already exists" do

      let(:income_lock)   do
                            { name: 'IncomeLock',
                              description: '',
                              is_program_lock: false,
                              parameters: [ 'Monthly Gross Income' ],
                              dts: []
                            }
                          end


      it "will raise exception" do
        expect { cli.create_lock(income_lock) }.to raise_exception(ArgumentError)
      end
    end # context

    # Commented out because this actually creates a lock and locks can't
    # be deleted:

    #context "lock name does not exist" do

    #  let(:test_lock)  do
    #    { name: 'TestLock',
    #      description: 'This is a test',
    #      is_program_lock: false,
    #      parameters: [ 'Monthly Gross Income' ],
    #      dts: [ '2nd Investor' ]
    #    }
    #  end

    #  it "lock is created" do
    #    cli.create_lock(test_lock)
    #    expect(cli.get_lock('TestLock')).to eq test_lock
    #  end
    #end # context
  end # describe "#create_lock"


  describe "#modify_lock" do

        before(:each) do
          tstlock = {  name: 'TestLock',
                        description: '',
                        is_program_lock: false,
                        parameters: [ 'Rank' ],
                        dts: []
                      }

          begin
            cli.modify_lock(tstlock, 'TestLock')
            success = true
          rescue
            unless success == true
              cli.modify_lock(tstlock, 'TestAnotherLock') 
            end
          end
        end


    context "lock data missing name parameter" do

      let(:lock_data_missing_name)  do
                                      { description: '',
                                        is_program_lock: false,
                                        parameters: [ 'Monthly Gross Income' ],
                                        dts: []
                                      }
                                    end


      it "will raise exception" do
        expect { cli.modify_lock(lock_data_missing_name) }.to raise_exception(ArgumentError)
      end


      context "lock name specified" do

        let(:lock_data_missing_name)  do
                                        { description: '',
                                          is_program_lock: false,
                                          parameters: [ 'Monthly Gross Income' ],
                                          dts: []
                                        }
                                      end

        let(:retrieved_lock)          do
                                        { name: 'TestLock',
                                          description: '',
                                          is_program_lock: false,
                                          parameters: [ 'Monthly Gross Income' ],
                                          dts: []
                                        }
                                      end


        it "lock is modified" do
          cli.modify_lock(lock_data_missing_name, 'TestLock')
          expect(cli.get_lock('TestLock')).to eq retrieved_lock
        end
      end # context
    end # context


    context "lock name exists" do

      let(:test_lock)   do
                          { name: 'TestLock',
                            description: '',
                            is_program_lock: false,
                            parameters: [],
                            dts: [ '2nd Lien Payoff' ]
                          }
                        end

      it "lock is modified" do
        cli.modify_lock(test_lock)
        expect(cli.get_lock('TestLock')).to eq test_lock
      end


      context "lock name is changed to data's name" do

        let(:another_lock)  do
                              { name: 'TestAnotherLock',
                                description: '',
                                is_program_lock: false,
                                parameters: [],
                                dts: [ '2nd Lien Payoff' ]
                              }
                            end

        let(:test_lock)     do
                              { name: 'TestLock',
                                description: '',
                                is_program_lock: false,
                                parameters: [],
                                dts: [ '2nd Lien Payoff' ]
                              }
                            end


        it "lock is renamed" do
          cli.modify_lock(another_lock, 'TestLock')
          expect(cli.get_lock('TestAnotherLock')).to eq another_lock
        end
      end # context
    end # context

  end # describe "#modify_lock"

  describe "#write_lock_to_file" do
    context "with filename" do
      context "lock name specified" do

        let(:target_file)   { 'tmp/spec/admin_module/locks.yml' }
        let(:lock_name)     { 'TestLock' }

        let(:test_lock)     do
                              { name: lock_name,
                                description: 'This is a test lock',
                                is_program_lock: false,
                                parameters: [ 'Monthly Gross Income' ],
                                dts: [ '2nd Lien Payoff' ]
                              }
                            end


        before(:each) do
          FileUtils.rm_rf target_file
          cli.modify_lock(test_lock)
        end

        it "writes to file" do
          cli.write_lock_to_file(lock_name, target_file)
          expect(File.exist?(target_file)).to be_true
        end

        it "is in YML format" do
          cli.write_lock_to_file(lock_name, target_file)
          lock = {}
          File.open(target_file, 'r') do |f|
            lock = YAML.load f
          end
          expect(lock).to eq test_lock
        end
      end # context
    end # context

  end # describe "#write_lock_to_file"

  describe "#export_locks" do
    context "with filename" do

      let(:target_file)   { 'tmp/spec/admin_module/locks.yml' }

      before(:each) do
        FileUtils.rm_rf target_file
      end


      it "writes multiple locks to a file" do
        cli.export_locks(target_file)
        locks = read_lock_data_file(target_file)
        #{}
        #File.open(target_file, 'r') do |f|
        #  locks = YAML.load f
        #end
        expect(locks.size).to eq 11
      end
    end # context

  end # describe "#export_locks"

  describe "#import_locks" do
    context "with filename" do

      let(:src_data)        do
                              { "TestLock" =>
                                  { name: 'TestLock',
                                    description: 'This is a test lock',
                                    is_program_lock: false,
                                    parameters: [ 'Rank' ],
                                    dts: []
                                  }
                              }
                            end

      let(:src_file_path)   { 'tmp/spec/admin_module/locks.yml' }
      let(:src_file)        { write_lock_data_file(src_file_path, src_data); src_file_path }

      let(:bad_src_data)    do
                              { "TestLock" =>
                                  { name: 'TestLock',
                                    description: 'This is a test lock',
                                    is_program_lock: false,
                                    parameters: [ 'I do not exist' ],
                                    dts: []
                                  }
                              }
                            end

      let(:bad_src_file_path) { 'tmp/spec/admin_module/locks_bad.yml' }
      let(:bad_src_file)      { write_lock_data_file(bad_src_file_path, bad_src_data); bad_src_file_path }


      it "configures locks sourced from a file" do
        cli.import_locks(src_file)
        expect(cli.get_lock('TestLock')).to eq src_data["TestLock"]
      end

      context "with non-existing DSMs" do
        it "raises an exception" do
          expect { cli.import_locks(bad_src_file) }.to raise_exception
        end
      end
    end # context

    context "with invalid filename" do
      it "raises an IOError" do
        expect { cli.import_locks('does_not_exist.yml') }.to raise_exception(IOError)
      end
    end

  end # describe "#import_locks"

end # describe AdminModule

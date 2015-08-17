require 'spec_helper'

describe AdminModule::CLI do

  ##
  # Quit the browser after each test.
  after(:each) do
    quit_cli
  end


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
      let(:src_file)        { write_yaml_data_file(src_file_path, src_data); src_file_path }

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
      let(:bad_src_file)      { write_yaml_data_file(bad_src_file_path, bad_src_data); bad_src_file_path }


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

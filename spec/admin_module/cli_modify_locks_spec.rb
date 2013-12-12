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
end # describe AdminModule

require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

require 'admin_module'

describe 'config command' do

  before do
    # Reset config to a known state.
    AdminModule.configuration.reset
    # Delete any config file that may have been created.
    file = Pathname.pwd + '.admin_module'
    file.delete if file.exist?
  end

  let(:cli) { AdminModule::CLI }

  it "returns help info" do
    output = capture_output do
      cli.start %w(help config)
    end

    expect( output ).to include "config help [COMMAND]"
    expect( output ).to include "config add [CATEGORY]"
    expect( output ).to include "config show [CATEGORY]"
    expect( output ).to include "config del [CATEGORY]"
    expect( output ).to include "config init"
    expect( output ).to include "config timeout <seconds>"
    expect( output ).to include "config defcomment '<comment>'"
    expect( output ).to include "config defenv <envname>"
    expect( output ).to include "config amsversion <version>"
  end

  context 'config init' do

    context "no filename/path provided" do
      it "writes a configuration file to the current working directory" do
        with_target_dir('config/init') do |working_dir|
          output = capture_output do
            run_with_args %w(config init)
          end

          output_file = Pathname(working_dir) + '.admin_module'

          expect( output ).to include "configuration written to #{output_file.to_s}"
          expect( output_file.exist? ).to eq true
        end
      end
    end

    context "filename/path provided" do
      it "writes a configuration file to the specified directory" do
        with_target_dir('config/init') do |working_dir|
          final_dir = clean_target_dir(working_dir + 'nested/dir')

          output = capture_output do
            run_with_args %W(config init #{final_dir.to_s})
          end

          output_file = Pathname(final_dir) + '.admin_module'

          expect( output_file.exist? ).to eq true
          expect( output ).to include "configuration written to #{output_file.to_s}"
        end
      end
    end
  end

  context 'config timeout' do

    it "returns the current timeout when no argument provided" do
      with_target_dir('config/timeout') do
        run_with_args %w(config init -q)

        output = capture_output do
          run_with_args %w(config timeout)
        end

        expect( output ).to include 'browser timeout: 360'
      end
    end

    it "sets the current timeout when an argument is provided" do
      with_target_dir('config/timout') do
        run_with_args %w(config init -q)

        run_with_args %w(config timeout 180)

        expect( AdminModule.configuration.browser_timeout ).to eq 180
      end
    end

    it "displays an argument error if timeout value is not an integer" do
      with_target_dir('config/timeout') do
        output = capture_output do
          run_with_args %w(config timeout blag)
        end

        expect( output ).to include 'argument error: seconds must be an integer'
      end
    end
  end

  context 'config defenv' do

    it "returns the current default environment when no argument provided" do
      with_target_dir('config/defenv') do
        run_with_args %w(config init -q)

        run_with_args %w(config add env test1 http://example.com)
        run_with_args %w(config defenv test1)

        output = capture_output do
          run_with_args %w(config defenv)
        end

        expect( output ).to include 'default environment: test1'
      end
    end

    it "sets the current default environment when an argument is provided" do
      with_target_dir('config/defenv') do
        run_with_args %w(config init -q)

        run_with_args %w(config add env test2 http://example.com)
        run_with_args %w(config defenv test2)

        expect( AdminModule.configuration.default_environment ).to eq :test2
      end
    end

    it "displays an argument error if environment doesn't exist" do
      with_target_dir('config/defenv') do
        run_with_args %w(config init -q)

        output = capture_output do
          run_with_args %w(config defenv nope)
        end

        expect( output ).to include "argument error: environment 'nope' has not been configured"
      end
    end
  end

  context 'config defcomment' do

    it "returns the current default comment when no argument provided" do
      with_target_dir('config/defcomment') do
        run_with_args %w(config init -q)

        output = capture_output do
          run_with_args %w(config defcomment)
        end

        expect( output ).to include 'default comment: no comment'
      end
    end

    it "sets the default comment when an argument is provided" do
      with_target_dir('config/defcomment') do
        run_with_args %w(config init -q)

        cmt = "new default comment"
        run_with_args %W(config defcomment #{cmt})

        expect( AdminModule.configuration.default_comment ).to eq 'new default comment'
      end
    end
  end

  context 'config amsversion' do

    it "returns the current AMS version when no argument provided" do
      with_target_dir('config/amsversion') do
        run_with_args %w(config init -q)

        output = capture_output do
          run_with_args %w(config amsversion)
        end

        expect( output ).to include 'ams version: 4.4.0'
      end
    end

    it "sets the ams version when an argument is provided" do
      with_target_dir('config/amsversion') do
        run_with_args %w(config init -q)

        ver = "3.1.10"
        run_with_args %W(config amsversion #{ver})

        expect( AdminModule.configuration.ams_version ).to eq ver
      end
    end
  end

  context 'config add' do

    it "returns help info" do
      output = capture_output do
        run_with_args %w(config help add)
      end

      expect( output ).to include "add help [COMMAND]"
      expect( output ).to include "add env <envname> <url>"
      expect( output ).to include "add xmlmap <xmlfile> <gdlname>"
      expect( output ).to include "add credentials <envname> <username> <pass>"
    end

    context "env" do

      it "adds an environment" do
        with_target_dir('config/add/env') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test http://example.com)

          actual = AdminModule.configuration.base_urls[:test]
          expect( actual ).to eq 'http://example.com'
        end
      end

      it "displays an error if environment already exists" do
        with_target_dir('config/add/env') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test http://example.com)

          output = capture_output do
            run_with_args %w(config add env test http://example.com)
          end

          expect( output ).to include "environment 'test' already exists"
        end
      end
    end

    context "xmlmap" do

      it "adds an xml file to guideline mapping" do
        with_target_dir('config/add/xmlmap') do
          run_with_args %w(config init -q)

          run_with_args %w(config add xmlmap file.xml Guideline)

          actual = AdminModule.configuration.xmlmaps['file']
          expect( actual ).to eq 'Guideline'
        end
      end

      it "displays an error if the file is already mapped" do
        with_target_dir('config/add/xmlmap') do
          run_with_args %w(config init -q)

          run_with_args %w(config add xmlmap file.xml Guideline)

          output = capture_output do
            run_with_args %w(config add xmlmap file.xml Guideline)
          end

          expect( output ).to include "a mapping already exists for 'file'"
          expect( output ).to include "delete and re-add the mapping to change it"
        end
      end
    end

    context "credentials" do

      it "adds a set of credentials" do
        with_target_dir('config/add/credentials') do
          run_with_args %w(config init -q)

          # Add an environment first...
          run_with_args %w(config add env test http://example.com)

          run_with_args %w(config add credentials test testuser testpass)

          actual_user, actual_pass = AdminModule.configuration.credentials[:test]
          expect( actual_user ).to eq 'testuser'
          expect( actual_pass ).to eq 'testpass'
        end
      end

      it "displays an error if credentials already exist for the given env" do
        with_target_dir('config/add/credentials') do
          run_with_args %w(config init -q)

          # Add an environment first...
          run_with_args %w(config add env test http://example.com)

          run_with_args %w(config add credentials test testuser testpass)

          output = capture_output do
            run_with_args %w(config add credentials test testuser testpass)
          end

          expect( output ).to include "credentials already exist for environment 'test'"
        end
      end

      it "displays an error if environment hasn't been created first" do
        with_target_dir('config/add/credentials') do
          run_with_args %w(config init -q)

          output = capture_output do
            run_with_args %w(config add credentials test testuser testpass)
          end

          expect( output ).to include "environment 'test' doesn't exist"
          expect( output ).to include "create environment before adding credentials"
          expect( AdminModule.configuration.credentials.key?(:test) ).to be false
        end
      end
    end
  end

  context 'config show' do

    it "returns help info" do
      output = capture_output do
        run_with_args %w(config help show)
      end

      expect( output ).to include "show help [COMMAND]"
      expect( output ).to include "show envs"
      expect( output ).to include "show xmlmaps"
      expect( output ).to include "show credentials <envname>"
    end

    context "envs" do

      it "displays configured environments" do
        with_target_dir('config/show/credentials') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test1 http://example.com)
          run_with_args %w(config add env test2 http://example.org)

          output = capture_output do
            run_with_args %w(config show envs)
          end

          expect( output ).to include 'Environments:'
          expect( output ).to include 'test1  http://example.com'
          expect( output ).to include 'test2  http://example.org'
        end
      end
    end

    context "xmlmaps" do

      it "displays configured xmlmaps" do
        with_target_dir('config/show/xmlmaps') do
          run_with_args %w(config init -q)

          gdl1 = 'Guideline 1'
          gdl2 = 'Guideline 2'
          run_with_args %W(config add xmlmap file1.xml #{gdl1})
          run_with_args %W(config add xmlmap file2.xml #{gdl2})

          output = capture_output do
            run_with_args %w(config show xmlmaps)
          end

          expect( output ).to include 'xmlmaps:'
          expect( output ).to include 'file1  Guideline 1'
          expect( output ).to include 'file2  Guideline 2'
        end
      end
    end

    context "credentials" do

      it "displays configured credentials" do
        with_target_dir('config/show/credentials') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test1 http://example.com)
          run_with_args %w(config add credentials test1 testuser1 testpass1)

          run_with_args %w(config add env test2 http://example.org)
          run_with_args %w(config add credentials test2 testuser2 testpass2)

          output = capture_output do
            run_with_args %w(config show credentials)
          end

          expect( output ).to include 'credentials:'
          expect( output ).to include 'test1  testuser1  testpass1'
          expect( output ).to include 'test2  testuser2  testpass2'
        end
      end

      it "displays configured credentials for specified environment" do
        with_target_dir('config/show/credentials') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test1 http://example.com)
          run_with_args %w(config add credentials test1 testuser1 testpass1)

          run_with_args %w(config add env test2 http://example.org)
          run_with_args %w(config add credentials test2 testuser2 testpass2)

          output = capture_output do
            run_with_args %w(config show credentials test1)
          end

          expect( output ).to include 'credentials:'
          expect( output ).to include 'test1  testuser1  testpass1'
          expect( output ).to_not include 'test2  testuser2  testpass2'
        end
      end
    end
  end

  context 'config del' do

    it "returns help info" do
      output = capture_output do
        run_with_args %w(config help del)
      end

      expect( output ).to include "del help [COMMAND]"
      expect( output ).to include "del env <envname>"
      expect( output ).to include "del xmlmap <xmlfile>"
      expect( output ).to include "del credentials <envname>"
    end

    context "env" do

      it "deletes an existing environment" do
        with_target_dir('config/del/env') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test1 http://example.com)

          run_with_args %w(config del env test1)

          expect( AdminModule.configuration.base_urls.key?(:test1) ).to be false
        end
      end

      it "deletes matching credentials when deleting an environment" do
        with_target_dir('config/del/env') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test1 http://example.com)
          run_with_args %w(config add credentials test1 testuser1 testpass1)

          run_with_args %w(config del env test1)

          expect( AdminModule.configuration.base_urls.key?(:test1) ).to be false
          expect( AdminModule.configuration.credentials.key?(:test1) ).to be false
        end
      end
    end

    context "xmlmap" do

      it "deletes an existing xmlmap" do
        with_target_dir('config/del/xmlmap') do
          run_with_args %w(config init -q)

          run_with_args %w(config add xmlmap file1.xml Guideline1)

          run_with_args %w(config del xmlmap file1.xml)

          expect( AdminModule.configuration.xmlmaps.key?('file1') ).to be false
        end
      end
    end

    context "credentials" do

      it "deletes existing credentials" do
        with_target_dir('config/del/credentials') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test1 http://example.com)
          run_with_args %w(config add credentials test1 testuser1 testpass1)

          run_with_args %w(config del credentials test1)

          expect( AdminModule.configuration.credentials.key?(:test1) ).to be false
        end
      end

      it "does not delete matching environment when deleting credentials" do
        with_target_dir('config/del/credentials') do
          run_with_args %w(config init -q)

          run_with_args %w(config add env test1 http://example.com)
          run_with_args %w(config add credentials test1 testuser1 testpass1)

          run_with_args %w(config del credentials test1)

          expect( AdminModule.configuration.base_urls.key?(:test1) ).to be true
          expect( AdminModule.configuration.credentials.key?(:test1) ).to be false
        end
      end
    end
  end
end


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
    expect( output ).to include "config timeout <seconds>"
    expect( output ).to include "config defcomment '<comment>'"
    expect( output ).to include "config defenv <envname>"
  end

  context 'config write' do

    context "no filename/path provided" do
      it "writes a configuration file to the current working directory" do
        working_dir = clean_output_dir('config')

        output = ""
        FileUtils.cd working_dir do
          output = capture_output do
            cli.start %w(config write)
          end
        end

        output_file = Pathname(working_dir) + '.admin_module'

        expect( output ).to include "configuration written to #{output_file.to_s}"
        expect( output_file.exist? ).to eq true
      end
    end

    context "filename/path provided" do
      it "writes a configuration file to the specified directory" do
        working_dir = clean_output_dir('config')
        final_dir = clean_output_dir('config/nested/dir')

        output = ""
        FileUtils.cd working_dir do
          output = capture_output do
            cli.start %W(config write #{final_dir.to_s})
          end
        end

        output_file = Pathname(final_dir) + '.admin_module'

        expect( output_file.exist? ).to eq true
        expect( output ).to include "configuration written to #{output_file.to_s}"
      end
    end
  end

  context 'config timeout' do

    it "returns the current timeout when no argument provided" do
      output = capture_output do
        cli.start %w(config timeout)
      end

      expect( output ).to include 'browser timeout: 360'
    end

    it "sets the current timeout when an argument is provided" do
      cli.start %w(config timeout 180)

      expect( AdminModule.configuration.browser_timeout ).to eq 180
    end

    it "displays an argument error if timeout value is not an integer" do
      output = capture_output do
        cli.start %w(config timeout blag)
      end

      expect( output ).to include 'argument error: seconds must be an integer'
    end
  end

  context 'config defenv' do

    it "returns the current default environment when no argument provided" do
      cli.start %w(config add env test1 http://example.com)
      cli.start %w(config defenv test1)

      output = capture_output do
        cli.start %w(config defenv)
      end

      expect( output ).to include 'default environment: test1'
    end

    it "sets the current default environment when an argument is provided" do
      cli.start %w(config add env test2 http://example.com)
      cli.start %w(config defenv test2)

      expect( AdminModule.configuration.default_environment ).to eq :test2
    end

    it "displays an argument error if environment doesn't exist" do
      output = capture_output do
        cli.start %w(config defenv nope)
      end

      expect( output ).to include "argument error: environment 'nope' has not been configured"
    end
  end

  context 'config defcomment' do

    it "returns the current default comment when no argument provided" do
      output = capture_output do
        cli.start %w(config defcomment)
      end

      expect( output ).to include 'default comment: no comment'
    end

    it "sets the default comment when an argument is provided" do
      cmt = "new default comment"
      cli.start %W(config defcomment #{cmt})

      expect( AdminModule.configuration.default_comment ).to eq 'new default comment'
    end
  end

  context 'config add' do

    it "returns help info" do
      output = capture_output do
        cli.start %w(config help add)
      end

      expect( output ).to include "add help [COMMAND]"
      expect( output ).to include "add env <envname> <url>"
      expect( output ).to include "add xmlmap <xmlfile> <gdlname>"
      expect( output ).to include "add credentials <envname> <username> <pass>"
    end

    context "env" do

      it "adds an environment" do
        cli.start %w(config add env test http://example.com)

        actual = AdminModule.configuration.base_urls[:test]
        expect( actual ).to eq 'http://example.com'
      end

      it "displays an error if environment already exists" do
        cli.start %w(config add env test http://example.com)

        output = capture_output do
          cli.start %w(config add env test http://example.com)
        end

        expect( output ).to include "environment 'test' already exists"
      end
    end

    context "xmlmap" do

      it "adds an xml file to guideline mapping" do
        cli.start %w(config add xmlmap file.xml Guideline)

        actual = AdminModule.configuration.xmlmaps['file']
        expect( actual ).to eq 'Guideline'
      end

      it "displays an error if the file is already mapped" do
        cli.start %w(config add xmlmap file.xml Guideline)

        output = capture_output do
          cli.start %w(config add xmlmap file.xml Guideline)
        end

        expect( output ).to include "a mapping already exists for 'file'"
        expect( output ).to include "delete and re-add the mapping to change it"
      end
    end

    context "credentials" do

      it "adds a set of credentials" do
        # Add an environment first...
        cli.start %w(config add env test http://example.com)

        cli.start %w(config add credentials test testuser testpass)

        actual_user, actual_pass = AdminModule.configuration.credentials[:test]
        expect( actual_user ).to eq 'testuser'
        expect( actual_pass ).to eq 'testpass'
      end

      it "displays an error if credentials already exist for the given env" do
        # Add an environment first...
        cli.start %w(config add env test http://example.com)

        cli.start %w(config add credentials test testuser testpass)

        output = capture_output do
          cli.start %w(config add credentials test testuser testpass)
        end

        expect( output ).to include "credentials already exist for environment 'test'"
      end

      it "displays an error if environment hasn't been created first" do
        output = capture_output do
          cli.start %w(config add credentials test testuser testpass)
        end

        expect( output ).to include "environment 'test' doesn't exist"
        expect( output ).to include "create environment before adding credentials"
        expect( AdminModule.configuration.credentials.key?(:test) ).to be false
      end
    end
  end

  context 'config show' do

    it "returns help info" do
      output = capture_output do
        cli.start %w(config help show)
      end

      expect( output ).to include "show help [COMMAND]"
      expect( output ).to include "show envs"
      expect( output ).to include "show xmlmaps"
      expect( output ).to include "show credentials <envname>"
    end

    context "envs" do

      it "displays configured environments" do
        cli.start %w(config add env test1 http://example.com)
        cli.start %w(config add env test2 http://example.org)

        output = capture_output do
          cli.start %w(config show envs)
        end

        expect( output ).to include 'Environments:'
        expect( output ).to include 'test1  http://example.com'
        expect( output ).to include 'test2  http://example.org'
      end
    end

    context "xmlmaps" do

      it "displays configured xmlmaps" do
        gdl1 = 'Guideline 1'
        gdl2 = 'Guideline 2'
        cli.start %W(config add xmlmap file1.xml #{gdl1})
        cli.start %W(config add xmlmap file2.xml #{gdl2})

        output = capture_output do
          cli.start %w(config show xmlmaps)
        end

        expect( output ).to include 'xmlmaps:'
        expect( output ).to include 'file1  Guideline 1'
        expect( output ).to include 'file2  Guideline 2'
      end
    end

    context "credentials" do

      it "displays configured credentials" do
        cli.start %w(config add env test1 http://example.com)
        cli.start %w(config add credentials test1 testuser1 testpass1)

        cli.start %w(config add env test2 http://example.org)
        cli.start %w(config add credentials test2 testuser2 testpass2)

        output = capture_output do
          cli.start %w(config show credentials)
        end

        expect( output ).to include 'credentials:'
        expect( output ).to include 'test1  testuser1  testpass1'
        expect( output ).to include 'test2  testuser2  testpass2'
      end

      it "displays configured credentials for specified environment" do
        cli.start %w(config add env test1 http://example.com)
        cli.start %w(config add credentials test1 testuser1 testpass1)

        cli.start %w(config add env test2 http://example.org)
        cli.start %w(config add credentials test2 testuser2 testpass2)

        output = capture_output do
          cli.start %w(config show credentials test1)
        end

        expect( output ).to include 'credentials:'
        expect( output ).to include 'test1  testuser1  testpass1'
        expect( output ).to_not include 'test2  testuser2  testpass2'
      end
    end
  end

  context 'config del' do

    it "returns help info" do
      output = capture_output do
        cli.start %w(config help del)
      end

      expect( output ).to include "del help [COMMAND]"
      expect( output ).to include "del env <envname>"
      expect( output ).to include "del xmlmap <xmlfile>"
      expect( output ).to include "del credentials <envname>"
    end

    context "env" do

      it "deletes an existing environment" do
        cli.start %w(config add env test1 http://example.com)

        cli.start %w(config del env test1)

        expect( AdminModule.configuration.base_urls.key?(:test1) ).to be false
      end

      it "deletes matching credentials when deleting an environment" do
        cli.start %w(config add env test1 http://example.com)
        cli.start %w(config add credentials test1 testuser1 testpass1)

        cli.start %w(config del env test1)

        expect( AdminModule.configuration.base_urls.key?(:test1) ).to be false
        expect( AdminModule.configuration.credentials.key?(:test1) ).to be false
      end
    end

    context "xmlmap" do

      it "deletes an existing xmlmap" do
        cli.start %w(config add xmlmap file1.xml Guideline1)

        cli.start %w(config del xmlmap file1.xml)

        expect( AdminModule.configuration.xmlmaps.key?('file1') ).to be false
      end
    end

    context "credentials" do

      it "deletes existing credentials" do
        cli.start %w(config add env test1 http://example.com)
        cli.start %w(config add credentials test1 testuser1 testpass1)

        cli.start %w(config del credentials test1)

        expect( AdminModule.configuration.credentials.key?(:test1) ).to be false
      end

      it "does not delete matching environment when deleting credentials" do
        cli.start %w(config add env test1 http://example.com)
        cli.start %w(config add credentials test1 testuser1 testpass1)

        cli.start %w(config del credentials test1)

        expect( AdminModule.configuration.base_urls.key?(:test1) ).to be true
        expect( AdminModule.configuration.credentials.key?(:test1) ).to be false
      end
    end
  end
end


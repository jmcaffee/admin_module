##############################################################################
# File::    deploy_task_spec.rb
# Purpose:: DeployTask definition specification
# 
# Author::    Jeff McAffee 03/19/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'spec_helper'
require 'admin_module/rake/deploy_task'

module AdminModule::Rake

  describe DeployTask do

    subject { DeployTask.new }

    it "accepts environment" do
      subject.env = :dev
    end

    it "accepts commit message" do
      subject.commit_msg = 'commit message'
    end

    it 'accepts a list of files' do
      subject.files = ['file1.xml', 'file2.xml']
    end

    it 'returns list of files' do
      expect(subject.files).to eq []
      subject.files = ['file1.xml', 'file2.xml']
      expect(subject.files).to eq ['file1.xml', 'file2.xml']
    end

    it 'accepts a single file' do
      subject.files = 'file1.xml'
      expect(subject.files).to eq ['file1.xml']
    end

    it 'accepts a target guideline name or alias' do
      subject.target = 'Z-TEMP'
      expect(subject.target).to eq 'Z-TEMP'
    end

    context '#deploy' do

      context 'with non-configured environment' do

        it "throws exception" do
          subject.env = :bad_env
          expect { subject.deploy }.to raise_error("Unknown environment [bad_env]")
        end
      end # with non-configured env

      context 'with configured environment' do

        let(:configure_gem) do
          AdminModule.configure do |config|
            config.credentials = { :dev => ['admin', 'Password1*'] }
          end
        end

        it "requires a target when file is not pre-configured or found in guideline list" do
          configure_gem
          subject.env = :dev
          subject.files = data_dir('patch-test.xml')

          expect { subject.deploy }.to raise_error
        end

        it "deploys to target if specified and only one file is provided" do
          configure_gem
          subject.env = :dev
          subject.files = data_dir('patch-test.xml')
          subject.target = 'Z-TEMP'

          expect { subject.deploy }.to_not raise_error
        end
      end # with configured env
    end
  end

end # module AdminModule::Task

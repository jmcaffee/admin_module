##############################################################################
# File::    rules_task_spec.rb
# Purpose:: RulesTask definition specification
# 
# Author::    Jeff McAffee 2014-04-24
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'spec_helper'
require 'admin_module/rake/rules_task'

module AdminModule::Rake

  describe RulesTask do

    subject { RulesTask.new }

    let(:configure_gem) do
      AdminModule.configure do |config|
        config.credentials = { :dev => ['admin', 'Password1*'] }
      end
    end


    it "accepts environment" do
      subject.env = :dev
    end

    it "accepts name" do
      subject.name = 'My Rule Name'
    end

    it 'accepts action' do
      subject.action = 'delete'
    end

    it 'accepts stop_on_exception' do
      subject.stop_on_exception = true
    end

    it 'rejects a non-true or non-false stop_on_exception' do
      expect { subject.stop_on_exception = 'hello' }.to raise_error
      expect { subject.stop_on_exception = nil }.to raise_error
      expect { subject.stop_on_exception = true }.to_not raise_error
      expect { subject.stop_on_exception = false }.to_not raise_error
    end

    context '#commit' do

      it "requires a rule name" do
        configure_gem
        subject.env = :dev
        subject.stop_on_exception = true
        subject.name = nil

        expect { subject.commit }.to raise_error
      end

      it "calls AdminModule:CLI#delete_rule" do
        configure_gem
        subject.env = :dev
        subject.stop_on_exception = true
        subject.name = 'Test Rule'
        subject.action = 'delete'

        # See https://github.com/rspec/rspec-mocks for documentation:
        expect_any_instance_of(AdminModule::CLI).to receive(:delete_rule).with('Test Rule')

        subject.commit
      end
    end # commit
  end

end # module AdminModule::Rake

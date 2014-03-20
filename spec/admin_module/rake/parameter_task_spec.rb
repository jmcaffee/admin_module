##############################################################################
# File::    parameter_task_spec.rb
# Purpose:: ParameterTask definition specification
# 
# Author::    Jeff McAffee 03/19/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'spec_helper'
require 'admin_module/rake/parameter_task'

module AdminModule::Rake

  describe ParameterTask do

    subject { ParameterTask.new }

    let(:configure_gem) do
      AdminModule.configure do |config|
        config.credentials = { :dev => ['admin', 'Password1*'] }
      end
    end


    it "accepts environment" do
      subject.env = :dev
    end

    it "accepts name" do
      subject.name = 'My Variable Name'
    end

    it 'accepts include' do
      subject.include = true
    end

    it 'rejects a non-true or non-false include' do
      expect { subject.include = 'hello' }.to raise_error
      expect { subject.include = nil }.to raise_error
      expect { subject.include = true }.to_not raise_error
      expect { subject.include = false }.to_not raise_error
    end

    context '#update' do

      it "requires a variable name" do
        configure_gem
        subject.env = :dev
        subject.include = true
        subject.name = nil

        expect { subject.update }.to raise_error
      end
    end # update
  end

end # module AdminModule::Task

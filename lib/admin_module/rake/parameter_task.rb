##############################################################################
# File::    parameter_task.rb
# Purpose:: ParameterTask definition
# 
# Author::    Jeff McAffee 03/19/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module'
require 'rake/dsl_definition'
require 'rake'

module AdminModule::Rake

  class ParameterTask
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :env
    attr_accessor :name
    attr_reader   :type
    attr_reader   :decision
    attr_reader   :order
    attr_reader   :precision
    attr_reader   :include

    def initialize(task_name = 'save_in_xml', desc = "Set or clear a variable's Save in XML flag")
      @task_name, @desc = task_name, desc

      yield self if block_given?

      define_task
    end

    def define_task #:nodoc:
      desc @desc
      task @task_name do
        update
      end
    end

    def type=(new_type)
      valid_types = ['Boolean', 'Date', 'DateTime', 'Money', 'Numeric', 'Percentage', 'Text']
      raise "type must be one of #{valid_types.join(', ')}" unless valid_types.include?(new_type)
      @type = new_type
    end

    def decision=(new_decision)
      raise "decision must be true or false" unless (new_decision === true || new_decision === false)
      @decision = new_decision ? 'Yes' : 'No'
    end

    def order=(new_order)
      @order = new_order.to_i
    end

    def precision=(new_precision)
      @precision = new_precision.to_i
    end

    def include=(new_state)
      raise "include must be true or false" unless (new_state === true || new_state === false)
      @include = new_state
    end

    def update(current_name = nil)
      current_name = name if current_name.nil?
      current_name = '' if current_name.nil?

      cli = AdminModule::CLI.new
      cli.environment = env
      params = { :name => @name,
                 :type => @type,
                 :decision => @decision,
                 :order => @order,
                 :precision => @precision,
                 :include => @include }
      params.delete_if { |k,v| v.nil? }

      cli.update_parameter(current_name, params)
    ensure
      cli.quit
    end
  end # class ParameterTask
end # module AdminModule::Task


##############################################################################
# File::    rules_task.rb
# Purpose:: RulesTask definition
# 
# Author::    Jeff McAffee 2014-04-24
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module'
require 'rake/dsl_definition'
require 'rake'

module AdminModule::Rake

  class RulesTask
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :env
    attr_accessor :name
    attr_reader   :action
    attr_reader   :stop_on_exception

    def initialize(task_name = 'rule_task', desc = "Modify a guideline rule")
      @task_name, @desc = task_name, desc
      @stop_on_exception = true

      yield self if block_given?

      define_task
    end

    def define_task #:nodoc:
      desc @desc
      task @task_name do
        commit  # Call method to perform when invoked.
      end
    end

    def action=(task_action)
      valid_types = ['delete']
      raise "action must be one of #{valid_types.join(', ')}" unless valid_types.include?(task_action.downcase)
      @action = task_action
    end

    def stop_on_exception=(do_stop)
      raise ArgumentError, 'Expecting true or false' unless do_stop === true || do_stop === false
      @stop_on_exception = do_stop
    end

    def commit
      raise 'Missing env' if env.nil? || env.empty?
      raise 'Missing name' if name.nil? || name.empty?
      raise 'Missing action' if action.nil? || action.empty?

      cli = AdminModule::CLI.new
      cli.environment = env

      cli.delete_rule(name) if action == 'delete'
    rescue Exception => e
      raise e if stop_on_exception == true
    ensure
      cli.quit unless cli.nil?
    end
  end # class RulesTask
end # module AdminModule::Task


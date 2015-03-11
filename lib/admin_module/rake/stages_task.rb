##############################################################################
# File::    stages_task.rb
# Purpose:: StagesTask definition
# 
# Author::    Jeff McAffee 2015-03-10
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module'
require 'rake/dsl_definition'
require 'rake'

module AdminModule::Rake

  class StagesTask
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :env
    attr_accessor :name
    attr_accessor :to
    attr_accessor :path
    attr_accessor :allow_create
    attr_reader   :action
    attr_reader   :stop_on_exception

    def initialize(task_name = 'stages_task', desc = "Modify a stage or stages")
      @task_name, @desc = task_name, desc
      @stop_on_exception = true
      @allow_create = false

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
      valid_types = ['import', 'export', 'read', 'list', 'rename', 'delete']
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
      raise 'Missing "to"' if action == 'rename' && (to.nil? || to.empty?)
      raise 'Missing "path"' if action == 'import' && (path.nil? || path.empty?)
      raise 'Missing "path"' if action == 'export' && (path.nil? || path.empty?)

      client = AdminModule::Client.new
      client.env = env

      case action
      when 'import'
        client.stages.import path, allow_create

      when 'export'
        client.stages.export path

      when 'read'
        client.stages.read name

      when 'list'
        client.stages.list

      when 'rename'
        client.stages.rename name, to

      when 'delete'
        client.stages.delete name

      else
        # Noop
      end

    rescue Exception => e
      raise e if stop_on_exception == true
    ensure
      client.logout unless client.nil?
    end
  end # class
end # module


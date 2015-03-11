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
    attr_reader   :valid_actions
    attr_reader   :stop_on_exception

    def initialize(task_name = 'stages_task', desc = "Modify a stage or stages")
      @valid_actions = ['import', 'export', 'read', 'list', 'rename', 'delete']
      @task_name, @desc = task_name, desc

      @stop_on_exception = true
      @allow_create = false

      yield self if block_given?

      define_task
    end

    def define_task #:nodoc:
      desc @desc
      task(@task_name, required_args_for_action) do |t,args|
        set_vars args
        commit  # Call method to perform when invoked.
      end
    end

    def set_vars args
      args.each do |arg,val|
        instance_variable_set "@#{arg}", val
      end

      args
    end

    def action=(task_action)
      raise "action must be one of #{valid_types.join(', ')}" unless valid_actions.include?(task_action.downcase)
      @action = task_action
    end

    def stop_on_exception=(do_stop)
      raise ArgumentError, 'Expecting true or false' unless do_stop === true || do_stop === false
      @stop_on_exception = do_stop
    end

    def commit
      validate_params

      client = AdminModule::Client.new
      client.env = env

      if self.respond_to? action
        self.send(action, client)
        return
      else
        raise "Unknown action - #{action}"
      end

    rescue Exception => e
      raise e if stop_on_exception == true
    ensure
      client.logout unless client.nil?
    end

    def list client
      $stdout << client.stages.list.join("\n")
      $stdout << "\n"
    end

    def read client
      result = {}
      result[name] = client.stages.read(name)
      $stdout << result.to_yaml
    end

    def import client
      $stdout << client.stages.import(path, allow_create)
    end

    def export client
      $stdout << client.stages.export(path)
    end

    def rename client
      $stdout << client.stages.rename(name, to)
    end

    def delete client
      $stdout << client.stages.delete(name)
    end

    def validate_params
      assert_provided env, 'Missing "env"'
      assert_provided action, 'Missing "action"'

      case action
      when 'import'
        assert_provided path, 'Missing "path"'

      when 'export'
        assert_provided path, 'Missing "path"'

      when 'read'
        assert_provided name, 'Missing "name"'

      when 'rename'
        assert_provided name, 'Missing "name"'
        assert_provided to, 'Missing "to"'

      when 'delete'
        assert_provided name, 'Missing "name"'

      end

      assert_env_is_configured env
    end

    def assert_provided value, msg
      if value.nil? || value.empty?
        raise msg
      end
    end

    def assert_env_is_configured arg
      unless AdminModule.configuration.credentials.key? arg
        init_msg = "Have you initialized your config file?\n Try: admin_module config init <filedir>"
        env_msg = "Have you configured your environments?\n Try: admin_module config add env <envname> <url>"
        raise "Unknown environment: #{arg}\n#{init_msg}\n\n#{env_msg}"
      end
    end

    def required_args_for_action
      args = []

      case action
      when 'read','delete'
        args << :name

      when 'rename'
        args << :name
        args << :to

      when 'import'
        args << :path
        args << :allow_create

      when 'export'
        args << :path

      else
        # Noop
      end

      args
    end

    class << self
      def install
        new.install
      end
    end

    def install
      AdminModule.configuration.credentials.keys.each do |e|
        valid_actions.each do |action|
          AdminModule::Rake::StagesTask.new("am:#{e}:stage:#{action}", "#{action} #{e} stage(s)") do |t|
            t.env = e
            t.action = action
          end
        end
      end
    end
  end # class
end # module

AdminModule::Rake::StagesTask.install


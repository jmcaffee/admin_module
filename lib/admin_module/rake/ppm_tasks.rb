##############################################################################
# File::    ppm_tasks.rb
# Purpose:: PpmTasks definition
#
# Author::    Jeff McAffee 2015-06-23
#
##############################################################################

require 'admin_module'
require 'rake/dsl_definition'
require 'rake'

module AdminModule::Rake
  class PpmTasks
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :env
    attr_accessor :name
    attr_accessor :to
    attr_accessor :path
    attr_reader   :action
    attr_reader   :valid_actions
    attr_reader   :stop_on_exception

    def initialize(task_name = '', desc = "")
      @valid_actions = ['import', 'export', 'dups', 'list']
      @task_name, @desc = task_name, desc

      @stop_on_exception = true

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

    #
    # Add each arg passed to the task, as an instance variable of the task
    #

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

    #
    # Execute the task (action)
    #

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
      client.quit
    end

    #
    # Actions
    #

    def list client
      $stdout << client.ppms.list.join("\n")
      $stdout << "\n"
    end

    def dups client
      result = {}
      result[name] = client.ppms.dups
      $stdout << result.to_yaml
    end

    def import client
      $stdout << client.ppms.import(path)
    end

    def export client
      $stdout << client.ppms.export(path)
    end

    #
    # Verify we have the needed parameters (arguments) to perform
    # the task action.
    #

    def validate_params
      assert_provided env, 'Missing "env"'
      assert_provided action, 'Missing "action"'

      case action
      when 'import'
        assert_provided path, 'Missing "path"'

      when 'export'
        assert_provided path, 'Missing "path"'

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

    #
    # Define the task args, based on the action.
    # Used when programatically generating the tasks.
    #

    def required_args_for_action
      args = []

      case action
      when 'import'
        args << :path

      when 'export'
        args << :path

      else
        # Noop
      end

      args
    end

    #
    # Class method to create an instance of the task generator,
    # and call the instance's install method.
    #

    class << self
      def install
        new.install
      end
    end

    #
    # Instance method to generate the tasks;
    # For each environment where we have configured credentials,
    # generate a task for each available action.
    #

    def install
      AdminModule.configuration.credentials.keys.each do |e|
        valid_actions.each do |action|
          AdminModule::Rake::PpmTasks.new("am:#{e}:ppm:#{action}", "#{action} #{e} ppms") do |t|
            t.env = e
            t.action = action
          end
        end
      end
    end
  end # class
end # module


#
# Install (generate) the tasks
#

AdminModule::Rake::PpmTasks.install


##############################################################################
# File::    gdl_tasks.rb
# Purpose:: GdlTasks definition
# 
# Author::    Jeff McAffee 2015-03-11
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module'
require 'rake/dsl_definition'
require 'rake'

module AdminModule::Rake

  class GdlTasks
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :env
    attr_accessor :name
    attr_accessor :comments
    attr_accessor :path
    attr_reader   :action
    attr_reader   :valid_actions
    attr_reader   :stop_on_exception

    def initialize(task_name = 'gdls_task', desc = "Modify a gdl or gdls")
      @valid_actions = ['deploy', 'version']
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
      client.quit unless client.nil?
    end

    def deploy client
      real_path = Pathname(path)
      if real_path.directory?
        client.guideline.deploy(path, comments)
      else
        client.guideline.deploy_file(path, comments)
      end
    end

    def version client
      client.guideline.version(name)
    end

    def default_params
      if comments.nil? || comments.empty?
        self.comments = AdminModule.configuration.default_comment
        unless comments.nil? || comments.empty?
          $stdout << "Using default comment - #{comments}\n"
        end
      end

      if path.nil? || path.empty?
        build_dir = Pathname('build')
        if build_dir.exist? && build_dir.directory?
          # Must be an absolute path:
          self.path = build_dir.expand_path.to_s
          $stdout << "Using default path - #{path}\n"
        end
      end
    end

    def validate_params
      assert_provided env, 'Missing "env"'
      assert_provided action, 'Missing "action"'

      default_params

      case action
      when 'deploy'
        assert_provided path, 'Missing "path"'

      when 'version'
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
      when 'deploy'
        args << :path
        args << :comments

      when 'version'
        args << :name
        args << :comments

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
          AdminModule::Rake::GdlTasks.new("am:#{e}:gdl:#{action}", "#{action} #{e} gdl(s)") do |t|
            t.env = e
            t.action = action
          end
        end
      end
    end
  end # class
end # module

AdminModule::Rake::GdlTasks.install


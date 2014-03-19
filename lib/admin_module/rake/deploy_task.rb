##############################################################################
# File::    deploy_task.rb
# Purpose:: DeployTask definition
# 
# Author::    Jeff McAffee 03/19/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module'
require 'rake/dsl_definition'
require 'rake'

module AdminModule::Rake

  class DeployTask
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :env
    attr_accessor :commit_msg
    attr_accessor :target

    def initialize(task_name = 'deploy', desc = 'Deploy guideline xml files')
      @task_name, @desc = task_name, desc

      yield self if block_given?

      define_task
    end

    def define_task #:nodoc:
      desc @desc
      task @task_name do
        deploy
      end
    end

    def files
      @files ||= []
    end

    def files=(file_list)
      @files ||= []
      @files += Array(file_list)
    end

    def deploy
      cli = AdminModule::CLI.new
      cli.environment = env
      if files.size == 1
        cli.deploy(files, target, commit_msg)
      else
        cli.deploy_files(files, commit_msg)
      end
    ensure
      cli.quit
    end
  end # class DeployTask
end # module AdminModule::Task

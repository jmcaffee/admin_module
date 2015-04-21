##############################################################################
# File::    tasks.rb
# Purpose:: Interface to tasks functionality in admin module
#
# Author::    Jeff McAffee 2015-04-19
#
##############################################################################

require 'admin_module/pages'

module AdminModule

  class Tasks
    attr_reader :page_factory

    def initialize(page_factory)
      @page_factory = page_factory
    end

    def rename src, dest
      src = assert_task_exists( extract_task_name(src) )
      dest = assert_task_does_not_exist( extract_task_name(dest) )

      tasks_page
        .modify(src)
        .set_name(dest)
        .save
    end

    def list
      tasks_page.get_tasks
    end

    def create task
      task_name = assert_task_does_not_exist( extract_task_name(task) )

      tasks_page
        .add
        .set_task_data(task)
        .save
    end

    def read task
      task_name = assert_task_exists( extract_task_name(task) )

      tasks_page
        .modify( task_name )
        .get_task_data
    end

    def update task
      task_name = assert_task_exists( extract_task_name(task) )

      tasks_page
        .modify( task_name )
        .set_task_data(task)
        .save
    end

    #
    # No functionality exists to DELETE tasks.
    #

    def export file_path
      tasks = list
      export_data = {}

      tasks.each do |task|
        export_data[task] = read task
      end

      File.open(file_path, 'w') do |f|
        f.write export_data.to_yaml
      end

      # Explicitly return (nothing) to avoid polluting stdout (in rake task).
      return

    rescue Exception => e
      if e.message.include? 'No such file or directory'
        raise IOError, "No such directory - #{file_path}"
      else
        raise e
      end
    end

    ##
    # Import task configurations into the current environment from a file.

    def import file_path, allow_create = false
      raise IOError, "File not found: #{file_path}" unless File.exists?(file_path)

      tasks = {}
      File.open(file_path, 'r') do |f|
        # Read array of task hashes.
        tasks = YAML.load(f)
      end

      existing_tasks = list

      tasks.each do |name, data|
        if existing_tasks.include?(name)
          update(data)
        else
          if allow_create
            create(data)
          else
            puts "Unable to create #{name}. allow_create = false"
          end
        end
      end

      # Explicitly return (nothing) to avoid polluting stdout (in rake task).
      return
    end

  private

    def tasks_page
      page_factory.tasks_page
    end

    def extract_task_name task
      task_name = if task.is_a? Hash
                    task[:name]
                  else
                    String(task)
                  end
    end

    def assert_task_exists task_name
      unless list.include? task_name
        fail ArgumentError.new("A task named '#{task_name}' does not exist")
      end

      task_name
    end

    def assert_task_does_not_exist task_name
      if list.include? task_name
        fail ArgumentError.new("A task named '#{task_name}' already exists")
      end

      task_name
    end
  end # class Tasks
end # module

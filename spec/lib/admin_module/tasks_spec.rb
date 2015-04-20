require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

# See support/task.rb
#def create_task_hash name
#  { name: name,
#    schedule: "To-Do",
#    priority: "Normal",
#    due_days: 2,
#    due_hours: "0",
#    due_minutes: "00",
#    followup: "",
#    assigned_to: "Negotiator",
#    fees_assigned: "0.00",
#    task_description: "#{name} task description",
#    letter_agreement: "",
#  }
#end

describe AdminModule::Tasks do

  context "api" do

    let(:task_list) { ['TstTask1', 'TstTask2'] }

    let(:tasks_page_stub) do
      obj = double('tasks_page')
      allow(obj).to receive(:get_tasks).and_return(task_list)
      allow(obj).to receive(:add).and_return(obj)
      allow(obj).to receive(:modify).and_return(obj)
      allow(obj).to receive(:set_name).and_return(obj)
      allow(obj).to receive(:set_task_data).and_return(obj)
      allow(obj).to receive(:get_task_data).and_return(create_task_hash('TstTask1'))
      allow(obj).to receive(:save).and_return(obj)
      #allow(obj).to receive(:add_version).and_return(obj)
      obj
    end

    let(:page_factory) do
      obj = MockPageFactory.new
      obj.login_page = double('login_page')
      obj.tasks_page = tasks_page_stub
      obj
    end

    context "#list" do
      it "returns list of tasks" do
        expect(page_factory.tasks_page)
          .to receive(:get_tasks)

        tasks = AdminModule::Tasks.new(page_factory)
        tasks = tasks.list()

        expect( tasks ).to include 'TstTask1'
        expect( tasks ).to include 'TstTask2'
      end
    end

    context "#rename" do
      context "source name exists and destination name does not exist" do
        it "renames the task" do
          src = 'TstTask1'
          dest = 'RnTstTask1'

          expect(page_factory.tasks_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.tasks_page)
            .to receive(:set_name)
            .with(dest)

          expect(page_factory.tasks_page)
            .to receive(:save)

          tasks = AdminModule::Tasks.new(page_factory)
          tasks.rename(src, dest)
        end
      end

      context "source name does not exist" do
        it "raises exception" do
          src = 'NotATask1'
          dest = 'TstTask2'

          tasks = AdminModule::Tasks.new(page_factory)
          expect { tasks.rename(src, dest) }.to raise_exception /named 'NotATask1' does not exist/
        end
      end

      context "destination name already exists" do
        it "raises exception" do
          src = 'TstTask1'
          dest = 'TstTask2'

          tasks = AdminModule::Tasks.new(page_factory)
          expect { tasks.rename(src, dest) }.to raise_exception /named 'TstTask2' already exists/
        end
      end
    end

    context "#read" do
      context "task exists" do
        it "reads the task" do
          src = 'TstTask1'

          expect(page_factory.tasks_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.tasks_page)
            .to receive(:get_task_data)
            .and_return(create_task_hash('TstTask1'))

          tasks = AdminModule::Tasks.new(page_factory)
          tasks.read(src)
        end
      end

      context "task does not exist" do
        it "raises exception" do
          src = 'NotATask1'

          tasks = AdminModule::Tasks.new(page_factory)
          expect { tasks.read(src) }.to raise_exception /named 'NotATask1' does not exist/
        end
      end
    end

    context "#export" do
      context "file directory exists" do
        it "exports the task definitions" do
          dest_file = spec_tmp_dir('tasks') + 'export.yml'
          src = 'TstTask1'

          expect(page_factory.tasks_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.tasks_page)
            .to receive(:get_task_data)
            .and_return(create_task_hash('TstTask1'))

          expect(page_factory.tasks_page)
            .to receive(:get_task_data)
            .and_return(create_task_hash('TstTask2'))

          tasks = AdminModule::Tasks.new(page_factory)
          tasks.export(dest_file)

          expect(File.exist?(dest_file)).to eq true
        end
      end

      context "file directory does not exist" do
        it "raises exception" do
          dest_path = spec_tmp_dir('tasks') + 'not/a/real/dir/export.yml'

          tasks = AdminModule::Tasks.new(page_factory)
          expect { tasks.export(dest_path) }.to raise_exception /No such directory - #{dest_path}/
        end
      end
    end

    context "#import" do
      context "file exists" do
        it "imports the task definitions" do
          src_file = spec_data_dir + 'import_tasks.yml'
          src = 'TstTask1'

          #allow(File).to receive(:exists?).and_return(true)

          expect(page_factory.tasks_page)
            .to receive(:modify)
            .with(src)

          expect(page_factory.tasks_page)
            .to receive(:set_task_data)

          tasks = AdminModule::Tasks.new(page_factory)
          tasks.import(src_file)
        end
      end

      context "file does not exist" do
        it "raises exception" do
          src = 'NotATask1'

          tasks = AdminModule::Tasks.new(page_factory)
          expect { tasks.import(src) }.to raise_exception /File not found: NotATask1/
        end
      end
    end
  end
end


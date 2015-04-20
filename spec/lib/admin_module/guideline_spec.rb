require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe AdminModule::Guideline do

  context "api" do

    let(:guidelines_page_stub) do
      obj = double('guidelines_page')
      allow(obj).to receive(:upload).and_return(obj)
      allow(obj).to receive(:add_version).and_return(obj)
      obj
    end

    let(:page_factory) do
      obj = MockPageFactory.new
      obj.login_page = double('login_page')
      obj.guidelines_page = guidelines_page_stub
      obj
    end

    let(:default_comment) { 'new default comment' }

    context "#deploy" do
      context "with comment" do
        it "deploys guidelines" do
          srcdir = data_dir('build')
          comment = 'this is a comment'

          AdminModule.configure do |config|
            config.xmlmaps['test1'] = 'Z-TEMP'
            config.xmlmaps['test2'] = 'Z-TEMP'
          end

          expect(page_factory.guidelines_page)
            .to receive(:open_guideline)
            .with('Z-TEMP')
            .and_return(page_factory.guidelines_page)
            .twice

          expect(page_factory.guidelines_page)
            .to receive(:add_version)
            .twice

          expect(page_factory.guidelines_page)
            .to receive(:upload)
            .with(anything, comment)
            .twice

          gdl = AdminModule::Guideline.new(page_factory)
          gdl.deploy(srcdir, comment)
        end
      end

      context "with no comment" do
        it "deploys guidelines with default comment" do
          srcdir = data_dir('build')

          AdminModule.configure do |config|
            config.xmlmaps['test1'] = 'Z-TEMP'
            config.xmlmaps['test2'] = 'Z-TEMP'
            config.default_comment = default_comment
          end

          expect(page_factory.guidelines_page)
            .to receive(:open_guideline)
            .with('Z-TEMP')
            .and_return(page_factory.guidelines_page)
            .twice

          expect(page_factory.guidelines_page)
            .to receive(:add_version)
            .twice

          expect(page_factory.guidelines_page)
            .to receive(:upload)
            .with(anything, default_comment)
            .twice

          gdl = AdminModule::Guideline.new(page_factory)
          gdl.deploy(srcdir)
        end
      end

      context "with xml file specified" do
        it "deploys the guideline" do
          srcdir = data_dir('build')

          AdminModule.configure do |config|
            config.xmlmaps['test1'] = 'Z-TEMP'
            config.xmlmaps['test2'] = 'Z-TEMP'
            config.default_comment = default_comment
          end

          expect(page_factory.guidelines_page)
            .to receive(:open_guideline)
            .with('Z-TEMP')
            .and_return(page_factory.guidelines_page)

          expect(page_factory.guidelines_page)
            .to receive(:add_version)
            .and_return(page_factory.guidelines_page)

          file_to_upload = Pathname(srcdir) + 'test1.xml'

          expect(page_factory.guidelines_page)
            .to receive(:upload)
            .with(file_to_upload.expand_path, default_comment)

          gdl = AdminModule::Guideline.new(page_factory)
          gdl.deploy_file(file_to_upload)
        end
      end
    end

    context "#version" do
      context "with comment" do
        it "versions guidelines" do
          comment = 'this is a comment'
          gdls = []

          AdminModule.configure do |config|
            config.xmlmaps['test1'] = 'Z-TEMP1'
            config.xmlmaps['test2'] = 'Z-TEMP2'

            gdls = config.xmlmaps.values
          end

          expect(page_factory.guidelines_page)
            .to receive(:version_all)
            .and_return(page_factory.guidelines_page)

          expect(page_factory.guidelines_page)
            .to receive(:version)
            .with(gdls, comment)

          allow(page_factory.guidelines_page)
            .to receive(:get_guidelines)
            .and_return( gdls )

          gdl = AdminModule::Guideline.new(page_factory)
          gdl.version(gdls, comment)
        end
      end

      context "with no comment" do
        it "versions guidelines with default comment" do
          gdls = []

          AdminModule.configure do |config|
            config.xmlmaps['test1'] = 'Z-TEMP1'
            config.xmlmaps['test2'] = 'Z-TEMP2'
            config.default_comment = default_comment

            gdls = config.xmlmaps.values
          end

          expect(page_factory.guidelines_page)
            .to receive(:get_guidelines)
            .and_return(['Z-TEMP1','Z-TEMP2'])

          expect(page_factory.guidelines_page)
            .to receive(:version_all)
            .and_return(page_factory.guidelines_page)

          expect(page_factory.guidelines_page)
            .to receive(:version)
            .with(gdls, default_comment)

          gdl = AdminModule::Guideline.new(page_factory)
          gdl.version(gdls)
        end
      end
    end
  end
end


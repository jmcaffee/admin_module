require 'spec_helper'

describe AdminModule::Guideline do

  context "#deploy" do

    let(:guidelines_page_stub) do
      obj = double('guidelines_page')
      obj.stub(:upload).and_return(obj)
      obj.stub(:add_version).and_return(obj)
      obj
    end

    let(:page_factory) do
      obj = MockPageFactory.new
      obj.login_page = double('login_page')
      obj.guidelines_page = guidelines_page_stub
      obj
    end

    it "deploys guidelines" do
      srcdir = data_dir('build')

      AdminModule.configure do |config|
        config.xmlmaps['test1'] = 'ZTemp'
        config.xmlmaps['test2'] = 'ZTemp'
      end

      expect(page_factory.guidelines_page)
        .to receive(:open_guideline)
        .with('ZTemp')
        .and_return(page_factory.guidelines_page)
        .twice

      gdl = AdminModule::Guideline.new(:testenv, page_factory)
      gdl.deploy(srcdir, 'this is a comment')
    end
  end
end


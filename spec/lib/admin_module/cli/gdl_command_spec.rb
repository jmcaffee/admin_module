require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

require 'admin_module'

describe 'gdl command' do

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

  let(:cli) { AdminModule::CLI }

  it "deploys a guideline" do
    AdminModule::ConfigHelper.page_factory = page_factory

    AdminModule.configure do |config|
      config.credentials[:dev] = ['user', 'pass']
      config.xmlmaps['test1'] = 'ZTemp'
      config.xmlmaps['test2'] = 'ZTemp'
    end

    expect(page_factory.login_page)
      .to receive(:login_as)
      .with('user', 'pass')

    expect(page_factory.guidelines_page)
      .to receive(:open_guideline)
      .with('ZTemp')
      .and_return(page_factory.guidelines_page)
      .twice

    expect(page_factory.login_page)
      .to receive(:logout)

    build_dir = data_dir('build')
    cli.start %W(gdl deploy -e dev #{build_dir})
  end

  it "returns help info" do
    output = capture_output do
      cli.start %w(help gdl)
    end

    expect( output ).to include "gdl help [COMMAND]"
    expect( output ).to include "gdl deploy <srcdir> <comments>"
    expect( output ).to include "gdl version <comments>"
    expect( output ).to include "e, [--environment=dev]"
  end
end


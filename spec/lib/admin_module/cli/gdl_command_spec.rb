require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

require 'admin_module'

describe 'gdl command' do

  let(:options) do
    %w(guideline -e dev -t main file.xml)
  end
  let(:cli) { AdminModule::CLI }

  it "deploys a guideline" do
    cli.start %w(gdl deploy -e dev -t main file.xml)
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


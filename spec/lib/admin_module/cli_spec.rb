require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

require 'admin_module/cli'

describe 'admin_module executable' do

  let(:cli) { AdminModule::CLI }

  it "returns help info" do
    output = capture_output do
      cli.start %w(help)
    end

    expect( output ).to include "help [COMMAND]"
    expect( output ).to include "gdl [COMMAND]"
    expect( output ).to include "config [COMMAND]"
    expect( output ).to include "ruleset [COMMAND]"
  end

=begin
  it "returns non-zero exit status when passed unrecognized options" do
    pending
    #admin_module '--invalid_argument', :exitstatus => true
    admin_module '--invalid_argument'
    expect(exitstatus).to_not be_zero
  end

  it "returns non-zero exit status when passed unrecognized task" do
    pending
    admin_module 'unrecognized-task'#, :exitstatus => true
    expect(exitstatus).to_not be_zero
  end
=end
end

##############################################################################
# File::    rake.rb
# Purpose:: Pull in all rake task classes
#
# Author::    Jeff McAffee 03/19/2014
#
##############################################################################

require 'admin_module'

module AdminModule::Rake
end

require_relative 'rake/gdl_tasks'
require_relative 'rake/stage_tasks'
require_relative 'rake/lock_tasks'
require_relative 'rake/dc_tasks'


##############################################################################
# File::    rake.rb
# Purpose:: Pull in all rake task classes
# 
# Author::    Jeff McAffee 03/19/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AdminModule::Rake
end

require_relative 'rake/deploy_task'
require_relative 'rake/parameter_task'


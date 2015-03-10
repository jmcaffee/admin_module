##############################################################################
# File::    lock.rb
# Purpose:: Lock testing helpers
# 
# Author::    Jeff McAffee 03/10/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

def create_lock_hash name
  { name: name,
    description: "#{name} Description",
    is_program_lock: false,
    parameters: [
      'Decision',
      'NewTerm'
    ],
    dts: [
      'Current Unpaid Balance',
    ]
  }
end


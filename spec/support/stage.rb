##############################################################################
# File::    stage.rb
# Purpose:: Stage testing helpers
# 
# Author::    Jeff McAffee 03/10/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

def create_stage_hash name
  { name: name,
    transition_to: {},
    groups: [
      'Appeal Underwriter',
      'CV Admin'
    ],
    events: {
      'ForwardApplication PreEvent' => '',
      'ForwardApplication PostEvent' => 'WF-ForwardApp-Post'
    },
  }
end


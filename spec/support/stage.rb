##############################################################################
# File::    stage.rb
# Purpose:: Stage testing helpers
#
# Author::    Jeff McAffee 03/10/2015
#
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


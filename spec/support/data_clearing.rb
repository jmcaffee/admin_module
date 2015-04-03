##############################################################################
# File::    data_clearing.rb
# Purpose:: Data Clearing testing helpers
#
# Author::    Jeff McAffee 2015-04-02
#
##############################################################################

def create_dc_hash name
  { name: name,
    description: "#{name} Description",
    delete_options: {
      :decision_data => true,
      :conditions_with_images => true,
      :incomes => true,
      :assets => true,
      :expenses => true,
      :hud1_fields => false,
      :payment_schedule => true,
    },
    dts: [
      'All Documents Received',
      'Approval',
      'Denial Reason',
    ]
  }
end


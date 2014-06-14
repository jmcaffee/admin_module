##############################################################################
# File::    stage_factory.rb
# Purpose:: Spec helper file to generate stage configuration data structures.
# 
# Author::    Jeff McAffee 06/13/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module Factory

  STAGE_NUMBER_MAP ||= {
      1 =>    "001 New File",
      2 =>    "002 Previous Incomplete App",
      5 =>    "005 Application and Eligibility",
      10 =>   "010 Customer Input",
      20 =>   "020 Pending Docs",
      22 =>   "022 Docs Verification",
      23 =>   "023 Docs Received",
      25 =>   "025 UW Review and Pre-screen",
      28 =>   "028 Pending Property Value",
      30 =>   "030 Trial Period Decision",
      35 =>   "035 In Trial",
      40 =>   "040 Trial Complete",
      45 =>   "045 Pending Mod",
      50 =>   "050 Mod Resend",
      52 =>   "052 Escrow Disbursement",
      55 =>   "055 Pending Activation",
      57 =>   "057 Pending Re-age/Escrow Set-up",
      60 =>   "060 Reconsideration Exceptions/Overrides",
      65 =>   "065 Approved Consideration",
      90 =>   "090 Mod Activation",
      93 =>   "093 Incomplete Application",
      95 =>   "095 Exclude Application",
      96 =>   "096 Withdrawn",
      97 =>   "097 Declined Appeal Eligible",
      98 =>   "098 Appeal Declined",
      99 =>   "099 Declined Not Appeal Eligible",
      105 =>  "105 Second Review-Hard Decline",
      120 =>  "120 Second Review-Pending Docs",
      125 =>  "125 Second Review-UW Review and Pre-screen",
      130 =>  "130 Second Review-Trial Period Decision",
      135 =>  "135 Second Review-In Trial",
      145 =>  "145 Second Review-Pending Mod",
      205 =>  "205 Appeal Hard Decline",
      210 =>  "210 Appeal Customer Input",
      220 =>  "220 Appeal Pending Docs",
      222 =>  "222 Appeal Docs Verification",
      223 =>  "223 Appeal Docs Received",
      225 =>  "225 Appeal-UW Review and Pre-screen",
      226 =>  "226 Appeal Preliminary NPV",
      227 =>  "227 Appeal Pending Appraisal Request",
      228 =>  "228 Appeal Pending Property Val",
      230 =>  "230 Appeal Trial Period Decision",
      305 =>  "305 Appeal 2nd Review-Hard Decline",
      320 =>  "320 Appeal 2nd Review-Pending Docs",
      325 =>  "325 Appeal 2nd Review-UW Review and Pre-screen",
      326 =>  "326 Appeal 2nd Review-Preliminary NPV",
      327 =>  "327 Appeal 2nd Review-Pending Appraisal Request",
      328 =>  "328 Appeal 2nd Review-Pending Property Val",
      330 =>  "330 Appeal 2nd Review-Trial Period Decision",
    }

  class StageFactory
    def initialize
      @name = ''
      @transitions = []
      @events = {
        "ForwardApplication PreEvent"=>"",
        "ForwardApplication PostEvent"=>"",
        "OrderCredit PreEvent"=>"",
        "OrderCredit PostEvent"=>"",
        "OrderAvm PreEvent"=>"",
        "OrderAvm PostEvent"=>"",
        "RerunProduct PreEvent"=>"",
        "RerunProduct PostEvent"=>"",
        "BatchUpload PreEvent"=>"",
        "BatchUpload PostEvent"=>"",
        "ProductSelection PreEvent"=>"",
        "ProductSelection PostEvent"=>"",
        "Decision Loan Pre Event"=>"",
        "Decision Loan Post Event"=>"",
        "ReDecision Loan Pre Event"=>"",
        "ReDecision Loan Post Event"=>"",
        "Lock Pre Event"=>"",
        "Lock Post Event"=>"",
        "Save Task Pre Event"=>"",
        "Save Task Post Event"=>"",
        "Export HSSN Pre Event"=>"",
        "Data Clearing Pre Event"=>"",
        "Data Clearing Post Event"=>""
      }
    end

    def name stage_name
      @name = stage_name
      self
    end

    def add_transition transition
      @transitions << transition.to_s
      self
    end

    def add_transition_by_number stage_num
      @transitions << Factory::STAGE_NUMBER_MAP[stage_num.to_i]
      self
    end

    def set_transitions transitions
      @transitions = Array(transitions)
      self
    end

    def set_event event, value
      if @events.fetch(event) { false }
        @events[event] = value.to_s
      end
      self
    end

    def set_events events
      @events.each_key do |k|
        @events[k] = events[k] if events.fetch(k) { false }
      end
      self
    end

    def data
      factory_data = {}
      factory_data[:name] = @name
      factory_data[:transition_to] = @transitions
      factory_data[:events] = @events
      factory_data
    end
  end # StageFactory
end # Factory


##############################################################################
# File::    cli_parameter.rb
# Purpose:: filedescription
# 
# Author::    Jeff McAffee 2014-03-19
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'admin_module/pages'

class AdminModule::CLI
  include AdminModule::Pages


  def get_parameters
    login

    parameters_page = ParametersPage.new(browser, base_url)
    variables = parameters_page.get_parameters
  end

  ###
  # Update a parameter's config values.
  # - var_name name of parameter to update
  # - params hash of values to update where:
  #   - :name is name of parameter
  #   - :type is Boolean, Date, DateTime, Money, Numeric, Percentage, or Text (case sensitive)
  #   - :decision is DSM when true, DPM when false
  #   - :order Fixnum value
  #   - :precision Only valid if :type is Numeric
  #   - :include include in app XML if true
  #
  def update_parameter(var_name, params)
    raise "Missing params" unless params.size > 0

    login

    parameters_page_url = ParametersPage.new(browser, base_url).edit_parameter(var_name)
    page = ParameterPage.new(browser, false)

    page.parameter_name = params.delete(:name) if params.key?(:name)
    page.parameter_type = params.delete(:type) if params.key?(:type)

    if ! params.key?(:decision).nil?
      page.decision_parameter = params[:decision] ? 'Yes' : 'No'
      params.delete(:decision)
    end

    page.parameter_order = params.delete(:order) if params.key?(:order)
    page.precision = params.delete(:precision) if params.key?(:precision)

    if ! params.key?(:include).nil?

      if params[:include]
        page.check_include_in_application_xml
      else
        page.uncheck_include_in_application_xml
      end
    end
    params.delete(:include)
    raise ArgumentError, "Unexpected params: #{params.inspect}" unless params.size == 0

    page.save
  end
end

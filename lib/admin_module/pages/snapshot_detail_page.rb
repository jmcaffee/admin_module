##############################################################################
# File::    snapshot_detail_page.rb
# Purpose:: Snapshot definition edit page for AdminModule
#
# Author::    Jeff McAffee 2015-04-05
#
##############################################################################
require 'page-object'

module AdminModule::Pages

class SnapshotDetailPage
  include PageObject

  #page_url(:get_dynamic_url)

  #def get_dynamic_url
  #  AdminModule.configuration.url(SnapshotDetailPage)
  #end

  text_field(:name,
             id: 'ctl00_cntPlh_txtName')

  text_area(:description,
            id: 'ctl00_cntPlh_txtDesc')

  select_list(:decision_data,
              id: 'ctl00_cntPlh_ddlDecision')

  select_list(:conditions,
              id: 'ctl00_cntPlh_ddlCondition')

  select_list(:incomes,
              id: 'ctl00_cntPlh_ddlIncome')

  select_list(:assets,
              id: 'ctl00_cntPlh_ddlAsset')

  select_list(:expenses,
              id: 'ctl00_cntPlh_ddlExpense')

  select_list(:hud1_fields,
              id: 'ctl00_cntPlh_ddlHUD1')

  select_list(:payment_schedule,
              id: 'ctl00_cntPlh_ddlPSchedule')


  # DTS/UDF Tab
  #

  link(:dts_tab,
        text: 'DTS/UDF')

    select_list(:dts_available,
                id: 'ctl00_cntPlh_tsSnapshotDTS_lstAvailable')

    select_list(:dts_selected,
                id: 'ctl00_cntPlh_tsSnapshotDTS_lstSelected')

    button(:add_dts_button,
                id: 'ctl00_cntPlh_tsSnapshotDTS_btnAdd')

    button(:remove_all_dts_button,
                id: 'ctl00_cntPlh_tsSnapshotDTS_btnRemoveAll')


  button(:save_button,
         id: 'ctl00_cntPlh_btnSave')

  button(:cancel_button,
         id: 'ctl00_cntPlh_btnCancel')

  def get_definition_data
    data = { name: self.name,
              description: self.description,
              delete_options: {
                :decision_data          => false,
                :conditions_with_images => false,
                :incomes                => false,
                :assets                 => false,
                :expenses               => false,
                :hud1_fields            => false,
                :payment_schedule       => false,
              }
    }

    data[:delete_options][:decision_data]           = true if self.decision_data == "Yes"
    data[:delete_options][:conditions_with_images]  = true if self.conditions == "Yes"
    data[:delete_options][:incomes]                 = true if self.incomes == "Yes"
    data[:delete_options][:assets]                  = true if self.assets == "Yes"
    data[:delete_options][:expenses]                = true if self.expenses == "Yes"
    data[:delete_options][:hud1_fields]             = true if self.hud1_fields == "Yes"
    data[:delete_options][:payment_schedule]        = true if self.payment_schedule == "Yes"

    self.dts_tab
    data[:dts] = self.dts_selected_options

    data
  end

  def set_definition_data data
    self.name = data[:name]
    self.description = data[:description]

    opts = data[:delete_options]
    set_delete_option decision_data_element,    opts[:decision_data]
    set_delete_option conditions_element,       opts[:conditions_with_images]
    set_delete_option incomes_element,          opts[:incomes]
    set_delete_option assets_element,           opts[:assets]
    set_delete_option expenses_element,         opts[:expenses]
    set_delete_option hud1_fields_element,      opts[:hud1_fields]
    set_delete_option payment_schedule_element, opts[:payment_schedule]

    self.dts_tab

    self.remove_all_dts_button
    assert_all_dts_fields_removed
    data[:dts].each do |d|
      dts_available_element.select(d)
      self.add_dts_button
    end

    self
  end

  def save
    self.save_button
  end

  def set_name name
    self.name = name

    self
  end

private

  def assert_all_dts_fields_removed
    raise "Unable to remove DTS fields" unless self.dts_selected_options.count == 0
  end

  def set_delete_option elem, value, name = ''
    if !elem.visible?
      $stdout << "The #{name} is not available for this definition." unless name.nil? || name.empty?
      return
    end

    if value == true
      elem.select('Yes')
    else
      elem.select('No')
    end
  end
end

end # module Pages


##############################################################################
# File::    select_list_syncable.rb
# Purpose:: Method to sync Available/Selected select lists
#
# Author::    Jeff McAffee 2015-06-27
#
##############################################################################

module AdminModule::Pages

module SelectListSyncable

  #
  # Sync an array of items between available and selected lists such that after
  # syncing, the selected list will contain only the items in the array.
  #
  # args:
  #   available_items   - list of items currently in the 'available' select element
  #   available_element - the 'available' select element
  #   selected_items    - list of items currently in the 'selected' select element
  #   selected_element  - the 'selected' select element
  #   add_btn           - the `Add` button element
  #   remove_btn        - the `Remove` button element
  #   items_to_select   - array of items to sync the select elements to
  #

  def sync_available_and_selected_lists available_items, available_element, selected_items, selected_element, add_btn, remove_btn, items_to_select
    working_set = items_to_select.dup
    items_to_remove = Array.new
    items_to_add = Array.new

    # Build a list of indices of items to remove from the selected list
    selected_items.each_index do |i|
      if working_set.include? selected_items[i]
        working_set.delete selected_items[i]
      else
        items_to_remove << i
      end
    end

    # Build a list of indices of items to add from the available list
    available_items.each_index do |i|
      if working_set.include? available_items[i]
        items_to_add << i
        working_set.delete available_items[i]
      end
    end

    # Select and remove all params in the removal list
    items_to_remove.each do |i|
      selected_element.options[i].click
    end
    remove_btn.click if items_to_remove.count > 0

    # Select and add all params in the add list
    items_to_add.each do |i|
      available_element.options[i].click
    end
    add_btn.click if items_to_add.count > 0
  end
end

end # module Pages


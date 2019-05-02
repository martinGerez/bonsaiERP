# == Schema Information
#
# Table name: inventory_details
#
#  id           :integer          not null, primary key
#  quantity     :decimal(14, 2)   default(0.0)
#  created_at   :datetime
#  updated_at   :datetime
#  inventory_id :integer
#  item_id      :integer
#  store_id     :integer
#
# Indexes
#
#  index_inventory_details_on_inventory_id  (inventory_id)
#  index_inventory_details_on_item_id       (item_id)
#  index_inventory_details_on_store_id      (store_id)
#

require 'spec_helper'

describe InventoryDetail do
  it { should belong_to(:inventory) }
  it { should belong_to(:item) }

  it { should validate_presence_of(:item) }
  it { should validate_presence_of(:item_id) }

  it { should have_valid(:quantity).when(0.1, 1, 100) }
  it { should_not have_valid(:quantity).when(-0.1, nil, 0.0) }
end

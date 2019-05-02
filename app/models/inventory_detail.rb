# encoding: utf-8

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

# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryDetail < ActiveRecord::Base
  belongs_to :inventory
  belongs_to :item

  validates_presence_of     :item, :item_id, :quantity
  validates_numericality_of :quantity, greater_than: 0

  attr_accessor :available
end

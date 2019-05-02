# encoding: utf-8

# == Schema Information
#
# Table name: movement_details
#
#  id             :integer          not null, primary key
#  balance        :decimal(14, 2)   default(0.0)
#  description    :string
#  discount       :decimal(14, 2)   default(0.0)
#  original_price :decimal(14, 2)   default(0.0)
#  price          :decimal(14, 2)   default(0.0)
#  quantity       :decimal(14, 2)   default(0.0)
#  created_at     :datetime
#  updated_at     :datetime
#  account_id     :integer
#  item_id        :integer
#
# Indexes
#
#  index_movement_details_on_account_id  (account_id)
#  index_movement_details_on_item_id     (item_id)
#

# Class to store the details of a expense
class ExpenseDetail < MovementDetail

  # Relationships
  belongs_to :expense, -> { where(type: 'Expense') }, foreign_key: :account_id,
             inverse_of: :expense_details
  belongs_to :item, inverse_of: :expense_details

  delegate :for_sale?, :to_s, :name, :price, :buy_price, to: :item, prefix: true, allow_nil: true

  # Validations
  validates_presence_of :item
end

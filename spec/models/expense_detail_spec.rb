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

require 'spec_helper'

describe ExpenseDetail do
  it { should belong_to(:expense) }
  it { should belong_to(:item) }

  it { should validate_presence_of(:item) }
end

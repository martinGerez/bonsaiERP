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

describe IncomeDetail do
  it { should belong_to(:income) }
  it { should belong_to(:item) }

  it { should validate_presence_of(:item) }
  let(:income) { Income.new }

  context 'Validate correct income_item' do
    let(:item) {
      build :item, id: 1, for_sale: true, stockable: true, active: true
    }

    it "Item For sale" do
      id = IncomeDetail.new(item_id: item.id, price: 10, quantity: 1, account_id: 1)
      id.stub(item: item, income: income)

      expect(id.valid?).to eq(true)
      expect(id.errors[:item_id].blank?).to eq(true)
    end


    it "Not for sale" do
      item.for_sale = false
      id = IncomeDetail.new(item_id: item.id, price: 10, quantity: 1,  account_id: 1)
      id.stub(item: item, income: income)

      expect(id.valid?).to eq(false)
      expect(id.errors[:item_id].blank?).to eq(false)
    end

    it "whe income_detail.item_id doesn't change but item.for_sale = false" do
      id = IncomeDetail.new(item_id: item.id, price: 10, quantity: 1,  account_id: 1)
      id.stub(item: item, income: income)

      id.save.should eq(true)

      id.item.for_sale = false
      id.item.should_not be_for_sale

      id.should be_valid
    end
  end
end

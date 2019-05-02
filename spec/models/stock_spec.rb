# == Schema Information
#
# Table name: stocks
#
#  id           :integer          not null, primary key
#  active       :boolean          default(TRUE)
#  minimum      :decimal(14, 2)   default(0.0)
#  quantity     :decimal(14, 2)   default(0.0)
#  unitary_cost :decimal(14, 2)   default(0.0)
#  created_at   :datetime
#  updated_at   :datetime
#  item_id      :integer
#  store_id     :integer
#  user_id      :integer
#
# Indexes
#
#  index_stocks_on_active    (active)
#  index_stocks_on_item_id   (item_id)
#  index_stocks_on_minimum   (minimum)
#  index_stocks_on_quantity  (quantity)
#  index_stocks_on_store_id  (store_id)
#  index_stocks_on_user_id   (user_id)
#

require 'spec_helper'

describe Stock do
  it { should belong_to(:store) }
  it { should belong_to(:item) }
  it { should belong_to(:user) }

  it { should validate_numericality_of(:minimum) }
  it { should validate_presence_of(:store) }
  it { should validate_presence_of(:store_id) }
  it { should validate_presence_of(:item) }
  it { should validate_presence_of(:item_id) }

  subject { Stock.new }
  it { subject.quantity.should == 0 }
  it { should be_active }

  it "#save_minimum" do
    stock = Stock.new(quantity: 2, item_id: 1, store_id: 2, minimum: 0)
    stock.stub(item: build(:item), store: build(:store))
    stock.save.should eq(true)

    UserSession.user = build(:user, id: 25)
    stock.save_minimum(10).should eq(true)

    stock.user_id.should eq(25)

    stock.save_minimum(-1).should eq(false)
    stock.errors[:minimum].should eq([I18n.t("errors.messages.greater_than", count: 0)])

    stock.errors.clear
    stock.save_minimum('-0.2').should eq(false)
    stock.errors[:minimum].should eq([I18n.t("errors.messages.greater_than", count: 0)])

    stock.save_minimum(nil).should eq(true)
    stock.minimum.should == 0
  end

  context '::scopes' do
    it "item_like" do
      sql = Stock.item_like('ba').to_sql

      expect(sql).to match(/items.name ILIKE '%ba%' OR items.code ILIKE '%ba%'/)
    end
  end
end

# == Schema Information
#
# Table name: items
#
#  id          :integer          not null, primary key
#  active      :boolean          default(TRUE)
#  buy_price   :decimal(14, 2)   default(0.0)
#  code        :string(100)
#  description :string
#  for_sale    :boolean          default(TRUE)
#  name        :string(255)
#  price       :decimal(14, 2)   default(0.0)
#  stockable   :boolean          default(TRUE)
#  tag_ids     :integer          default([]), is an Array
#  unit_name   :string(255)
#  unit_symbol :string(20)
#  created_at  :datetime
#  updated_at  :datetime
#  creator_id  :integer
#  unit_id     :integer
#  updater_id  :integer
#
# Indexes
#
#  index_items_on_code        (code)
#  index_items_on_creator_id  (creator_id)
#  index_items_on_for_sale    (for_sale)
#  index_items_on_stockable   (stockable)
#  index_items_on_tag_ids     (tag_ids) USING gin
#  index_items_on_unit_id     (unit_id)
#  index_items_on_updater_id  (updater_id)
#

class ItemSerializer
  attr_reader :items, :store_id

  def income(items)
    @items = items
    items.map do |item|
      {
        id: item.id, name: item.name,
        code: item.code, price: item.price,
        unit_symbol: item.unit_symbol, unit_name: item.unit_name, label: item.to_s
      }
    end
  end

  def expense(items)
    @items = items
    items.map do |item|
      {
        id: item.id, name: item.name,
        code: item.code, price: item.buy_price,
        unit_symbol: item.unit_symbol, unit_name: item.unit_name, label: item.to_s
      }
    end
  end

  def inventory(items, store_id)
    @items, @store_id = items, store_id
    items.map do |item|
      {
        id: item.id, name: item.name,
        code: item.code, price: item.buy_price,
        unit_symbol: item.unit_symbol, unit_name: item.unit_name, label: item.to_s,
        stock: get_stock(item.id)
      }
    end
  end

  private

    def get_stock(item_id)
      stocks_hash.fetch(item_id) { 0 }
    end

    def stocks_hash
      Hash[stocks(items.map(&:id)).map { |v| [v.item_id, v.quantity] }]
    end

    def stocks(item_ids)
      @stocks ||= Stock.active.select('item_id, quantity').where(store_id: store_id, item_id: item_ids)
    end
end

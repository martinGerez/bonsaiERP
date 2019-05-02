# == Schema Information
#
# Table name: histories
#
#  id               :integer          not null, primary key
#  all_data         :json
#  extras           :hstore
#  historiable_type :string
#  history_data     :json
#  klass_type       :string
#  new_item         :boolean          default(FALSE)
#  created_at       :datetime
#  historiable_id   :integer
#  user_id          :integer
#
# Indexes
#
#  index_histories_on_created_at                           (created_at)
#  index_histories_on_historiable_id_and_historiable_type  (historiable_id,historiable_type)
#  index_histories_on_user_id                              (user_id)
#

class History < ActiveRecord::Base

  # Relationships
  belongs_to :historiable, polymorphic: true
  belongs_to :user

  store_accessor :extras, :klass_to_s, :operation_type

  def history_attributes
    @history_attributes ||= history_data.keys
  end

  def history
    @hist_data ||= get_typecasted
  end

  private

    def get_typecasted
      Hash[history_data.map do |key, val|
        [key, typecast_hash(val) ]
      end]
    end

    def typecast_hash(val)
      case val['type']
      when 'string', 'text', 'integer', 'boolean', 'float'
        { from: val['from'], to: val['to'], type: val['type'] }
      when 'date', 'datetime', 'time'
        { from: typecast_transform(val['from'], val['type']),
          to: typecast_transform(val['to'], val['type']), type: val['type'] }
      when 'decimal'
        { from: BigDecimal.new(val['from'].to_s),
          to: BigDecimal.new(val['to'].to_s), type: val['type'] }
      end
    rescue
      {}
    end

    def typecast_transform(val, type)
      val.to_s.send(:"to_#{type}")
    rescue
      val
    end

end

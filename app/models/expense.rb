# encoding: utf-8

# == Schema Information
#
# Table name: accounts
#
#  id                :integer          not null, primary key
#  active            :boolean          default(TRUE)
#  amount            :decimal(14, 2)   default(0.0)
#  approver_datetime :datetime
#  balance_inventory :decimal(, )
#  bill_number       :string
#  currency          :string(10)
#  date              :date
#  delivered         :boolean
#  description       :text
#  devolution        :boolean
#  discounted        :boolean
#  due_date          :date
#  error_messages    :string(400)
#  exchange_rate     :decimal(14, 4)   default(1.0)
#  extras            :jsonb
#  gross_total       :decimal(, )
#  has_error         :boolean          default(FALSE)
#  inventory         :boolean
#  name              :string
#  null_reason       :string
#  nuller_datetime   :datetime
#  operation_type    :string
#  original_total    :decimal(, )
#  state             :string(30)
#  tag_ids           :integer          default([]), is an Array
#  tax_in_out        :boolean          default(FALSE)
#  tax_percentage    :decimal(5, 2)    default(0.0)
#  total             :decimal(14, 2)   default(0.0)
#  type              :string(30)
#  created_at        :datetime
#  updated_at        :datetime
#  approver_id       :integer
#  contact_id        :integer
#  creator_id        :integer
#  nuller_id         :integer
#  project_id        :integer
#  tax_id            :integer
#  updater_id        :integer
#
# Indexes
#
#  index_accounts_on_active       (active)
#  index_accounts_on_amount       (amount)
#  index_accounts_on_approver_id  (approver_id)
#  index_accounts_on_contact_id   (contact_id)
#  index_accounts_on_creator_id   (creator_id)
#  index_accounts_on_currency     (currency)
#  index_accounts_on_date         (date)
#  index_accounts_on_description  (description) USING gin
#  index_accounts_on_due_date     (due_date)
#  index_accounts_on_extras       (extras) USING gin
#  index_accounts_on_has_error    (has_error)
#  index_accounts_on_name         (name) UNIQUE
#  index_accounts_on_nuller_id    (nuller_id)
#  index_accounts_on_project_id   (project_id)
#  index_accounts_on_state        (state)
#  index_accounts_on_tag_ids      (tag_ids) USING gin
#  index_accounts_on_tax_id       (tax_id)
#  index_accounts_on_tax_in_out   (tax_in_out)
#  index_accounts_on_type         (type)
#  index_accounts_on_updater_id   (updater_id)
#

# author: Boris Barroso
# email: boriscyber@gmail.com
class Expense < Movement

  include Models::History
  has_history_details Movements::History, :expense_details

  self.code_name = 'E'

  jsonb_accessor(:extras,
    {delivered: :boolean,
    discounted: :boolean,
    devolution: :boolean,
    gross_total: :decimal,
    inventory: :boolean,
    balance_inventory: :decimal,
    original_total: :decimal,
    bill_number: :string,
    null_reason: :string,
    operation_type: :string,
    nuller_datetime: :date_time,
    approver_datetime: :date_time})
  ########################################
  # Relationships
  has_many :expense_details, -> { order('id asc') },
           foreign_key: :account_id, dependent: :destroy
  alias_method :details, :expense_details

  accepts_nested_attributes_for :expense_details, allow_destroy: true,
                                reject_if: proc { |det| det.fetch(:item_id).blank? }

  has_many :payments, -> { where(operation: 'payout') },
           class_name: 'AccountLedger', foreign_key: :account_id
  has_many :devolutions, -> { where(operation: 'devin') },
           class_name: 'AccountLedger', foreign_key: :account_id

  ########################################
  # Scopes
  scope :approved, -> { where(state: 'approved') }
  scope :active,   -> { where(state: %w(approved paid)) }
  scope :paid, -> { where(state: 'paid') }
  scope :contact, -> (cid) { where(contact_id: cid) }
  scope :pendent, -> { active.where.not(amount: 0) }
  scope :error, -> { active.where(has_error: true) }
  scope :due, -> { approved.where("accounts.due_date < ?", Time.zone.now.to_date) }
  scope :nulled, -> { where(state: 'nulled') }
  scope :inventory, -> { active.where("extras->'delivered' = ?", 'false') }
  scope :like, -> (s) {
    s = "%#{s}%"
    t = Expense.arel_table
    where(t[:name].matches(s).or(t[:description].matches(s) ) )
  }
  scope :date_range, -> (range) { where(date: range) }

  def subtotal
    expense_details.inject(0) { |sum, det| sum += det.total }
  end

  def as_json(options = {})
    super(options).merge(expense_details: expense_details.map(&:attributes))
  end
end

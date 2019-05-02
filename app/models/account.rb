# encoding: utf-8

# == Schema Information
#
# Table name: accounts
#
#  id             :integer          not null, primary key
#  active         :boolean          default(TRUE)
#  amount         :decimal(14, 2)   default(0.0)
#  currency       :string(10)
#  date           :date
#  description    :text
#  due_date       :date
#  error_messages :string(400)
#  exchange_rate  :decimal(14, 4)   default(1.0)
#  extras         :jsonb
#  has_error      :boolean          default(FALSE)
#  name           :string
#  state          :string(30)
#  tag_ids        :integer          default([]), is an Array
#  tax_in_out     :boolean          default(FALSE)
#  tax_percentage :decimal(5, 2)    default(0.0)
#  total          :decimal(14, 2)   default(0.0)
#  type           :string(30)
#  created_at     :datetime
#  updated_at     :datetime
#  approver_id    :integer
#  contact_id     :integer
#  creator_id     :integer
#  nuller_id      :integer
#  project_id     :integer
#  tax_id         :integer
#  updater_id     :integer
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
class Account < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include ::Models::Tag
  include ::Models::Updater

  ########################################
  # Relationships
  belongs_to :contact
  has_many :account_ledgers, -> { order('date desc, id desc') }

  belongs_to :approver, class_name: 'User'
  belongs_to :nuller,   class_name: 'User'
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
  belongs_to :tax

  ########################################
  # Validations
  validates_presence_of :currency, :name
  validates_numericality_of :amount
  validates_inclusion_of :currency, in: CURRENCIES.keys
  validates_uniqueness_of :name
  validates_lengths_from_database

  # attribute
  serialize :error_messages, JSON

  ########################################
  # Scopes
  scope :to_pay, -> { where('amount < 0') }
  scope :to_recieve, -> { where('amount > 0') }
  scope :active, -> { where(active: true) }
  scope :money, -> { where(type: %w(Bank Cash)) }
  scope :in, -> { where(type: %w(Income Loans::Give)) }
  scope :out, -> { where(type: %w(Expense Loans::Receive)) }
  scope :approved, -> { where(state: 'approved') }
  scope :operations, -> { where(type: %w(Income Loans::Give Expense Loans::Receive)) }

  delegate :name, :code, :symbol, to: :curr, prefix: true

  ########################################
  # Methods
  def to_s
    name
  end

  def curr
    @curr ||= Currency.find(currency)
  end
end

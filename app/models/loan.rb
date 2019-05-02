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
class Loan < Account
  # module for setters and getters
  extend SettersGetters
  extend Models::AccountCode

  include Models::History

  STATES = %w(approved paid nulled).freeze
  LOAN_TYPES = %w(Loans::Receive Loans::Give).freeze

  # Store
  extend Models::HstoreMap
  store_accessor :extras, :interests
  convert_hstore_to_decimal :interests

  # Validations
  validates_presence_of :date, :due_date, :name, :contact, :contact_id
  validates :total, numericality: { greater_than: 0 }
  validate :valid_greater_due_date
  validates :state, inclusion: { in: STATES }

  class << self
    def find(id)
      Account.where(type: LOAN_TYPES).find(id)
    end
  end

  alias_method :old_attributes, :attributes
  def attributes
    old_attributes.merge("interests" => interests)
  end

  STATES.each do |m|
    define_method :"is_#{m}?" do
      state == m
    end
  end

  private

    def valid_greater_due_date
      if due_date.present? && date.present? && due_date < date
        errors.add(:due_date, I18n.t('errors.messages.loan.due_date'))
      end
    end

end

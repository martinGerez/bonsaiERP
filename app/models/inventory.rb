# encoding: utf-8

# == Schema Information
#
# Table name: inventories
#
#  id              :integer          not null, primary key
#  date            :date
#  description     :string
#  error_messages  :string
#  has_error       :boolean          default(FALSE)
#  operation       :string(10)
#  ref_number      :string
#  total           :decimal(14, 2)   default(0.0)
#  created_at      :datetime
#  updated_at      :datetime
#  account_id      :integer
#  contact_id      :integer
#  creator_id      :integer
#  project_id      :integer
#  store_id        :integer
#  store_to_id     :integer
#  transference_id :integer
#  updater_id      :integer
#
# Indexes
#
#  index_inventories_on_account_id  (account_id)
#  index_inventories_on_contact_id  (contact_id)
#  index_inventories_on_date        (date)
#  index_inventories_on_has_error   (has_error)
#  index_inventories_on_operation   (operation)
#  index_inventories_on_project_id  (project_id)
#  index_inventories_on_ref_number  (ref_number)
#  index_inventories_on_store_id    (store_id)
#  index_inventories_on_updater_id  (updater_id)
#

# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventory < ActiveRecord::Base

  include ::Models::Updater

  before_create { self.creator_id = UserSession.id }

  OPERATIONS = %w(in out inc_in inc_out exp_in exp_out trans).freeze

  belongs_to :store
  belongs_to :store_to, class_name: "Store"
  belongs_to :contact
  belongs_to :creator, class_name: "User"
  belongs_to :expense, foreign_key: :account_id
  belongs_to :income, foreign_key: :account_id
  belongs_to :project

  #has_one    :transference, :class_name => 'InventoryOperation', :foreign_key => "transference_id"

  has_many :inventory_details, dependent: :destroy
  accepts_nested_attributes_for :inventory_details, allow_destroy: true,
                                reject_if: lambda {|attrs| attrs[:quantity].blank? || attrs[:quantity].to_d <= 0 }
  alias :details :inventory_details

  # Validations
  validates_presence_of :ref_number, :store_id, :store, :date
  validates_inclusion_of :operation, in: OPERATIONS
  validates_lengths_from_database

  # attribute
  serialize :error_messages, JSON

  OPERATIONS.each do |_op|
    define_method :"is_#{_op}?" do
      _op === operation
    end
  end

  #with_options :if => :transout? do |inv|
    #inv.validates_presence_of :store_to
  #end

  def is_transference?
    %w(transin transout).include?(operation)
  end

  def to_s
    ref_number
  end

  # Returns an array with the details fo the transaction
  def get_transaction_items
    transaction.transaction_details
  end

  def is_income?
    is_inc_in? || is_inc_out?
  end

  def is_expense?
    is_exp_in? || is_exp_out?
  end

  def set_ref_number
    io = Inventory.select("id, ref_number").order("id DESC").limit(1).first

    if io.present?
      self.ref_number = get_ref_io(io)
    else
      self.ref_number = "#{op_ref_type}-#{year}-0001"
    end
  end

  def movement
    case
    when(is_inc_in? || is_inc_out?)
      income
    when(is_exp_in? || is_exp_out?)
      expense
    end
  end

  def is_in?
    %w(in inc_in exp_in).include? operation
  end

  def is_out?
    %w(out inc_out exp_out).include? operation
  end

  private

    def get_ref_io(io)
      _, y, _ = io.ref_number.split('-')
      if y === year
        "#{op_ref_type}-#{year}-#{"%04\d" % io.id.next}"
      else
        "#{op_ref_type}-#{year}-0001"
      end
    end

    def year
      @year ||= Time.zone.now.year.to_s[2..4]
    end

    def op_ref_type
      case
      when is_in?    then "I"
      when is_out?   then "E"
      when is_trans? then "T"
      end
    end
end

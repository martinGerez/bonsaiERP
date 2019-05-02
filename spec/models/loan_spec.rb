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

require 'spec_helper'

describe Loan do
  it { should have_valid(:total).when(1, 100) }
  it { should_not have_valid(:total).when(0, -100) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:due_date) }
  it { should have_valid(:state).when(*Loan::STATES) }
  it { should_not have_valid(:state).when('a', nil) }

  it { should have_many(:histories) }

  let(:attributes) {
    today = Date.today
    {
      name: 'P-0001', currency: 'BOB', date: today,
      due_date: today + 10.days, total: 100, amount: 100,
      interests: 10, contact_id: 1, state: 'approved'
    }
  }

  it "is_approved?" do
    l = Loan.new
    l.state = 'approved'
    l.should be_is_approved
    l.state = 'paid'
    l.should be_is_paid
    l.state = 'nulled'
    l.should be_is_nulled
  end

  it "#valid_due_date" do
    l = Loan.new(attributes)
    l.stub(contact: build(:contact))

    l.due_date = l.date - 1.day

    expect(l).to be_invalid

    l.due_date = l.date

    expect(l).to be_valid
  end


  before(:each) do
    UserSession.user = build(:user, id: 1)
  end

  describe 'initialization' do
    it "#attributes" do
      l = Loan.new
      keys = l.attributes.keys

      keys.should be_include('id')
      keys.should be_include('name')
      keys.should be_include('total')
      keys.should be_include('interests')
    end

    it "initializes all attributes" do
      l = Loan.new(attributes)
      expect(l.name).to eq('P-0001')
      l.total.should == 100
      l.amount.should == 100
      l.interests.should == 10
    end

    #it "create" do
    #  Loan.any_instance.stub(contact: build(:contact))

    #  l = Loan.new(attributes)
    #  l.save.should be_true
    #  #Loan.create!(attributes.merge(name: 'P-0002'))

    #  l.attributes
    #  l.amount.should == 100

    #  l.amount = 50
    #  l.save.should be_true

    #  l = Loan.find l.id
    #  l.amount.should == 50
    #  #Loan.all.each do |l|
    #  #  puts l.amount
    #  #end
    #end
  end
end

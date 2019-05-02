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

require 'spec_helper'

describe Account do

  it { should belong_to(:updater).class_name('User') }
  #
  it { should belong_to(:contact) }
  it { should have_many(:account_ledgers) }


  it { should have_valid(:currency).when('BOB', 'EUR') }
  it { should_not have_valid(:currency).when('BOBB', 'UUUU') }
  it { should have_valid(:amount).when(10, 0.0, -10.0) }
  it { should_not have_valid(:amount).when(nil, '') }

  it { should validate_uniqueness_of(:name) }

  before :each do
    UserSession.user = build :user, id: 1
  end

  let(:valid_params) do
    {name: 'account1', currency: 'BOB', amount: 100, state: 'new'}
  end

  context 'scopes' do
    it "::to_pay" do
      ac = Account.active.new
      ac.should be_active
    end

    it "::money" do
      ac = Account.money
      #expect(ac.type).to eq(["Bank", "Cash"])
      expect(ac.to_sql).to match(/'Bank', 'Cash'/)

      ac = Account.active.money
      expect(ac.to_sql).to match(/"accounts"."active" = 't' AND "accounts"."type" IN \('Bank', 'Cash'\)/)
    end
  end

  it 'should be created' do
    Account.create!(valid_params)
  end

  context 'tags' do
    before(:each) do
      Tag.create(name: 'tag1', bgcolor: '#efefef')
      Tag.create(name: 'tag2', bgcolor: '#efefef')
    end

    let (:tag_ids) { Tag.select("id").pluck(:id) }

    it "valid_tags" do
      a = Account.new(valid_params.merge(tag_ids: [tag_ids.first]))
      a.save.should eq(true)
      a.tag_ids.should eq([tag_ids.first])

      t_ids = tag_ids + [100000, 99999999]
      a.tag_ids = t_ids

      expect(a.tag_ids.size).to eq(4)

      a.save.should eq(true)

      expect(a.tag_ids).to eq(tag_ids)
      expect(a.tag_ids.size).to eq(2)

      expect(a.updater_id).to eq(1)

      a.tag_ids = [1231231232, 23232]
      a.save.should eq(true)

      expect(a.tag_ids).to eq([])
      expect(a.tag_ids.size).to eq(0)
    end

    it "scopes" do
      Tag.create!(name: 'tag3', bgcolor: '#efefef')
      Account.create!(valid_params.merge(tag_ids: [tag_ids.first]))
      Account.create!(valid_params.merge(name: 'other name', tag_ids: tag_ids))

      expect(Account.any_tags(*tag_ids).count).to eq(2)

      expect(Account.all_tags(*tag_ids).count).to eq(1)
    end
  end
end

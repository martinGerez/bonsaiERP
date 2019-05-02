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

describe Bank do
  let(:valid_attributes) {
    { currency: 'BOB', name: 'Banco Uno 12365498', address: 'Uno', amount: 100, phone: '55-6678', website: 'mind.com' }
  }


  it "returns to_s" do
    b = Bank.new name: 'Banco Central 121-121289'
    b.to_s.should eq("Banco Central 121-121289")
  end

  it 'should create an instance' do
    UserSession.user = build :user, id: 1
    b = Bank.new(valid_attributes)

    b.save.should eq(true)

    valid_attributes.each do |k, v|
      b.send(k).should eq(v)
    end
  end


  it 'should update attributes' do
    UserSession.user = build :user, id: 1
    b = Bank.new(valid_attributes)
    b.save.should eq(true)
    b.should be_persisted

    h = {:website => "www.bnb.com.bo", :address => "Very near", :phone => "2798888"}
    b.update_attributes(h).should eq(true)

    b.reload

    h.each do |k, v|
      b.send(k).should eq(v)
    end
  end

  it "#attributes" do
    attrs = { email: 'test@mail.com', address: 'Por ahi', phone: '555 555', website: 'mysite..com' }
    b = Bank.new(attrs)

    attrs.each do |k, v|
      b.attributes[k.to_s].should eq(v)
    end
  end

end

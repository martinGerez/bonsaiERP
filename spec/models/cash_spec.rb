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

describe Cash do
  let(:valid_attributes) do
    { currency: 'BOB', name: 'Caja 1', amount: 1000.0, address: 'First way', phone: '777-12345', email: 'my@mail.com' }
  end

  before(:each) do
    OrganisationSession.organisation = build(:organisation, currency: 'BOB')
  end

  context 'Created related and check relationships, validations' do
    subject { Cash.new }


    it { should_not have_valid(:name).when('No', 'E', '', nil) }
    it { should have_valid(:name).when('Especial', 'Caja 2') }
  end

  before(:each) do
    UserSession.user = build :user, id: 1
  end

  it "returns to_s method" do
    c = Cash.new name: 'Cash 1', currency: 'USD'

    c.to_s.should  eq(c.name)
  end

  it "methods" do
    c = Cash.new
    expect(c).to respond_to(:ledgers)
    expect(c).to respond_to(:pendent_ledgers)
  end

  it 'create an instance' do
    c = Cash.new(valid_attributes)
    c.save.should eq(true)

    valid_attributes.each do |k, v|
      c.send(k).should eq(v)
    end
  end

  it 'allow updates' do
    # Does not allow the use of create or create! methods
    c = Cash.new(valid_attributes.merge(amount: 200))
    c.save.should eq(true)

    c.should be_persisted

    c.update_attributes(address: 'Another address', email: 'caja1@mail.com').should eq(true)

    c = Cash.find(c.id)

    c.address.should eq('Another address')
    c.email.should eq('caja1@mail.com')
  end
end

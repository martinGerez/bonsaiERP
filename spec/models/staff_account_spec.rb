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

describe StaffAccount do
  let(:attributes) {
    { name: 'Lucas Estrella', currency:'BOB', amount: 1000,
      email: 'lucacho@facebook.com', address: 'Samaipata, La Paz',
      phone: '555 666 777', mobile: '777 888 999'
    }
  }

  before(:each) do
    OrganisationSession.organisation = build(:organisation, currency: 'BOB')
  end

  context 'Created related and check relationships, validations' do
    subject { StaffAccount.new }


    it { should_not have_valid(:name).when('No', 'E', '', nil) }
    it { should have_valid(:name).when('Juan Perez', 'Luci Luna 23') }

    it { should have_valid(:currency).when('BOB', 'USD') }
    it { should_not have_valid(:currency).when('BOBS', 'JEJE') }

  end

  it "methods" do
    c = Cash.new
    expect(c).to respond_to(:ledgers)
    expect(c).to respond_to(:pendent_ledgers)
  end

  before(:each) do
    UserSession.user = build :user, id: 1
  end

  context 'create' do
    let(:subject) { StaffAccount.create!(attributes) }

    it { subject.amount.should == 1000 }
    it { subject.to_s.should eq('Lucas Estrella BOB') }
    it { subject.address.should eq(attributes.fetch(:address)) }
    it { subject.phone.should eq(attributes.fetch(:phone)) }
    it { subject.mobile.should eq(attributes.fetch(:mobile)) }
  end
end

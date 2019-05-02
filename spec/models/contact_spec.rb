# encoding: utf-8

# == Schema Information
#
# Table name: contacts
#
#  id                :integer          not null, primary key
#  active            :boolean          default(TRUE)
#  address           :string(250)
#  aditional_info    :string(250)
#  client            :boolean          default(FALSE)
#  code              :string
#  email             :string(200)
#  expenses_status   :string(300)      default({})
#  first_name        :string(100)
#  incomes_status    :string(300)      default({})
#  last_name         :string(100)
#  matchcode         :string
#  mobile            :string(40)
#  organisation_name :string(100)
#  phone             :string(40)
#  position          :string
#  staff             :boolean          default(FALSE)
#  supplier          :boolean          default(FALSE)
#  tag_ids           :integer          default([]), is an Array
#  tax_number        :string(30)
#  type              :string
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_contacts_on_active      (active)
#  index_contacts_on_client      (client)
#  index_contacts_on_first_name  (first_name)
#  index_contacts_on_last_name   (last_name)
#  index_contacts_on_matchcode   (matchcode)
#  index_contacts_on_staff       (staff)
#  index_contacts_on_supplier    (supplier)
#  index_contacts_on_tag_ids     (tag_ids) USING gin
#

# author: Boris Barroso
# email: boriscyber@gmail.com
require 'spec_helper'

describe Contact do
  let(:valid_attributes) do
    {
      matchcode: 'Boris Barroso',  first_name: 'Boris', last_name: "Barroso",
      organisation_name: 'bonsailabs', email: 'boris@bonsailabs.com',
      address: "Los Pinos Bloque 80\nDpto. 202", phone: '2745620',
      mobile: '70681101', tax_number: '3376951'
    }
  end

  it { should have_many(:accounts) }
  it { should have_many(:contact_accounts) }
  it { should have_many(:incomes) }
  it { should have_many(:expenses) }
  it { should have_many(:inventories) }

  context 'Validations' do
    it {should validate_uniqueness_of(:matchcode) }
    it {should validate_presence_of(:matchcode) }

    it { should have_valid(:email).when('test@mail.com', 'my@example.com.bo', '') }
    it { should_not have_valid(:email).when('test@mail.com.1', 'my@example.com.bo.', 'hi') }


  end

  it "returns the correct methods for to_s and compleet_name" do
    c = Contact.new(valid_attributes.merge(matchcode: 'Boris B.'))

    c.to_s.should eq('Boris B.')
    c.complete_name.should eq('Boris Barroso')
    c.pdf_name.should eq(c.complete_name)
  end

  it "creates a new instance with staff false" do
    c = Contact.new
    c.should_not be_staff
  end

  it 'create a valid' do
    Contact.create!(valid_attributes)
  end

  it "#destroy" do
    c = Contact.create!(valid_attributes)

    c.stub(accounts: [Account.new])

    c.destroy.should eq(false)

    # inventories
    c.stub(accounts: [], inventories: [Inventory.new])
    c.destroy.should eq(false)

    c.stub(accounts: [], inventories: [])
    c.destroy.destroyed?.should eq(true)
  end

  context 'scopes' do
    it "::search" do
      expect(Contact.search('pa').to_sql).to match(
        /contacts.matchcode ILIKE '%pa%' OR contacts.first_name ILIKE '%pa%' OR contacts.last_name ILIKE '%pa%'/)
    end
  end
end

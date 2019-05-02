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

class ContactSerializer < ActiveModel::Serializer
  attributes :id, :matchcode, :first_name, :last_name, :to_s, :label

  def label
    to_s
  end
end

# encoding: utf-8

# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  active      :boolean          default(TRUE)
#  date_end    :date
#  date_start  :date
#  description :text
#  name        :string
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_projects_on_active  (active)
#

# author: Boris Barroso
# email: boriscyber@gmail.com
class Project < ActiveRecord::Base

  # associations
  has_many :accounts
  has_many :account_ledgers

  # validations
  validates_presence_of :name
  validates_lengths_from_database

  scope :active, -> { where(active: true) }

  def to_s
    name
  end

  def to_param
    "#{id}-#{to_s}".parameterize
  end
end

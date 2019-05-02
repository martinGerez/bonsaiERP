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

require 'spec_helper'

describe Project do
  it { should have_many(:accounts) }
  it { should have_many(:account_ledgers) }
end

# == Schema Information
#
# Table name: tag_groups
#
#  id         :integer          not null, primary key
#  bgcolor    :string
#  name       :string
#  tag_ids    :integer          default([]), is an Array
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_tag_groups_on_name     (name) UNIQUE
#  index_tag_groups_on_tag_ids  (tag_ids) USING gin
#

require 'spec_helper'

describe TagGroup do
  it { should validate_presence_of(:name) }
  it { should ensure_length_of(:name).is_at_least(3) }
  it { should ensure_length_of(:name).is_at_most(100) }

  let(:tag1) { create :tag, name: 'Tag 1' }
  let(:tag2) { create :tag, name: 'Tag 2' }

  it "#to_s" do
    tg = TagGroup.new(name: 'test')

    expect(tg.to_s).to eq('test')

    tg.name = 'Other'
    expect(tg.to_s).to eq('Other')
  end

  it "#tags" do
    tg = TagGroup.new(name: 'Group 1', tag_ids: [tag1.id])

    expect(tg.tags).to eq([tag1])

    tg.tag_ids = [tag1.id, tag2.id]

    expect(tg.tags).to eq([tag1, tag2])

    expect(tg.save).to eq(true)

    tg = TagGroup.find(tg.id)
    expect(tg.tags).to eq([tag1, tag2])
  end
end

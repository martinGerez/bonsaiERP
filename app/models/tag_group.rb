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

class TagGroup < ActiveRecord::Base

  validates :name, presence: true, length: { within: 3..100 }, uniqueness: true

  scope :api, -> { select('id, name, tag_ids') }

  def tags(reload = false)
    @tags = nil  if reload
    @tags ||= Tag.where(id: tag_ids)
  end

  def tag_ids=(ids)
    @tags = nil
    write_attribute(:tag_ids, Array(ids))
  end

  def to_s
    name
  end

  def to_api
    { id: id, name: name, tag_ids: tag_ids }
  end

end

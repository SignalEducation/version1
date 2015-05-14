# == Schema Information
#
# Table name: forum_post_concerns
#
#  id            :integer          not null, primary key
#  forum_post_id :integer
#  user_id       :integer
#  reason        :string(255)
#  live          :boolean          default(TRUE), not null
#  created_at    :datetime
#  updated_at    :datetime
#

class ForumPostConcern < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :forum_post_id, :user_id, :reason, :live

  # Constants

  # relationships
  belongs_to :forum_post
  belongs_to :user

  # validation
  validates :forum_post_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :reason, presence: true, length: {maximum: 255}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:forum_post_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

end

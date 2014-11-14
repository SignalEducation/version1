# == Schema Information
#
# Table name: user_exam_levels
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  exam_level_id    :integer
#  exam_schedule_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class UserExamLevel < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :exam_level_id, :exam_schedule_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :exam_level # todo de-normalised
  # todo belongs_to :exam_schedule

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_schedule_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end

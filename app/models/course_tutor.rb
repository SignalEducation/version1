# == Schema Information
#
# Table name: course_tutors
#
#  id                :integer          not null, primary key
#  course_id :integer
#  user_id           :integer
#  sorting_order     :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class CourseTutor < ApplicationRecord

  # Constants

  # relationships
  belongs_to :course
  belongs_to :user

  # validation
  validates :course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true
  #validates :title, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end

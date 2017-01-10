# == Schema Information
#
# Table name: exam_sittings
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  exam_body_id      :integer
#

class ExamSitting < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :subject_course_id, :date, :exam_body_id

  # Constants

  # relationships
  belongs_to :exam_body
  belongs_to :subject_course

  # validation
  validates :exam_body_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }

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

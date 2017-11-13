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
#  active            :boolean          default(TRUE)
#

class ExamSitting < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :subject_course_id, :date, :exam_body_id, :active

  # Constants

  # relationships
  belongs_to :exam_body
  belongs_to :subject_course

  # validation
  validates :exam_body_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :date, presence: true

  # callbacks
  before_destroy :check_dependencies
  after_create :create_expiration_worker

  # scopes
  scope :all_in_order, -> { order(:date, :name) }
  scope :all_active, -> { where(active: true) }

  # class methods

  # instance methods
  def destroyable?
    !self.active
  end

  def formatted_date
    date.strftime("%B %Y")
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def create_expiration_worker
    ExamSittingExpirationWorker.perform_at(self.date.to_datetime + 23.hours, self.id)
  end

end

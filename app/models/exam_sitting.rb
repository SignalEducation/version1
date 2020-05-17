# == Schema Information
#
# Table name: exam_sittings
#
#  id                :integer          not null, primary key
#  name              :string
#  course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  exam_body_id      :integer
#  active            :boolean          default("true")
#  computer_based    :boolean          default("false")
#

class ExamSitting < ApplicationRecord

  # Constants
  SORT_OPTIONS = %w(active not-active all)

  # relationships
  belongs_to :exam_body
  belongs_to :course
  has_many :enrollments

  # validation
  validates :exam_body_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0},
            unless: :computer_based?
  validates :name, presence: true
  validates :date, presence: true,
            unless: :computer_based?

  # callbacks
  before_destroy :check_dependencies
  after_create :create_expiration_worker, unless: :computer_based?

  # scopes
  scope :all_in_order, -> { order(:date, :name) }
  scope :all_active, -> { where(active: true) }
  scope :all_not_active, -> { where(active: false) }
  scope :all_computer_based, -> { where(computer_based: true) }
  scope :all_standard, -> { where(computer_based: false) }
  # scope :sort_by, -> { where(computer_based: false) }

  # class methods

  # instance methods
  def destroyable?
    # Can never be destroyed because the CSV data files will not be available
    false
  end

  def formatted_date
    computer_based ? 'Computer Based Exam' : date.strftime("%B %Y")
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
      throw :abort
    end
  end

  def create_expiration_worker
    return if Rails.env.test?

    ExamSittingExpirationWorker.perform_at(date.to_datetime + 23.hours, id)
  end

end

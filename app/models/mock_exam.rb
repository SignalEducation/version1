# == Schema Information
#
# Table name: mock_exams
#
#  id                :integer          not null, primary key
#  subject_course_id :integer
#  product_id        :integer
#  name              :string
#  sorting_order     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class MockExam < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :subject_course_id, :product_id, :name, :sorting_order
  # Constants

  # relationships
  belongs_to :subject_course
  has_one :product


  # validation
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  #validates :product_id, presence: true,
  #          numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :subject_course_id) }

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

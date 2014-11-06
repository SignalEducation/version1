# == Schema Information
#
# Table name: exam_sections
#
#  id                                :integer          not null, primary key
#  name                              :string(255)
#  name_url                          :string(255)
#  exam_level_id                     :integer
#  active                            :boolean          default(FALSE), not null
#  sorting_order                     :integer
#  best_possible_first_attempt_score :float
#  created_at                        :datetime
#  updated_at                        :datetime
#

class ExamSection < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :exam_level_id, :active, :sorting_order, :best_possible_first_attempt_score

  # Constants

  # relationships
  belongs_to :exam_level
  has_many :course_modules

  # validation
  validates :name, presence: true
  validates :name_url, presence: true, uniqueness: true
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true
  validates :best_possible_first_attempt_score, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }

  # class methods

  # instance methods
  def destroyable?
    self.course_modules.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end

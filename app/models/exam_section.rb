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
  attr_accessible :name, :name_url, :exam_level_id, :active, :sorting_order

  # Constants

  # relationships
  belongs_to :exam_level
  has_many :course_modules
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :student_exam_tracks

  # validation
  validates :name, presence: true
  validates :name_url, presence: true, uniqueness: true
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true

  # callbacks
  before_save :calculate_best_possible_score
  before_save :sanitize_name_url
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :with_url, lambda { |the_url| where(name_url: the_url) }

  # class methods

  # instance methods
  def children
    self.course_modules.all
  end

  def destroyable?
    !self.active && self.course_modules.empty? && self.student_exam_tracks.empty?
  end

  protected

  def calculate_best_possible_score
    self.best_possible_first_attempt_score = self.course_module_element_quizzes.sum(:best_possible_score_first_attempt)
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def sanitize_name_url
    self.name_url = self.name_url.to_s.gsub(' ', '-').gsub('/', '-').gsub('.', '-').gsub('_', '-').gsub('&', '-').gsub('?', '-').gsub('=', '-').gsub(':', '-').gsub(';', '-')
  end

end

# == Schema Information
#
# Table name: exam_levels
#
#  id                                      :integer          not null, primary key
#  qualification_id                        :integer
#  name                                    :string(255)
#  name_url                                :string(255)
#  is_cpd                                  :boolean          default(FALSE), not null
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  best_possible_first_attempt_score       :float
#  created_at                              :datetime
#  updated_at                              :datetime
#  default_number_of_possible_exam_answers :integer          default(4)
#

class ExamLevel < ActiveRecord::Base

  # attr-accessible
  attr_accessible :qualification_id, :name, :name_url, :is_cpd, :sorting_order, :active, :default_number_of_possible_exam_answers

  # Constants

  # relationships
  belongs_to :qualification
  has_many :exam_sections
  has_many :course_modules
  has_many :student_exam_tracks
  has_many :user_exam_level

  # validation
  validates :qualification_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true
  validates :sorting_order, presence: true
  validates :default_number_of_possible_exam_answers, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_save :calculate_best_possible_score
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:qualification_id) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

  # instance methods
  def destroyable?
    !self.active && self.exam_sections.empty? && self.course_modules.empty? && self.student_exam_tracks.empty? && self.user_exam_level.empty?
  end

  def full_name
    self.qualification.name + ' > ' + self.name
  end

  protected

  def calculate_best_possible_score
    # todo
    self.best_possible_first_attempt_score = 100
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end

# == Schema Information
#
# Table name: exam_levels
#
#  id                                :integer          not null, primary key
#  qualification_id                  :integer
#  name                              :string(255)
#  name_url                          :string(255)
#  is_cpd                            :boolean          default(FALSE), not null
#  sorting_order                     :integer
#  active                            :boolean          default(FALSE), not null
#  best_possible_first_attempt_score :float
#  created_at                        :datetime
#  updated_at                        :datetime
#

class ExamLevel < ActiveRecord::Base

  # attr-accessible
  attr_accessible :qualification_id, :name, :name_url, :is_cpd, :sorting_order, :active

  # Constants

  # relationships
  #todo: belongs_to :qualification
  #todo: has_many :exam_sections
  #todo: has_many :course_modules

  # validation
  validates :qualification_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true
  validates :sorting_order, presence: true
  validates :best_possible_first_attempt_score, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:qualification_id) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

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

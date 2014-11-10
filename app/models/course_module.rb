# == Schema Information
#
# Table name: course_modules
#
#  id                        :integer          not null, primary key
#  institution_id            :integer
#  qualification_id          :integer
#  exam_level_id             :integer
#  exam_section_id           :integer
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  tutor_id                  :integer
#  sorting_order             :integer
#  estimated_time_in_seconds :integer
#  compulsory                :boolean          default(FALSE), not null
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#

class CourseModule < ActiveRecord::Base

  # attr-accessible
  attr_accessible :institution_id, :qualification_id, :exam_level_id,
                  :exam_section_id, :name, :name_url, :description,
                  :tutor_id, :sorting_order, :estimated_time_in_seconds,
                  :compulsory, :active

  # Constants

  # relationships
  has_many :course_module_elements
  has_many :course_module_element_user_logs
  has_many :course_module_jumbo_quizzes
  belongs_to :exam_level
  belongs_to :exam_section
  belongs_to :institution
  belongs_to :qualification
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id

  # validation
  validates :institution_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_section_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true
  validates :description, presence: true
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true
  validates :estimated_time_in_seconds, presence: true, if: 'active == true'

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :institution_id) }
  scope :all_active, -> { where(active: true) }
  scope :all_inactive, -> { where(active: false) }

  # class methods

  # instance methods
  def array_of_sibling_ids
    self.parent_thing.course_modules.all_in_order.map(&:id)
  end

  def destroyable?
    self.course_module_elements.empty?
  end

  def my_position_among_siblings
    self.array_of_sibling_ids.index(self.id)
  end

  def next_module_id
    if self.my_position_among_siblings < (self.array_of_sibling_ids.length - 1)
      self.array_of_sibling_ids[self.my_position_among_siblings + 1]
    else
      nil
    end
  end

  def parent_thing
    self.exam_section ? self.exam_section : self.exam_level
  end

  def previous_module_id
    if self.my_position_among_siblings > 0
      self.array_of_sibling_ids[self.my_position_among_siblings - 1]
    else
      nil
    end
  end

  def recalculate_estimated_time
    self.update_attributes(estimated_time_in_seconds: self.course_module_elements.sum(:estimated_time_in_seconds))
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end

# == Schema Information
#
# Table name: course_module_elements
#
#  id                             :integer          not null, primary key
#  name                           :string(255)
#  name_url                       :string(255)
#  description                    :text
#  estimated_time_in_seconds      :integer
#  course_module_id               :integer
#  course_module_element_video_id :integer
#  course_module_element_quiz_id  :integer
#  sorting_order                  :integer
#  forum_topic_id                 :integer
#  tutor_id                       :integer
#  related_quiz_id                :integer
#  related_video_id               :integer
#  created_at                     :datetime
#  updated_at                     :datetime
#

class CourseModuleElement < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :description, :estimated_time_in_seconds,
                  :course_module_id, :course_module_element_video_id,
                  :course_module_element_quiz_id, :sorting_order,
                  :forum_topic_id, :tutor_id, :related_quiz_id, :related_video_id

  # Constants

  # relationships
  belongs_to :course_module
  # todo belongs_to :course_module_element_video
  belongs_to :course_module_element_quiz
  # todo belongs_to :forum_topic
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  belongs_to :related_quiz, class_name: 'CourseModuleElement', foreign_key: :related_quiz_id
  # todo belongs_to :related_video, class_name: 'CourseModuleElement', foreign_key: :related_video_id
  has_many :course_module_element_resources
  # todo has_many :course_module_element_user_logs

  # validation
  validates :name, presence: true, uniqueness: true
  validates :name_url, presence: true, uniqueness: true
  validates :description, presence: true
  validates :estimated_time_in_seconds, presence: true
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_quiz_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :forum_topic_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :related_quiz_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :related_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validate :video_or_quiz_id_required

  # callbacks
  before_destroy :check_dependencies
  after_save :update_the_module_total_time

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def video_or_quiz_id_required
    if self.course_module_element_video_id.nil? && self.course_module_element_quiz_id.nil?
      errors.add(:base, I18n.t('models.course_module_element.must_link_with_a_video_or_quiz'))
    elsif self.course_module_element_video_id.to_i > 0 && self.course_module_element_quiz_id.to_i > 0
      errors.add(:base, I18n.t('models.course_module_element.can_only_link_to_a_video_or_quiz_not_both'))
    end
  end

  def update_the_module_total_time
    self.course_module.try(:recalculate_estimated_time)
  end

  def array_of_sibling_ids
    self.course_module.course_module_elements.all_in_order.map(&:id)
  end

  def my_position_among_siblings
    self.array_of_sibling_ids.index(self.id)
  end

  def previous_element_id
    if self.my_position_among_siblings > 0
      self.array_of_sibling_ids[self.my_position_among_siblings - 1]
    else
      nil
    end
  end

  def next_element_id
    if self.my_position_among_siblings < (self.array_of_sibling_ids.length - 1)
      self.array_of_sibling_ids[self.my_position_among_siblings + 1]
    else
      nil
    end
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end

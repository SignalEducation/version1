# == Schema Information
#
# Table name: corporate_group_grants
#
#  id                 :integer          not null, primary key
#  corporate_group_id :integer
#  exam_level_id      :integer
#  exam_section_id    :integer
#  compulsory         :boolean
#  restricted         :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  subject_course_id  :integer
#

class CorporateGroupGrant < ActiveRecord::Base

  # attr-accessible
  attr_accessible :corporate_group_id, :compulsory, :restricted, :subject_course_id

  # Constants

  # relationships
  belongs_to :corporate_group
  belongs_to :subject_course

  # validation
  validates :corporate_group_id, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :subject_course_id, presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:corporate_group) }

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

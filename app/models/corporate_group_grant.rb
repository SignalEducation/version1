class CorporateGroupGrant < ActiveRecord::Base

  # attr-accessible
  attr_accessible :corporate_group_id, :exam_level_id, :exam_section_id, :compulsory, :restricted

  # Constants

  # relationships
  belongs_to :corporate_group
  belongs_to :exam_level
  belongs_to :exam_section

  # validation
  validates :corporate_group_id, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :exam_level_id, allow_nil: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :exam_section_id, allow_nil: true,
            numericality: { only_integer: true, greater_than: 0 }

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:corporate_group) }

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

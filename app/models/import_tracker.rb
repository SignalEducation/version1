# == Schema Information
#
# Table name: import_trackers
#
#  id             :integer          not null, primary key
#  old_model_name :string
#  old_model_id   :integer
#  new_model_name :string
#  new_model_id   :integer
#  imported_at    :datetime
#  original_data  :text
#  created_at     :datetime
#  updated_at     :datetime
#

class ImportTracker < ActiveRecord::Base

  # attr-accessible
  attr_accessible :old_model_name, :old_model_id, :new_model_name, :new_model_id, :imported_at, :original_data

  # Constants

  # relationships

  # validation
  validates :old_model_name, presence: true
  validates :old_model_id, presence: true
  validates :new_model_name, presence: true
  validates :new_model_id, presence: true
  validates :imported_at, presence: true
  validates :original_data, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:old_model_name) }

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

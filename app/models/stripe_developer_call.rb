# == Schema Information
#
# Table name: stripe_developer_calls
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  params_received :text
#  prevent_delete  :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

class StripeDeveloperCall < ActiveRecord::Base

  serialize :params_received, Hash

  # attr-accessible
  attr_accessible :user_id, :params_received, :prevent_delete

  # Constants

  # relationships
  belongs_to :user

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :params_received, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    !self.prevent_delete
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end

# == Schema Information
#
# Table name: corporate_requests
#
#  id               :integer          not null, primary key
#  name             :string
#  title            :string
#  company          :string
#  email            :string
#  phone_number     :string
#  website          :string
#  personal_message :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CorporateRequest < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :title, :company, :email, :phone_number, :website, :personal_message

  # Constants

  # relationships

  # validation
  validates :name, presence: true
  validates :title, presence: true
  validates :company, presence: true
  validates :email, presence: true
  validates :phone_number, presence: true
  validates :website, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }

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

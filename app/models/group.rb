# == Schema Information
#
# Table name: groups
#
#  id                    :integer          not null, primary key
#  name                  :string
#  name_url              :string
#  active                :boolean          default(FALSE), not null
#  sorting_order         :integer
#  description           :text
#  subject_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corporate_customer_id :integer
#

class Group < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :active, :sorting_order, :description, :subject_id

  # Constants

  # relationships
  #belongs_to :subject
  has_and_belongs_to_many :subject_courses

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :description, presence: true
  validates :subject_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true) }
  scope :for_corporates, -> { where.not(corporate_customer_id: nil) }
  scope :for_public, -> { where(corporate_customer_id: nil) }

  # class methods

  # instance methods
  def active_children
    children.all_active
  end

  def children
    self.subject_courses
  end

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
